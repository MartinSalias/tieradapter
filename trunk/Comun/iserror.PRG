* RR, 26/06/2004
* Determina si es Error o Warning. Si es error se debería parar la ejecución, si no avisar y seguir adelante.

Lparameters toError As Exception 

* Elimino los "User thrown errors" y me quedo con el error "original"
loError = toError
Do While loError.ErrorNo = 2071 && User Thrown Error
	If Vartype( loError.UserValue ) = "O"
		loError = loError.UserValue 
	Else 
		Exit 
	EndIf 
EndDo 

Return ( loError.ErrorNo = 9999 )  && Si el ErrorNo es 9999, es un aviso (Warning) y dejo seguir, caso contrario paro la ejecución del sistema.
