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
  user_id INT,
  iban VARCHAR(50),
  pan VARCHAR(30),
  pin INT,
  cvv INT,
  track1 VARCHAR(80),
  track2 VARCHAR(40),
  expiring_date VARCHAR(10),
  card_type VARCHAR(20),
  card_renewal_flag BOOL
);

ALTER TABLE transaction
ADD CONSTRAINT fk_card
FOREIGN KEY (credit_card_id) 
REFERENCES credit_card(id);

SELECT *
FROM credit_card;

ALTER TABLE transaction
DROP CONSTRAINT fk_card;

-- Mal entendido del enunciado lleva al siguiente codigo,
-- No lo borro para dejar como referencia, ni lo comento.
-- El ejercicio 4 acaba en esta linea. Para cargar los datos
-- solo tengo que ejecutar el fichero desde Administration
-- Data Import/Restore

SET GLOBAL local_infile = ON;
-- connection configuration
-- connection > advanced > write in others field: OPT_LOCAL_INFILE=1

SHOW VARIABLES LIKE "secure_file_priv";
-- "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\"

-- LOAD DATA
--     [LOW_PRIORITY | CONCURRENT] [LOCAL]
--     INFILE 'file_name'
--     [REPLACE | IGNORE]
--     INTO TABLE tbl_name
--     [PARTITION (partition_name [, partition_name] ...)]
--     [CHARACTER SET charset_name]
--     [{FIELDS | COLUMNS}
--         [TERMINATED BY 'string']
--         [[OPTIONALLY] ENCLOSED BY 'char']
--         [ESCAPED BY 'char']
--     ]
--     [LINES
--         [STARTING BY 'string']
--         [TERMINATED BY 'string']
--     ]
--     [IGNORE number {LINES | ROWS}]
--     [(col_name_or_user_var
--         [, col_name_or_user_var] ...)]
--     [SET col_name={expr | DEFAULT}
--         [, col_name={expr | DEFAULT}] ...]

-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv'
-- INTO TABLE your_table
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (@col1, @col2, @col3, @col4, @col5)  -- Read all columns into variables
-- SET 
--     column1 = @col1,  -- Pass through as-is
--     column2 = STR_TO_DATE(@col2, '%m/%d/%Y'),  -- Fix date format
--     column3 = NULLIF(@col3, ''),  -- Convert empty strings to NULL
--     column4 = TRIM(@col4),  -- Remove whitespace
--     column5 = CAST(REPLACE(@col5, '$', '') AS DECIMAL(10,2));  -- Remove currency symbols

LOAD DATA LOCAL
INFILE "C:\\Program Files\\MySQL\\MySQL Server 8.0\\Uploads\\N1-Ex.8__credit_cards.csv"
INTO TABLE credit_card
FIELDS TERMINATED BY ","
LINES TERMINATED BY "\n"
IGNORE 1 ROWS
(@c1, @c2, @c3, @c4, @c5, @c6, @c7, @c8, @c9, @c10, @c11)
SET
  id = @c1,
  user_id = CAST(@c2 AS UNSIGNED),
  iban = @c3,
  pan = REPLACE(@c4, ' ', ''),
  pin = CAST(@c5 AS UNSIGNED),
  cvv = CAST(@c6 AS UNSIGNED),
  track1 = @c7,
  track2 = @c8,
  expiring_date = STR_TO_DATE(@c9, '%m/%d/%Y'),
  card_type = @c10,
  card_renewal_flag = @c11
;

SELECT * FROM credit_card;

ALTER TABLE transaction
ADD CONSTRAINT fk_transactions_card
FOREIGN KEY (credit_card_id) 
REFERENCES credit_card(id);















