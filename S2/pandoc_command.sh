pandoc ./S2.md \
  --pdf-engine=xelatex \
  --resource-path=. \
  -f markdown-yaml_metadata_block \
  -o S2.pdf \
  -V title="S2 entrega" \
  -V author="Marc Ponce" \
  --from=markdown+wikilinks_title_after_pipe+mark-yaml_metadata_block
