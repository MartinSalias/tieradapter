* RR, 17/10/2003
* Entidades: Orders, OrderDetails
* Capa: Negocios
* 
Define Class boOrder As boGeneral Of boGeneral.prg OLEPUBLIC

cTierClass  = "doOrder"       && Nombre de la clase con los que hace la instanciación.

* RR, 30/01/2004 - Ejemplifico la utilizacion de validaciones y/o agregado
*                  o modificación de datos en la capa de negocios antes de grabar.
Procedure Put( idEntidad As Variant, tcDiffGram As String, nLevel AS Number ) As String

    Local lcDiffGram As String

    Local loXA As rrXMLAdapter
    loXA = NewObject("rrXMLAdapter", "rrXMLAdapter.Prg" )

    This.GetBack( IdEntidad, tcDiffGram, nLevel, loXA )

    *** Desde aca se pueden validar y/o modificar los cursores a gusto ***

	Local llOk As Boolean 
	Local lcErrDetail As String 
	Do Case
		Case Empty( OrderHeader.RequiredDate )
			lcErrDetail = "You can not leave empty the RequiredDate!"
			llOk = .F.
		Case Empty( OrderHeader.ShippedDate )
			lcErrDetail = "You can not leave empty the ShippedDate!"
			llOk = .F.
		Otherwise
			llOk = .T.
	EndCase

    *** Hasta aca se pueden validar y/o modificar los cursores a gusto ***

	* Si todo esta Ok bajo a la capa de datos si no retorno a la capa de usuario 
	* informando el problema
	If llOk
	    lcDiffGram = This.PutBack( loXA )
    	Return( This.oEntidad.Put( idEntidad, lcDiffGram, nLevel ) )
	Else
		Local loError As rrException
		loError = NewObject( "rrException", "rrException.prg" )
		With loError
			.Message = "Some errors where found in the order"
			.ErrorNo = 9999
			.Details = lcErrDetail
			.Procedure = "boOrder.Put()"
			.Save()
		EndWith
		Local lcRetVal As String  
		lcRetVal = This.SendData( 1 )
		Return ( lcRetVal )
	EndIf
 
EndProc

EndDefine 
