-- La secció de màrqueting desitja tenir accés a informació específica
-- per a realitzar anàlisi i estratègies efectives.
-- S'ha sol·licitat crear una vista que proporcioni detalls clau sobre
-- les companyies i les seves transaccions.
-- Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació:
--   Nom de la companyia.
--   Telèfon de contacte.
--   País de residència.
--   Mitjana de compra realitzat per cada companyia.
-- Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.

-- Asumo que una compra (o venta) es una transaccion no denegada.

CREATE OR REPLACE VIEW VistaMarketing AS
SELECT
  c.name,
  c.phone,
  c.country,
  AVG(t.amount) AS avg_sale
FROM companies AS c
JOIN transactions AS t
ON t.company_id = c.id
WHERE t.declined = FALSE
GROUP BY
  c.name,
  c.phone,
  c.country
ORDER BY avg_sale DESC
;
