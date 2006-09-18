Local lnBefore As Number
lnBefore = Seconds()
Do While Seconds() - lnBefore < 0.1
EndDo 

Return Seconds() * -1000	 && Identical to Sys(3) * -1

*!*	NO SIRVE PARA SER UTILIZADO EN UN INSERT INTO...
*!*		Lparameters tcAlias
*!*		Return ( Abs( Recno( tcAlias ) ) * -1 )

*!*	AGREGADO PARA UTILIZARLO DESDE FORMS QUE NO REFERENCIAN
*!*	A NINGUNA DE LAS 3 CAPAS
*!*	VER TIERADAPTER.TEMPID()