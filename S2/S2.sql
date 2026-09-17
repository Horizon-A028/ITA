-- ############################################################
-- Ejecutar paso a paso y seguir las instrucciones.
-- ############################################################
-- ############################################################
-- Lvl. 1
-- ############################################################
-- ############################################################
-- Ex. 1
-- ############################################################

-- [OP001]
CREATE DATABASE IF NOT EXISTS transactions;
-- [OP002]
USE transactions;

-- [OP003]
CREATE TABLE IF NOT EXISTS company (
  id VARCHAR(15) PRIMARY KEY,
  company_name VARCHAR(255),
  phone VARCHAR(15),
  email VARCHAR(100),
  country VARCHAR(100),
  website VARCHAR(255)
);

-- [OP004]
CREATE TABLE IF NOT EXISTS transaction (
  id VARCHAR(255) PRIMARY KEY,
  credit_card_id VARCHAR(15) REFERENCES credit_card(id),
  company_id VARCHAR(20),
  user_id INT REFERENCES user(id),
  lat FLOAT,
  longitude FLOAT,
  timestamp TIMESTAMP,
  amount DECIMAL(10, 2),
  declined BOOLEAN,
  FOREIGN KEY (company_id) REFERENCES company(id) 
);

-- ############################################################
-- ############################################################
-- Importar los datos de "dades_introduir.sql".
-- ############################################################
-- ############################################################
-- Diagrama S2L1E1D
-- ############################################################
-- ############################################################
-- Ex. 2
-- ############################################################

-- [OP005]
SELECT DISTINCT c.country
FROM transaction AS t
JOIN company AS c
ON t.company_id = c.id;

-- [OP006]
SELECT COUNT(DISTINCT c.country)
FROM transaction AS t
JOIN company AS c
ON t.company_id = c.id;

-- [OP007]
SELECT
  c.id,
  c.company_name,
  ROUND(AVG(t.amount), 2) AS media
FROM transaction AS t
JOIN company AS c
ON t.company_id = c.id
WHERE t.declined = FALSE
GROUP BY c.id
ORDER BY media DESC
LIMIT 1;

-- ############################################################
-- Ex. 3
-- ############################################################

-- [OP008]
SELECT *
FROM transaction AS t
WHERE declined = FALSE
AND EXISTS (
  SELECT 1
  FROM company as c
  WHERE t.company_id = c.id
  AND c.country = "Germany"
);

-- [OP009]
SELECT
  c.id,
  c.company_name
FROM company AS c
WHERE EXISTS (
  SELECT 1
  FROM transaction AS t
  WHERE t.company_id = c.id
  AND t.amount > (
    SELECT AVG(t.amount)
    FROM transaction AS t
  )
);

-- [OP010]
SELECT *
FROM company AS c
WHERE NOT EXISTS (
  SELECT 1
  FROM transaction AS t
  WHERE t.company_id = c.id
);

-- [OP012]
SET SQL_SAFE_UPDATES = 0;

-- [OP011]
DELETE FROM company AS c
WHERE NOT EXISTS (
  SELECT 1
  FROM transaction AS t
  WHERE t.company_id = c.id
);

-- [OP013]
SET SQL_SAFE_UPDATES = 1;

-- ############################################################
-- Ex. 4
-- ############################################################

-- [OP014]
DROP TABLE IF EXISTS credit_card;
-- [OP015]
CREATE TABLE IF NOT EXISTS credit_card (
  id VARCHAR(15) PRIMARY KEY,
  iban VARCHAR(50),
  pan VARCHAR(30),
  pin VARCHAR(10),
  cvv VARCHAR(10),
  expiring_date VARCHAR(10)
);

-- ############################################################
-- ############################################################
-- Importar datos de "N1-Ex.4__datos_introducir_credit.sql".
-- ############################################################
-- ############################################################

-- [OP016]
ALTER TABLE transaction
ADD CONSTRAINT fk_card
FOREIGN KEY (credit_card_id) 
REFERENCES credit_card(id);

-- ############################################################
-- Diagrama S2L1E4D
-- ############################################################

-- [OP017]
SELECT *
FROM credit_card;

-- ############################################################
-- Ex. 5
-- ############################################################

-- [OP018]
SELECT *
FROM credit_card AS c
WHERE c.id = "CcU-2938";

