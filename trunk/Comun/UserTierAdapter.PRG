*------------------------------------------------------------------*
* Author........: Ruben Rovira
* Date..........: 18/04/2003
* Parameters....: -
* Returns.......: -
* Notes.........: Segundo nivel de abstraccion del modelo de capas.
*               :
* See also......: TierAdapter.prg
*

Define Class UserTierAdapter As TierAdapter Of TierAdapter.prg

	DataSession = 1      			&& Default Datasession (in this tier, to join its client's datasession)

	cTierLevel = "User"				&& Indica el nivel de la capa dentro del modelo.
	cTierClass  = ""     			&& Nombre de la clase con los que hace la instanciación.

	nNivelJerarquiaTablas = 1       && Mantiene el nivel de jerarquia de tablas del último New(), GetOne() o GetAll() para usar en el Put().

	cFormName = ""					&& Nombre del form donde se mostrarán los datos de la entidad

	cSelectorFormName = ""			&& Nombre del form "Selector" que se usará para esta entidad.
	cSelectorFields = "*"     		&& Lista de campos separados por comas para utilizar en el form Selector.
	cSelectorCaptions = ""			&& Lista de captions separadas por comas correspondientes a los campos de This.cSelectorFields, para utilizar en el form Selector.
	cSelectorOrderBy = ""			&& Indica el ordenamiento inicial de los resultados para el Selector (este puede ser luego cambiado por el usuario haciendo click en el header de cada columna del selector)

	cPickOneCursorFields = ""     	&& Lista de campos del cursor, separados por comas, utilizado en el objeto PickOne.
	&& Los campos a indicar son los correspondientes a:
	&& ID (Primary Key), ID Again or Codigo (Unique Value), Descripcion (Details)
	cPickOneTableFields = ""		&& Lista de campos separadas por comas de la tabla utilizada en el objeto PickOne.
	&& Los campos a indicar son los correspondientes a:
	&& ID (Primary Key), ID Again or Codigo (Unique Value), Descripcion (Details)

	cType ='I'						&& (C=Char/I=Int) - Type para el ingreso del "ID" o "Unique Code" de la entidad
	cFormat = 'Z'					&& Format para el ingreso del "ID" o "Unique Code" de la entidad
	cInputMask = '99999999'			&& InputMask para el ingreso del "ID" o "Unique Code" de la entidad

	nRowsPerPage = 20				&& Numero de registros (filas) por pagina (metodo GetAllPaginated)

	Function Init( tnDataSessionID As Number )

		DoDefault()

		If Empty( tnDataSessionID )
		Else
			This.DataSessionId = tnDataSessionID
		Endif

		This.oUser = This.SetUserData()

		Return

	EndFunc

	Protected Function PostProcessEachCursor( tcAlias As String ) As VOID
		This.CreateIndexes( tcAlias )
	Endfunc

	* [Abstract method]
	Protected Function CreateIndexes( tcAlias As String ) As VOID
		* Used to index every cursor after a GetOne() or New() call
	Endfunc



	* RR, 22/10/2004: Con este método, subo los datos de la colección de tablas desde la DataTier a la UserTier "on-demand"
	* y no siempre que se crea un objeto uoEntidad, como se hacia anteriormente, lo que bajaba la performance notablemente.
	Function colTables_Access
		If This.colTables.Count = 0
			Local loCol As Collection
			If Vartype( _Screen.oColTablesCache ) # [O]
				_Screen.AddObject( [oColTablesCache], [Collection] )
			Endif
			Local loCol As Collection, lxIndex As Variant, lcXMLTables As String
			loCol = _Screen.oColTablesCache
			lxIndex = loCol.GetKey( This.Name )
			If Empty(lxIndex)
				Local loEntidad As Object
				loEntidad = This.NextTier()
				lcXMLTables = loEntidad.GetTables()
				loEntidad = Null
				loCol.Add(lcXMLTables,This.Name)
			Else
				lcXMLTables = loCol.Item(lxIndex)
			Endif
			This.CopyTables( lcXMLTables )
		Endif
		Return This.colTables
	EndFunc

	Function New( nLevel As Number ) As Boolean

		This.nNivelJerarquiaTablas = Iif( Empty( nLevel ), 1, nLevel )

		Local loEntidad, lcXML
		loEntidad = This.NextTier()
		lcXML = loEntidad.New( This.nNivelJerarquiaTablas )
		This.GetData( lcXML, .t. )

		* Se agrega el APPEND BLANK para todas las tablas de nivel 1 ya que se comentó en
		* DataTierAdapter ya que si no, el DiffGram toma como "Modified" lo que debería ser "Inserted".
		For Each colItem In This.colTables
			If colItem.Item( "nNivel" ) = 1
				Select ( colItem.Item( "cCursor" ) )
				Append Blank
				Exit
			Endif
		Endfor

		Return .T.

	EndFunc

	Function GetOne( idEntidad As Number, nLevel As Number ) As Boolean

		This.nNivelJerarquiaTablas = Iif( Empty( nLevel ), 1, nLevel )

		Local loEntidad, lcXML
		loEntidad = This.NextTier()
		lcXML = loEntidad.GetOne( idEntidad, This.nNivelJerarquiaTablas )
		***************************
		* RR, 18/06 ErrorHandler
		Local llRetVal As Boolean
		llRetVal = .T.
		Try
			* DEBUG Code
			If .F. And _Screen.oApp.lDebugMode 
				StrToFile( lcXML, "C:\GetOne_" + Alltrim(This.Name) + ".Xml" )
			EndIf 
			This.GetData( lcXML, .T. )
		Catch To loError
			If Used( 'cExceptionInformation' )
				Use In cExceptionInformation
			Endif
			llRetVal = .F.
			Stop( ParseError( loError ) )
		Finally
		Endtry
		***************************

		Return llRetVal

	EndFunc

	Function GetAll( tcFilterCriteria As String, tcCursorAlias As String ) As Boolean

		lcFilterCriteria = IfEmpty( tcFilterCriteria, "" )

		Local loEntidad, lcXML
		loEntidad = This.NextTier()
		lcXML = loEntidad.GetAll( lcFilterCriteria, tcCursorAlias )

		***************************
		* RR, 18/06 ErrorHandler
		Local llRetVal As Boolean
		llRetVal = .T.
		Try
			This.GetData( lcXML )
		Catch To loError
			If Used( 'cExceptionInformation' )
				Use In cExceptionInformation
			Endif
			llRetVal = .F.
			Stop( ParseError( loError ) )
		Finally
		Endtry
		***************************

		Return ( llRetVal )

	EndFunc

	Function GetAllPaginated( nPageNro As Number, cFilterCriteria As String, tcOrderBy As String ) As Boolean

		Local loEntidad, lcXML
		loEntidad = This.NextTier()
		lcXML = loEntidad.GetAllPaginated( cFilterCriteria, nPageNro, This.nRowsPerPage, tcOrderBy )

		Local llRetVal As Boolean
		llRetVal = .T.
		Try
			This.GetData( lcXML )
		Catch To loError
			If Used( 'cExceptionInformation' )
				Use In cExceptionInformation
			Endif
			llRetVal = .F.
			Stop( ParseError( loError ) )
		Finally
		Endtry

		Return ( llRetVal )

	EndFunc

	Function GetAllPaginatedCount( tcFilterCriteria As String ) As Boolean

		Local loEntidad, lcXML
		loEntidad = This.NextTier()
		lcXML = loEntidad.GetAllPaginatedCount( tcFilterCriteria )

		Local llRetVal As Boolean
		llRetVal = .T.
		Try
			This.GetData( lcXML )
		Catch To loError
			If Used( 'cExceptionInformation' )
				Use In cExceptionInformation
			Endif
			llRetVal = .F.
			Stop( ParseError( loError ) )
		Finally
		Endtry

		Return ( llRetVal )

	EndFunc

	Function Put( idEntidad As Variant ) As Boolean

		Local loEntidad As Object, lcDiffGram As String

		Local loMyXA As rrXMLAdapter

		loMyXA = Newobject( "rrXMLAdapter", "rrXMLAdapter.Prg" )
		With loMyXA
			Local colItem As Collection
			For Each colItem In This.colTables
				If colItem.Item( "nNivel" ) <= This.nNivelJerarquiaTablas
					.AddTableSchema( colItem.Item( "cCursor" ) )
				Endif
			Endfor
			lcDiffGram = .GetDiffGram()
		Endwith
		loMyXA = .F.

		loEntidad = This.NextTier()

		***************************
		* RR, 18/06 ErrorHandler
		***************************
		Local llRetVal As Boolean, lcRetVal As String
		llRetVal = .T.
		Try
			lcRetVal = loEntidad.Put( idEntidad, lcDiffGram, This.nNivelJerarquiaTablas )
			If Not Empty( lcRetVal )
				This.GetData( lcRetVal )
			Endif
		Catch To loError
			If Used( 'cExceptionInformation' )
				Use In cExceptionInformation
			Endif
			llRetVal = .F.
			Stop( ParseError( loError ) )
		Finally
		Endtry
		***************************

		Return( llRetVal )

	EndFunc

	Function GetAllFromView( tcViewName As String, tcViewFields As String, tcFilterCriteria As String, tcCursorAlias As String, tcOrderFields As String ) As Boolean

		Local loEntidad As Object, lcXML As String, llRetVal As Boolean

		loEntidad = This.NextTier()
		lcXML = loEntidad.GetAllFromView( tcViewName, tcViewFields, tcFilterCriteria, tcCursorAlias, tcOrderFields )
		llRetVal = .T.

		Try
			This.GetData( lcXML )
		Catch To loError
			If Used( 'cExceptionInformation' )
				Use In cExceptionInformation
			Endif
			llRetVal = .F.
			Stop( ParseError( loError ) )
		Finally
		Endtry

		Return ( llRetVal )

	EndFunc

	Function SetUserData() As Object
		Local loUser As Object
		If Vartype(_Screen.oApp)="O" And Vartype(_Screen.oApp.oUser)="O"
			loUser = Createobject("Empty")
			AddProperty( loUser, 'IdUser',  _Screen.oApp.oUser.IdUser )
			AddProperty( loUser, 'cName',   _Screen.oApp.oUser.cName  )
			AddProperty( loUser, 'lAdmin',  _Screen.oApp.oUser.lAdmin )
		Endif
		Return loUser
	EndFunc

Enddefine
