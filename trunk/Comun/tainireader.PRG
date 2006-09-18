
* To try it on, put "DO taIniReader.prg" in the VFP Command Windows.
TryMyself()
Return

*------------------------------------------------------------------*
*------------------------------------------------------------------*
*------------------------------------------------------------------*
*    Clase: taIniReader
* Objetivo: Lee un archivo .INI de configuración y devuelve el valor de una variable.
*    Autor: Rubén O. Rovira
*    Fecha: 13 de Agosto de 2004
*  Version: 1.0  ---> TierAdapter Framework

Define Class taIniReader As Session

* Hidden implementation Properties:
Protected nIniLines
Protected aIniFile[1]

nIniLines = 0
aIniFile[1] = ""

lCaseSensitive = .F.  && Case insensitive by default.

Procedure Destroy
	Sys(1104)  && Purge cached memory.
EndProc 

Procedure lCaseSensitive_Assign(tlNewVal As Boolean)
	If This.nIniLines > 0
		Local loError As rrException
		loError = NewObject( "rrException", "rrException.prg" )
		loError.Set( 9999, "Could not change case sensitive mode if a INI file is loaded.", Program(), "taIniReader.Prg" )
		loError.Throw()
	Else
		This.lCaseSensitive = tlNewVal
	EndIf 
EndProc 

Procedure ReadValue(tcVariable As String, tcSection As String)

	If This.nIniLines > 0

		Local llIgnoreSection As Boolean
		llIgnoreSection = Empty(tcSection)

		If llIgnoreSection 
			tcSection = ""
		Else 
			* Check for "[" and "]" at the begining and end of the tcSection parameter.
			tcSection = Iif( Left(Alltrim(tcSection),1) = "[", "", "[" ) ;
			          + Alltrim(tcSection) ;
		    	      + Iif( Right(Alltrim(tcSection),1) = "]", "", "]" )
		EndIf 

		If This.lCaseSensitive
			* Case sensitive mode
		Else
			* Case insensitive mode, convert all to uppercase
			tcSection = Upper(tcSection)
			tcVariable = Upper(tcVariable)
		EndIf 

		Local llIsTheSection As Boolean 
		* Flag que prendo al llegar a la sección pasada como parámetro 
		* y desde allí empiezo la lectura de los valores.
		* Si tcSection vino vacío, prendo el flag ahora dado que se asume
		* que no se quiere diferenciar entre secciones dentro el INI.
		llIsTheSection = (tcSection == "")

		Local lcReturn As String, lnEqual As Integer 

		lcReturn = ""

		For i = 1 To This.nIniLines
			lnEqual = At("=",This.aIniFile(i))
			If Not llIgnoreSection And "[" $ This.aIniFile(i) And "]" $ This.aIniFile(i) And lnEqual = 0
				If tcSection $ This.aIniFile(i)
					llIsTheSection = .T.
					Loop
				Else
					If llIsTheSection
						Exit
					Else
						Loop  
					EndIf 
				EndIf 
			EndIf 
			If llIsTheSection
				If Upper(This.aIniFile(i)) = Upper(tcVariable)
					If lnEqual>0 And lnEqual < Len(This.aIniFile(i))
						lcReturn = Substr(This.aIniFile(i),lnEqual+1)
					EndIf 
					Exit 
				EndIf 
			EndIf 
		EndFor 

		Return lcReturn

	Else
		Local loError As rrException
		loError = NewObject( "rrException", "rrException.prg" )
		loError.Set( 9999, Upper(tcIniFileName) + " file could not be loaded.", Program(), "taIniReader.Prg" )
		loError.Throw()
	EndIf 

EndProc 

Procedure ReleaseIniFile() As Void
	This.nIniLines = 0
	This.aIniFile = Null
EndProc 

Procedure LoadIniFile(tcIniFileName As String) As Boolean 

	* Limpia el nombre del archivo
	tcIniFileName = Alltrim(tcIniFileName)

	* Si no tiene extensión, le agrega .INI
	If Empty(JustExt(tcIniFileName))
		tcIniFileName = tcIniFileName + ".INI"
	EndIf 

	If File(tcIniFileName)
		Local lcIniFile As String 
		lcIniFile = FileToStr(tcIniFileName)
		If This.lCaseSensitive
			* Case sensitive mode
		Else
			* Case insensitive mode, convert all to uppercase
			lcIniFile = Upper(lcIniFile)
		EndIf 
		This.nIniLines = ALines( This.aIniFile, lcIniFile )
		Return (This.nIniLines > 0)
	Else
		Local loError As rrException
		loError = NewObject( "rrException", "rrException.prg" )
		loError.Set( 9999, Upper(tcIniFileName) + " file not found.", Program(), "taIniReader.Prg" )
		loError.Throw()
	EndIf 

EndProc 

EndDefine 

* Fin de taIniReader Class


*------------------------------------------------------------------*
*------------------------------------------------------------------*
*------------------------------------------------------------------*


* Begin Class taIniReader Test Code

Function TryMyself

Text To cIniFile

[left]
path=C:\DEVELOP\

[right]
path=C:\SOURCE\

EndText 

StrToFile(cIniFile,"Test.Ini")

Clear

Local loTest As taIniReader Of taIniReader.Prg

Try

	loTest = NewObject( "taIniReader", "taIniReader.Prg" )

	loTest.lCaseSensitive = .F.  && Default Value
	loTest.LoadIniFile("Test")
	? "1 " + loTest.Readvalue("path","LEFT")  && Case Insensitive
	? "2 " + loTest.Readvalue("path","left]")
	? "3 " + loTest.Readvalue("path","[right")
	loTest.ReleaseIniFile()

	loTest.lCaseSensitive = .T.
	loTest.LoadIniFile("Test")
	? "4 " + loTest.Readvalue("path","[LEFT]")  && Case Sensitive
	? "5 " + loTest.Readvalue("path")
	? "6 " + loTest.Readvalue("path","[right]")
	loTest.ReleaseIniFile()

Catch To oErr
	Stop(ParseError(oErr))
Finally
	loTest = Null
	Erase Test.Ini
EndTry 

Return

EndFunc 
* End Class taIniReader Test Code
*------------------------------------------------------------------*
*------------------------------------------------------------------*
*------------------------------------------------------------------*