-- [OP019]
UPDATE credit_card AS c
SET iban = "TR323456312213576817699999"
WHERE c.id = "CcU-2938";

-- [OP020]
SELECT *
FROM credit_card AS c
WHERE c.id = "CcU-2938";

-- ############################################################
-- Ex. 6
-- ############################################################

-- [OP021]
INSERT INTO transaction (
  id,
  credit_card_id,
  company_id,
  user_id,
  lat,
  longitude,
  amount,
  declined,
  timestamp
) VALUES (
  "108B1D1D-5B23-A76C-55EF-C568E49A99DD",
  "CcU-9999",
  "b-9999",
  9999,
  829.999,
  -117.999,
  111.11,
  0,
  NOW()
);

-- [OP022]
SELECT *
FROM company AS c
WHERE c.id = "b-9999";

-- ############################################################
-- Ex. 7
-- ############################################################

-- [OP023]
SELECT *
FROM credit_card
LIMIT 10;

-- [OP024]
ALTER TABLE credit_card
DROP COLUMN pan;

-- [OP025]
SELECT *
FROM credit_card
LIMIT 10;

-- ############################################################
-- Ex. 8
-- ############################################################

-- Descarrega els arxius CSV:
--   american_users.csv
--   european_users.csv
--   companies.csv
--   credit_cards.csv
--   transactions.csv
-- Estudia'ls i dissenya una base de dades amb
-- un esquema d'estrella que contingui, almenys 4 taules de
-- les quals puguis realitzar les següents consultes:
-- La taula de products.csv l'utilitzarem més endavant.

-- ############################################################
-- ############################################################
-- 01.Asegura que los ficheros estan en:
--      "C:\Program Files\MySQL\MySQL Server 8.0\Uploads"
-- 02. Configurar la coneccion del workbench
-- 03. "advanced" >
-- 04. Escribir en el text field "others":
--     "OPT_LOCAL_INFILE=1"
-- ############################################################
-- ############################################################

-- [OP026]
CREATE SCHEMA IF NOT EXISTS S2L1E8;
-- [OP027]
USE S2L1E8;
-- [OP028]
DROP TABLE IF EXISTS transactions;
-- [OP029]
DROP TABLE IF EXISTS products;
-- [OP030]
DROP TABLE IF EXISTS cards;
-- [OP031]
DROP TABLE IF EXISTS users;
-- [OP032]
DROP TABLE IF EXISTS companies;

-- [OP033]
CREATE TABLE IF NOT EXISTS users (
  id          INT PRIMARY KEY,
  name        VARCHAR(20),
  surname     VARCHAR(20),
  phone       VARCHAR(20),
  email       VARCHAR(80),
  birth_date  DATE,
  country     VARCHAR(20),
  city        VARCHAR(20),
  postal_code VARCHAR(10),
  address     VARCHAR(100),
  signup_date DATE,
  segment     VARCHAR(40),
  income_band VARCHAR(20)
);

