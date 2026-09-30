# This metadata section is at the beginning of every .sql file
/* @datacloud.settings
{
    "version": 1,
    "service": "BIG_QUERY",
    "connectionInfo": {
      "billingProjectId": "sprint3-analytics-marc-ponce",
      "location": "europe-southwest1"
    },
    "dialect": "GOOGLE_SQL"
}
*/
# For dry runs I use the folloing command:

bq query --dry_run < [Filename].sql

# To create the project

gcloud projects create sprint3-analytics-marc-ponce

# To point the shell to the project

gcloud config set project sprint3-analytics-marc-ponce

# L1E1

CREATE SCHEMA `sprint3-analytics-marc-ponce.sprint3_silver`
Options (
    location= 'europe-southwest1'
)

bq --location=europe-southwest1 \
  mk --dataset sprint3-analytics-marc-ponce:sprint3_gold

# L1E2

gcloud storage cat gs://bootcamp-data-analytics-public/ERP/companies.csv | head -n 10

CREATE OR REPLACE EXTERNAL TABLE
    `sprint3-analytics-marc-ponce.sprint3_bronze.transactions_raw`
OPTIONS (
    format='CSV',
    uris=['gs://bootcamp-data-analytics-public/ERP/transactions.csv'],
    field_delimiter=';'
);

CREATE OR REPLACE EXTERNAL TABLE
    `sprint3-analytics-marc-ponce.sprint3_bronze.companies_raw`
(
    company_id STRING,
    company_name STRING,
    phone STRING,
    email STRING,
    country STRING,
    website STRING
)
OPTIONS (
    format='CSV',
    uris=['gs://bootcamp-data-analytics-public/ERP/companies.csv'],
    skip_leading_rows=1
);

CREATE OR REPLACE EXTERNAL TABLE
    `sprint3-analytics-marc-ponce.sprint3_bronze.american_users_raw`
OPTIONS (
    format='CSV',
    uris=['gs://bootcamp-data-analytics-public/CRM/american_users.csv']
);

CREATE OR REPLACE EXTERNAL TABLE
    `sprint3-analytics-marc-ponce.sprint3_bronze.european_users_raw`
OPTIONS (
    format='CSV',
    uris=['gs://bootcamp-data-analytics-public/CRM/european_users.csv']
);

CREATE OR REPLACE EXTERNAL TABLE
    `sprint3-analytics-marc-ponce.sprint3_bronze.credit_cards_raw`
OPTIONS (
    format='CSV',
    uris=['gs://bootcamp-data-analytics-public/CRM/credit_cards.csv']
);

#L1E4A

CREATE OR REPLACE TABLE
    `sprint3-analytics-marc-ponce.sprint3_bronze.transactions_raw_native`
AS SELECT * FROM
    `sprint3-analytics-marc-ponce.sprint3_bronze.transactions_raw`;

#L1E4B

SELECT t.id
FROM `sprint3-analytics-marc-ponce.sprint3_bronze.transactions_raw` AS t;

SELECT t.id
FROM `sprint3-analytics-marc-ponce.sprint3_bronze.transactions_raw_native` AS t;

#L1E4C

SELECT t.id
FROM `sprint3-analytics-marc-ponce.sprint3_bronze.transactions_raw` AS t
LIMIT 10;

SELECT t.id
FROM `sprint3-analytics-marc-ponce.sprint3_bronze.transactions_raw_native` AS t
LIMIT 10;

#L1E5

SELECT
    DATE(t.timestamp) AS t_day,
    ROUND(SUM(t.amount), 2) AS day_total
FROM `sprint3-analytics-marc-ponce.sprint3_bronze.transactions_raw_native` AS t
WHERE t.declined = 0
GROUP BY t_day
ORDER BY day_total DESC
LIMIT 5;

#L1E6

SELECT
    c.company_name,
    c.country,
    t.timestamp
FROM `sprint3-analytics-marc-ponce.sprint3_bronze.transactions_raw_native` AS t
JOIN `sprint3-analytics-marc-ponce.sprint3_bronze.companies_raw` AS c
ON t.business_id = c.company_id
WHERE t.amount BETWEEN 100 AND 200
AND DATE(t.timestamp) in ('2015-04-29', '2018-07-20', '2024-03-13');

#Old

SELECT
    eu.name,
    c.country,
    DATE(t.timestamp) AS t_day
FROM `sprint3-analytics-marc-ponce.sprint3_bronze.transactions_raw_native` AS t
JOIN `sprint3-analytics-marc-ponce.sprint3_bronze.companies_raw` AS c
ON t.business_id = c.company_id
JOIN `sprint3-analytics-marc-ponce.sprint3_bronze.european_users_raw` AS eu
ON t.user_id = eu.id
WHERE t.amount BETWEEN 100 AND 200
AND DATE(t.timestamp) in ('2015-04-29', '2018-07-20', '2024-03-13')
UNION ALL
SELECT
    au.name,
    c.country,
    DATE(t.timestamp) AS t_day
FROM `sprint3-analytics-marc-ponce.sprint3_bronze.transactions_raw_native` AS t
JOIN `sprint3-analytics-marc-ponce.sprint3_bronze.companies_raw` AS c
ON t.business_id = c.company_id
JOIN `sprint3-analytics-marc-ponce.sprint3_bronze.american_users_raw` AS us
ON t.user_id = au.id
WHERE t.amount BETWEEN 100 AND 200
AND DATE(t.timestamp) in ('2015-04-29', '2018-07-20', '2024-03-13');

#Improved

