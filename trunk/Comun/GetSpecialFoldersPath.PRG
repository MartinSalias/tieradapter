*Test() && See Test code below - Uncomment to run the test!

* -------------------------------------------------------
Function GetSpecialFoldersPath
* -------------------------------------------------------
* Get the path to one of Windows Special folders
* such as the Desktop, Favorites, Fonts, Start-up, etc.  
* -------------------------------------------------------
* There are three solutions below:
*   1 - Using SHGetFolderPath In SHFolder.dll
*   2 - Using SHGetSpecialFolderPath In SHELL32.DLL
*   3 - Using Windows Script
* -------------------------------------------------------
* See: http://www.tek-tips.com/faqs.cfm?fid=4264
* -------------------------------------------------------

Lparameters tcFolderName As String, tcMethod As String

Local lcReturn As String 

Do Case
	Case tcMethod = "SHGetFolderPath"
		lcReturn = SHFolderMethod( CSIDL_Number(tcFolderName) )
	Case tcMethod = "SHGetSpecialFolderPath"
		lcReturn = SHELL32Method( CSIDL_Number(tcFolderName) )
	Otherwise
		lcReturn = WindowsScriptMethod( tcFolderName )
EndCase 

Return lcReturn

* -------------------------------------------------------
Function SHFolderMethod( tnFolderName As Number ) As String 

	Local lcFolderPath As String, lcReturn As String 
	lcFolderPath = Space(255)

	Declare Short SHGetFolderPath In SHFolder.Dll ;
		Integer hwndOwner, Integer nFolder, Integer hToken, ;
		Integer dwFlags, String @pszPath

	SHGetFolderPath(0, tnFolderName, 0, 0, @lcFolderPath)

	lcReturn = Alltrim(lcFolderPath)
	lcReturn = SubStr(lcReturn,1, Len(lcReturn)-1)
	Return lcReturn 

EndFunc 

* -------------------------------------------------------
Function SHELL32Method( tnFolderName As Number ) As String 

	Local lcFolderPath As String, lcReturn As String 
	lcFolderPath = Space(255)

	Declare SHGetSpecialFolderPath In SHELL32.Dll ;
		Long hwndOwner, ;
		String @cSpecialFolderPath, ;
		Long nWhichFolder

	SHGetSpecialFolderPath(0, @lcFolderPath, tnFolderName)

	lcReturn = Alltrim(lcFolderPath)
	lcReturn = SubStr(lcReturn,1, Len(lcReturn)-1)
	Return lcReturn 

EndFunc 

* -------------------------------------------------------
Function WindowsScriptMethod( tcFolderName As String ) As String 

	Local lcReturn As String, loWSHShell As Object 
	lcReturn = ""

	loWSHShell = CreateObject("WScript.Shell")
	If Type("loWSHShell") = "O"
    	 lcReturn = loWSHShell.SpecialFolders(tcFolderName)
	EndIf 
	Return lcReturn 

EndFunc 

* -------------------------------------------------------

Function CSIDL_Number
Lparameters tcFolderName

Local lxFolderName As Variant 
Do Case
	Case tcFolderName = "Desktop"
		lxFolderName = 0x0000		&& CSIDL_DESKTOP
	Case tcFolderName = "Favorites"
		lxFolderName = 0x0006		&& CSIDL_FAVORITES 	 		
	Case tcFolderName = "Fonts"
		lxFolderName = 0x0014		&& CSIDL_FONTS
	Case tcFolderName = "MyDocuments"
*		lxFolderName = 0x000c		&& CSIDL_MYDOCUMENTS
		lxFolderName = 0x0005		&& CSIDL_PERSONAL 
	Case tcFolderName = "NetHood"
		lxFolderName = 0x0013		&& CSIDL_NETHOOD
	Case tcFolderName = "PrintHood"
		lxFolderName = 0x001b		&& CSIDL_PRINTHOOD
	Case tcFolderName = "Programs"
		lxFolderName = 0x0002		&& CSIDL_PROGRAMS
	Case tcFolderName = "Recent"
		lxFolderName = 0x0008		&& CSIDL_RECENT
	Case tcFolderName = "SendTo"
		lxFolderName = 0x0009		&& CSIDL_SENDTO
	Case tcFolderName = "StartMenu"
		lxFolderName = 0x000b		&& CSIDL_STARTMENU
	Case tcFolderName = "Startup"
		lxFolderName = 0x0007		&& CSIDL_STARTUP
	Case tcFolderName = "Templates"
		lxFolderName = 0x0015		&& CSIDL_TEMPLATES
	Otherwise
		lxFolderName = 0
