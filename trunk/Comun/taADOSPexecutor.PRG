* RR, 05/06/2004
* taADOSPExecutor
* TierAdapter Framework
* Execute a Stored Procedure through ADO

Define Class taADOSPExecutor AS Session OLEPUBLIC

Hidden oComm, Cursors, Parameters, DataSession

oComm = Null 		&& ADO Command object.
Cursors = Null  	&& Collection of cursors names generated from the returned RecordSets.
Parameters = Null	&& Collection of output parameters values filled in the Execute method.
DataSession = 1     && Default Datasession.

Procedure Init
	This.Parameters = NewObject( "msCollection", "msBaseClass.Vcx" )
	This.Cursors = NewObject( "msCollection", "msBaseClass.Vcx" )
	This.oComm = CreateObject( "ADODB.Command" )
	This.oComm.CommandType = 4	&& Stored Procedure.
EndProc 

Procedure Destroy
	This.Parameters = Null
	This.Cursors = Null
	This.oComm = Null
EndProc 

*!*	tcName 	 	A String representing the name of the Parameter object. 
*!*	tcType   	Optional. A Long value specifying the data type of the Parameter object. See the Type property for valid settings. 
*!*	tcDirection Optional. A Long value specifying the type of Parameter object. See the Direction property for valid settings. 
*!*	tnSize 		Optional. A Long value specifying the maximum length for the parameter value in characters or bytes. 
*!*	txValue 	Optional. A Variant specifying the value for the Parameter object. 
Procedure AddParameter( tcName As String, tcType As String, tcDirection As String, tnSize As Integer, txValue As Variant, tnNumericScale As Integer, tnPrecision As Integer ) As Boolean 

	Local lcName As String, lnType As Long, lnDirection As Long, lnSize As Long, lxValue As Variant, lnNumericScale As Integer, lnPrecision As Integer 

	lcName 		   = tcName
	lnType 		   = This.GetAdoDataTypeEnum( tcType )
	lnDirection    = This.GetAdoParameterDirectionEnum( tcDirection )
	lnSize 		   = tnSize
	lxValue 	   = txValue
	lnNumericScale = tnNumericScale
	lnPrecision    = tnPrecision

	Local loParam As ADODB.Parameter 
	loParam = This.oComm.CreateParameter(lcName, lnType, lnDirection, lnSize, lxValue)
	If InList( lnType, 14, 131 ) && Decimal or Numeric 
		If Not (Empty(lnNumericScale) Or Empty(lnPrecision))
			loParam.NumericScale = lnNumericScale
			loParam.Precision = lnPrecision
		Else 
			This.ThrowError( 9999, [Both "NumericScale" and "Precision" parameters must be defined.], Program() ) 
		EndIf 
	EndIf 
	This.oComm.Parameters.Append(loParam)
	loParam = Null
	Release loParam

EndProc 

Procedure RemoveParameter( tcParameterName As String ) As VOID 
	Local loParam As ADODB.Parameter, llUnrecognizedParameter As Boolean 
	llUnrecognizedParameter = .T. 
	For Each loParam In This.oComm.Parameters
		If loParam.Name == tcParameterName
			This.oComm.Parameters.Delete( tcParameterName )
			llUnrecognizedParameter = .F.
			Exit 
		EndIf 
	EndFor 
	If llUnrecognizedParameter
		This.ThrowError( 9999, "Could not remove the parameter - Parameter not recognized", Program() ) 
	EndIf 
EndProc 

Procedure SetParameterValue( tcParameterName As String, txNewValue As Variant ) As VOID 
	Local loParam As ADODB.Parameter, llUnrecognizedParameter As Boolean 
	llUnrecognizedParameter = .T. 
	For Each loParam In This.oComm.Parameters
		If loParam.Name == tcParameterName
			loParam.Value = txNewValue
			llUnrecognizedParameter = .F.
			Exit 
		EndIf 
	EndFor 
	If llUnrecognizedParameter
		This.ThrowError( 9999, "Could not set the parameter - Parameter not recognized", Program() ) 
	EndIf 
EndProc 

Procedure GetParameterValue( tcParameterName As String ) As Variant
	Local loParam As ADODB.Parameter, ;
		  llUnrecognizedParameter As Boolean, ;
		  lxRetVal As Variant 
	llUnrecognizedParameter = .T. 
	For Each loParam In This.oComm.Parameters
		If loParam.Name == tcParameterName
			lxRetVal = loParam.Value
			llUnrecognizedParameter = .F.
			Exit 
		EndIf 
	EndFor 
	If llUnrecognizedParameter
		This.ThrowError( 9999, "Could not get the parameter - Parameter not recognized", Program() ) 
	Else
		Return lxRetVal 
	EndIf 
