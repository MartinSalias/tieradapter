*------------------------------------------------------------------*
* Author........: Martín Salías
* Date..........: 06/12/2001
*)Notes.........: Basic application class
*)              : Usually subclassed in every project
* See also......:
*
Define Class msApp As Session OlePublic

	lDebugMode	= .F.	&& Indicates if running in debug (development) mode
	lSplash		= .T.	&& If there is a splash screen
	lDesktop	= .T.	&& If there is a desktop (with a main menu)
	lAppLogo	= .T.	&& If there is an aplication logo for the screen
	lForcedExit = .F.   && Forces to exit the application - See method Exit() of This

	cAppName	= "Application"
	cVersion	= "alpha"
	cAppIcon	= "TierAdapter.ico"

	oUser        = Null
	oMainToolbar = Null
	oMenuBuilder = Null
	
	oReportManager = null

	cSplashClass = "msSplashScreen"
	cSplashClassLibrary = "..\Comun\msSplashScreen.vcx"

	cAppLogoClass = "AppLogo"
	cAppLogoClassLibrary = "..\Comun\AppLogo.Prg"
	
	cToolsMenu = "taMenu.mpr"
	cDeveloperMenu = "taDevelopTools.mpr"
	cTrailerMenu = "taTrailerMenu.mpr"
	
	nInitialWindowState = 2 && Maximized on startup

	*---------------- Constructor ----------------
	Function Init( tcAppName As String, tcVersion As String )

		* Este try atrapa todo error en el Init del objeto aplicación.
		Try

			With This

				.cAppName	= tcAppName
				.cVersion	= tcVersion

				* Sets debug or production mode
				.lDebugMode = Version( 2 ) > 0 And File( "debug.ini" )

				.SetPaths()
				.SetClassLibs()
				.SetEnvironment()
				.SetManagers()

				** MS, 30/06/2003: The screen should come invisible from config.fpw
				** _SCREEN.Visible = .F.
				_Screen.WindowState = .nInitialWindowState
				_Screen.Icon = .cAppIcon
				If .lDebugMode
				Else
					Set Sysmenu Off
				Endif
				.AppCaption()

				* Displays splash screen
				If .lSplash
					Local loSplash As Object
					loSplash = .SplashScreen()
				Endif

				_Screen.Visible = .T.

				.oMenuBuilder = Newobject( "taMenu", "taMenuVFP.prg" )

				* Displays user login screen
				.oUser = Newobject( "uoUser", "uoUser.prg", "", .DataSessionId )
				.oUser.ChkIfOneUserExist()
				.oUser.Login()

				* If there is a desktop, builds the menu and shows all
				If .lDesktop
					.BuildToolbar()
					.DesktopLogo()

					On Shutdown Clear Events
					Set Cursor On

				Else

					_Screen.Visible = .F.

				Endif

				* Este DO WHILE esta porque no puedo llamar al oApp.Exit() desde el objeto Menu
				* ya que este metodo Exit() destruye a ese objeto Menu, por lo tanto, el menu se
				* limita a hacer un CLEAR READS y luego se ejecuta el metodo oApp.Exit()
				Local llExit As Boolean
				llExit = .F.
				Do While Not llExit
					* Este try atrapa todo error no controlado en la aplicación.
					Try
						Read Events
						If _Screen.oApp.Exit()
							llExit = .T.
						Endif
					Catch To loErr
						Stop(ParseError(loErr))
					Finally
					Endtry
				Enddo

			Endwith

		Catch To oErr

			Stop(ParseError(oErr))
			_Screen.oApp.Exit(.T.)

		Finally

		Endtry

		Return .F.

	EndFunc

	*---------------- General Path Settings ----------------
	Protected Function SetPaths() as VOID 
		* Abstract method
	EndFunc

	*---------------- General ClassLib Settings ----------------
	Protected Function SetClassLibs() as VOID 

		* Custom Base Class Library
		Set Classlib To msBaseClass Additive
		Set Classlib To taCal Additive

		* Custom Function File (Grid member classes: msHeader / msColumn)
		Set Procedure To msBaseClass.prg Additive
	EndFunc

	
	*--------------- Set Manager objects --------------
	Protected Function SetManagers()
		this.oReportManager = this.ReportManagerFactory()
	EndFunc 	
	
	*-------------- Report Manager Factory ------------
	Protected Function ReportManagerFactory()
		Return NewObject( "NativeReportManager", "NativeReportManager.prg" )
	EndFunc 
	
	*---------------- Splash Screen ----------------
	Protected Function SplashScreen()

		Local loReturn

		If .lDebugMode
			* Skips splash screen
		Else
			loReturn = Newobject( .cSplashClass, .cSplashClassLibrary, ;
				"", .cAppName, .cVersion )
		Endif

	EndFunc


	*---------------- Set basic environment settings ----------------
	Function SetEnvironment()

		* Private DataSession Settings
		This.PrivateSettings()

		If This.lDebugMode
			Set Asserts On
			Set Notify	Cursor	On
		Else
			Set Asserts Off
			Set Notify	Cursor	Off
		Endif

		Set TablePrompt Off
		Set Escape		Off
		Set Notify		Off
		Set Cursor		Off
		Set Headings	Off
		Set Exclusive	Off
		Set Exact		Off
		Set Safety		Off

		Set Near		On
		Set Textmerge	On
		Set Bell		On

		Set Memowidth	To 100
		Set Reprocess	To   2
		Set Hour		To  24
		Set Date 		To Dmy

	EndFunc

	*---------------- Private DataSessions Settings ----------------
	Function PrivateSettings()

		Set Echo		Off
		Set Talk		Off
		Set Safety		Off

		Set Confirm		On
		Set Deleted		On
		Set Near		On
		Set Multilocks	On
		Set Century		On

		Set Message		To ""

		* Local settings
		* ##MS Have to be read from a config file (or Windows settings)
		Set Century		To 19 rollover 50
		Set Point		To ","
		Set Separator	To "."
		Set Date		To Dmy

	EndFunc


	*---------------- Application Caption ----------------
	Function AppCaption()

		With This
			If .lDesktop
				Local lcCaption As String
				lcCaption = Alltrim( .cAppName ) ;
					+ " - v" + .cVersion ;
					+ Iif( Vartype( .oUser ) = "O", "   [" + .oUser.cName +"]" , "" )
				_Screen.Caption = lcCaption
			Endif
		Endwith

	EndFunc

	*---------------- Main Menu ----------------
	Function BuildMenu( tcMenuName As String )

		With This

			If .lDebugMode
				* Keeps the System Menu
			Else
				Do BlankMenu.mpr
			Endif
			
			If Empty( .cToolsMenu )
			Else 
				Do ( .cToolsMenu )
			EndIf 

			If Empty( tcMenuName )
			Else 
				This.oMenuBuilder.BuildMenu( tcMenuName )
			Endif

			If .lDebugMode and !Empty( .cDeveloperMenu )
				Do ( .cDeveloperMenu )
			Endif

			If Empty( .cTrailerMenu )
			Else 
				Do ( .cTrailerMenu )
			EndIf 
		Endwith

	EndFunc

	*---------------- Main Toolbar----------------
	Function BuildToolbar()

		If .lDebugMode
			* Keeps the Standard Toolbar
		Else
			If Wexist( "standard" )
				Hide Window standard
			Endif
		Endif

		If Vartype( .oMainToolbar ) # "O"
			.oMainToolbar = Newobject( "msMainToolbar", "..\Comun\msMainToolbar.vcx" )
			With .oMainToolbar
				.Dock(0)
				.Show()
			Endwith
		Endif

	EndFunc

	*---------------- Displays desktop logo ----------------
	Function DesktopLogo()

		If .lAppLogo
			With _Screen

				If Vartype( .oAppLogo ) = "O"
					* Already exists
				Else
					_Screen.Newobject( "oAppLogo", This.cAppLogoClass, This.cAppLogoClassLibrary )
				Endif
				.oAppLogo.Visible = .T.
			Endwith
		Endif

	EndFunc

	*----------------- Exit point ---------------
	Function ExitHook() As Boolean
		Local lnFormCount As Integer, oForm As Form
		lnFormCount = 0
		For Each oForm In _Screen.Forms
			If oForm.BaseClass = "Form"
				Do Case
				Case oForm.Caption = "Toolbox"
				Case oForm.Caption = "Report Preview"
				Otherwise 
					lnFormCount = lnFormCount + 1
					If This.lDebugMode
						Local lcWontop As String 
						lcWontop = Wontop()
						Activate Screen 
						If lnFormCount = 1
							? "Open forms:"
						EndIf 
						? Transform(lnFormCount) + [- ]+ oForm.Caption
						If Not Empty(lcWontop)
							Activate Window (lcWontop)
						EndIf 
					EndIf 
				EndCase 
			EndIf 
		EndFor
		
		Local llRetVal As Boolean
		If lnFormCount = 0
			llRetVal = .T.
		Else
			llRetVal = Confirm( "There are open forms in the application." ;
				+ Chr(13) ;
				+ "If you shutdown, uncommited changes may be lost." ;
				+ Chr(13) + Chr(13) ;
				+ "Continue?" )
			This.lForcedExit = llRetVal
		Endif
		Return llRetVal
	EndFunc

	*----------------- Exit point ---------------
	Function Exit( tlForced As Boolean ) As Boolean

		This.lForcedExit = tlForced  && See method QueryUnload() in msActionForm.

		* Exit forced or by user confirmation
		Local llReturn
		llReturn = tlForced ;
			Or ( Confirm( "Exit the aplication?" ) ;
			And This.ExitHook() )

		If llReturn

			* El siguiente "Release Windows" se coloca dentro de un loop porque
			* por ejemplo, si cuando un msActionForm ha llamado a un Selector
			* (este último es Modal) se intenta salir de la aplicación y por lo
			* tanto se ejecuta un "Release Windows", este comando intentará cerrar
			* primero el msActionForm y no podrá hacerlo porque el Selector lo
			* impide. Luego, si es liberado el Selector. En el segundo loop, al
			* no existir ya el Selector, si se libera al msActionForm.
			* El contador está para prevenir "dead loops" en caso de no poder resolver
			* la referencia cruzada explicada anteriormente.
			lnOldCount = 0
			Do While lnOldCount # _Screen.FormCount
				lnOldCount = _Screen.FormCount
				Release Windows
			Enddo
			This.Destroy()

		Endif

		Return llReturn

	EndFunc

	*---------------- Destructor ----------------
	Function Destroy

		This.oMainToolbar = Null
		This.oMenuBuilder = Null
		This.oUser        = Null

		Clear Events
		On Shutdown

		If This.lDebugMode
			Set Sysmenu To Default
			If Wexist( 'standard' )
				Show Window standard
			Endif
		Endif

		If Version(2) = 0	&& Running on runtime
			Close Databases All
			Set Library To
			Quit
		Endif

	EndFunc

	*---------------- Configuration handler ----------------
	* tcParameter - Nombre del parámetro del que se quiere recuperar el valor guardado
	* tcSection   - Segundo nivel de agrupamiento de los parámetros (Opcional)
	* tcDomain    - Nivel máximo de agrupamiento de los parámetros (Opcional)
	Function ReadConfiguration( tcParameter As String, tcSection As String, tcDomain As String )

		Assert Vartype( tcParameter ) = "C"                   Message "tcParameter should be a string"
		Assert Inlist( Vartype( tcSection ), "C", "L" , "X" ) Message "tcSection should be a string o Null"
		Assert Inlist( Vartype( tcDomain ), "C", "L" , "X" )  Message "tcDomain should be a string o Null"

		Local lcReturn As String
		lcReturn = ""

		If Empty( tcParameter )
		Else
			Try
				Xmltocursor( "Configuration", "cConfiguration", 4+512 )
			Catch
				Assert .F. Message "Can't read from XML configuraction file"
			Endtry

			If Used( "cConfiguration" )
				Select cConfiguration
				Try
					Local lcForCondition As String
					lcForCondition = "Upper( cParameter ) = " + Upper( Alltrim( tcParameter ) )
					If Not IsEmpty( tcSection )
						lcForCondition = lcForCondition = " And Upper( cSection ) = " + Upper( Alltrim( tcSection ) )
					Endif
					If Not IsEmpty( tcDomain )
						lcForCondition = lcForCondition + " And Upper( cDomain ) = " + Upper( Alltrim( tcDomain ) )
					Endif
					Locate For &lcForCondition
					If Found()
						lcReturn = Alltrim( cConfiguration.cValue )
					Endif
				Catch
					Assert .F. Message "Couldn't search on the configuration cursor"
				Endtry

				Use In cConfiguration
			Endif
		Endif

		Return lcReturn
	EndFunc

	*---------------- Custom Assertion ----------------
	Function Assert( tcMessage As String, tlLog As Boolean ) As VOID

		tcMessage = Iif( Empty( tcMessage ), "", tcMessage ) ;
			+ Chr(13) + Chr(13) + "Suspend and Debug?"

		If This.lDebugMode
			Local lnOption As Number
			lnOption = Messagebox( tcMessage, 3+32, "Debugging assertion" )

			Do Case
			Case lnOption = 6 && Yes
				Debug
				Suspend
			Case lnOption = 2 && Cancel
				Cancel
			Endcase
		Else
			* TODO: Log the message
		Endif

	Endfunc

Enddefine
*------------------------------------------------------------------*