WITH
    tc AS (
        SELECT
            t.user_id,
            c.country,
            t.timestamp
        FROM `sprint3-analytics-marc-ponce.sprint3_bronze.transactions_raw_native` AS t
        JOIN `sprint3-analytics-marc-ponce.sprint3_bronze.companies_raw` AS c
        ON t.business_id = c.company_id
        WHERE t.amount BETWEEN 100 AND 200
        AND DATE(t.timestamp) in ('2015-04-29', '2018-07-20', '2024-03-13')
    )
SELECT
    eu.name,
    tc.country,
    tc.timestamp
FROM tc
JOIN `sprint3-analytics-marc-ponce.sprint3_bronze.european_users_raw` AS eu
ON tc.user_id = eu.id
UNION ALL
SELECT
    us.name,
    tc.country,
    tc.timestamp
FROM tc
JOIN `sprint3-analytics-marc-ponce.sprint3_bronze.american_users_raw` AS us
ON tc.user_id = us.id;

#L2E1

CREATE OR REPLACE TABLE
    `sprint3-analytics-marc-ponce.sprint3_silver.products_clean`
AS SELECT
    p.id AS product_id,
    p.product_name AS name,
    CAST(REGEXP_REPLACE(p.warehouse_id, r'[^0-9]', '') AS INT64) AS warehouse_id,
    CAST(price AS FLOAT64) AS price,
    p.colour,
    p.category,
    p.weight,
    p.brand,
    p.cost,
    p.launch_date
FROM `sprint3-analytics-marc-ponce.sprint3_bronze.products_raw` AS p;

#L2E2

CREATE OR REPLACE TABLE
    `sprint3-analytics-marc-ponce.sprint3_silver.transactions_clean`
AS SELECT
    t.id AS transaction_id,
    t.business_id,
    t.card_id,
    timestamp,
    IFNULL(SAFE_CAST(t.amount AS FLOAT64), 0) AS amount,
    t.declined,
    ARRAY(
        SELECT SAFE_CAST(TRIM(product_id) AS INT64)
        FROM UNNEST(SPLIT(t.product_ids, ',')) AS product_id
    ) AS product_ids,
    user_id,
    SAFE_CAST(t.lat AS FLOAT64) AS lat,
    SAFE_CAST(t.longitude AS FLOAt64) AS longitude
FROM `sprint3-analytics-marc-ponce.sprint3_bronze.transactions_raw_native` AS t;

#L2E3

CREATE OR REPLACE TABLE
    `sprint3-analytics-marc-ponce.sprint3_silver.users_combined`
AS SELECT
    eu.id AS user_id,
    eu.name,
    eu.surname,
    eu.phone,
    eu.email,
    eu.birth_date,
    eu.country,
    eu.city,
    eu.postal_code,
    eu.address,
    'EU' AS origin
FROM `sprint3-analytics-marc-ponce.sprint3_bronze.european_users_raw` AS eu
UNION ALL
SELECT
    au.id AS user_id,
    au.name,
    au.surname,
    au.phone,
    au.email,
    au.birth_date,
    au.country,
    au.city,
    au.postal_code,
    au.address,
    'US' AS origin
FROM `sprint3-analytics-marc-ponce.sprint3_bronze.american_users_raw` AS au;

#L2E4

CREATE OR REPLACE TABLE
    `sprint3-analytics-marc-ponce.sprint3_silver.companies_clean`
AS SELECT *
FROM `sprint3-analytics-marc-ponce.sprint3_bronze.companies_raw` AS c;

CREATE OR REPLACE TABLE
    `sprint3-analytics-marc-ponce.sprint3_silver.credit_cards_clean`
AS SELECT *
FROM `sprint3-analytics-marc-ponce.sprint3_bronze.credit_cards_raw` AS c;

#L3E1

CREATE OR REPLACE VIEW
    `sprint3-analytics-marc-ponce.sprint3_gold.v_marketing_kpis`
AS WITH
    a AS (
        SELECT
            c.company_id,
            c.company_name,
            c.phone,
            c.country,
            AVG(t.amount) AS avg_amount
        FROM `sprint3-analytics-marc-ponce.sprint3_silver.companies_clean` AS c
        JOIN `sprint3-analytics-marc-ponce.sprint3_silver.transactions_clean` AS t
        ON t.business_id = c.company_id
        WHERE t.declined = 0
        GROUP BY
            c.company_id,
            c.company_name,
            c.phone,
            c.country
    )
SELECT
    a.company_name,
    a.phone,
    a.country,
    a.avg_amount,
    CASE
        WHEN a.avg_amount > 260 THEN 'Premium'
        ELSE 'Standard'
    END AS client_tier
FROM a;

SELECT *
FROM `sprint3-analytics-marc-ponce.sprint3_gold.v_marketing_kpis`
ORDER BY avg_amount DESC;

#L3E2

CREATE OR REPLACE TABLE
`sprint3-analytics-marc-ponce.sprint3_gold.product_sales_ranking`
AS WITH
    p_counts_raw AS (
        SELECT
            product_id,
            COUNT(1) AS total_sold
        FROM `sprint3-analytics-marc-ponce.sprint3_silver.transactions_clean` AS t
        CROSS JOIN UNNEST(t.product_ids) AS product_id
        WHERE t.declined = 0
        GROUP BY product_id
    )
SELECT
    p.product_id,
    p.name,
    p.price,
    p.colour,
    COALESCE(c.total_sold, 0) AS total_sold
FROM `sprint3-analytics-marc-ponce.sprint3_silver.products_clean` AS p
LEFT JOIN p_counts_raw AS c
ON p.product_id = c.product_id
ORDER BY total_sold DESC;

#L3E3

SELECT *
FROM `sprint3-analytics-marc-ponce.sprint3_gold.product_sales_ranking`;

bq query \
    --format=csv \
    --max_rows=1000000 \
    < S3L3E3.sql \
    > S3L3E3.csv