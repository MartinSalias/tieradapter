*------------------------------------------------------------------*
* Author........: Ruben Rovira - Martín Salías
* Date..........: 18/04/2003
* Parameters....: -
* Returns.......: -
* Notes.........: First abstraction level in the Tier model
*               :
* See also......: -
*

Define Class TierAdapter As Session

	Protected cTierLevel
	cTierLevel = ""				&& Indica el nivel de la capa dentro del modelo, se especifica en la especialización de cada capa.

	lComComponent = .F. 		&& Indicates if the components are in external COM dlls.
	cTierComponent = "" 		&& Name of the COM component
	cTierClass  = ""    		&& Name of the class for the next tier

	DataSession = 2				&& Private data session
	colTables = Null			&& Data about each updatable table on the entity

	oUser = Null				&& Objet with data about the current user of the application

	Function Init

		* Por si en las capas, que tienen sesión privada de datos, se utilizan
		* operaciones y/o transformaciones con fechas.
		Set Century On

		Set Date Dmy  && TO-DO devolver el formato de fecha desde un archivo de configuracion

		Set Deleted On
		Set Multilocks On

		This.colTables = Newobject( "colTables", "colTables.Prg" )

	EndFunc

	* Factory method - Instantiate the next Tier component
	Function NextTier() As Object
		Local loTier As Object

		If This.lComComponent
			loTier = Newobject( This.cTierComponent + "." + This.cTierClass )
		Else
			loTier = Newobject( This.cTierClass, This.cTierClass +".prg" )
		Endif

		If This.cTierLevel = "User"
			loTier.oUser = This.oUser
		Endif

		Return loTier
	EndFunc

	* Recibe un cursor y devuelve xData (XML por ahora) para ser pasado entre capas.
	Protected Function SendData( tnLevel As Number) As String

		Local loMyXA As rrXMLAdapter, lcRetVal

		loMyXA = Newobject( "rrXMLAdapter", "rrXMLAdapter.Prg" )
		If Used( "cExceptionInformation" )
			* Un error ha ocurrido
			loMyXA.AddTableSchema( "cExceptionInformation" )
		Else
			* No errors
			For Each colItem In This.colTables
				If colItem.Item( "nNivel" ) <= tnLevel
					loMyXA.AddTableSchema( colItem.Item( "cCursor" ) )
				Endif
			Endfor
		Endif

		loMyXA.PreserveWhiteSpace = .T.
		loMyXA.ToXML( "lcRetVal" )

		If Used( "cExceptionInformation" )
			* Un error ha ocurrido
			Use In cExceptionInformation
		Else
			* No errors
			For Each colItem In This.colTables
				If colItem.Item( "nNivel" ) <= tnLevel
					Use In ( colItem.Item( "cCursor" ) )
				Endif
			Endfor
		Endif

		Return(lcRetVal)

	EndFunc

	* Recibe XML desde otra capa y lo convierte a cursor para ser usado en la capa actual.
	Protected Function GetData( tcData As String, tlPostProcessEachCursor As Boolean ) As Boolean

		Local loMyXA As rrXMLAdapter
		loMyXA = Newobject( "rrXMLAdapter", "rrXMLAdapter.Prg" )
		loMyXA.LoadXML( tcData, .F. )
		For Each oTable In loMyXA.Tables
			Use In Select( oTable.Alias )
			oTable.ToCursor( .F. )

			If tlPostProcessEachCursor
				This.PostProcessEachCursor( oTable.Alias )
			Endif

			CursorSetProp( "Buffering", 5 )
		Endfor
		loMyXA = .F.

		If Used( "cExceptionInformation" )
			loError = Newobject( "rrException", "rrException.prg" )
			With loError
				.Fill()
				Use In "cExceptionInformation"
				.Throw()
			Endwith
		Endif

		Return .T.

	EndFunc

	* [Abstract method]
	Protected Function PostProcessEachCursor( tcAlias As String ) As VOID
		* PostProcessing for each cursor
	Endfunc

	* Devuelve todos los registros segun un PK,
	* hasta determinado nivel de jerarquía
	Function GetOne( idEntidad As Number, nLevel As Number ) As String
		* Especializado en cada subclase.
		Return ""
	EndFunc

	* Devuelve todos los registros del nivel 1 que cumplan con el
	* criterio de filtro recibido como parámetro.
	Function GetAll( cFilterCriteria As String, tcCursorAlias As String ) As String
		* Especializado en cada subclase.
		Return ""
	EndFunc

	* Crea un nuevo elemento para la entidad. Basicamente, llama el metodo PUT sin un ID.
	* Incluido para hacer "amigable" al codigo.
	Function New( nLevel As Number ) As Boolean
		* Especializado en cada subclase.
		Return .T.
	EndFunc

	* Graba en la base de datos segun un PK.
	Function Put( nIDEntidad As Number, cDiffGram As String, nLevel As Number ) As Boolean
		* Especializado en cada subclase.
		Return .T.
	EndFunc

	* Devuelve la colección colTables serializada como XML. Antes devolvía directamente una colección
	* pero encontramos distintos Bugs a saber:
	*		El Remove(-1) para vaciar una colección no se comportaba como era esperado.
	*		Está documentado un BUG de VFP8 al usar FOR EACH con colección de colecciones (como en este caso).
	*       En COM, al pasar las colecciones entre capas, se generaban errores.
	* Copia solo aquellos items de la coleccion que van a ser utilizados en las capas superiores (Business y User)
	Function GetTables() As String
		* Conservo el area actual de trabajo para luego restaurarla al finalizar el metodo
		Local lcOldArea As String
		lcOldArea = Select()
		* Creo el cursor auxiliar
		Create Cursor cColTablesGet ( cTabla Varchar(30), cCursor Varchar(30), nNivel Integer, cPKName Varchar(30) )
		* Por cada item de la coleccion, agrego un registro al cursor
		For Each colItems In This.colTables
			Insert Into cColTablesGet ( cTabla, cCursor, nNivel, cPKName ) Values ( colItems.Item('cTabla'), colItems.Item('cCursor'), colItems.Item('nNivel'), colItems.Item('cPKName') )
		Endfor
		* Creo un XMLAdapter para serializar el cursor
		Local lcRetVal As String
		Local loXA As rrXMLAdapter
		loXA = Newobject( "rrXMLAdapter", "rrXMLAdapter.Prg" )
		loXA.AddTableSchema( "cColTablesGet" )
		loXA.ToXML( "lcRetVal" )
		loXA = .F.
		Release loXA
		* Cierro el cursor auxiliar
		Use In cColTablesGet
		* Restauro el area original de trabajo
		If Not Empty(lcOldArea)
			Select (lcOldArea)
		Endif
		* Retorno la coleccion serializada
		Return (lcRetVal)
	EndFunc

	* Llena la colección colTables con los datos del XML recibido como parámetro.
	* Antes se recibia una colección directamente pero generaba errores en COM
	* por lo que se decidió pasar la colección entre capas serializada como XML.
	Function CopyTables( tcXML As String ) As Boolean
		* Conservo el area actual de trabajo para luego restaurarla al finalizar el metodo
		Local lcOldArea As String
		lcOldArea = Select()
		* Remuevo todos los items de la coleccion miembro de la capa
		This.colTables.Remove( -1 )
		* Creo un XMLAdapter para obtener el cursor desde el XML recibido
		Local loXA As rrXMLAdapter
		loXA = Newobject( "rrXMLAdapter", "rrXMLAdapter.Prg" )
		loXA.LoadXML( tcXML, .F. )
		loXA.Tables(1).ToCursor(.F.,"cColTablesCopy")
		Scan
			* Creo una coleccion auxiliar dentro del SCAN para evitar usar el metodo
			* Remove( -1 ) de la coleccion, que no se comprota como es de esperar
			loColAux = Createobject( 'Collection' )
			loColAux.Add( Alltrim( cColTablesCopy.cTabla ), 'cTabla')
			loColAux.Add( Alltrim( cColTablesCopy.cCursor ), 'cCursor')
			loColAux.Add( cColTablesCopy.nNivel, 'nNivel')
			loColAux.Add( Alltrim( cColTablesCopy.cPKName ), 'cPKName')
			This.colTables.Add( loColAux )
			loColAux = .F.
			Release loColAux
		Endscan
		loXA = .F.
		Release loXA
		* Cierro el cursor auxiliar
		Use In cColTablesCopy
		* Restauro el area original de trabajo
		If Not Empty(lcOldArea)
			Select (lcOldArea)
		Endif
		Return .T.
	EndFunc

	Function Serialize( tcCommaSeparatedCursorList As String ) As String
		Local loMyXA As rrXMLAdapter, lcRetVal As String
		loMyXA = Newobject( "rrXMLAdapter", "rrXMLAdapter.Prg" )
		If Used( "cExceptionInformation" )
			loMyXA.AddTableSchema( "cExceptionInformation" )
		Else
			Local i As Integer
			For i = 1 To GetWordCount( tcCommaSeparatedCursorList, [,] )
				loMyXA.AddTableSchema( Alltrim(GetWordNum( tcCommaSeparatedCursorList, i, [,] ) ))
			Endfor
		EndIf
		loMyXA.PreserveWhiteSpace = .T.
		loMyXA.ToXML( "lcRetVal" )
		loMyXA = .F.
		Release loMyXA
		Return lcRetVal
	EndFunc

	Function TempId() As Integer
		Return TempId()  && TempId.Prg
	EndFunc

Enddefine
