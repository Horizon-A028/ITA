
-- En la taula "transaction" ingressa una nova transacció amb la següent informació:

-- Id: 108B1D1D-5B23-A76C-55EF-C568E49A99DD 
-- credit_card_id: CcU-9999 
-- company_id: b-9999 
-- user_id: 9999 
-- lat: 829.999 
-- longitude: -117.999 
-- amount: 111.11 
-- declined: 0

SELECT *
FROM transaction
LIMIT 1;

INSERT INTO transaction (
  id,
  credit_card_id,
  company_id,
  user_id,
  lat,
  longitude,
  amount,
  declined,
  timestamp
) VALUES (
  "108B1D1D-5B23-A76C-55EF-C568E49A99DD",
  "CcU-9999",
  "b-9999",
  9999,
  829.999,
  -117.999,
  111.11,
  0,
  NOW()
);

-- Estos datos no se pueden ingresar porque no son validos:

SELECT *
FROM company AS c
WHERE c.id = "b-9999";

-- No existe una compania con esta id. Ya que no hay instrucciones para proceder
-- en este caso, no voy a inventar datos en la tabla de compania y credit card
-- para facilitar esta operacion. Tampoco voy a eliminar las 
-- CONSTRAINT FOREIGN KEY de las tablas.