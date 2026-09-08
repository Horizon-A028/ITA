-- La teva tasca és dissenyar i crear una taula anomenada "credit_card"
-- que emmagatzemi detalls crucials sobre les targetes de crèdit.
-- La nova taula ha de ser capaç d'identificar de manera única cada targeta
-- i establir una relació adequada amb les altres dues taules ("transaction"
-- i "company"). Després de crear la taula serà necessari que ingressis la
-- informació del document denominat "dades_introduir_credit".
-- Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.

DROP TABLE IF EXISTS credit_card;
CREATE TABLE IF NOT EXISTS credit_card (
    id VARCHAR(15) PRIMARY KEY,
    
);