#Include MS.h

Define Class NativeReportManager As AbstractReportManager of AbstractReportManager.prg

	lToolbarPrint = .t.
	lToolbarPreview = .t.
	lToolbarExport = .t.
	
	Protected cReportClauses
	cReportClauses = ""
	
	*------------------------------------------------------------------
	Function GenerateReport() as Boolean
		
	 	this.cReportClauses = ""
	 	
	 	Do case
	 	Case this.cTargetDevice = "PRINTER"
	 		
	 		this.cReportClauses = "TO PRINTER" ;
	 		 + Iif( this.lForcePrinter, "", " PROMPT" )
		
		Case this.cTargetDevice = "PREVIEW"
		
		 	this.cReportClauses = "PREVIEW"
		EndCase 
		
		If Empty( this.cReportName )
			* No defined report
		Else 
			If _SCREEN.oApp.lDebugMode And ( xMenu( "Continue;Edit" ) = 2 )
				Return this.EditReport()
			Else
				Return this.SendReport()
			EndIf 
		EndIf
	EndFunc
	
	*-----------------------------------------------------------
	Protected Function EditReport() as VOID 
	
		Select ( this.cDetailAlias )
		Modify Report ( this.cReportName ) NoWait
		Suspend 
	EndFunc 
	
	*-----------------------------------------------------------
	Protected Function SendReport() as Boolean 
		
		Local llReturn, lcSaveFolder as String, lcReportClauses as String, loError as Exception
		llReturn = .t.
		
		* private variable to be used on Reports
		Private pnCopy As Integer, poPrintContext As Object 
		pnCopy = 1

		* poPrintContext está para referenciar dentro de un reporte al form actual
		* dado que no se puede utilizar Thisform.
		* Otra forma podría ser _SCREEN.oApp.oReportManager.CurrentContext
		poPrintContext = This.oCurrentContext

		* If printing to Acrobat, the default directory can be changed
		lcSaveFolder = Sys(5)+Curdir()
		Set Path To ( lcSaveFolder ) ADDITIVE 
		
		lcReportClauses = this.cReportClauses

		For pnCopy = 1 to this.nCopies
			
			Select ( this.cDetailAlias )

			Try
				Report Form ( this.cReportName ) &lcReportClauses noconsole nodialog 
			Catch to loError
				* RR, 29/06/2005 (Spanish)
				* Atrapo el error, pero actuo en consecuencia abajo del EndTry
				* para recomponer la carpeta de trabajo en el Finally, caso
				* contrario darían error ParseError y Warning,
				* y nunca encontraría en archivo debug.ini
			Finally
				Cd ( lcSaveFolder )
			EndTry

			If Vartype( loError ) = "O"
				If _SCREEN.oApp.lDebugMode And Confirm( ParseError( loError ), "¿Suspend?" )
					Suspend 
				Else 
					Warning( "Missing or misconfigured report format:";
					 +CR+ this.cReportName )
					Exit
				EndIf
			EndIf 
			
		Next
		
	EndFunc 
	
Enddefine
