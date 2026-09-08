
-- El departament de Recursos Humans ha identificat un error en el número
-- de compte associat a la targeta de crèdit amb ID CcU-2938. La informació
-- que ha de mostrar-se per a aquest registre és: TR323456312213576817699999.
-- Recorda mostrar que el canvi es va realitzar.

SELECT *
FROM credit_card AS c
WHERE c.id = "CcU-2938"
;

-- Asumo que por "informació que s'ha de mostrar en aquest registre",
-- se esta refiriendo al iban cual es "CA137550525951024363769804".

UPDATE credit_card AS c
SET iban = "TR323456312213576817699999"
WHERE c.id = "CcU-2938"
;

SELECT *
FROM credit_card AS c
WHERE c.id = "CcU-2938"
;

-- El cambio se ha efectuado como esperaba.