EndCase 
Return lxFolderName

****************************************************************************
****************************************************************************
****************************************************************************

Function Test As VOID

Clear
? "Carpeta Desktop"
? GetSpecialFoldersPath( "Desktop", "SHGetFolderPath" )
? GetSpecialFoldersPath( "Desktop", "SHGetSpecialFolderPath" )
? GetSpecialFoldersPath( "Desktop", "WindowsScript" )
?
? "Presione una tecla para seguir..."
Inkey(0)

Clear
? "Carpeta Favorites"
? GetSpecialFoldersPath( "Favorites", "SHGetFolderPath" )
? GetSpecialFoldersPath( "Favorites", "SHGetSpecialFolderPath" )
? GetSpecialFoldersPath( "Favorites", "WindowsScript" )
?
? "Presione una tecla para seguir..."
Inkey(0)

Clear
? "Carpeta Fonts"
? GetSpecialFoldersPath( "Fonts", "SHGetFolderPath" )
? GetSpecialFoldersPath( "Fonts", "SHGetSpecialFolderPath" )
? GetSpecialFoldersPath( "Fonts", "WindowsScript" )
?
? "Presione una tecla para seguir..."
Inkey(0)

Clear
? "Carpeta MyDocuments"
? GetSpecialFoldersPath( "MyDocuments", "SHGetFolderPath" )
? GetSpecialFoldersPath( "MyDocuments", "SHGetSpecialFolderPath" )
? GetSpecialFoldersPath( "MyDocuments", "WindowsScript" )
?
? "Presione una tecla para seguir..."
Inkey(0)

Clear
? "Carpeta NetHood"
? GetSpecialFoldersPath( "NetHood", "SHGetFolderPath" )
? GetSpecialFoldersPath( "NetHood", "SHGetSpecialFolderPath" )
? GetSpecialFoldersPath( "NetHood", "WindowsScript" )
?
? "Presione una tecla para seguir..."
Inkey(0)

Clear
? "Carpeta PrintHood"
? GetSpecialFoldersPath( "PrintHood", "SHGetFolderPath" )
? GetSpecialFoldersPath( "PrintHood", "SHGetSpecialFolderPath" )
? GetSpecialFoldersPath( "PrintHood", "WindowsScript" )
?
? "Presione una tecla para seguir..."
Inkey(0)

Clear
? "Carpeta Programs"
? GetSpecialFoldersPath( "Programs", "SHGetFolderPath" )
? GetSpecialFoldersPath( "Programs", "SHGetSpecialFolderPath" )
? GetSpecialFoldersPath( "Programs", "WindowsScript" )
?
? "Presione una tecla para seguir..."
Inkey(0)

Clear
? "Carpeta Recent"
? GetSpecialFoldersPath( "Recent", "SHGetFolderPath" )
? GetSpecialFoldersPath( "Recent", "SHGetSpecialFolderPath" )
? GetSpecialFoldersPath( "Recent", "WindowsScript" )
?
? "Presione una tecla para seguir..."
Inkey(0)

Clear
? "Carpeta SendTo"
? GetSpecialFoldersPath( "SendTo", "SHGetFolderPath" )
? GetSpecialFoldersPath( "SendTo", "SHGetSpecialFolderPath" )
? GetSpecialFoldersPath( "SendTo", "WindowsScript" )
?
? "Presione una tecla para seguir..."
Inkey(0)

Clear
? "Carpeta StartMenu"
? GetSpecialFoldersPath( "StartMenu", "SHGetFolderPath" )
? GetSpecialFoldersPath( "StartMenu", "SHGetSpecialFolderPath" )
? GetSpecialFoldersPath( "StartMenu", "WindowsScript" )
?
? "Presione una tecla para seguir..."
Inkey(0)

Clear
? "Carpeta Startup"
? GetSpecialFoldersPath( "Startup", "SHGetFolderPath" )
? GetSpecialFoldersPath( "Startup", "SHGetSpecialFolderPath" )
? GetSpecialFoldersPath( "Startup", "WindowsScript" )
?
? "Presione una tecla para seguir..."
Inkey(0)

Clear
? "Carpeta Templates"
? GetSpecialFoldersPath( "Templates", "SHGetFolderPath" )
? GetSpecialFoldersPath( "Templates", "SHGetSpecialFolderPath" )
? GetSpecialFoldersPath( "Templates", "WindowsScript" )
?
? "Presione una tecla para seguir..."
Inkey(0)

Return

****************************************************************************
