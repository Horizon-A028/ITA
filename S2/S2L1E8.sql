
-- Descarrega els arxius CSV que trobaràs a l'apartat de recursos:
--   american_users.csv
--   european_users.csv
--   companies.csv
--   credit_cards.csv
--   transactions.csv
-- Estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui,
-- almenys 4 taules de les quals puguis realitzar les següents consultes:
-- La taula de products.csv l'utilitzarem més endavant.

CREATE SCHEMA S2L1E8;
USE S2L1E8;

DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS cards;
DROP TABLE IF EXISTS companies;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS transactions;

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