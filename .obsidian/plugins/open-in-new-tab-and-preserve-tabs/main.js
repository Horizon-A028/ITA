const { Plugin, TFile, WorkspaceLeaf } = require("obsidian");

const PATCH_MARK = Symbol.for("open-in-new-tab-and-preserve-tabs.patch");

module.exports = class NanOpenFileInNewTabPlugin extends Plugin {
  async onload() {
    this.patchOpenFile();
  }

  onunload() {
    this.unpatchOpenFile();
  }

  patchOpenFile() {
    if (WorkspaceLeaf.prototype.openFile[PATCH_MARK]) {
      this.previousOpenFile = WorkspaceLeaf.prototype.openFile[PATCH_MARK].previous;
      return;
    }

    const plugin = this;
    const previousOpenFile = WorkspaceLeaf.prototype.openFile;
    this.previousOpenFile = previousOpenFile;

    async function openFileInNewTab(file, openState) {
      if (!plugin.shouldOpenInNewTab(this, file)) {
        return previousOpenFile.call(this, file, openState);
      }

      const existingLeaf = plugin.findOpenFileLeaf(file.path);
      if (existingLeaf) {
        plugin.app.workspace.setActiveLeaf(existingLeaf, { focus: true });
        return Promise.resolve();
      }

      const targetLeaf = plugin.getTargetLeaf(this);
      const nextOpenState = Object.assign({}, openState, { active: true });
      return previousOpenFile.call(targetLeaf, file, nextOpenState);
    }

    openFileInNewTab[PATCH_MARK] = { previous: previousOpenFile };
    WorkspaceLeaf.prototype.openFile = openFileInNewTab;
  }

  unpatchOpenFile() {
    const currentOpenFile = WorkspaceLeaf.prototype.openFile;
    if (currentOpenFile && currentOpenFile[PATCH_MARK]) {
      WorkspaceLeaf.prototype.openFile = currentOpenFile[PATCH_MARK].previous;
    }
  }

  shouldOpenInNewTab(sourceLeaf, file) {
    if (!(file instanceof TFile)) return false;

    const state = sourceLeaf.getViewState();
    if (!state || state.type === "empty") return false;

    const currentFile = state.state && state.state.file;
    if (!currentFile) return false;

    return currentFile !== file.path;
  }

  getTargetLeaf(sourceLeaf) {
    const emptyLeaf = this.findEmptyLeaf(sourceLeaf);
    if (emptyLeaf) return emptyLeaf;
    return this.app.workspace.getLeaf("tab");
  }

  findEmptyLeaf(sourceLeaf) {
    let found = null;
    this.app.workspace.iterateAllLeaves((leaf) => {
      if (found || leaf === sourceLeaf) return;
      const state = leaf.getViewState();
      if (state && state.type === "empty") found = leaf;
    });
    return found;
  }

  findOpenFileLeaf(path) {
    let found = null;
    this.app.workspace.iterateAllLeaves((leaf) => {
      if (found) return;
      const state = leaf.getViewState();
      if (state && state.state && state.state.file === path) {
        found = leaf;
      }
    });
    return found;
  }
};

/* nosourcemap */