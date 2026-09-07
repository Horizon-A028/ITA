USE transactions;

-- Lvl. 1, Ex. 1:

-- Hay dos tablas:
-- company:
--   Representa una empresa.
--   "id"          : Texto, PK ID empresa
--   "company_name": Texto, nombre
--   "phone"       : Texto, numero de telefono
--   "email"       : Texto, email
--   "country"     : Texto, pais
--   "website"     : Texto, pagina web
-- transaction:
--   Representa una transaccion o un pago, realizado por un usuario.
--    Contexto adicional: las companias venden a los usuarios
--   "id"            : Texto, PK ID transaccion
--   "credit_card_id": Texto, FK referencia a "id" en una tabla absente "credit_card",
--                       enlace tarjeta credito usada en la transaccion
--   "company_id"    : Texto, FK referencia a "id" en la tabla "company", enlace a
--                       empresa de la transaccion
--   "user_id"       : Numero entero, FK rederencia a "id" en una tabla absente "user",
--                       enlace a usuario ejecutando la transaccion
--   "lat"           : Numero decimal de coma flotante, latitud geografica
--                       donde ocurrio la transaccion
--   "longitude"     : Numero decimal de coma flotante, longitud geografica
--                       donde ocurrio la transaccion
--   "timestamp"     : Momento en el tiempo especifico cuando ocurrio la transaccion
--   "amount"        : Numero decimal fijo, precision 2 decimales,
--                       cantidad de dinero transferido en la transaccion
--   "declined"      : Booleano, en caso True, significa que la transaccion fue
--                       anulada, cancelada, refutada, etc. posiblemente
--                       por la entidad bancaria.

-- Lvl. 1, Ex. 2: llistat de paisos que estan fent compres.

SELECT DISTINCT c.country
FROM transaction AS t
JOIN company AS c
ON t.company_id = c.id
;

-- Lvl. 1, Ex. 2: Des de quants paisos es realitzen les compres.

SELECT COUNT(DISTINCT c.country)
FROM transaction AS t
JOIN company AS c
ON t.company_id = c.id
;

-- Lvl. 1, Ex. 2: Identifica la companyia amb la mitjana més gran de vendes.
-- Una venta constituye una transaccion no anulada

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

-- Lvl. 1, Ex. 3: Mostra totes les transaccions realitzades per empreses d'Alemanya.

SELECT t.id
FROM transaction AS t
WHERE "Germany" = (
  SELECT c.country
  FROM company as c
  WHERE t.company_id = c.id
);

-- Lvl. 1, Ex. 3: Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.

SELECT DISTINCT
  c.id,
  c.company_name
FROM company AS c
WHERE (
  SELECT t.amount
  FROM transaction AS t
  WHERE t.company_id = c.id
  ORDER BY t.amount DESC
  LIMIT 1
) > (
  SELECT AVG(t.amount)
  FROM transaction AS t
);

-- Lvl. 1, Ex. 3: Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

SELECT DISTINCT
  c.id,
  c.company_name
FROM company AS c
WHERE NOT EXISTS (
  SELECT 1
  FROM transaction AS t
  WHERE t.company_id = c.id
);

-- Lvl. 2, Ex. 1: Identifica els cinc dies que es va generar la quantitat més gran d'ingressos
-- a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.

WITH
agregated AS (
  SELECT
    c.id AS company_id,
    c.company_name AS company_name,
    DATE(t.timestamp) AS t_day,
    SUM(t.amount) AS amount_day
  FROM transaction AS t
  JOIN company as c
  ON t.company_id = c.id
  WHERE t.declined = FALSE
  GROUP BY
	c.id,
	c.company_name,
    t_day
  ORDER BY amount_day DESC
),
ranked AS (
  SELECT
    a.*,
    ROW_NUMBER() OVER (
	  PARTITION BY
	    a.company_id,
	    a.company_name
	  ORDER BY a.amount_day DESC
    ) AS rn
  FROM agregated AS a
)
SELECT
  r.company_id,
  r.company_name,
  r.t_day,
  r.amount_day
FROM ranked AS r
WHERE r.rn <= 5
ORDER BY
  r.company_id,
  r.company_name,
  r.amount_day
DESC
;















