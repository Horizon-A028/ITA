-- Crea una taula amb la qual puguem unir les dades de l'arxiu de products.csv
-- amb la base de dades creada (ja que fins ara no podíem fer-ho),
-- tenint en compte que des de transaction tens product_ids. Genera la següent consulta:

-- Necessitem conèixer el nombre de vegades que s'ha venut cada producte.

DROP TABLE IF EXISTS orders;
CREATE TABLE IF NOT EXISTS orders (
  transaction_id VARCHAR(40),
  product_id     INT,
  PRIMARY KEY (transaction_id, product_id),
  FOREIGN KEY (transaction_id) REFERENCES transactions(id),
  FOREIGN KEY (product_id) REFERENCES products(id),
  INDEX idx_product_id (product_id),
  INDEX idx_transaction_id (transaction_id)
);


INSERT INTO orders
(transaction_id, product_id)
WITH
  RECURSIVE split AS (
    SELECT
      t.id AS tr,
      SUBSTRING_INDEX(t.product_ids, ',', 1) AS token,
      CASE
        WHEN t.product_ids LIKE '%,%'
        THEN SUBSTRING(t.product_ids, INSTR(t.product_ids, ',') + 1)
        ELSE NULL
      END AS remainder
    FROM transactions AS t
    WHERE
      t.product_ids IS NOT NULL
      AND t.product_ids <> ''
    UNION ALL
    SELECT
      s.tr,
      SUBSTRING_INDEX(s.remainder, ',', 1),
      CASE
        WHEN s.remainder LIKE '%,%'
        THEN SUBSTRING(s.remainder, INSTR(s.remainder, ',') + 1)
        ELSE NULL
      END
    FROM split AS s
    WHERE s.remainder IS NOT NULL
  )
SELECT
  s.tr,
  CAST(s.token AS UNSIGNED)
FROM split AS s
;

SELECT *
FROM orders AS o;

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
GROUP BY
  o.product_id,
  p.name
ORDER BY o.product_id
;