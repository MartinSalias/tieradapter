*!* Program: PrintReport
*!* Author: M.Salias
*!* Date: 05/23/03 12:40:38 AM
*!* Copyright: 2003
*!* Description: Prints, previews or exports a report
*!* Revision Information:

Lparameters ;
 tcReport, ;	&& Report name
 txMode, ;		&& Mode: 0 (default) Prints, 1 Previews, 2 Export (Or the device as a string)
 tnCopies, ;	&& Number of copies
 tcAlias, ;		&& Alias to print
 tlForcePrinter	&& TRUE to force a specific printer (don't ask)
 
#include MS.h

txMode   = Iif( Empty( txMode   ), 0, txMode   )
tnCopies = Iif( Empty( tnCopies ), 1, tnCopies )

If Type( "_Screen.oApp.oReportManager" ) = "O"

	* ============= NEW CODE --- Now this function delegates to _Screen.oApp.oReportManager ===============
	With _Screen.oApp.oReportManager
		
	 	.cReportName = tcReport
	 	If Vartype( txMode ) = "N"
		 	.cTargetDevice = ICase( ;
		 	 txMode=1, "PREVIEW", ;
		 	 txMode=2, "EXPORT", ;
		 	 txMode=3, "PDF", ;
		 	 txMode=4, "EMAIL", ;
			 "PRINTER" )
		 Else
		 	.cTargetDevice = txMode
		 EndIf 
		 
	 	.nCopies = tnCopies
	 	.lForcePrinter = tlForcePrinter
		
		.Send( tcAlias )
	EndWith 
else

	* ============= OLD CODE --- Now this function delegates to _Screen.oApp.oReportManager ===============

	If txMode = 2	&& Export to a file
		
		Local lcFileName as String, lcExtension as String 
		
		lcFileName = Putfile( "Archivo", "C:\", "XLS;DBF;TXT" )
		
		If Empty( lcFileName )
			* Cancelled - nothing to do
		Else
			* Adds single-quotes to handle spaces on filenames
			lcFileName = "'" + lcFileName + "'"
			
			* Strips extension
			lcExtension = Upper( JustExt( lcFileName ) )
			
			Select ( Iif( Empty( tcAlias ), Alias(), tcAlias ) )
			
			Billboard( "Exportando..." )
			DO case
			Case lcExtension = "XLS"
				Copy To ( &lcFileName ) type XL5
			Case lcExtension = "DBF"
				Copy To ( &lcFileName ) type fox2x 
			Otherwise 
				Copy To ( &lcFileName ) DELIMITED 
			EndCase 
			
			Billboard()
		EndIf 
		
	Else 
		_Screen.oApp.AddPath( "report" )

		Local lcPrinter
		lcPrinter = ""

		If txMode > 0 or tlForcePrinter
			* Will preview, export or print to the default printer
		Else
			lcPrinter = "prompt"
		EndIf 

		If Empty( tcReport )
			* No defined report
		else
			Local loError as Exception, lcTarget as String, lnCopy as Integer, ;
			 lcAlias as String, lcDirectory as String 
			
			Private pnCopy
			 
			lcTarget = Iif( txMode=1, "preview", "to printer prompt" )
			lnCopy = 1
			lcAlias = Iif( Empty( tcAlias ), Alias(), tcAlias )
			
			If Version(2) = 0
				llEdit = .f.
			Else
				llEdit = ( xMenu( "Continuar;Editar" ) = 2 )
			EndIf
			
			If llEdit
				Select ( lcAlias )
				Modify Report ( tcReport ) NoWait
				Suspend 
			Else 

				* If printing to Acrobat, the default directory can be changed
				lcDirectory = Sys(5)+Curdir()
				
				If lcDirectory $ Set("Path")
				Else
					Set Path To Set("Path") +";"+ lcDirectory
				EndIf 
				
				Select ( lcAlias )

				Try
					For lnCopy = 1 to tnCopies
						pnCopy = lnCopy	&& private variable for external functions
						Report Form ( tcReport ) &lcTarget noconsole nodialog 
					Next
				Catch to loError
					* RR, 29/06/2005 (Spanish)
					* Atrapo el error, pero actuo en consecuencia abajo del EndTry
					* para recomponer la carpeta de trabajo en el Finally, caso
					* contrario darían error ParseError y Warning,
					* y nunca encontraría en archivo debug.ini
				Finally 
					* Restore de current directory
					Cd ( lcDirectory )
				EndTry

				If Vartype( loError ) = "O"
					If File( "debug.ini" ) And Confirm( ParseError( loError ), "¿Suspend?" )
						Suspend 
					Else 
						Warning( "Missing or misconfigured report format:";
						 +CR+ this.cReportName )
						Exit
					EndIf
				EndIf

			EndIf 
		EndIf
	EndIf
EndIf 

Return
