Define Class GeneralEmailContext As EmailContext Of EmailContext.prg

	#If .F.
		Local This As GeneralEmailContext Of GeneralEmailContext.prg
	#EndIf 

	cEventType = "UNDEFINED"

	*---------------------------------------------
	Function Setup() As Boolean 
		* Abstract Method
		Return .t.
	EndFunc 

	*---------------------------------------------
	Function Valid() As Boolean 
		Local llReturn As Boolean
* Por ahora muestro siempre el form de validacion de datos
* el codigo comentado de mas abajo serviria solo para mostrar
* este form, si hay algun dato no valido o incompleto
Do Form EmailContextValidData With This To llReturn 
*!*			Do While .T.
*!*				If This.ValidData()
*!*					llReturn = .T.
*!*					Exit
*!*				Else 
*!*					Do Form EmailContextValidData With This To llInputData
*!*					If llInputData
*!*						Loop
*!*					Else
*!*						llReturn = .F.
*!*						Exit 
*!*					EndIf 
*!*				EndIf 
*!*			EndDo 
		Return llReturn 
	EndFunc 

EndDefine 