EndProc 

Procedure AddCursor( tcName As String ) As Boolean
	This.Cursors.Add( tcName, tcName )
EndProc 

Procedure RemoveCursor( tcName As String ) As Boolean 
	This.Cursors.Remove( tcName )
EndProc 

Procedure RemoveAllCursors() As Boolean 
	This.Cursors.Remove( -1 )
EndProc 

Procedure SetConnection( toConn As ADODB.Connection )
	This.oComm.ActiveConnection = toConn 
EndProc 

Procedure Execute( tcStoredProcedureName As String )

	If Empty( tcStoredProcedureName )
		This.ThrowError( 9999, "Stored procedure name not especified as a parameter of the execute method.", Program() ) 
	EndIf 

	This.oComm.CommandText = tcStoredProcedureName

	Local oRS As ADODB.RecordSet
	Local i As Integer
	Local loParam As ADODB.Parameter 
	Local loCursor As CursorAdapter 
	Local oErr As Exception 
	
	Try

		oRS = CreateObject("ADODB.RecordSet")

		* Execute the Stored Procedure.
		oRS.CursorLocation = 3  && adUseClient
		oRS.Open(This.oComm)

		* Fill the Parameters collection.
		This.Parameters.Remove( -1 )
		For i = 1 To This.oComm.Parameters.Count
			loParam = This.oComm.Parameters(i-1)
			This.Parameters.Add( loParam.Value, loParam.Name )
		EndFor 

		* Generate a VFP Cursor from each returned ADO RecordSet.
		i = 1
		Do While VarType( oRS ) = "O" And oRS.State = 1 
			If Not oRS.EOF

				loCursor = CreateObject('CursorAdapter')
				With loCursor
					.Alias = This.Cursors.Item(i)
					.DataSourceType = 'ADO'
					llReturn = .CursorFill( .F., .F., 0, oRS )
					If llReturn
						.CursorDetach()
					Else 
						AError(laErrors)
						This.ThrowError( laErrors( 1 ), Transform(laErrors( 2 )), Program(), Transform(laErrors( 3 )) ) 
				   EndIf 
				EndWith 
				loCursor = Null

		    EndIf 
	    	oRS = oRS.NextRecordset 
   			i = i + 1
		EndDo 

	Catch to oErr
		loMyError = NewObject( "rrException", "rrException.prg" )
		With loMyError
			.Save( oErr )
			.Throw()
		EndWith 
	Finally 
	EndTry 
	
EndProc 

* ADO ParameterDirectionEnum Values
* Return -1 if the parameter direction is not recognized!
Hidden Procedure GetAdoParameterDirectionEnum( tcADOParameterDirection As String ) As Integer
	Local lnRetVal As Integer
	Do Case
		Case tcADOParameterDirection = [adParamUnknown]		&& Direction unknown.
			lnRetVal = 0
		Case tcADOParameterDirection = [adParamInput]		&& Input parameter (Default).
			lnRetVal = 1
		Case tcADOParameterDirection = [adParamInputOutput]	&& Input and output parameter.
			lnRetVal = 3
		Case tcADOParameterDirection = [adParamOutput]		&& Output parameter.
			lnRetVal = 2
		Case tcADOParameterDirection = [adParamReturnValue]	&& Return value.
			lnRetVal = 4
		Otherwise
			lnRetVal = -1
	EndCase 
	Return lnRetVal 
EndProc 

