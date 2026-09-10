
-- Descarrega els arxius CSV que trobaràs a l'apartat de recursos:
--   american_users.csv
--   european_users.csv
--   companies.csv
--   credit_cards.csv
--   transactions.csv
-- Estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui,
-- almenys 4 taules de les quals puguis realitzar les següents consultes:
-- La taula de products.csv l'utilitzarem més endavant.

-- Solo hace falta dejar los archivos en la carpeta adecuada, en mi caso estan en:
-- C:\Program Files\MySQL\MySQL Server 8.0\Uploads
-- Y se puede ejecutar todo este fichero en orden para cargar la base de datos.

CREATE SCHEMA IF NOT EXISTS S2L1E8;
USE S2L1E8;

DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS cards;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS companies;

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

CREATE INDEX idx_cards_user_id ON cards(user_id);
CREATE INDEX idx_transactions_card_id ON transactions(card_id);
CREATE INDEX idx_transactions_company_id ON transactions(company_id);
CREATE INDEX idx_transactions_user_id ON transactions(user_id);

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

-- id,name,surname,phone,email,birth_date,country,city,postal_code,address,signup_date,user_segment,income_band
LOAD DATA LOCAL
INFILE "C:\\Program Files\\MySQL\\MySQL Server 8.0\\Uploads\\N1-Ex.8__american_users.csv"
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@id,@name,@surname,@phone,@email,@birth,@country,@city,@postal,@address,@signup,@segment,@income)
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

LOAD DATA LOCAL
INFILE "C:\\Program Files\\MySQL\\MySQL Server 8.0\\Uploads\\N1-Ex.8__european_users.csv"
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@id,@name,@surname,@phone,@email,@birth,@country,@city,@postal,@address,@signup,@segment,@income)
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

SELECT * FROM users;

-- id,user_id,iban,pan,pin,cvv,track1,track2,expiring_date,card_type,card_renewal_flag
LOAD DATA LOCAL
INFILE "C:\\Program Files\\MySQL\\MySQL Server 8.0\\Uploads\\N1-Ex.8__credit_cards.csv"
INTO TABLE cards
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@id, @user_id, @iban, @pan, @pin, @cvv, @track1, @track2, @expiring, @card_t, @renewal)
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

SELECT * FROM cards;

-- company_id,company_name,phone,email,country,website,merchant_category,merchant_price_position
LOAD DATA LOCAL
INFILE "C:\\Program Files\\MySQL\\MySQL Server 8.0\\Uploads\\N1-Ex.8__companies.csv"
INTO TABLE companies
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@id, @name, @phone, @email, @country, @website, @category, @price)
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

SELECT * FROM companies;

-- id,product_name,price,colour,weight,warehouse_id,category,brand,cost,launch_date
LOAD DATA LOCAL
INFILE "C:\\Program Files\\MySQL\\MySQL Server 8.0\\Uploads\\N1-Ex.8__products.csv"
INTO TABLE products
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@id, @name, @price, @color, @weight, @w_id, @category, @brand, @cost, @launch_date)
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

SELECT * FROM products;

-- id;card_id;business_id;timestamp;amount;declined;product_ids;user_id;lat;longitude;discount_amount;
-- tax_amount;shipping_amount;channel;campaign_id;device_type;is_international;decline_reason;distance_km
LOAD DATA LOCAL
INFILE "C:\\Program Files\\MySQL\\MySQL Server 8.0\\Uploads\\N1-Ex.8__transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@id, @card_id, @com_id, @instant, @amount, @declined, @products, @user_id, @lat, @lon, @discount,
@tax, @shipping, @channel, @campaign, @device, @international, @decl_reason, @distance)
SET
  id             = TRIM(@id), -- VARCHAR(40)
  card_id        = TRIM(@card_id), -- VARCHAR(15)
  company_id     = TRIM(@com_id), -- VARCHAR(15)
  instant        = STR_TO_DATE(@instant, '%Y-%m-%d %H:%i:%s'), -- TIMESTAMP
  amount         = CAST(@amount AS DECIMAL(8,2)), -- DECIMAL(8,2)
  declined       = CAST(@declined AS BINARY), -- BOOL
  product_ids    = TRIM(@products), -- VARCHAR(255)
  user_id        = CAST(@user_id AS UNSIGNED), -- INT
  latitude       = CAST(@lat AS FLOAT), -- FLOAT
  longitude      = CAST(@lon AS FLOAT), -- FLOAT
  discount       = CAST(@discount AS DECIMAL(8,2)), -- DECIMAL(8,2)
  tax            = CAST(@tax AS DECIMAL(8,2)), -- DECIMAL(8,2)
  shipping       = CAST(@shipping AS DECIMAL(8,2)), -- DECIMAL(8,2)
  channel        = TRIM(@channel), -- VARCHAR(20)
  campaign_id    = TRIM(@campaign), -- VARCHAR(30)
  device_type    = TRIM(@device), -- VARCHAR(20)
  international  = CAST(@international AS BINARY), -- BOOL
  decline_reason = TRIM(@decl_reason), -- VARCHAR(255)
  distance_km    = CAST(@distance AS DECIMAL(8,2)) -- DECIMAL(8,2)
;

SELECT * FROM transactions;