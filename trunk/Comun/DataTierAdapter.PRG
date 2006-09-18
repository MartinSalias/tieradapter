*------------------------------------------------------------------*
* Author........: Ruben Rovira
* Date..........: 18/04/2003
* Parameters....: -
* Returns.......: -
* Notes.........: Segundo nivel de abstraccion del modelo de capas.
*               
* See also......: TierAdapter.prg
*

Define Class DataTierAdapter As TierAdapter Of TierAdapter.prg

Protected cIniFileName , ;
          cAccessType , ;
          cDataBaseName , ;
          cStringConnection , ;
          cBackEndEngine , ;
          oADOConnection , ;
          cConfigurationPath

cIniFileName = ''
cAccessType = ''
cDataBaseName = ''
cStringConnection = ''
cBackEndEngine = ''
oADOConnection = Null

* The startup path is necessary for the Dll to find its startup location and related data.
* Any COM object starts in the path of the calling process. If you're running as an IIS component or a
* Transaction Server component that path will be the SYSTEM path. If you're called from a standalone 
* application, that application's path will be your startup path.
* The Init event, simply SET PATH to all the relevant directories where the DLL need to find data 
* and other support files. Note that these paths should be relative to the base path (THIS.cConfigurationPath) 
* so that there are no hardcoded references anywhere. (Markus Egger)
cConfigurationPath = ''

* cGetAllFields acepta una lista (separada por comas) de campos
* como alternativa a un "SELECT *" en los métodos GetAll y GetAllPaginated.
* Se puede hacer referencia a campos de mas de una tabla, especificando 
* los JOINs en la propiedad cGetAllJoins.
cGetAllFields = ""	

* Si cGetAllFields hace referencia a campos que no están en la tabla de
* nivel 1 de la entidad, se debe indicar la relación que une a esta
* última con la/las tablas que los contienen.
cGetAllJoins = ""

* cGetAllView permite trabajar con una vista como "source" para
* obtener los campos en los métodos GetAll y GetAllPaginated.
cGetAllView = ""

cTierLevel = "Data"		&& Indica el nivel de la capa dentro del modelo.

Function Init() As Boolean 
	If DoDefault()
		Set TablePrompt Off
		If This.lComComponent
			This.cConfigurationPath = Addbs(JustPath(Application.ServerName))  && Application.ServerName returns the full path name of de COM server.
		EndIf 
		Local loIniReader As taIniReader Of taIniReader.Prg
		loIniReader = NewObject( "taIniReader", "taIniReader.Prg" )
		With loIniReader
			.lCaseSensitive = .F.
			.LoadIniFile(This.cConfigurationPath + This.cIniFileName )
			This.cAccessType       = .Readvalue( "cAccessType",       "[Backend]" )
			This.cDataBaseName     = .Readvalue( "cDataBaseName",     "[Backend]" )
			This.cStringConnection = .Readvalue( "cStringConnection", "[Backend]" )
			This.cBackEndEngine    = .Readvalue( "cBackEndEngine",    "[Backend]" )
			.ReleaseIniFile()
		EndWith 
		loIniReader = Null
	EndIf 
EndFunc 

* Este método se utiliza para forzar la utilización de una conexión ya abierta y no abrir una nueva.
* Puede ser útil para, por ejemplo, si se abrió una transacción en otra entidad, utilizar la misma
* conexión y anidad transacciones.

Function GetConnection() As Object
	Local loConnection As taConnection Of taConnection.prg 
	loConnection = NewObject( 'taConnection' , 'taConnection.prg' )
	With loConnection
		.cType          = Upper(Alltrim(This.cAccessType))
		.nDataSessionID = 0
		.oADOConnection = Null
		Do Case 
			Case .cType="NATIVE" 
				.nDataSessionID = This.DataSessionID
			Case .cType="ODBC" 
				* Connection type not supported yet.
			Case .cType="ADO"
				.oADOConnection = This.oADOConnection
			Otherwise 
		EndCase 	
	EndWith 
	Return loConnection
EndFunc

Function SetConnection( toConnection As Object) As VOID 
	Local lcType As String 
	lcType = Upper( Alltrim( toConnection.cType ) )
	Do Case 
		Case lcType="NATIVE" 
			This.DataSessionID = toConnection.nDataSessionID
		Case lcType="ODBC" 
			* Connection type not supported yet.
		Case lcType="ADO"
			This.oADOConnection = toConnection.oADOConnection
		Otherwise 
	EndCase 	
EndFunc

*---------------------------------
* Se conecta con la base de datos.
* Retorna: .F. si ya estaba conectado.
*          .T. si se conectó con éxito.
* Genera un error (Throw) si falla.
*---------------------------------
Protected Function ConnectToBackend() As Boolean

	* Added to force the setting under COM+
	Set Deleted On

	Local llRetVal As Boolean

	TRY
		DO CASE 
			CASE UPPER(This.cAccessType)="NATIVE" 
				IF NOT DBUSED(JUSTSTEM(This.cDataBaseName))
					OPEN DATABASE (This.cDataBaseName) SHARED
					llRetVal = .T.
				ELSE
					SET DATABASE TO JUSTSTEM(This.cDataBaseName)
					llRetVal = .F.
				ENDIF
				
			CASE UPPER(This.cAccessType)="ODBC" 
				* Connection type not supported yet.

			CASE UPPER(This.cAccessType)="ADO"
			
				IF Vartype(This.oADOConnection) <> "O" 
					This.oADOConnection= CreateObject("ADODB.Connection")
				EndIf 
				IF This.oADOConnection.State = 0 &&adStateClosed
					This.oADOConnection.ConnectionString = This.cStringConnection
					This.oADOConnection.Open()
					llRetVal = .T.
				Else 
					llRetVal = .F.
				EndIf 	

			Otherwise 

				Local loError As rrException
				loError = NewObject( "rrException", "rrException.prg" )
				loError.Set( 9999, "Data access type not recognized", Program(), This.Name + ".cAccessType = " + This.cAccessType )
				loError.Throw()
				
		EndCase 
		
	Catch To loError
		llRetVal = .F.
		loMyError = NewObject( "rrException", "rrException.prg" )
		With loMyError
			.Save( loError )
			.Throw()
		EndWith 
	Finally 
	EndTry && ConnectToBackend

	Return llRetVal
	
