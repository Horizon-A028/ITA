-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions
-- amb un valor comprès entre 350 i 400 euros i en alguna d'aquestes dates:
-- 29 d'abril del 2015,
-- 20 de juliol del 2018,
-- 13 de març del 2024. 
-- Ordena els resultats de major a menor quantitat.

-- Asumo que el valor se cuenta por transaccion, no la suma del dia:

SELECT
  c.name,
  c.phone,
  c.country,
  DATE(t.instant) AS t_day,
  t.amount
FROM companies AS c
JOIN transactions AS t
ON t.company_id = c.id
WHERE 
  DATE(t.instant) in (DATE '2015-3-29', DATE '2018-7-20', DATE '2024-3-13')
  AND t.amount BETWEEN 350 AND 400
ORDER BY t.amount DESC
;

-- Asumo que el valor es la suma del dia:

SELECT
  c.name,
  c.phone,
  c.country,
  DATE(t.instant) AS t_day,
  SUM(t.amount) AS total
FROM companies AS c
JOIN transactions AS t
ON t.company_id = c.id
WHERE
  DATE(t.instant) in (
    DATE '2015-3-29',
    DATE '2018-7-20',
    DATE '2024-3-13'
  )
GROUP BY
  c.name,
  c.phone,
  c.country,
  t_day
HAVING total BETWEEN 350 AND 400
ORDER BY total DESC
;