* ADO DataTypeEnum Values
* Specifies the data type of a Field, Parameter, or Property object
* Return -1 if the type is not recognized!
Hidden Procedure GetAdoDataTypeEnum( tcADOType As String ) As Integer
	Local lnRetVal As Integer
	Do Case
		Case tcADOType = [adEmpty]				&& No value.
			lnRetVal = 0
		Case tcADOType = [adSmallInt]			&& A 2-byte signed integer.
			lnRetVal = 2
		Case tcADOType = [adInteger]			&& A 4-byte signed integer.
			lnRetVal = 3
		Case tcADOType = [adSingle]				&& A single-precision floating-point value. 
			lnRetVal = 4
		Case tcADOType = [adDouble]				&& A double-precision floating-point value. 
			lnRetVal = 5
		Case tcADOType = [adCurrency]			&& A currency value.
			lnRetVal = 6
		Case tcADOType = [adDate]				&& The number of days since December 30, 1899 + the fraction of a day.
			lnRetVal = 7
		Case tcADOType = [adBSTR]				&& A null-terminated character string.
			lnRetVal = 8
		Case tcADOType = [adIDispatch]			&& A pointer to an IDispatch interface on a COM object.
	*!*		Note: Currently not supported by ADO.
	*!*		lnRetVal = 9 	 
			lnRetVal = -1
		Case tcADOType = [adError]				&& A 32-bit error code.
			lnRetVal = 10
		Case tcADOType = [adBoolean]			&& A boolean value.
			lnRetVal = 11
		Case tcADOType = [adVariant]			&& An Automation Variant.
	*!*		Note: Currently not supported by ADO.
	*!*		lnRetVal = 12
			lnRetVal = -1
		Case tcADOType = [adIUnknown]			&& A pointer to an IUnknown interface on a COM object.
	*!*		Note: Currently not supported by ADO.
	*!*		lnRetVal = 13
			lnRetVal = -1
		Case tcADOType = [adDecimal]			&& An exact numeric value with a fixed precision and scale. 
			lnRetVal = 14
		Case tcADOType = [adTinyInt]			&& A 1-byte signed integer.
			lnRetVal = 16
		Case tcADOType = [adUnsignedTinyInt]	&& A 1-byte unsigned integer.
			lnRetVal = 17
		Case tcADOType = [adUnsignedSmallInt]	&& A 2-byte unsigned integer.
			lnRetVal = 18
		Case tcADOType = [adUnsignedInt]		&& A 4-byte unsigned integer.
			lnRetVal = 19
		Case tcADOType = [adBigInt]				&& An 8-byte signed integer.
			lnRetVal = 20
		Case tcADOType = [adUnsignedBigInt]		&& An 8-byte unsigned integer.
			lnRetVal = 21
		Case tcADOType = [adFileTime]			&& The number of 100-nanosecond intervals since January 1,1601.
			lnRetVal = 64
		Case tcADOType = [adGUID]				&& A globally unique identifier (GUID).
			lnRetVal = 72
		Case tcADOType = [adBinary]				&& A binary value.
			lnRetVal = 128
		Case tcADOType = [adChar]				&& A string value.
			lnRetVal = 129
		Case tcADOType = [adWChar]				&& A null-terminated Unicode character string.
			lnRetVal = 130
		Case tcADOType = [adNumeric]			&& An exact numeric value with a fixed precision and scale.
			lnRetVal = 131
		Case tcADOType = [adUserDefined]		&& A user-defined variable.
			lnRetVal = 132
		Case tcADOType = [adDBDate]				&& A date value (yyyymmdd).
			lnRetVal = 133
		Case tcADOType = [adDBTime]				&& A time value (hhmmss).
			lnRetVal = 134
		Case tcADOType = [adDBTimeStamp]		&& A date/time stamp (yyyymmddhhmmss plus a fraction in billionths).
			lnRetVal = 135
		Case tcADOType = [adChapter]			&& A 4-byte chapter value that identifies rows in a child rowset.
			lnRetVal = 136
		Case tcADOType = [adPropVariant]		&& An Automation PROPVARIANT.
			lnRetVal = 138
		Case tcADOType = [adVarNumeric]			&& A numeric value (Parameter object only).
			lnRetVal = 139
		Case tcADOType = [adVarChar]			&& A string value (Parameter object only).
			lnRetVal = 200
		Case tcADOType = [adLongVarChar]		&& A long string value.
			lnRetVal = 201
		Case tcADOType = [adVarWChar]			&& A null-terminated Unicode character string.
			lnRetVal = 202
		Case tcADOType = [adLongVarWChar]		&& A long null-terminated Unicode string value.
			lnRetVal = 203
		Case tcADOType = [adVarBinary]			&& A binary value (Parameter object only).
			lnRetVal = 204
		Case tcADOType = [adLongVarBinary]		&& A long binary value.
			lnRetVal = 205
		Case tcADOType = [AdArray]				&& A flag value combined with another data type constant. Indicates an array of that other data type.
	*!*		Note: Currently not supported by TierAdapter Framework.
	*!*		lnRetVal = 0x2000
			lnRetVal = -1
		Otherwise
			lnRetVal = -1
	EndCase 
	Return lnRetVal 
EndProc 

Procedure ThrowError( tnErrorNo As Integer, tcMessage As String, tcProcedure As String, tcDetails As String ) 
	oError = NewObject( "rrException", "rrException.prg" )
	With oError
		.Set( tnErrorNo, tcMessage, tcProcedure, tcDetails )
		.Throw()
	EndWith 
EndProc 

EndDefine 

