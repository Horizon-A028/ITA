
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.

SELECT
  c.iban,
  AVG(t.amount) AS mitjana
FROM transactions AS t
JOIN users AS u
ON t.user_id = u.id
JOIN cards AS c
ON u.id = c.user_id
WHERE
  t.company_id = (
    SELECT c.id
    FROM companies AS c
    WHERE c.name = "Donec Ltd"
  )
GROUP BY c.iban;