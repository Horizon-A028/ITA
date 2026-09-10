-- Elimina de la taula transaction el registre amb 
--   ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD
-- de la base de dades.

SELECT *
FROM transactions AS t
WHERE t.id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

DELETE FROM transactions AS t
WHERE t.id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

SELECT *
FROM transactions AS t
WHERE t.id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';