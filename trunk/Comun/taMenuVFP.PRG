*------------------------------------------------------------------*
* Author........: Ruben Rovira
* Date..........: 08/11/2003
* Parameters....: -
* Returns.......: -
* Notes.........: Standard Visual FoxPro menu builder.
*               : 
* See also......: -
*

Define Class taMenu AS Session

	Procedure Init
		Set Sysmenu To Default 
		Set Sysmenu Automatic 
		If _SCREEN.oApp.lDebugMode
		Else
			Set Sysmenu Off
		EndIf 
	EndProc 

	Procedure BuildMenu( tcMenuName As String ) As VOID
		With This
			If .ReadData( tcMenuName )

				Select * ;
				   From cItemsMenu ;
				   Where Empty( cCodeParent ) ;
				   Order By iOrder ;
				   Into Cursor cPads

				Local lcPad As String
				Scan
					lcPad = "MPAD" + Alltrim( Str( iOrder ) )
					lcSkip = Iif( Empty( cSkipFor ), "", "SKIP FOR " + Alltrim( cSkipFor ) )
					Define Pad ( lcPad  ) Of _MSYSMENU ;
					   Prompt Alltrim( cPads.cCaption ) ;
					   Color Scheme 3 ;
					   Message Alltrim( cPads.cStatus ) ;
					   &lcSkip
					This.BuildPopup( cPads.cCodeItem, lcPad, 0 )
					Select cPads
				EndScan 
				Use In cPads

				On Selection Popup All * 

			EndIf 
		EndWith 
	EndProc

	Procedure ReadData( tcMenuName As String ) As Boolean
		
		Local loMenuUserTier As Object, llRetVal As Boolean 

		loMenuUserTier = NewObject( "uoAccess", "uoAccess.prg", "", .DataSessionID )
*		llRetVal = loMenuUserTier.GetAll( "cType = 'MENU' And cModule = '" + Alltrim(tcMenuName) + "'" )
		llRetVal = loMenuUserTier.GetUserAccess( 'MENU', tcMenuName )
		If llRetVal
			Select * ;
				From cUserAccess ;
				Into Cursor cItemsMenu ;
				Order by cUserAccess.cCodeParent, cUserAccess.iOrder
		EndIf 
		Return ( llRetVal )

	EndProc

	Procedure BuildPopup( tcCodeParent As String, tcPadParent As String, tnBarParent As Integer )

		Select cItemsMenu
		Locate for cCodeParent == tcCodeParent

		If Found()

			Local lcPop As String
			lcPop = tcPadParent + "MPOP" + Alltrim( Str( iOrder ) ) + Transform( tnBarParent, "@L 999" )
			If tnBarParent = 0
				* Cuelga del menú principal.
				On Pad ( tcPadParent ) Of _MSYSMENU Activate Popup &lcPop
			Else 
				* Cuelga de un submenú.
				On Bar tnBarParent Of ( tcPadParent ) Activate Popup &lcPop
			EndIf 

			Define Popup ( lcPop ) Margin Relative Shadow Color Scheme 4

			Local lnBar As Integer, lcKey As String, ;
			      lcPic As String,  lcInv As String, ;
				  lcSkip As String, lnRec As Integer

			lnBar = 0

			Scan While cCodeParent = tcCodeParent

				lcKey  = Iif( Empty( cShortCut ), "", "KEY [" + Alltrim( cShortCut ) + Iif( Empty( cShortCutText ), "]", "], [" + Alltrim( cShortCutText ) + "]" ) )
				lcPict = Iif( Empty( cPicture ), "", Iif( Left( Alltrim( cPicture ), 1 ) = "_", "PICTRES ", "PICTURE " ) + Alltrim( cPicture ))
				lcInv  = Iif( iInverted=1, "INVERT", "" )
				lcSkip = Iif( Empty( cSkipFor ), "", "SKIP FOR " + Alltrim( cSkipFor ) )
				lnBar = lnBar + 1

				Define Bar lnBar Of ( lcPop ) ;
				   Prompt Alltrim( cCaption ) ;
				   &lcKey ;
				   &lcPict ;
				   Message Alltrim( cStatus ) ;
				   &lcInv ;
				   &lcSkip

				lnRec = Recno()
				This.BuildPopup( cCodeItem, lcPop, lnBar )	&& Define todos los popups de ese nivel para abajo.
				Go lnRec
				If lnBar > 0 AND Not Empty( cCommand )
					Local lcBarCommand As String
					lcBarCommand = Alltrim( cCommand )
					On Selection Bar lnBar Of ( lcPop ) &lcBarCommand 
				EndIf 

			EndScan 
	
		EndIf 

	EndProc 

EndDefine