-- [OP034]
CREATE TABLE IF NOT EXISTS cards (
  id            VARCHAR(15) PRIMARY KEY,
  user_id       INT,
  iban          VARCHAR(50),
  pan           VARCHAR(30),
  pin           VARCHAR(8),
  cvv           VARCHAR(8),
  track1        VARCHAR(80),
  track2        VARCHAR(40),
  expiring_date VARCHAR(10),
  card_type     VARCHAR(20),
  renewal_flag  BOOL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- [OP035]
CREATE TABLE IF NOT EXISTS companies (
  id       VARCHAR(15) PRIMARY KEY,
  name     VARCHAR(50),
  phone    VARCHAR(20),
  email    VARCHAR(80),
  country  VARCHAR(20),
  website  VARCHAR(60),
  category VARCHAR(20),
  price    VARCHAR(20)
);

-- [OP036]
CREATE TABLE IF NOT EXISTS products (
  id           INT PRIMARY KEY,
  name         VARCHAR(40),
  price        DECIMAL(8,2),
  hex_color    CHAR(6),
  weight       DECIMAL(8,2),
  warehouse_id INT,
  category     VARCHAR(20),
  brand        VARCHAR(20),
  cost         DECIMAL(8,2),
  launch_date  DATE
);

-- [OP037]
CREATE TABLE IF NOT EXISTS transactions (
  id             VARCHAR(40) PRIMARY KEY,
  card_id        VARCHAR(15),
  company_id     VARCHAR(15),
  instant        TIMESTAMP,
  amount         DECIMAL(8,2),
  declined       BOOL,
  product_ids    VARCHAR(255),
  user_id        INT,
  latitude       FLOAT,
  longitude      FLOAT,
  discount       DECIMAL(8,2),
  tax            DECIMAL(8,2),
  shipping       DECIMAL(8,2),
  channel        VARCHAR(20),
  campaign_id    VARCHAR(30),
  device_type    VARCHAR(20),
  international  BOOL,
  decline_reason VARCHAR(255),
  distance_km    DECIMAL(8,2),
  FOREIGN KEY (company_id) REFERENCES companies(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (card_id) REFERENCES cards(id)
);

-- [OP038]
CREATE INDEX idx_cards_user_id
ON cards(user_id);
-- [OP039]
CREATE INDEX idx_transactions_card_id
ON transactions(card_id);
-- [OP040]
CREATE INDEX idx_transactions_company_id
ON transactions(company_id);
-- [OP041]
CREATE INDEX idx_transactions_user_id
ON transactions(user_id);

-- [OP042]
SET GLOBAL local_infile = ON;

-- [OP043]
SHOW VARIABLES LIKE "secure_file_priv";
-- "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\"

-- [OP044]
LOAD DATA LOCAL
INFILE "C:\\Program Files\\MySQL\\MySQL Server 8.0\\Uploads\\N1-Ex.8__american_users.csv"
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@id, @name, @surname, @phone, @email, @birth, @country, @city,
  @postal, @address, @signup, @segment,@income)
SET
  id          = CAST(@id AS UNSIGNED),
  name        = TRIM(@name),
  surname     = TRIM(@surname),
  phone       = TRIM(@phone),
  email       = TRIM(@email),
  birth_date  = STR_TO_DATE(@birth, '%b %d, %Y'),
  country     = TRIM(@country),
  city        = TRIM(@city),
  postal_code = TRIM(@postal),
  address     = TRIM(@address),
  signup_date = STR_TO_DATE(@signup, '%Y-%m-%d'),
  segment     = TRIM(@segment),
  income_band = TRIM(@income)
;

-- [OP045]
LOAD DATA LOCAL
INFILE "C:\\Program Files\\MySQL\\MySQL Server 8.0\\Uploads\\N1-Ex.8__european_users.csv"
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@id, @name, @surname, @phone, @email, @birth, @country, @city,
  @postal, @address, @signup, @segment, @income)
SET
  id          = CAST(@id AS UNSIGNED),
  name        = TRIM(@name),
  surname     = TRIM(@surname),
  phone       = TRIM(@phone),
  email       = TRIM(@email),
  birth_date  = STR_TO_DATE(@birth, '%b %d, %Y'),
  country     = TRIM(@country),
  city        = TRIM(@city),
  postal_code = TRIM(@postal),
  address     = TRIM(@address),
  signup_date = STR_TO_DATE(@signup, '%Y-%m-%d'),
  segment     = TRIM(@segment),
  income_band = TRIM(@income)
;

-- [OP046]
SELECT * FROM users;

-- [OP047]
LOAD DATA LOCAL
INFILE "C:\\Program Files\\MySQL\\MySQL Server 8.0\\Uploads\\N1-Ex.8__credit_cards.csv"
INTO TABLE cards
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@id, @user_id, @iban, @pan, @pin, @cvv, @track1, @track2,
  @expiring, @card_t, @renewal)
SET
  id = TRIM(@id),
  user_id = CAST(@user_id AS UNSIGNED),
  iban = TRIM(@iban),
  pan = REPLACE(@pan, ' ', ''),
  pin = TRIM(@pin),
  cvv = TRIM(@cvv),
  track1 = @track1,
  track2 = @track2,
  expiring_date = STR_TO_DATE(@expiring, '%m/%d/%Y'),
  card_type = TRIM(@card_t),
  renewal_flag = CAST(@renewal AS BINARY)
;

-- [OP048]
SELECT * FROM cards;

-- [OP049]
LOAD DATA LOCAL
INFILE "C:\\Program Files\\MySQL\\MySQL Server 8.0\\Uploads\\N1-Ex.8__companies.csv"
INTO TABLE companies
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@id, @name, @phone, @email, @country, @website,
  @category, @price)
