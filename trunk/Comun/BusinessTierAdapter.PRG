*------------------------------------------------------------------*
* Author........: Ruben Rovira
* Date..........: 18/04/2003
* Parameters....: -
* Returns.......: -
* Notes.........: Segundo nivel de abstraccion del modelo de capas.
*               : 
* See also......: TierAdapter.prg
*
Define Class BusinessTierAdapter As TierAdapter Of TierAdapter.prg

oEntidad = Null				&& Para albergar la referencia al objeto de la capa de datos
cTierLevel = "Business"		&& Indica el nivel de la capa dentro del modelo.

Protected oConnection
oConnection = Null
Procedure GetConnection() As VOID 
	Return This.oConnection
EndProc 
Procedure SetConnection( toConnection As Object ) As VOID 
	This.oConnection = toConnection
EndProc 
Procedure GlobalTransactionBegin
	This.oConnection = This.oEntidad.GlobalTransactionBegin()
EndProc 
Procedure GlobalTransactionEnd
	This.oEntidad.GlobalTransactionEnd()
	This.oConnection = Null
EndProc 
Procedure GlobalTransactionRollback
	This.oEntidad.GlobalTransactionRollback()
	This.oConnection = Null
EndProc 

Procedure oEntidad_Access
  	If Vartype(This.oEntidad)#"O"
		This.oEntidad = This.NextTier()
	EndIf 
  	If Vartype(This.oConnection)="O"
		This.oEntidad.SetConnection( This.GetConnection() )
	EndIf 
	This.oEntidad.oUser = This.oUser
	Return This.oEntidad
EndProc 

* RR, 22/10/2004: Con este método, subo los datos de la colección de tablas desde la DataTier a la UserTier "on-demand"
* y no siempre que se crea un objeto uoEntidad, como se hacía anteriormente, lo que bajaba sensiblemente la performance.
Procedure colTables_Access
	If This.colTables.Count = 0
		This.CopyTables( This.oEntidad.GetTables() )
	EndIf 
	Return This.colTables
EndProc 

Procedure Destroy
	If DoDefault()
		This.oEntidad = Null
	EndIf 
EndProc 

Procedure New( nLevel AS Number ) AS String
	Return ( This.oEntidad.New( nLevel ) )
EndProc 

Procedure GetOne( idEntidad AS Number, nLevel AS Number ) AS String
	Return ( This.oEntidad.GetOne( idEntidad, nLevel ) )
EndProc 

Procedure GetAll( cFilterCriteria AS String, tcCursorAlias As String ) AS String
	Return ( This.oEntidad.GetAll( cFilterCriteria, tcCursorAlias ) )
EndProc 

Procedure GetAllPaginated( tcFilterCriteria AS String, tnPageNro As Number, tnRowsPerPage As Number, tcOrderBy As String ) AS String
	Return ( This.oEntidad.GetAllPaginated( tcFilterCriteria, tnPageNro, tnRowsPerPage, tcOrderBy ) )
EndProc

Procedure GetAllPaginatedCount( tcFilterCriteria AS String ) AS String
	Return ( This.oEntidad.GetAllPaginatedCount( tcFilterCriteria ) )
EndProc 

Procedure Put( idEntidad As Variant, cDiffGram As String, nLevel AS Number ) As String
	Return ( This.oEntidad.Put( idEntidad, cDiffGram, nLevel ) )
EndProc 

*!*	RR, 31/12/2003 (Hic...)
*!*	
*!*	Al hacer un Put, si las reglas de negocio creaban la necesidad de modificar y/o agregar algunos datos
*!*	a los cursores que se iban a grabar, se presentaba el problema que al obtener el nuevo DiffGram, este
*!*	solo contenía las modificaciones efectuadas en la capa de negocios y no aquellas hechas en la capa de
*!*	uusarios. Para incluir ambas es necesario bajar a la capa de datos, traer los cursores en su estado 
*!*	original (podemos utilizar el metodo GetOne) y aplicarles el diffgram con las modificaciones hechas
*!*	en la capa de usuario. Luego si estaremos en condiciones de modificar dichos cursores según lo indiquen
*!*	las reglas de negocio para despues obtener un diffgram con la totalidad de las modificaciones. 
*!*	
*!*	Este metodo de la capa de negocios tiene como objetivo, dados los datos originales junto a las modificaciones
*!*	efectuadas en la capa de usuario y un XMLAdapter (para contener las modificaciones, aplicar y obtener el nuevo
*!*	DiffGram), obtener los cursores "marcados" como modificados.
*!*	
*!*	Parámetros recibidos:
*!*	
*!*	tcOriginalData	Los datos originales, en el estado previo a la modificaciones efectuadas en la capa de usuario (sin tener en cuenta la concurrencia de usuarios)
*!*	tcDiffGram		Las modificaciones efectuadas en la capa de usuarios
*!*	tnLevel			El nivel de detalle
*!*	toXA			El objeto XMLAdapter que mantendrá el control de los cambios y del que luego extraeremos el nuevo DiffGram
*!*	
Protected Procedure GetBack( tnIdEntidad As Variant, tcDiffGram As String, tnLevel As Integer, toXA As rrXMLAdapter )

	This.GetData( This.oEntidad.GetOne( tnIdEntidad, tnLevel ) )

	For Each colItem In This.colTables
		IF colItem.Item( "nNivel" ) <= tnLevel
			loCA = NewObject( "rrCursorAdapter", "rrCursorAdapter.Prg" )
			loCA.CursorAttach( colItem.Item( "cCursor" ) )
			colItem.Add( loCA, "oCursorAdapter" )
			loCA = .F.
			toXA.AddTableSchema( colItem.Item( "cCursor" ) )
		EndIf 
	EndFor 

	toXA.LoadXML( tcDiffGram )

	Local lnTableIndex As Integer
	lnTableIndex = 1 && Utilizo esta variable como indice para la coleccion Tables del XMLAdapter 
	                 && ya que no me acepta como indice al nombre del cursor
			
	For Each colItem In This.colTables
		If colItem.Item( "nNivel" ) <= tnLevel
			* Seteo los campos clave del cursor para evitar el error Nº 18 - Line too long
			* al hacer el AppyDiffGram con cursores de más de 50 campos.
			For Each oField As XMLField In toXA.Tables( lnTableIndex ).Fields
				If IsIn( Upper(Alltrim(oField.Alias)), Upper(Alltrim(colItem.Item( "cPKName" ))) ) > 0
					oField.Keyfield = .T.
				EndIf 
			EndFor 
			* Aplico el DiffGram
			Select( colItem.Item( "cCursor" ) )
			toXA.Tables( lnTableIndex ).ApplyDiffGram()
			lnTableIndex = lnTableIndex + 1 
		EndIf 
	EndFor

EndProc 

Protected Procedure PutBack( toXA As rrXMLAdapter )
	Return toXA.GetDiffGram()
EndProc 

Procedure GetAllFromView( tcViewName As String, tcViewFields As String, tcFilterCriteria As String, tcCursorAlias As String, tcOrderFields As String ) As String
	Return ( This.oEntidad.GetAllFromView( tcViewName, tcViewFields, tcFilterCriteria, tcCursorAlias, tcOrderFields ) )
EndProc 

EndDefine 