EndFunc 

*-----------------------------------
* Se desconecta de la base de datos.
*-----------------------------------
Protected Function DisconnectFromBackend() AS Boolean 

	LOCAL llRetVal AS Boolean
	llRetVal = .T.

	TRY	
		DO CASE 
			CASE Upper(This.cAccessType)="NATIVE" 
				IF DBused(JUSTSTEM(This.cDataBaseName))
					SET DATABASE TO JUSTSTEM(This.cDataBaseName)
					CLOSE DATABASE
				EndIf 	
					
			CASE Upper(This.cAccessType)="ODBC" 
				* Connection type not supported yet.

			CASE Upper(This.cAccessType)="ADO" 
				IF Vartype(This.oADOConnection) = "O" AND This.oADOConnection.State = 1 &&adStateOpen
					This.oADOConnection.Close()
				EndIf 
				This.oADOConnection = Null
		EndCase 
	Catch To loError
		loMyError = NewObject( "rrException", "rrException.prg" )
		With loMyError
			.Save( loError )
			.Throw()
		EndWith 
		llRetVal = .F.
	FINALLY
	ENDTRY && DisconnectFromBackend

	RETURN llRetVal
ENDFUNC

*------------------------------------------------------------
* Devuelve un nuevo registro (Estructura en un cursor vacío).
*------------------------------------------------------------
PROCEDURE New( nLevel AS Number ) AS String

	Local lcRetVal AS String
	Local llAlreadyConnected As Boolean 
	Local lcAlias As String, lcSelectCmd As String 
	Try 

		llAlreadyConnected = Not This.ConnectToBackend()

		For Each colItem In This.colTables
			If colItem.Item( "nNivel" ) <= nLevel
				lcAlias = colItem.Item( "cCursor" )
				If Empty( colItem.Item( "SQLStat" ) )
					lcSelectCmd = "SELECT * FROM " + colItem.Item( "cTabla" )
				Else 
					lcSelectCmd = colItem.Item( "SQLStat" )
				EndIf 
				lcSelectCmd = lcSelectCmd + " WHERE 1 = 0"
				This.BuildCursor( lcAlias, lcSelectCmd )
				* Aquí sería el lugar indicado para hacerle un APPEND BLANK al cursor generado
				* ya que estamos "agregando" un nuevo registro pero vamos a tener que hacerlo
				* en UserTierAdapter ya que si no, el DiffGram toma como "Modified" lo que 
				* debería tomar como "Inserted".
			EndIf 
		EndFor 

	Catch To loError

		loMyError = NewObject( "rrException", "rrException.prg" )
		loMyError.Save( loError )

	Finally 

		If Not llAlreadyConnected 
			This.DisconnectFromBackend()
		EndIf 

	EndTry 

	* Aquí, SenData() va a serializar ( convierte a XML ) todos los cursores, ya sean los cursores 
	* con datos o el cursor conteniendo la información del/los errores ocurridos durante el proceso.
	lcRetVal = This.SendData( nLevel )

	Return ( lcRetVal )

EndProc 

*-------------------------------------------
* Devuelve un registro segun su Primary Key.
*-------------------------------------------
Procedure GetOne( idEntidad as Number, nLevel AS Number ) AS String

	LOCAL lcRetVal AS String
	Local llAlreadyConnected As Boolean 

	TRY

		llAlreadyConnected = Not This.ConnectToBackend()

		* Almacenará el ID de la identidad contemplado la posibilidad de que sea númerico o alfanumérico
		Local lcIdEntidad As String, lcFieldName As String, lcAlias As String, lcSelectCmd As String 

		For Each colItem In This.colTables
			If colItem.Item( "nNivel" ) <= nLevel
				lcAlias = colItem.Item( "cCursor" )
				If Empty( colItem.Item( "SQLStat" ) )
					lcSelectCmd = "SELECT * FROM " + colItem.Item( "cTabla" )
				Else 
					lcSelectCmd = colItem.Item( "SQLStat" )
				EndIf 
				lcIdEntidad = IIF( Type( 'idEntidad' ) = 'C', "'", "" ) + Transform( idEntidad ) + IIF( TYPE( 'idEntidad' ) = 'C', "'", "" )
				Do Case
					Case colItem.Item( "nNivel" ) = 1
						lcFieldName = colItem.Item( "cPKName" )
					Case colItem.Item( "nNivel" ) = 2
						lcFieldName = colItem.Item( "cForeign" )
					Otherwise
						lcFieldName = colItem.Item( "cMainId" )
				EndCase 
				lcSelectCmd = lcSelectCmd + " WHERE " + colItem.Item( "cTabla" ) + "." + lcFieldName + " = " + lcIdEntidad
				This.BuildCursor( lcAlias, lcSelectCmd )
			EndIf 
		EndFor 

	Catch To loError

		loMyError = NewObject( "rrException", "rrException.prg" )
		loMyError.Save( loError )

	Finally 

		If Not llAlreadyConnected 
			This.DisconnectFromBackend()
		EndIf 

	EndTry 

	* Aquí, SenData() va a serializar ( convierte a XML ) todos los cursores, ya sean los cursores 
	* con datos o el cursor conteniendo la información del/los errores ocurridos durante el proceso.

	lcRetVal = This.SendData( nLevel )

	Return ( lcRetVal )

EndProc 