SET
  id       = TRIM(@id),
  name     = TRIM(@name),
  phone    = TRIM(@phone),
  email    = TRIM(@email),
  country  = TRIM(@country),
  website  = TRIM(@website),
  category = TRIM(@category),
  price    = TRIM(@price)
;

-- [OP050]
SELECT * FROM companies;

-- [OP051]
LOAD DATA LOCAL
INFILE "C:\\Program Files\\MySQL\\MySQL Server 8.0\\Uploads\\N1-Ex.8__products.csv"
INTO TABLE products
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@id, @name, @price, @color, @weight, @w_id, @category,
  @brand, @cost, @launch_date)
SET
  id           = CAST(@id AS UNSIGNED),
  name         = TRIM(@name),
  price        = CAST(REPLACE(@price, '$', '') AS DECIMAL(8,2)),
  hex_color    = UPPER(REPLACE(TRIM(@color), '#', '')),
  weight       = CAST(@weight AS DECIMAL(8,2)),
  warehouse_id = REPLACE(TRIM(@w_id), 'WH-', ''),
  category     = TRIM(@category),
  brand        = TRIM(@brand),
  cost         = CAST(REPLACE(@cost, '$', '') AS DECIMAL(8,2)),
  launch_date  = STR_TO_DATE(@launch_date, '%Y-%m-%d')
;

-- [OP052]
SELECT * FROM products;

-- [OP053]
LOAD DATA LOCAL
INFILE "C:\\Program Files\\MySQL\\MySQL Server 8.0\\Uploads\\N1-Ex.8__transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@id, @card_id, @com_id, @instant, @amount, @declined,
  @products, @user_id, @lat, @lon, @discount, @tax, @shipping,
  @channel, @campaign, @device, @international, @decl_reason,
  @distance)
SET
  id             = TRIM(@id),
  card_id        = TRIM(@card_id),
  company_id     = TRIM(@com_id),
  instant        = STR_TO_DATE(@instant, '%Y-%m-%d %H:%i:%s'),
  amount         = CAST(@amount AS DECIMAL(8,2)),
  declined       = CAST(@declined AS BINARY),
  product_ids    = TRIM(@products),
  user_id        = CAST(@user_id AS UNSIGNED),
  latitude       = CAST(@lat AS FLOAT),
  longitude      = CAST(@lon AS FLOAT),
  discount       = CAST(@discount AS DECIMAL(8,2)),
  tax            = CAST(@tax AS DECIMAL(8,2)),
  shipping       = CAST(@shipping AS DECIMAL(8,2)),
  channel        = TRIM(@channel),
  campaign_id    = TRIM(@campaign),
  device_type    = TRIM(@device),
  international  = CAST(@international AS BINARY),
  decline_reason = TRIM(@decl_reason),
  distance_km    = CAST(@distance AS DECIMAL(8,2))
;

-- [OP054]
SELECT * FROM transactions;

-- ############################################################
-- Ex. 9
-- ############################################################

-- [OP055]
WITH
  tr_count AS (
    SELECT
      t.user_id,
      COUNT(1) AS n
    FROM transactions AS t
    GROUP BY t.user_id
    HAVING n > 80
  )
SELECT u.*, c.n
FROM users AS u
JOIN tr_count AS c
ON u.id = c.user_id;

-- ############################################################
-- Ex. 10
-- ############################################################

-- [OP056]
SELECT
  c.iban,
  AVG(t.amount) AS mitjana
FROM transactions AS t
JOIN cards AS c
ON t.card_id = c.id
JOIN companies AS cm
ON t.company_id = cm.id
WHERE cm.name = "Donec Ltd"
GROUP BY c.iban;

-- ############################################################
-- ############################################################
-- Lvl. 2
-- ############################################################
-- ############################################################
-- Ex. 1
-- ############################################################

-- [OP057]
WITH
  agregated AS (
    SELECT
      DATE(t.instant) AS t_day,
      SUM(t.amount) AS total
    FROM transactions AS t
    JOIN companies AS c
    ON t.company_id = c.id
    WHERE c.name = "Donec Ltd"
    GROUP BY t_day
  ),
  ranked AS (
    SELECT
      a.*,
      RANK() OVER(ORDER BY a.total DESC) AS rn
    FROM agregated AS a
    ORDER BY a.total DESC
  )
SELECT *
FROM ranked AS r
WHERE r.rn <= 5;

