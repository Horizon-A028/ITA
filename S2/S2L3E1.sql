-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si
-- les tres últimes transaccions han estat declinades aleshores és inactiu,
-- si almenys una no és rebutjada aleshores és actiu. Partint d’aquesta taula respon:

-- Quantes targetes estan actives?

DROP TABLE IF EXISTS cards_activity;
CREATE TABLE IF NOT EXISTS cards_activity AS
WITH
  ranked AS (
    SELECT
      c.id,
      CASE
        WHEN t.declined THEN 0
        ELSE 1
      END AS not_declined,
      ROW_NUMBER() OVER(
        PARTITION BY c.id
        ORDER BY t.instant DESC
      ) AS rn
    FROM transactions AS t
    JOIN cards AS c
    ON t.card_id = c.id
  ),
  activity AS (
    SELECT
      r.id,
      SUM(not_declined) AS act
    FROM ranked AS r
    WHERE r.rn < 4
    GROUP BY r.id
    HAVING act > 0
  )
SELECT COUNT(1) AS active_cards
FROM activity AS a
;

SELECT * FROM cards_activity;