*------------------------------------------------------------------*
* Author........: Rubén Rovira
* Date..........: 06/30/2003
* Notes.........: Subclass CursorAdapter Base Class
*
DEFINE CLASS rrCursorAdapter AS CursorAdapter

*!*	PROTECTED BreakOnError , ;
*!*	          DataSourceType , ;
*!*	          oADOCommand , ;
*!*	          oADORecordset

*--PROTECTED
BreakOnError   = .F.
DataSourceType = ""
oADOCommand    = Null
oADORecordset  = Null

Procedure selectcmd_assign
	Lparameters vNewVal
	This.SelectCmd = Chrtran(m.vNewVal, Chr(13) + Chr(10), "")
EndProc 

Procedure AfterDelete 
	*!*	This procedure was added according to Aleksey's answer to the error below
	*!*	"Row handle referred to a deleted row or a row marked for deletion"
	Lparameters cFldState, lForce, cDeleteCmd, lResult
	If Upper(This.DataSourceType)="ADO"
		This.DataSource.MoveFirst()
	EndIf 
EndProc

*-----------------------------------------------------------------------------------------
Function Init(tcDataSourceType AS String, toADOConnection AS Object)
*-----------------------------------------------------------------------------------------
	This.DataSourceType = IfEmpty( tcDataSourceType, "NATIVE" )
	
	If Upper(This.DataSourceType)="ADO"


		* Once detached, the cursor is independent from the CursorAdapter object, but not
		* from its data source. You can use CURSORGETPROP("ADORecordset") to get the Recordset
		* associated with the cursor even if it is detached from the CursorAdapter object. 
		* If you close the connection when the cursor is not fetched completely and then
		* try to fetch more records an error is reported. To avoid this problem, execute 
		* GO BOTTOM before closing connection or use oCA.FetchSize = -1 when you call CursorFill.

		This.FetchSize = -1  && retrieves the complete result set.

		If Vartype(This.oADOCommand) <> "O"
			This.oADOCommand = CreateObject("ADODB.Command")
			This.oADOCommand.ActiveConnection = toADOConnection
		EndIf 
		
		If Vartype(This.oADORecordset) <> "O"
			This.oADORecordset = CreateObject("ADODB.Recordset")

			With This.oADORecordset 
				.CursorLocation 	= 3 &&adUseClient
				.LockType 			= 3 &&adLockOptimistic
				.ActiveConnection 	= toADOConnection
			EndWith 

			This.DataSource = This.oADORecordset				
		EndIf 

	EndIf 

EndFunc 

*-----------------------------------------------------------------------------------------
Function Destroy()
*-----------------------------------------------------------------------------------------
	This.oADORecordset = Null
EndFunc 

*-----------------------------------------------------------------------------------------
Function BeforeCursorFill(lUseCursorSchema, lNoDataOnLoad, cSelectCmd)
*-----------------------------------------------------------------------------------------

	* Si el origen de datos es ADO, CursorFill intentará abrir el Recordset al menos que este
	* sea pasado como 4to parámetro, para lo cual ya debe estar abierto. 
	* Dado que hay ocasiones, en el Put() por ejemplo, en que se hacen 2 CursorFill 
	* seguidos para el mismo CursorAdapter, la segunda vez generaba un error
	* dado que el ADORecorset ya estaba abierto.

	IF UPPER(This.DataSourceType)="ADO"
		IF This.oADORecordset.State = 1 &&adStateOpen
			This.oADORecordset.Close()
		ENDIF
	ENDIF

	* Si el cursor a generar ya existe, lo cierro.
	Use In Select( This.Alias )

EndFunc 

*-----------------------------------------------------------------------------------------
Protected Procedure AfterCursorFill(lUseCursorSchema, lNoDataOnLoad, cSelectCmd, lResult)
*-----------------------------------------------------------------------------------------

	IF Upper(This.DataSourceType)="NATIVE"
		*-- CursorFill by default leaves local tables open so we need to close it manually.
		*-- Because of this you need to watch out; with NATIVE you need to name your 
		*-- CursorAdapter Aliases DIFFERENT than the base table name.
		If Used(This.Tables)
			Use In (This.Tables)
		EndIf 
	EndIf 

	*!*	--------------------------------------------------------------------
	*!*	Unique Table, Unique Schema, Unique Catalog Properties—Dynamic (ADO)
	*!*	--------------------------------------------------------------------
	*!*	Enables you to closely control modifications to a particular base table in
	*!*	a Recordset that was formed by a JOIN operation on multiple base tables.
	*!*	
	*!*	- Unique Table: specifies the name of the base table upon which updates, 
	*!*	                insertions, and deletions are allowed. 
	*!*	- Unique Schema: specifies the schema, or name of the owner of the table. 
	*!*	- Unique Catalog: specifies the catalog, or name of the database containing the table. 
	*!*	
	*!*	Remarks
	*!*	-------
	*!*	The desired base table is uniquely identified by its catalog, schema, and table names. 
	*!*	When the Unique Table property is set, the values of the Unique Schema or Unique Catalog 
	*!*	properties are used to find the base table. It is intended, but not required, that either
	*!*	or both the Unique Schema and Unique Catalog properties be set before the Unique Table
	*!*	property is set.
	*!*	
	*!*	The primary key of the Unique Table is treated as the primary key of the entire Recordset.
	*!*	This is the key that is used for any method requiring a primary key.
	*!*	
	*!*	While Unique Table is set, the Delete method affects only the named table. 
	*!*	The AddNew, Resync, Update, and UpdateBatch methods affect any appropriate 
	*!*	underlying base tables of the Recordset.
	*!*	
	*!*	Unique Table must be specified before doing any custom resynchronizations.
	*!*	If Unique Table has not been specified, the Resync Command property will have no effect.
	*!*	
	*!*	A run-time error results if a unique base table cannot be found.
	*!*	
	*!*	These dynamic properties are all appended to the Recordset object Properties collection
	*!*	when the CursorLocation property is set to adUseClient.
	*!*	--------------------------------------------------------------------
	IF Upper(This.DataSourceType)="ADO" And Not Empty(This.Tables) And Occurs([,],This.Tables)=0
		* RR, 03/10/2004: por lo indicado en el comentario anterior
		*  y si - Not Empty(This.Tables)      --->   no está vacía la propiedad (sería el caso si se ejecuta una Stored Procedure)
		*       - Occurs([,],This.Tables)=0   --->   se refiere a una tabla (no es una lista de tablas)
		* Esto lo hago ya que es posible que en la DataTier se contruya el GetOne con un Select
		* resultante de un JOIN de múltiples tablas.
		* El Chrtran() es para que tome cosas tan odiosas como "[Order Details]" de Northwind
		This.DataSource.Properties("Unique Table") = Chrtran(This.Tables,"[]","")
	EndIf 

	IF lResult
		* Todo OK!
	Else 
	    = AError( laErrorArray )
	    Local loError As Object
	    loError = NewObject( "rrException", "rrException.prg" )
	    With loError
			.ErrorNo = laErrorArray( 1 )
			.Message = laErrorArray( 2 )
			.Procedure = Program()
			.Save()
		EndWith 
		Throw loError
	EndIf 

EndProc 

EndDefine 