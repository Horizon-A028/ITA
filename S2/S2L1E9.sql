-- Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.

WITH
  tr_count AS (
    SELECT t.user_id, COUNT(1) AS n
    FROM transactions AS t
    GROUP BY t.user_id
    HAVING n > 80
  )
SELECT u.*, c.n
FROM users AS u
JOIN tr_count AS c;