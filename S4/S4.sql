########
# Lvl. 1
########

# Ex. 1

SELECT *
FROM `sprint3-analytics-marc-ponce.sprint3_silver.transactions_clean` AS t
JOIN `sprint3-analytics-marc-ponce.sprint3_silver.companies_clean` AS c
ON t.business_id = c.company_id
WHERE c.country = 'Germany'
AND DATE(t.timestamp) = '2022-03-12';

# Ex. 2

CREATE OR REPLACE TABLE
    `sprint3-analytics-marc-ponce.sprint3_silver.transactions_recent`
AS SELECT
    t.* EXCEPT(t.timestamp),
    TIMESTAMP_SUB(
        CURRENT_TIMESTAMP(),
        CAST(RAND() * 50 AS INT64)
    ) AS timestamp
FROM `sprint3-analytics-marc-ponce.sprint3_silver.transactions_clean` AS t;

CREATE OR REPLACE TABLE
    `sprint3-analytics-marc-ponce.sprint3_gold.fact_transactions_optimized`
PARTITION BY DATE(timestamp)
CLUSTER BY business_id
AS (
    SELECT *
    FROM `sprint3-analytics-marc-ponce.sprint3_silver.transactions_recent`
);

# Ex. 3

SELECT *
FROM `sprint3-analytics-marc-ponce.sprint3_silver.transactions_recent` AS t
WHERE t.timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY);

SELECT *
FROM `sprint3-analytics-marc-ponce.sprint3_gold.fact_transactions_optimized` AS t
WHERE t.timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY);

# Ex. 4

CREATE OR REPLACE MATERIALIZED VIEW
    `sprint3-analytics-marc-ponce.sprint3_gold.mv_daily_sales`
AS SELECT
    DATE(t.timestamp) AS `date`,
    COUNT(1) AS n_sales
FROM `sprint3-analytics-marc-ponce.sprint3_silver.transactions_clean` AS t
WHERE t.declined = 0
GROUP BY `date`;

SELECT *
FROM `sprint3-analytics-marc-ponce.sprint3_gold.mv_daily_sales`;

########
# Lvl. 2
########

# Ex. 1

WITH
    VIP_Stats AS (
        SELECT
            t.user_id,
            ROUND(SUM(t.amount), 2) AS total_expended,
            COUNT(1) AS n_transactions,
            ROUND(AVG(t.amount), 2) AS average_ticket,
            ROUND(MAX(t.amount), 2) AS max_expended
        FROM `sprint3-analytics-marc-ponce.sprint3_silver.transactions_clean` AS t
        WHERE declined = 0
        GROUP BY t.user_id
        HAVING total_expended > 500
    )
SELECT
    u.user_id,
    CONCAT(u.name, ' ', u.surname) AS nom_complet,
    u.email,
    v.n_transactions AS num_compres,
    v.average_ticket AS tiquet_mig,
    v.max_expended AS max_compra,
    v.total_expended AS total_gastat
FROM VIP_Stats AS v
JOIN `sprint3-analytics-marc-ponce.sprint3_silver.users_combined` AS u
ON v.user_id = u.user_id
ORDER BY v.total_expended DESC;

# Ex. 2

WITH
    l AS (
        SELECT
            s.date AS Data,
            s.n_sales AS Vendes_Avui,
            LAG(s.n_sales) OVER (
                ORDER BY s.date
            ) AS Vendes_Ahir
        FROM `sprint3-analytics-marc-ponce.sprint3_gold.mv_daily_sales` AS s
    )
SELECT
    l.*,
    ROUND(
        (l.Vendes_Avui - l.Vendes_Ahir) /
        l.Vendes_Ahir * 100
    , 2) AS Diff_Percentual
FROM l
ORDER BY l.Data;

# Ex. 3

SELECT
    s.date AS Data,
    s.n_sales AS `Vendes del Dia`,
    SUM(s.n_sales) OVER (
        PARTITION BY EXTRACT(YEAR FROM s.date)
        ORDER BY s.date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS `Vendes Acumulades YTD`
FROM `sprint3-analytics-marc-ponce.sprint3_gold.mv_daily_sales` AS s
ORDER BY s.date;

# Ex. 4

WITH 
    three AS (
        SELECT
            t.user_id,
            t.amount,
            t.timestamp
        FROM `sprint3-analytics-marc-ponce.sprint3_silver.transactions_clean` AS t
        WHERE declined = 0
        QUALIFY ROW_NUMBER() OVER (
            PARTITION BY t.user_id
            ORDER BY t.timestamp ASC
        ) <= 3
    ),
    agr AS (
        SELECT
            t.user_id,
            ROUND(AVG(t.amount), 2) AS total_avg,
            MAX(t.timestamp) AS last_timestamp,
            COUNT(1) AS n
        FROM three AS t
        GROUP BY t.user_id
        HAVING n = 3
    )
SELECT
    u.user_id,
    CONCAT(u.name, ' ', u.surname) AS nom_complet,
    u.email,
    a.total_avg,
    a.last_timestamp
FROM agr AS a
JOIN `sprint3-analytics-marc-ponce.sprint3_silver.users_combined` AS u
ON u.user_id = a.user_id;

########
# Lvl. 3
########

# Ex. 1

CREATE OR REPLACE TABLE 
    `sprint3-analytics-marc-ponce.sprint3_gold.dim_transactions_flat`
AS SELECT
    t.transaction_id,
    t.timestamp,
    t.amount AS `total_ticket |Global|`,
    product_sku,
    p.name AS product_name,
    p.price AS product_price
FROM `sprint3-analytics-marc-ponce.sprint3_silver.transactions_clean` AS t
CROSS JOIN UNNEST(t.product_ids) AS product_sku
JOIN `sprint3-analytics-marc-ponce.sprint3_silver.products_clean` AS p
ON product_sku = p.product_id;

# Ex. 2

SELECT
    t.product_sku,
    t.product_name,
    t.product_price,
    COUNT(1) AS n_units
FROM `sprint3-analytics-marc-ponce.sprint3_silver.dim_transactions_flat` AS t
GROUP BY
    t.product_sku,
    t.product_name,
    t.product_price
QUALIFY RANK() OVER (ORDER BY n_units) <= 5
ORDER BY
    n_units,
    t.product_sku DESC
;

# Ex. 3

CREATE OR REPLACE FUNCTION
    `sprint3-analytics-marc-ponce.sprint3_gold.calculate_tax`
    (amount FLOAT64)
AS (amount * 1.21);

CREATE OR REPLACE TABLE 
    `sprint3-analytics-marc-ponce.sprint3_gold.dim_transactions_flat`
AS SELECT
    t.transaction_id,
    t.timestamp,
    t.amount AS `total_ticket |Global|`,
    product_sku,
    p.name AS product_name,
    p.price AS product_price,
    `sprint3-analytics-marc-ponce.sprint3_gold.calculate_tax`(t.amount) AS product_price_tax_inc
FROM `sprint3-analytics-marc-ponce.sprint3_silver.transactions_clean` AS t
CROSS JOIN UNNEST(t.product_ids) AS product_sku
JOIN `sprint3-analytics-marc-ponce.sprint3_silver.products_clean` AS p
ON product_sku = p.product_id;

bq query \
    --display_name=shc_dim_transactions_flat \
    --schedule='every day 06:33' \
    --use_legacy_sql=false \
    < S4L3E3.sql