*---------------------------------------------------------------------------------------------
* Devuelve los campos especificados en "cGetAllFields" (por defecto TODOS) de aquellos
* registros que cumplan con el filtro "cFilterCriteria" (por defecto TODOS)
*---------------------------------------------------------------------------------------------
Procedure GetAll( tcFilterCriteria As String, tcCursorAlias As String ) As String

	Local lcFields as String, lcFilter as String 
	
	lcFields = Iif( Empty( This.cGetAllFields ), "*", " " + Alltrim(This.cGetAllFields) + " " )
	lcJoins  = Iif( Empty( This.cGetAllJoins ), "", " " + Alltrim(This.cGetAllJoins) + " " )
	lcFilter = Iif( Empty( tcFilterCriteria ), "", " WHERE " + tcFilterCriteria )

	Local llAlreadyConnected As Boolean, lcAlias As String, lcSelectCmd As String 

	Try 

		llAlreadyConnected = Not This.ConnectToBackend()
		For Each colItem In This.colTables
			* GetAll solo procesará la tabla de nivel 1 (uno) dentro de la colección
			IF colItem.Item( "nNivel" ) = 1
				lcAlias = Iif( Empty( tcCursorAlias ), colItem.Item( "cCursor" ), tcCursorAlias )
				lcSelectCmd = "SELECT " + lcFields ;
	    		            + " FROM " + IfEmpty( This.cGetAllView, colItem.Item( "cTabla" ) ) ;
	    		            + lcJoins ;
	        		        + lcFilter
				This.BuildCursor( lcAlias, lcSelectCmd )
				Exit
			EndIf 
		EndFor 

	Catch To loError

		loMyError = NewObject( "rrException", "rrException.prg" )
		loMyError.Save( loError )

	Finally 

		If Not llAlreadyConnected 
			This.DisconnectFromBackend()
		EndIf 

	EndTry 

	Return ( This.Serialize( lcAlias ) )

EndProc 

* Especializado en la DataTier de cada entidad
Procedure GetAllFilterCriteria( tcFilterCriteria As String ) As String
	Return ''
EndProc 

*!*	---------------------------------------------------------------------------------------------
*!*	Devuelve los campos especificados en "cGetAllFields" (por defecto TODOS) de aquellos
*!*	registros que cumplan con el filtro "cFilterCriteria" (por defecto TODOS)
*!*	
*!*	Parámetros adicionales para paginación de resultados:
*!*		tnPageNro			El número de la página a visualizar
*!*		tnRowsPerPage		La cantidad de filas por página
*!*	---------------------------------------------------------------------------------------------

Procedure GetAllPaginated( tcFilterCriteria AS String, tnPageNro As Number, tnRowsPerPage As Number, tcOrderBy As String ) AS String

	Local lcRetVal AS String, lcFields as String, lcFilter as String
	lcFields  = Iif( Empty( This.cGetAllFields ), "*",  Alltrim(This.cGetAllFields) + " " )
	lcJoins   = Iif( Empty( This.cGetAllJoins ), "", " " + Alltrim(This.cGetAllJoins) + " " )
	lcFilter  = This.GetAllFilterCriteria( tcFilterCriteria )

	Local lnExcludedRows As Integer 
	lnExcludedRows = (tnPageNro - 1) * tnRowsPerPage

	Local llAlreadyConnected As Boolean 

	Try

		llAlreadyConnected = Not This.ConnectToBackend()
		Local loMyCA AS rrCursorAdapter
		For Each colItem In This.colTables
			If colItem.Item( "nNivel" ) = 1 && Solo devuelve resultados para el primer nivel
				loMyCA = NewObject( "rrCursorAdapter", "rrCursorAdapter.Prg", "", This.cAccessType, This.oADOConnection )
				With loMyCA

					Local lcPK as String, lcOrderBy as String
					lcPK      = IfEmpty( This.cGetAllView, colItem.Item( "cTabla" ) ) + '.' + colItem.Item( 'cPKName' )
					lcOrderBy = Iif( Empty( tcOrderBy ), lcPk, tcOrderBy )

					.Alias = colItem.Item( 'cCursor' )

					Local lcSelectCmd As String 
					lcSelectCmd = 'Select '
					If Upper(Left(lcFields,8)) == 'DISTINCT'
						lcFields = Substr(lcFields,Atc(lcFields,'DISTINCT') + 9)
						lcSelectCmd = lcSelectCmd + 'Distinct '
					EndIf
					If tnRowsPerPage # 0
						lcSelectCmd = lcSelectCmd + 'Top ' + Transform(tnRowsPerPage) + ' '
					EndIf 
					lcSelectCmd = lcSelectCmd ;
							    + lcFields ;
							    + ' From ' + IfEmpty( This.cGetAllView, colItem.Item( 'cTabla' ) ) ;
				    		    + lcJoins
					If lnExcludedRows # 0
						lcFilter = Iif( Empty( lcFilter ), '', lcFilter + ' And ' ) ;
							     + lcPK + ' Not In (Select Top ' + Transform(lnExcludedRows) + ' ' + lcPK ;
							     + ' From ' + IfEmpty( This.cGetAllView, colItem.Item( 'cTabla' ) ) ;
				    		     + lcJoins ;
							     + Iif( Empty( lcFilter ), '', ' Where ' + lcFilter ) ;
							     + ' Order By ' + lcOrderBy + ')'
					EndIf 
					lcSelectCmd = lcSelectCmd ;
							    + Iif( Empty( lcFilter ), '', ' Where ' + lcFilter ) ;
					            + ' Order By ' + lcOrderBy
					.SelectCmd = lcSelectCmd
					.CursorFill()
					.CursorDetach()

				EndWith 
				loMyCA = .F.
			EndIf 
		EndFor 

	Catch To loError

		loMyError = NewObject( "rrException", "rrException.prg" )
		loMyError.Save( loError )

	Finally 

		If Not llAlreadyConnected 
			This.DisconnectFromBackend()
		EndIf 

	EndTry 

	* Aquí, SenData() va a serializar ( convierte a XML ) todos los cursores, ya sean los cursores 
	* con datos o el cursor conteniendo la información del/los errores ocurridos durante el proceso.

	lcRetVal = This.SendData( 1 )

	Return ( lcRetVal )

