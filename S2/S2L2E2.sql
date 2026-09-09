-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions
-- amb un valor comprès entre 350 i 400 euros i en alguna d'aquestes dates:
-- 29 d'abril del 2015,
-- 20 de juliol del 2018,
-- 13 de març del 2024. 
-- Ordena els resultats de major a menor quantitat.

SELECT *
FROM companies AS c
JOIN transactions AS t
ON t.company_id = c.id
WHERE t.instant