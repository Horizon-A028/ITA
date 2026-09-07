-- Utilitzant només subconsultes (sense utilitzar JOIN):

-- Mostra totes les transaccions realitzades per empreses d'Alemanya.

SELECT t.id
FROM transaction AS t
WHERE "Germany" = (
  SELECT c.country
  FROM company as c
  WHERE t.company_id = c.id
);

-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.

SELECT DISTINCT
  c.id,
  c.company_name
FROM company AS c
WHERE EXISTS (
  SELECT 1
  FROM transaction AS t
  WHERE t.company_id = c.id
  AND t.amount > (
    SELECT AVG(t.amount)
    FROM transaction AS t
  )
);

-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

-- Con esta consulta se puede observar que hay 100 empresas.
SELECT COUNT(1)
FROM company;

-- De las cuales 100 empresas tienen transacciones.
SELECT COUNT(1)
FROM company AS c
WHERE EXISTS (
  SELECT 1
  FROM transaction AS t
  WHERE t.company_id = c.id
);

-- Efectivamente, 0 empresas no tienen transacciones,
-- con lo cual la operación eliminara 0 empresas.
SELECT COUNT(1)
FROM company AS c
WHERE NOT EXISTS (
  SELECT 1
  FROM transaction AS t
  WHERE t.company_id = c.id
);

-- Esta operacion elimina las empresas.
-- Disabled Safe Mode on Workbench, since there didn't seem a way around it.
DELETE FROM company AS c
WHERE NOT EXISTS (
  SELECT 1
  FROM transaction AS t
  WHERE t.company_id = c.id
);