*!*	---------------------------------------------------------------------------------------------
*!*	Devuelve la cantidad de registros que cumplen con "tcFilterCriteria"
*!*	Se debe utilizar junto a GetAllPaginated para calcular la cantidad de paginas a mostrar segun
*!*	la cantidad de resultados a mostrar
*!*	---------------------------------------------------------------------------------------------
Procedure GetAllPaginatedCount( tcFilterCriteria AS String ) AS String

	Local lcRetVal AS String, lcFilter as String
	lcFilter = This.GetAllFilterCriteria( tcFilterCriteria )
	lcFilter = Iif( Empty( lcFilter ), '', ' Where ' + lcFilter )

	lcJoins = Iif( Empty( This.cGetAllJoins ), "", " " + Alltrim(This.cGetAllJoins) + " " )

	Local llAlreadyConnected As Boolean, lcSelectCmd As String 

	Try

		llAlreadyConnected = Not This.ConnectToBackend()

		For Each colItem In This.colTables
			* solo devuelve resultados para el primer nivel
			IF colItem.Item( "nNivel" ) = 1
				Local lcPK As String
				lcPK      = IfEmpty( This.cGetAllView, colItem.Item( "cTabla" ) ) + '.' + colItem.Item( 'cPKName' )
				lcSelectCmd = 'Select ' + lcPK ;
						    + ' From ' + IfEmpty( This.cGetAllView, colItem.Item( "cTabla" ) ) ;
			    		    + lcJoins ;
			    		    + lcFilter

				This.BuildCursor( "cTemp", lcSelectCmd )

				Local lcCursorName As String
				lcCursorName = colItem.Item( 'cCursor' )
				Create Cursor &lcCursorName ( nRowsQuantity Int )
				Insert Into &lcCursorName ( nRowsQuantity ) Values ( Reccount( "cTemp" ) )
				Use In "cTemp"

				Exit
			EndIf 
		EndFor 
		
	Catch To loError

		loMyError = NewObject( "rrException", "rrException.prg" )
		loMyError.Save( loError )

	Finally 

		If Not llAlreadyConnected 
			This.DisconnectFromBackend()
		EndIf 

	EndTry 

	* Aquí, SenData() va a serializar ( convierte a XML ) todos los cursores, ya sean los cursores 
	* con datos o el cursor conteniendo la información del/los errores ocurridos durante el proceso.

	lcRetVal = This.SendData( 1 )

	Return ( lcRetVal )

*--------------------------------------------------------------------------------------
* Crea los datos para "UpdatableFieldList" y "UpdateNameList" 
* en base al cursor del area actual o a una sentecia SELECT-SQL recibida como parámetro
* y lo guarda como un miembro más de la collección colTables.
*--------------------------------------------------------------------------------------
PROTECTED PROCEDURE AddUpdatableFieldsData( tColItem AS Collection, tcSQL AS String, tcTabla AS String ) AS Void

	Local lcFields as string, lcNames as String, lnCurrentField AS Integer

	lcFields = ""
	lcNames = ""

	IF PCOUNT() = 1 && No se pasó un SELECT-SQL, se toma la estructura del cursor del área actual

		LOCAL laFields[1]

		FOR lnCurrentField = 1 TO AFields( laFields )

			If IsIn( UPPER( laFields[lnCurrentField,1] ), UPPER( tColItem.Item( "cPKName" )) ) > 0 ;
			   AND NOT tColItem.Item( "lPKUpdatable" )
				* No incluyo la primary key en la lista de campos actualizables
			Else 
				lcFields = lcFields ;
				 + Iif( Empty( lcFields ), "", ", " ) ;
				 + laFields[lnCurrentField,1]
			EndIf 

			lcNames = lcNames ;
			 + Iif( Empty( lcNames ), "", ", " ) ;
			 + laFields[lnCurrentField,1] ;
			 + " " + tColItem.Item( "cTabla" ) + "." + laFields[lnCurrentField,1]

		NEXT

	ELSE

		* Se pasó un SELECT-SQl, entonces "parseo" el string que contiene al SELECT para
		* obtener el nombre de los campos actualizables (Todos menos la PrimaryKey)

		Local lnPosicSelect AS Number, lnPosicSelect AS Number, lcCamposSQL AS String, ;
		      lnInicio AS Number, lnFin AS Number, lcJustName AS String, lcCampo AS String

		* Contemplo que el SELECT a parsear tenga DISTINCT al calcular la posicion de inicio del parseo
		IF 'DISTINCT' $ tcSQL 
			lnPosicSelect = ATC( 'DISTINCT', tcSQL ) + 9
		Else 
			lnPosicSelect = ATC( "SELECT", tcSQL ) + 7
		EndIf

		* Contemplo que el SELECT a parsear tenga un CASE entre los campos a extraer y allí detiene el parseo
		* por lo que sería necesario colocar los CASE (de ser necesarios) al final de toda la lista de campos.
		lnPosicFrom = Iif(Atc("CASE", tcSQL ) = 0, Atc( "FROM", tcSQL ), Atc("CASE", tcSQL ))
		lcCamposSQL = SUBSTR( tcSQL, lnPosicSelect, lnPosicFrom - lnPosicSelect )
		
		lnInicio = 1
		FOR lnCurrentField = 1 TO OCCURS( ",", lcCamposSQL ) + 1
			lnFin = ATC( ",", lcCamposSQL, lnCurrentField )
			IF lnFin = 0 && Hay n-1 cantidad de comas para n campos, entonces cuando llego al ultimo campo el AT devuelve 0
				lnFin = LEN( lcCamposSQL )
			EndIf 
			lcCampo = ALLTRIM( SUBSTR( lcCamposSQL, lnInicio, lnFin - lnInicio ) )
			IF tcTabla $ lcCampo AND ATC( tcTabla, lcCampo ) < ATC( ".", lcCampo )
				lcJustName = ALLTRIM( STRTRAN( lcCampo, tcTabla + ".", "" ) )

				If IsIn( UPPER( lcJustName ), UPPER( tColItem.Item( "cPKName" )) ) > 0 ;
			 	   AND NOT tColItem.Item( "lPKUpdatable" )
					* No incluyo la primary key en la lista de campos actualizables
				Else 
					lcFields = lcFields ;
					 + Iif( Empty( lcFields ), "", ", " ) ;
					 + lcJustName
				EndIf 

				lcNames = lcNames ;
				 + Iif( Empty( lcNames ), "", ", " ) ;
				 + lcJustName + " " + lcCampo

			EndIf 
			lnInicio = lnFin + 1
		EndFor 
	EndIf 

	If tColItem.GetKey( 'cUpdatableFieldList' ) > 0  && Existe el item en la colección
		tColItem.Remove( 'cUpdatableFieldList' )
	EndIf 
	tColItem.Add( lcFields, 'cUpdatableFieldList' )

	If tColItem.GetKey( 'cUpdateNameList' ) > 0  && Existe el item en la colección
		tColItem.Remove( 'cUpdateNameList' )
	EndIf 
	tColItem.Add( lcNames,  'cUpdateNameList' )

EndProc 

