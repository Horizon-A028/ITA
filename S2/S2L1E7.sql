
-- Des de recursos humans et sol·liciten eliminar la columna "pan" de
-- la taula credit_card. Recorda mostrar el canvi realitzat.

ALTER TABLE credit_card
DROP COLUMN pan;

SELECT *
FROM credit_card
LIMIT 10;