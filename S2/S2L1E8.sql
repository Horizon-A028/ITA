
-- Descarrega els arxius CSV que trobaràs a l'apartat de recursos:
--   american_users.csv
--   european_users.csv
--   companies.csv
--   credit_cards.csv
--   transactions.csv
-- Estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui,
-- almenys 4 taules de les quals puguis realitzar les següents consultes:
-- La taula de products.csv l'utilitzarem més endavant.

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
  singup_date DATE,
  segment     VARCHAR(40),
  income_band VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS cards (
  id            VARCHAR(15) PRIMARY KEY,
  user_id       INT,
  iban          VARCHAR(50),
  pan           VARCHAR(30),
  pin           INT,
  cvv           INT,
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
  id            INT PRIMARY KEY,
  price         DECIMAL(6,2),
  hex_color     CHAR(6),
  weight        DECIMAL(6,2),
  wharehouse_id INT,
  category      VARCHAR(20),
  brand         VARCHAR(20),
  cost          DECIMAL(6,2),
  launch_date   DATE
);

CREATE TABLE IF NOT EXISTS transactions (
  id             VARCHAR(40) PRIMARY KEY,
  card_id        VARCHAR(15),
  company_id     VARCHAR(15),
  instant        TIMESTAMP,
  amount         DECIMAL(6,2),
  declined       BOOL,
  product_ids    VARCHAR(255),
  user_id        INT,
  latitude       FLOAT,
  longitude      FLOAT,
  discount       DECIMAL(6,2),
  tax            DECIMAL(6,2),
  shipping       DECIMAL(6,2),
  channel        VARCHAR(20),
  campaign_id    VARCHAR(30),
  device_type    VARCHAR(20),
  international  BOOL,
  decline_reason VARCHAR(255),
  distance_km    DECIMAL(6,2),
  FOREIGN KEY (company_id) REFERENCES companies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

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
  singup_date = STR_TO_DATE(@signup, '%Y-%m-%d'),
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
  singup_date = STR_TO_DATE(@signup, '%Y-%m-%d'),
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
  pin = CAST(@pin AS UNSIGNED),
  cvv = CAST(@cvv AS UNSIGNED),
  track1 = @track1,
  track2 = @track2,
  expiring_date = STR_TO_DATE(@expiring, '%m/%d/%Y'),
  card_type = TRIM(@card_t),
  renewal_flag = CAST(@renewal AS BINARY)
;

SELECT * FROM cards;