*--------------------------------------------------------------------------------------------
* SOLO SE UTILIZA SI LOS ID SON AUTOINCREMENTALES
* Cuando se hace un alta (New+Put) en una estructura cabecera-detalle, al grabar el registro
* en la tabla "cabecera", a este se le asigna un nuevo ID (autoincremental) el cual es
* necesario recuperar para luego volcarlo a la tabla "detalle" a modo de Foreign Key.
*--------------------------------------------------------------------------------------------
Protected PROCEDURE GetNewID ( tcTable AS String ) AS Integer

	Local lnRetVal As Integer

	DO CASE 
		CASE UPPER(This.cAccessType)="NATIVE" 
			= AFields( laField, tcTable )
			lxRetVal = laField[17] - 1
		CASE UPPER(This.cAccessType)="ODBC" 
			* Connection type not supported yet.
		CASE UPPER(This.cAccessType)="ADO" AND This.cBackEndEngine = 'VFPOLEDB'
			= AFields( laField, tcTable )
			lxRetVal = laField[17] - 1
		CASE UPPER(This.cAccessType)="ADO" AND This.cBackEndEngine = 'SQLOLEDB'
			* SQL-Server devuelve un RecordSet con el dato del nuevo ID
			Local oRS as ADODB.RecordSet
*			oRS = This.oADOConnection.Execute( "SELECT @@IDENTITY" )
			oRS = This.oADOConnection.Execute( "SELECT IDENT_CURRENT( '" + tcTable + "' )" )
			lxRetVal = oRS.Fields(0).Value
		Otherwise 
	EndCase 		

	RETURN lxRetVal
	
EndProc 

*-------------------------------------------------------------------------------------
* Hace persistentes los cambios efectuados por el usuario a EL/LOS registros afectados 
* en la entidad (Aplica un DiffGram)
*-------------------------------------------------------------------------------------
Procedure Put( IdEntidad As Number, cDiffGram As String, nLevel AS Number ) As String

	Local lxIdEntidad As Variant, llAlreadyConnected As Boolean, llSuccess As Boolean 
	lxIdEntidad = IdEntidad
	llSuccess = .F.

	Try 

		llAlreadyConnected = Not This.ConnectToBackend()

		* Almacenará el ID de la IdEntidad contemplado la posibilidad de que sea númerico o alfanumérico
		LOCAL lcIdEntidad AS String, lcFieldName As String 
		lcIdEntidad = ""
		lcFieldName = ""

		If .F.
			This.RegenCursorAndApplyDiff()
		Else 
			Local lnTableIndex As Integer
			lnTableIndex = 1 && Utilizo esta variable como indice para la coleccion Tables del XMLAdapter 
			                 && ya que no me acepta como indice al nombre del cursor
			Local loMyCA As rrCursorAdapter Of rrCursorAdapter.Prg
			Local loMyXA AS rrXMLAdapter    Of rrXMLAdapter.prg

			loMyXA = NewObject( "rrXMLAdapter", "rrXMLAdapter.Prg" )
			loMyXA.LoadXML( cDiffGram )

			* DEBUG Code
			If .F. And _Screen.oApp.lDebugMode 
				StrToFile( cDiffGram, "C:\PutDiff.Xml" )
			EndIf 

			For Each colItem In This.colTables
				If colItem.Item( "nNivel" ) <= nLevel

					* Genero el cursor con los cambios
					loMyXA.Tables( lnTableIndex ).ChangesToCursor()

					* Creo un CursorAdapter para actualizar la tabla subyacente.
					loMyCA = NewObject( "rrCursorAdapter", "rrCursorAdapter.Prg", "", This.cAccessType, This.oADOConnection )
					With loMyCA
						.Tables = colItem.Item( "cTabla" )
						.Alias = colItem.Item( "cCursor" )
						* Generación de la UpdatableFieldList y UpdateNameList para
						* cada uno de los cursores de la colección ColTables. Los valores obtenidos
						* serán agregados a dicha colección - Ver método AddUpdatableFieldsData()
						If Empty( colItem.Item( "SQLStat" ) )
							This.AddUpdatableFieldsData( colItem )
						Else 
							This.AddUpdatableFieldsData( colItem, Upper(colItem.Item( "SQLStat" )), Upper(colItem.Item( "cTabla" )) )
						EndIf 
						.KeyFieldList = colItem.Item( "cPKName" )
						.UpdatableFieldList = colItem.Item( "cUpdatableFieldList" )
						.UpdateNameList = colItem.Item( "cUpdateNameList" )
						.CursorAttach()

						* Código de DEBUG
						If .F. And _Screen.oApp.lDebugMode 
							StrToFile( Alltrim( .Alias+Chr(13)+Chr(10) )			                , "C:\Log.err", 1 )
							StrToFile( Alltrim( .KeyFieldList+Chr(13)+Chr(10) )						, "C:\Log.err", 1 )
							StrToFile( Alltrim( .UpdatableFieldList+Chr(13)+Chr(10) )				, "C:\Log.err", 1 )
							StrToFile( Alltrim( .UpdateNameList+Chr(13)+Chr(10)+Chr(13)+Chr(10) )	, "C:\Log.err", 1 )
						EndIf 

					EndWith 
					If colItem.GetKey( "oCursorAdapter" ) > 0  && Existe el item en la colección
						colItem.Remove( "oCursorAdapter" )
					EndIf 
					colItem.Add( loMyCA, "oCursorAdapter" )
					loMyCA = Null

					lnTableIndex = lnTableIndex + 1

				EndIf 
			Next 
			loMyXA = Null
		EndIf

		Try
		
			* Ahora si, abro la transacción y aplico, uno a uno, los TABLEUPDATE() correspondientes.
			This.TransactionBegin()
		
			* Vuelvo a recorrer la colección de tablas haciendo el TableUpdate.
			Local lnUpperLevelID As Integer
			Local lcPKName As String, lnOldIdValue As Integer, lnNewIdValue As Integer

			* Hago invisible los registros deleteados, serán procesados por separado.
			Set Deleted On
		
			* El orden de las tablas según nivel debe ser ascendente para INSERT y UPDATE 
			* para cumplir posibles reglas de integridad referencial. Lo contrario aplica
			* para DELETE por eso se procesan los registros deleteados por separado.
			This.colTables.KeySort = 2 && Sort by key ascending

			For Each colItem In This.colTables
				IF colItem.Item( "nNivel" ) <= nLevel
					Select ( colItem.Item( "cCursor" ) )
					lcPKName = colItem.Item( "cCursor" ) + "." + colItem.Item( "cPKName" )
					If colItem.Item( "lPKUpdatable" )
						* Si la PK es definida por el usuario (no utiliza IDs "AutoInc")
						* Actualizo todos los registros de una sola vez.
						This.PerformUpdate( .T. ) 
					Else 
						Scan
							If This.Modified()
								* Retengo el valor del ID que viene en el cursor.
								lnOldIdValue = Evaluate( lcPKName )
								* Actualizo el registro actual.
								This.PerformUpdate( .F. )				
								* Si el viejo ID es <= 0 es un alta, entonces averiguo el nuevo ID, 
								* caso contrario es una modificación, no hay cambio de ID.
								lnNewIdValue = Iif( lnOldIdValue <= 0, ;
											   This.GetNewID( colItem.Item( "cTabla" ) ), ;
											   lnOldIdValue )
								If lnNewIdValue # lnOldIdValue	&& Es un nuevo ID
									* Lo reflejo en la tabla "actual".
									Replace &lcPKName With lnNewIdValue
									If colItem.Item( "nNivel" ) = 1
										lxIdEntidad = lnNewIdValue
										* Para nivel 1 actualizo toda la colección de tablas
										This.UpdateFamily( lnNewIdValue, lnOldIdValue, nLevel )
									Else 
										* Para nivel 2 o superior actualizo solo las tablas "hijas" (si las tuviere).
										This.UpdateChildren( colItem.Item( "cTabla" ), lnNewIdValue, lnOldIdValue, nLevel )
									EndIf 
								EndIf 
							EndIf 
						EndScan 
					EndIf
				EndIf
			EndFor

			* Hago visible los registros deleteados para poder aplicarles el TableUpdate( .F. )
			Set Deleted Off
			
			* El orden de las tablas según nivel debe ser descendente para DELETE
			* para cumplir posibles reglas de integridad referencial.
			This.colTables.KeySort = 3 && Sort by key descending

			For Each colItem In This.colTables
				IF colItem.Item( "nNivel" ) <= nLevel
					Select ( colItem.Item( "cCursor" ) )
					Scan for Deleted()
						This.PerformUpdate( .F. ) 
					EndScan
				EndIf
			EndFor
			
			This.TransactionEnd()
			llSuccess = .T.

		Catch To loError

			This.TransactionRollBack()

			loMyError = NewObject( "rrException", "rrException.prg" )
			With loMyError
				.Save( loError )
				.Throw()
			EndWith 

		EndTry 

		loMyXA = .F.

	Catch To loError

		loMyError = NewObject( "rrException", "rrException.prg" )
		loMyError.Save( loError )

	Finally 

		If Not llAlreadyConnected 
			This.DisconnectFromBackend()
		EndIf 

	EndTry 

	Set Deleted On

	* Devuelve SIEMPRE los datos como han sido actualizados, con el/los nuevos IDs si fue un alta.
	If llSuccess
		* Ojo con los Bulk insert
		lcRetVal = This.GetOne(lxIdEntidad,nLevel)
	Else 
		lcRetVal = This.SendData(nLevel)
	EndIf 
		
	Return ( lcRetVal )

