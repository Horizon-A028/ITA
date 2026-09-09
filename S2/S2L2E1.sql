-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes.
-- Mostra la data de cada transacció juntament amb el total de les vendes.

-- Asumo que me pide que muestre las 5 datas y la suma de sus ingresos en la compania
-- del enunciado anterior "Donec Ltd"

WITH
  agregated AS (
    SELECT
      DATE(t.instant) AS t_day,
      SUM(t.amount) AS total
    FROM transactions AS t
    WHERE 
      t.company_id = (
        SELECT c.id
        FROM companies AS c
        WHERE c.name = "Donec Ltd"
      )
    GROUP BY t_day
  ),
  -- Show all tied items:
  -- top 1, 2, 3, 4, 5 <- no ties
  -- top 1, 2, 2, 4, 5 <- tie second place
  -- top 1, 1, 1, 1, 5 <- four way tie first place
  ranked AS (
    SELECT
      a.*,
      RANK() OVER(ORDER BY a.total DESC) AS rn
    FROM agregated AS a
    ORDER BY a.total DESC
  )
SELECT *
FROM ranked AS r
WHERE r.rn <= 5
;