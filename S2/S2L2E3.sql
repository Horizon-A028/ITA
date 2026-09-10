-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa
-- que es requereixi, per la qual cosa et demanen la informació sobre la quantitat de
-- transaccions que realitzen les empreses, però el departament de recursos humans és exigent
-- i vol un llistat de les empreses on especifiquis si tenen igual o més de 400 transaccions o menys.

-- Asumo que se quiere que discretice el amount
SELECT
  t.id,
  t.name,
  CASE
    WHEN n_tr > 400 THEN '400+'
    WHEN n_tr = 400 THEN '=400'
    ELSE '<400'
  END AS category
FROM (
SELECT
  c.id,
  c.name,
  COUNT(t.id) AS n_tr
FROM companies AS c
JOIN transactions AS t
ON t.company_id = c.id
GROUP BY
  c.id,
  c.name
ORDER BY n_tr DESC
) AS t;