EndProc 

Protected Procedure TransactionBegin
	DO CASE 
		CASE UPPER(This.cAccessType)="NATIVE" 
			Begin Transaction
		CASE UPPER(This.cAccessType)="ODBC" 
			* Connection type not supported yet.
		CASE UPPER(This.cAccessType)="ADO" AND This.cBackEndEngine = 'VFPOLEDB'
			Begin Transaction
		CASE UPPER(This.cAccessType)="ADO" AND This.cBackEndEngine = 'SQLOLEDB'
			This.oADOConnection.Execute( "BEGIN TRANSACTION" )
		Otherwise 
	EndCase 
EndProc

Protected Procedure TransactionEnd
	DO CASE 
		CASE UPPER(This.cAccessType)="NATIVE" 
			END TRANSACTION
		CASE UPPER(This.cAccessType)="ODBC" 
			* Connection type not supported yet.
		CASE UPPER(This.cAccessType)="ADO" AND This.cBackEndEngine = 'VFPOLEDB'
			END TRANSACTION 
		CASE UPPER(This.cAccessType)="ADO" AND This.cBackEndEngine = 'SQLOLEDB'
			This.oADOConnection.Execute( "COMMIT TRANSACTION" )
		Otherwise 
	EndCase 	
EndProc

Protected Procedure TransactionRollBack
	DO CASE 
		CASE UPPER(This.cAccessType)="NATIVE" 
			RollBack
		CASE UPPER(This.cAccessType)="ODBC" 
			* Connection type not supported yet.
		CASE UPPER(This.cAccessType)="ADO" AND This.cBackEndEngine = 'VFPOLEDB'
			RollBack
		CASE UPPER(This.cAccessType)="ADO" AND This.cBackEndEngine = 'SQLOLEDB'
			* -----------------------------------------
			* De los "Books On-Line" de SQL-SERVER 2000
			* -----------------------------------------
			* When nesting transactions, ROLLBACK TRANSACTION rolls back all inner transactions to the outermost 
			* BEGIN TRANSACTION statement. ROLLBACK TRANSACTION decrements the @@TRANCOUNT system function to 0.
			* -----------------------------------------
			If This.ExecuteSQL( "SELECT @@TRANCOUNT" ) > 0
				This.oADOConnection.Execute( "ROLLBACK TRANSACTION" )
			EndIf 
		OTHERWISE
	ENDCASE		
EndProc

Protected Procedure PerformUpdate( tlAllRows As Boolean ) As Boolean
	If TableUpdate( tlAllRows, .T. )
		Return .T.
	Else 
	    = AError( laErrorArray )  && Data from most recent error
		* SE AGREGA EL IF PARA CONTROLAR ESTE ERROR ESPECÍFICO QUE SE PRODUCE AL HACER EL TABLEUPDATE() DE UN
		* REGISTRO QUE DISPARA UN TRIGGER QUE ACTUALIZA MÚLTIPLES REGISTROS (INVESTIGAR)
		* Si en el Trigger no se puede incluir un SET NOCOUNT ON hay que controlar este error con el IF porque
		* el trigger devuelve que actualizó + de un fila y produce error.
		* Desde el VFP8-SP1 estan las propiedades ConflictCheckType y ConflictCheckCmd del CursorAdapter para controlar esto (Buscar más info en la Web).
	    * If laErrorArray( 2 ) # [Microsoft Cursor Engine : Key column information is insufficient or incorrect. Too many rows were affected by update.]
