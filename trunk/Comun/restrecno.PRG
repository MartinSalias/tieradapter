*------------------------------------------------------------------*
* Funcion.......: RestRecNo
* Devuelve......: 
* Autor.........: Martin Salias - Modificada por Ruben Rovira
* Fecha.........: Mayo 1997 / Marzo 2004
* Version.......: 2.0
* Parametros....: tnRecno = Número de registro; tcAlias = Alias (opcional)
* Notas.........: Reemplazo seguro del GO ( en conjunto con SaveRecNo() )
*               :
* Relacionadas..: SaveRecNo
*
Lparameters tnRecno, tcAlias

If Empty( tcAlias )
	tcAlias = Alias()
EndIf 

If tnRecno # Recno( tcAlias )
	If tnRecno = 0
		Go Bottom In ( tcAlias )
	Else 
		Go tnRecno In ( tcAlias )
	EndIf 
*!*		DO Case 
*!*			Case tnRecno <= 1
*!*				Go Top In ( tcAlias )
*!*			Case tnRecno >= Reccount( tcAlias )
*!*				Go Bottom In ( tcAlias )
*!*			Otherwise
*!*				Go tnRecno In ( tcAlias )
*!*		EndCase 
EndIf 

Return 
*------------------------------------------------------------------*
