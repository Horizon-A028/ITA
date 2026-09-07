-- Utilitzant JOIN realitzaràs les següents consultes:

-- Llistat dels països que estan generant vendes.

SELECT DISTINCT c.country
FROM transaction AS t
JOIN company AS c
ON t.company_id = c.id
;

-- Des de quants països es generen les vendes?

SELECT COUNT(DISTINCT c.country)
FROM transaction AS t
JOIN company AS c
ON t.company_id = c.id
;

-- Identifica la companyia amb la mitjana més gran de vendes.
-- Una venta constituye una transaccion no denegada.
-- Asumo que se me pide la compania con el mayor numero de ventas.

SELECT
  c.id,
  c.company_name,
  COUNT(t.id) AS n_ventas
FROM transaction AS t
JOIN company AS c
ON t.company_id = c.id
WHERE t.declined = FALSE
GROUP BY
  c.id,
  c.company_name
ORDER BY n_ventas DESC
LIMIT 1
;