*	    If Left(laErrorArray( 2 ),103) # [Microsoft OLE DB Provider for SQL Server : DELETE statement conflicted with COLUMN REFERENCE constraint]
		    oError = NewObject( "rrException", "rrException.prg" )
		    With oError
				.ErrorNo = laErrorArray( 1 )
				.Message = laErrorArray( 2 )
*				StrToFile(.Message,'Err.txt')
				.Details = laErrorArray( 3 )
				.Procedure = Program()
				.Save()
				.Throw()
			EndWith 
			Return .F.
*		EndIf
	EndIf
EndProc 

* Actualiza el nuevo ID de un registro de una tabla de nivel = 1 en toda su descendencia (hijos, nietos, etc.)
Protected Procedure UpdateFamily( tnNewID As Integer, tnOldID As Integer, tnLevel As Integer ) As Void
	Local colItem As Collection, lcCursor As String, lcField As String
	For Each colItem In This.colTables
		If Between( colItem.Item( "nNivel" ), 2, tnLevel )
			lcCursor = colItem.Item( "cCursor" )
			If colItem.Item( "nNivel" ) = 2
				* En el nivel 2 se puede referenciar al padre mediante "cForeign" o "cMainId" ya que serían iguales.
				lcField = IfEmpty( colItem.Item( "cMainId" ), colItem.Item( "cForeign" ) )
			Else
				lcField = colItem.Item( "cMainId" )
			EndIf 
			Replace In &lcCursor ;
					&lcField With tnNewID ;
				For &lcField = tnOldID
		EndIf 
	EndFor	
	Return 
EndProc 

* Actualiza el nuevo ID de un registro de una tabla de nivel > 1 en sus tablas hijas.
Protected Procedure UpdateChildren( tcTableName As String, tnNewID As Integer, tnOldID As Integer, tnLevel As Integer ) As Void
	Local colItem As Collection, lcCursor As String, lcField As String
	For Each colItem In This.colTables
		If colItem.Item( "nNivel" ) <= tnLevel And colItem.Item( "cPadre" ) == tcTableName 
			lcCursor = colItem.Item( "cCursor" )
			lcField = colItem.Item( "cForeign" )
			Replace In &lcCursor ;
					&lcField With tnNewID ;
				For &lcField = tnOldID
		EndIf 
	EndFor
	Return 
EndProc 

Procedure ExecuteSQL( tcSQLStat As String ) As String
	Local llAlreadyConnected As Boolean
	llAlreadyConnected = Not This.ConnectToBackend()
	Local oRS as ADODB.RecordSet, lcRetVal As String 
	oRS = This.oADOConnection.Execute( tcSQLStat )
	lcRetVal = oRS.Fields(0).Value
	If Not llAlreadyConnected
		This.DisconnectFromBackend()
	EndIf 
	Return lcRetVal
EndProc 

Procedure GlobalTransactionBegin As Object
	This.ConnectToBackend()
	This.TransactionBegin()
	Return This.GetConnection() 
EndProc 

Procedure GlobalTransactionEnd
	This.TransactionEnd()
	This.DisconnectFromBackend()
EndProc 

Procedure GlobalTransactionRollback
	This.TransactionRollback()
	This.DisconnectFromBackend()
EndProc 

*---------------------------------------------------------------------------------------------
* Desaparece... Se agrega un Hook en GetAll y de acuerdo a un parametro, arma el Select-SQL
* 
Procedure GetAllFromView( tcViewName As String, tcViewFields As String, tcFilterCriteria As String, tcCursorAlias As String, tcOrderFields As String ) As String

	Local lcRetVal AS String, lcFields As String, lcFilter As String, lcAlias As String, lcOrder As String, lcSelectCmd As String 

	lcFields = Iif( Empty( tcViewFields ), "*", tcViewFields )
	lcFilter = Iif( Empty( tcFilterCriteria ), "", " Where " + tcFilterCriteria )
	lcAlias  = Iif( Empty( tcCursorAlias ), "cTmp" + This.Name, tcCursorAlias )
	lcOrder  = Iif( Empty( tcOrderFields ), "", " Order By " + tcOrderFields )

	Local llAlreadyConnected As Boolean 

	Try 

		llAlreadyConnected = Not This.ConnectToBackend()

		lcSelectCmd = "SELECT " + lcFields ;
   		            + " FROM " + tcViewName ;
       		        + lcFilter ;
       		        + lcOrder 

		This.BuildCursor( lcAlias, lcSelectCmd )

	Catch To loError

		loMyError = NewObject( "rrException", "rrException.prg" )
		loMyError.Save( loError )

	Finally 

		If Not llAlreadyConnected 
			This.DisconnectFromBackend()
		EndIf 

	EndTry 

	Return ( This.Serialize( lcAlias ) )

EndProc 

*---------------------------------------------------------------------------------------------

Hidden Procedure Modified
	Local lcModifCtrl As String, llRetVal As Boolean 
	lcModifCtrl = Replicate( "1", Fcount() + 1 )
	Do Case
		Case Recno() < 0 And Deleted()  		&& Agregado y Borrado.
			llRetVal = .F.
		Case lcModifCtrl == GetFldState( -1 )	&& No modificado.
			llRetVal = .F.
		Otherwise
			llRetVal = .T.
	EndCase 
	Return llRetVal 
EndProc 

*---------------------------------------------------------------------------------------------

Procedure BuildCursor( tcCursorName As String, tcSelectCmd As String ) As Boolean
	Local loMyCA As rrCursorAdapter
	loMyCA = NewObject( "rrCursorAdapter", "rrCursorAdapter.Prg", "", This.cAccessType, This.oADOConnection )
	With loMyCA
		.Alias = tcCursorName 
		.SelectCmd = tcSelectCmd 
		.CursorFill()
		.CursorDetach()
	EndWith 
	loMyCA = .F.
	Release loMyCA
EndProc 