-- ############################################################
-- Ex. 2
-- ############################################################

-- [OP058]
SELECT
  c.name,
  c.phone,
  c.country,
  DATE(t.instant) AS t_day,
  t.amount
FROM companies AS c
JOIN transactions AS t
ON t.company_id = c.id
WHERE DATE(t.instant) in (
  '2015-3-29',
  '2018-7-20',
  '2024-3-13')
AND t.amount BETWEEN 350 AND 400
ORDER BY t.amount DESC;

-- ############################################################
-- Ex. 3
-- ############################################################

-- [OP059]
SELECT
  t.id,
  t.name,
  CASE
    WHEN n_tr > 400 THEN 'mas de 400'
    WHEN n_tr = 400 THEN '400'
    ELSE 'menos de 400'
  END AS category
FROM (
  SELECT
    c.id,
    c.name,
    COUNT(t.id) AS n_tr
  FROM companies AS c
  JOIN transactions AS t
  ON t.company_id = c.id
  GROUP BY c.id
  ORDER BY n_tr DESC
) AS t;

-- ############################################################
-- Ex. 4
-- ############################################################

-- [OP060]
SELECT *
FROM transactions AS t
WHERE t.id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- [OP061]
DELETE FROM transactions AS t
WHERE t.id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- [OP062]
SELECT *
FROM transactions AS t
WHERE t.id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- ############################################################
-- Ex. 5
-- ############################################################

-- [OP063]
CREATE OR REPLACE VIEW VistaMarketing AS
SELECT
  c.name,
  c.phone,
  c.country,
  AVG(t.amount) AS avg_sale
FROM companies AS c
JOIN transactions AS t
ON t.company_id = c.id
WHERE t.declined = FALSE
GROUP BY
  c.name,
  c.phone,
  c.country
ORDER BY avg_sale DESC;

-- [OP064]
SELECT *
FROM vistamarketing;

-- ############################################################
-- ############################################################
-- Lvl. 3
-- ############################################################
-- ############################################################
-- Ex. 1
-- ############################################################

-- [OP065]
DROP TABLE IF EXISTS cards_activity;
-- [OP066]
CREATE TABLE IF NOT EXISTS cards_activity AS
WITH
  ranked AS (
    SELECT
      c.id,
      t.declined,
      ROW_NUMBER() OVER(
        PARTITION BY c.id
        ORDER BY t.instant DESC
      ) AS rn
    FROM transactions AS t
    JOIN cards AS c
    ON t.card_id = c.id
  ),
  activity AS (
    SELECT
      r.id,
      SUM(r.declined) AS decl_count
    FROM ranked AS r
    WHERE r.rn < 4
    GROUP BY r.id
  )
SELECT
  a.id,
  CASE
    WHEN a.decl_count > 2 THEN FALSE
    ELSE TRUE
  END AS is_active
FROM activity AS a;

-- [OP067]
SELECT * FROM cards_activity;

-- [OP068]
SELECT COUNT(1) AS n_active
FROM cards_activity AS c
WHERE c.is_active = TRUE;

-- ############################################################
-- Ex. 2
-- ############################################################

-- [OP069]
DROP TABLE IF EXISTS orders;
-- [OP070]
CREATE TABLE IF NOT EXISTS orders (
  transaction_id VARCHAR(40),
  product_id     INT,
  PRIMARY KEY (transaction_id, product_id),
  FOREIGN KEY (transaction_id) REFERENCES transactions(id),
  FOREIGN KEY (product_id) REFERENCES products(id),
  INDEX idx_product_id (product_id),
  INDEX idx_transaction_id (transaction_id)
);

-- [OP071]
INSERT INTO orders
(transaction_id, product_id)
SELECT
  t.id,
  p.id
FROM transactions AS t
JOIN JSON_TABLE (
  CONCAT('[', t.product_ids, ']'),
  '$[*]' COLUMNS (id INT PATH '$')
) AS p;

-- [OP072]
SELECT *
FROM orders AS o;

-- [OP073]
SELECT
  o.product_id,
  p.name,
  COUNT(o.transaction_id) AS n_sales
FROM orders AS o
JOIN transactions AS t
ON o.transaction_id = t.id
JOIN products AS p
ON o.product_id = p.id
WHERE t.declined = FALSE
GROUP BY o.product_id
ORDER BY o.product_id;
