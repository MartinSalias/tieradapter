* ------------------------------------------------------------------------------------
* RR, 14/05/2004
* 
* Colección de tablas utilizada en la capa de datos
* 
* Detalle del uso de los ítems de la colección
* 1) cTabla			- Nombre de la tabla - No dejar en Blanco
* 2) cCursor		- Nombre del cursor a generar - No dejar en Blanco
* 3) cPadre			- Se usa solo en caso de 2 o más tablas con relaciones padre/hijo, 
*					  caso contrario se debe dejar en blanco.
*					  En la tabla padre queda en blanco,
*					  en la tabla hija va el nombre de la tabla padre.
* 4) cForeign		- Se usa solo en caso de 2 o más tablas con relaciones padre/hijo, 
*					  caso contrario se debe dejar en blanco.
*					  En la tabla padre queda en blanco, ;
*					  en la tabla hija va el nombre del campo con el que se relaciona 
*					  con la tabla padre (Foreign Key)
* 5) cMainID		- Se usa solo en caso de tablas de nivel 3 o superior, es decir, 
*					  con relaciones padre/hijo/nieto/etc, y referencia al nombre del 
*					  campo que contiene el ID de la tabla de nivel 1 con la que 
*					  está relacionada.
* 6) SQLStat		- Para NEW y GETONE, se puede definir una sentencia SQL especializada
*					  si se deja en blanco, se utilizará "SELECT * FROM ..."
*					  La idea es, por ejemplo, en un Cabecera/Detalle con 2 tablas
*					  Orders y Orders Detail (Northwind), especializar  el SELECT para el
*					  detalle, incluyendo el campo ProductName mediante un INNER JOIN con
*					  la tabla Products, evitando asi por cada ítem del detalle hacer un 
*					  Hit contra la base de datos en búsqueda del nombre del producto.
*					  NOTA: aqui no se puede utilizar una vista dado que sobre este mismo
*					  cursor se pueden hacer actualizaciones por medio del método PUT.
* 7) cPKName		- Nombre de la Primary Key de la tabla/nivel de la entidad.
* 8) lPKUpdatable	- Indica si la PK es Updatable para incluirla o no en la UpdatableFieldList.
* ------------------------------------------------------------------------------------

Define Class colTables As taCollection Of taCollection.Prg


* Agrega un item a colTables (para el desarrollador, no le permito asignar el NIVEL)
* Llama a InternalAddTable que si permite setear el nivel de la tabla pero que es un método
* de uso interno de la clase.
Procedure AddTable( cTabla As String, cCursor As String, cPadre As String, ;
		            cForeign As String, cMainID AS String, cSQLStat As String, ;
		            cPKName as String, lPKUpdatable As Boolean ) AS Boolean
	This.InternalAddTable( cTabla, cCursor, cPadre, cForeign, cMainID, cSQLStat, cPKName, lPKUpdatable, 0, "" )
EndProc 

* Agrega un item a colTables (para el desarrollador, no le permito asignar el NIVEL)
Hidden Procedure InternalAddTable( cTabla As String, cCursor As String, cPadre As String, ;
		            			   cForeign As String, cMainID AS String, cSQLStat As String, ;
		            			   cPKName as String, lPKUpdatable As Boolean, nNivel As Integer, tcKey As String ) AS Boolean
	Local ColItems As Collection
	ColItems = NewObject( 'taCollection', 'taCollection.Prg' )
	With ColItems
		.Add( cTabla,       "cTabla" 		)
		.Add( cCursor,      "cCursor" 		)
		.Add( cPadre,       "cPadre" 		)
		.Add( cForeign,     "cForeign" 		)
		.Add( cMainID,   	"cMainId" 		)
		.Add( cSQLStat,     "SQLStat"		)
		.Add( cPKName,      "cPKName"		)
		.Add( lPKUpdatable, "lPKUpdatable" 	)
		.Add( nNivel,       "nNivel"    	)
	EndWith
	If Empty( tcKey )
		This.Add( ColItems )
	Else
		This.Add( ColItems, tcKey )
	EndIf 
	Return .T.
EndProc 

* Valida colTables
* Retorna una colección similar a colTables pero validada y con los niveles asignados.
* En caso de no ser valida la colección, retorna Null.
Procedure Validate() As Boolean
	Local llRetVal As Boolean
	Create Cursor cColTables ( cTabla Memo, cCursor Memo, cPadre Memo, cForeign Memo, cMainID Memo, cSQLStat Memo, cPKName Memo, lPKUpdatable L, nNivel Int )
	Select cColTables	
	llRetVal = This.ValidAndAsignLevel( "", 1 )
	If llRetVal
		This.Remove( -1 )
		Scan
			This.InternalAddTable( cTabla, cCursor, cPadre, cForeign, cMainID, cSQLStat, cPKName, lPKUpdatable, nNivel, Transform( nNivel, "@L 99999" ) + Transform( Recno( "cColTables" ), "@L 99999" ) )
		EndScan 
	Else 
		Assert .f. message "The collection of tables in the DataTier is not valid !"
	EndIf 
	Use In cColTables
	Return llRetVal 
EndProc 

* Recorre colTables validando y determinando el nivel de cada uno de las tablas que la componen (Recursiva)
Hidden Procedure ValidAndAsignLevel( cTablaNivelAnterior AS String, tnNivel AS Number ) AS Boolean
	Local llRetVal As Boolean
	llRetVal = .T.
	For Each colItem In This
		If colItem.Item('cPadre') == cTablaNivelAnterior
			If tnNivel = 1
				* Controlo que haya un sólo nivel 1 (padre vacío)
				Locate For nNivel = 1
				If Found()
					Return .F.
				EndIf
			Else 
				* Controlo que todo hijo tenga una Foreign Key
				If Empty( colItem.Item('cForeign') )
					Return .F.
				EndIf 
			EndIf 
			With colItem
				Insert into cColTables ( cTabla, cCursor, cPadre, cForeign, cMainID, cSQLStat, cPKName, lPKUpdatable, nNivel ) ;
					   values ( .Item('cTabla'),  .Item('cCursor'), .Item('cPadre'),  .Item('cForeign'), ;
					            .Item('cMainId'), .Item('SQLStat'), .Item('cPKName'), .Item('lPKUpdatable'), tnNivel )
			EndWith 
			llRetVal = This.ValidAndAsignLevel( colItem.Item('cTabla'), tnNivel + 1 )
		EndIf 
	EndFor 
	Return llRetVal
EndProc 

EndDefine 