*---------------------------------------------------------------------------------------------

Procedure PerformSelectSQL( tcSource As String, tcFields As String, tcFilterCriteria As String, tcCursorAlias As String, tcOrderFields As String ) As String
EndProc 

*---------------------------------------------------------------------------------------------

Function RegenCursorAndApplyDiff
* Ahora recorro colTables para generar los CursorAdapters correspondientes
* para cada una de las tablas involucradas.
* Lo hago fuera de la transacción porque necesito CURSORSETPROP( "Buffering", 5 )
* cuyo uso no está permitido dentro de transacciones.
* Acá podría invocar al método GetOne() pero este me da solo los cursores y no los
* CursorAdapters correspondientes, los cuales necesito la actualización mediante
* sus propiedades UpdatableFieldList

LOCAL loMyXA AS rrXMLAdapter
loMyXA = NewObject( "rrXMLAdapter", "rrXMLAdapter.Prg" )

Local colItem As Collection, loMyCA AS rrCursorAdapter

FOR EACH colItem IN This.colTables
	IF colItem.Item( "nNivel" ) <= nLevel

		loMyCA = NewObject( "rrCursorAdapter", "rrCursorAdapter.Prg", "", This.cAccessType, This.oADOConnection )
		With loMyCA
			.Tables = colItem.Item( "cTabla" )
			.Alias = colItem.Item( "cCursor" )
		EndWith 

		* Inicio de la generación de la UpdatableFieldList y UpdateNameList para
		* cada uno de los cursores de la colección ColTables. Los valores obtenidos
		* serán agregados a dicha colección - Ver método AddUpdatableFieldsData()
		If Empty( colItem.Item( "SQLStat" ) )
			With loMyCA
				.SelectCmd = "SELECT * FROM " + colItem.Item( "cTabla" ) + " WHERE 1 = 0"
				.CursorFill()
				.CursorDetach()
			EndWith 
			Select ( colItem.Item( "cCursor" ) )
			This.AddUpdatableFieldsData( colItem )
			Use 
		Else 
			This.AddUpdatableFieldsData( colItem, Upper(colItem.Item( "SQLStat" )), Upper(colItem.Item( "cTabla" )) )
		EndIf 
		* Fin de la generación de la UpdatableFieldList y UpdateNameList

		* Como los DiffGrams pueden ser generados en base a cursores resultantes de un JOIN de tablas,
		* para que no de error el método ApplyDiffGram() debo regenerar los cursores exactamente igual
		* a como los había generado el método GetOne(), que no puedo invocar desde aquí ya que debo
		* utilizar las propiedades KeyFieldList, UpdatableFieldList y UpdateNameList.
		With loMyCA
			If Empty( colItem.Item( "SQLStat" ) )
				.SelectCmd = "SELECT * FROM " + .Tables
			Else 
				.SelectCmd = colItem.Item( "SQLStat" )
			EndIf 
			lcIdEntidad = IIF( TYPE( 'lxIdEntidad' ) = 'C', "'", "" ) + Alltrim(Transform( lxIdEntidad )) + IIF( TYPE( 'lxIdEntidad' ) = 'C', "'", "" )
			Do Case
				Case colItem.Item( "nNivel" ) = 1
					lcFieldName = colItem.Item( "cPKName" )
				Case colItem.Item( "nNivel" ) = 2
					lcFieldName = colItem.Item( "cForeign" )
				Otherwise
					lcFieldName = colItem.Item( "cMainId" )
			EndCase 
			.SelectCmd = .SelectCmd + " Where " + .Tables + "." + lcFieldName + " = " + lcIdEntidad
			.KeyFieldList = colItem.Item( "cPKName" )
			.UpdatableFieldList = colItem.Item( "cUpdatableFieldList" )
			.UpdateNameList = colItem.Item( "cUpdateNameList" )

			* Código de DEBUG
			If .F. And _Screen.oApp.lDebugMode 
				StrToFile( Alltrim( .Alias+Chr(13)+Chr(10) )							, "C:\Log.err", 1 )
				StrToFile( Alltrim( .KeyFieldList+Chr(13)+Chr(10) )						, "C:\Log.err", 1 )
				StrToFile( Alltrim( .UpdatableFieldList+Chr(13)+Chr(10) )				, "C:\Log.err", 1 )
				StrToFile( Alltrim( .UpdateNameList+Chr(13)+Chr(10)+Chr(13)+Chr(10) )	, "C:\Log.err", 1 )
			EndIf 
			
			.CursorFill()
		EndWith 

		If colItem.GetKey( "oCursorAdapter" ) > 0  && Existe el item en la colección
			colItem.Remove( "oCursorAdapter" )
		EndIf 
		colItem.Add( loMyCA, "oCursorAdapter" )

		loMyCA = .F.

		* Turn table buffering on and make some changes
		CursorSetProp( "Buffering", 5 )

		loMyXA.AddTableSchema( colItem.Item( "cCursor" ) )

	EndIf 
EndFor 

loMyXA.LoadXML( cDiffGram )

* Código de DEBUG
If .F. And _Screen.oApp.lDebugMode 
	StrToFile( cDiffGram, "C:\PutDiff.Xml" )
EndIf 

* Recorro la colección de tablas aplicando el DiffGram a cada uno de los cursores.
Local lnTableIndex As Integer
lnTableIndex = 1 && Utilizo esta variable como indice para la coleccion Tables del XMLAdapter 
                 && ya que no me acepta como indice al nombre del cursor
For Each colItem In This.colTables
	If colItem.Item( "nNivel" ) <= nLevel
		* Seteo los campos clave del cursor para evitar el error Nº 18 - Line too long
		* al hacer el AppyDiffGram con cursores de más de 50 campos.
		For Each oField As XMLField In loMyXA.Tables( lnTableIndex ).Fields
			If IsIn( Upper(Alltrim(oField.Alias)), Upper(Alltrim(colItem.Item( "cPKName" ))) ) > 0
				oField.Keyfield = .T.
			EndIf 
		EndFor 
		* Aplico el DiffGram
		Select ( colItem.Item( "cCursor" ) )
		loMyXA.Tables( lnTableIndex ).ApplyDiffGram()
		lnTableIndex = lnTableIndex + 1
	EndIf 
EndFor
EndFunc 

EndDefine 

