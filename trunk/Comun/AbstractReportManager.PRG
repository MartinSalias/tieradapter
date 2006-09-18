#include MS.h

Define Class AbstractReportManager As Session
	
	DataSession = 1
	cReportName = ""
	cTargetDevice = "PRINTER"
	
	nCopies = 1
	lForcePrinter = .f.
	oCurrentContext = null
	cFlatFileGenerator = ""
	
	lToolbarPrint = .f.
	lToolbarPreview = .f.
	lToolbarExport = .f.
	lToolbarMail = .f.

	Protected cDetailAlias, cDefaultFolder, ;
			  cAvailableFileTypes, cFlatFileTypes, ;
			  cSaveAsFileName
	cDetailAlias = ""
	cDefaultFolder = ""
	cAvailableFileTypes = "XLS|DBF|TXT|XML"
	cFlatFileTypes = "XLS|DBF|TXT|XML"
	cSaveAsFileName = ""
	
	*------------------------------------------------------------------
	Protected FUNCTION Init() as Boolean
		If DoDefault()
			This.cDefaultFolder = Addbs( GetSpecialFoldersPath( "MyDocuments", "WindowsScript" ) )
		Else
			Return .f.
		endif 
	EndFunc 
		
	*------------------------------------------------------------------
	Protected Function cTargetDevice_Assign( tcValue as String ) as String 
		this.cTargetDevice = Upper( tcValue )
	EndFunc 
	
	
	*------------------------------------------------------------------
	Function Send( tcAlias as String ) as Boolean 
	 	
	 	If Vartype( _Screen.ActiveForm ) = "O"
			Set Datasession To _Screen.ActiveForm.DataSessionID
	 	EndIf 

	 	This.cDetailAlias = Iif( Empty( tcAlias ), Alias(), tcAlias )

		Do Case
			Case this.cTargetDevice = "EXPORT"
		 		Return this.GenerateFile()
		 	Case this.cTargetDevice $ this.cAvailableFileTypes
		 		Return this.GenerateFile( this.cTargetDevice )
		 	Otherwise
		 		Return this.GenerateReport()
	 	EndCase 
	EndFunc 
	
	
	*------------------------------------------------------------------
	Function GenerateFile( tcFileType As String ) as Boolean
		
		Local llReturn as Boolean, lcExtension as String 
		llReturn = .t.
		
		this.cSaveAsFileName = Putfile( "Archivo", this.cDefaultFolder, Iif( Empty(tcFileType), this.cAvailableFileTypes, tcFileType ) )
	
		If Empty( this.cSaveAsFileName )
			* Cancelled - nothing to do
			llReturn = .f.
		Else
			* Adds single-quotes to handle spaces on filenames
			this.cSaveAsFileName = "'" + this.cSaveAsFileName + "'"
			
			* Strips extension
			lcExtension = Upper( JustExt( this.cSaveAsFileName ) )
			
			Select ( this.cDetailAlias )
			
			Assert .f. message "Está mandando a "+ this.cSaveAsFileName 
			
			Billboard( "Exportando..." )
			
			If Atc( lcExtension, this.cFlatFileTypes ) > 0
				this.DelegateFlatFileGeneration()
			EndIf 
			
			Local lcSaveAsFileName As String 
			lcSaveAsFileName = this.cSaveAsFileName
			Do Case
			Case lcExtension = "XLS"
				Copy To ( &lcSaveAsFileName ) Type XL5
				
			Case lcExtension = "DBF"
				Copy To ( &lcSaveAsFileName ) Type fox2x 
				
			Case lcExtension = "TXT"
				Copy To ( &lcSaveAsFileName ) Delimited 
				
			Case lcExtension = "XML"
				* RR, (Spanish)
				* Si se intenta hacer un CursorToXML a this.cSaveAsFileName directamente, da error
				* por eso se hace un CD a la carpeta destino, se genera el archivo XML y luego se
				* vuelve a cambiar a la carpeta en la que se estaba posicionado previamente.				
				Local lcAppFolder As String, lcSaveAsFolder As String, lcSaveAsFileName As String 
				lcAppFolder = Sys(5)+Curdir()
				lcSaveAsFolder = JustPath( this.cSaveAsFileName )
				lcSaveAsFileName = JustFname( this.cSaveAsFileName )				
				Try
					Cd(lcSaveAsFolder)
					* Export current work area data
					CursorToXML(0,lcSaveAsFileName,1,4+8+512,0,"1")
				Catch to loError
					* RR, (Spanish)
					* Atrapo el error, pero actuo en consecuencia abajo del EndTry
					* para recomponer la carpeta de trabajo en el Finally, caso
					* contrario darían error ParseError y Warning.
				Finally
					Cd ( lcAppFolder )
				EndTry

				If Vartype( loError ) = "O"
					If _SCREEN.oApp.lDebugMode And Confirm( ParseError( loError ), "¿Suspend?" )
						Suspend 
					Else 
						Warning( "Error exporting data to file:";
						 +CR+ this.cSaveAsFileName )
					EndIf
				EndIf 
			Otherwise 
				this.GenerateOtherFileTypes( lcExtension )
			EndCase 
			
			Billboard()
		EndIf 
		
		Return llReturn
	EndFunc 

	*------------------------------------------------------------------
	Protected Function GenerateOtherFileTypes( tcExtension as String ) as Boolean
	EndFunc
	
	*------------------------------------------------------------------
	Protected Function GenerateReport() as Boolean
	EndFunc
	
	*------------------------------------------------------------------
	Protected Function DelegateFlatFileGeneration() as Boolean 
		
		Local llReturn as Boolean 
		llReturn = .f.
		
		If Vartype( this.oCurrentContext ) # "O" ;
		 or Empty( this.cFlatFileGenerator )
		 	* No delegate
		Else
			Local lcDelegate as String 
			lcDelegate = "this.oCurrentContext."+ this.cFlatFileGenerator + "()"
			Try 
				llReturn = Evaluate( lcDelegate )
			Catch to oError
				Stop( ParseError( oError ) )
			EndTry 
		EndIf 
		
		Return llReturn 
	EndFunc 
	
Enddefine

