*------------------------------------------------------------------*
* Author........: Martín Salías
* Date..........: 06/12/2001
*)Notes.........: Splash screen
*)              : 
* See also......: 
*
DEFINE CLASS SplashScreen AS msForm

	Height = 300
	Width = 400
	Desktop = .T.
	ShowWindow = 2
	DoCreate = .T.
	BorderStyle = 0
	Caption = "Splash Screen"
	ControlBox = .F.
	HalfHeightCaption = .T.
	MinButton = .F.
	Movable = .F.
	MousePointer = 11
	Name = "frmSplash"
	
	ADD OBJECT cntFrame AS msContainer WITH ;
		Top = 20, ;
		Left = 20, ;
		Width = 355, ;
		Height = 240, ;
		BorderWidth = 3, ;
		ZOrderSet = 0, ;
		Name = "cntFrame"

	ADD OBJECT cntBorder AS msContainer WITH ;
		Top = 0, ;
		Left = 0, ;
		Width = 400, ;
		Height = 300, ;
		BorderWidth = 5, ;
		SpecialEffect = 0, ;
		ZOrderSet = 1, ;
		Name = "cntBorder"

	ADD OBJECT shpFrame AS msShape WITH ;
		Top = 10, ;
		Left = 10, ;
		Height = 280, ;
		Width = 380, ;
		ZOrderSet = 2, ;
		Name = "shpFrame"

	ADD OBJECT imgSplash AS msImage WITH ;
		Picture = ("Splash.jpg"), ;
		Height = 230, ;
		Left = 25, ;
		Top = 25, ;
		Width = 345, ;
		ZOrderSet = 3, ;
		Name = "imgSplash"

	ADD OBJECT lblAppName AS msLabel WITH ;
		FontItalic = .T., ;
		FontSize = 12, ;
		Caption = _Screen.oApp.cAppName, ;
		Left = 25, ;
		Top = 265, ;
		ForeColor = RGB(0,0,255), ;
		ZOrderSet = 4, ;
		Name = "lblAppName"

	ADD OBJECT lblVersion AS msLabel WITH ;
		AutoSize = .F., ;
		FontBold = .F., ;
		Caption = _Screen.oApp.cVersion, ;
		Height = 17, ;
		Left = 120, ;
		Top = 267, ;
		Width = 40, ;
		ZOrderSet = 5, ;
		Name = "lblVersion"

	ADD OBJECT txtAppName AS msTextBox WITH ;
		Alignment = 2, ;
		Value = _Screen.oApp.cAppName, ;
		Height = 20, ;
		Left = 170, ;
		MousePointer = 1, ;
		ReadOnly = .T., ;
		Top = 265, ;
		Width = 201, ;
		ZOrderSet = 6, ;
		Name = "txtAppName"


	PROCEDURE Unload
		*
	ENDPROC


	PROCEDURE Release
		*
	ENDPROC


	PROCEDURE Refresh
		*
	ENDPROC


	PROCEDURE QueryUnload
		*
	ENDPROC


	PROCEDURE LostFocus
		*
	ENDPROC


	PROCEDURE Load
		*
	ENDPROC


	PROCEDURE GotFocus
		*
	ENDPROC


	PROCEDURE Destroy
		*
	ENDPROC


	PROCEDURE Deactivate
		*
	ENDPROC


	PROCEDURE Activate
		*
	ENDPROC


	PROCEDURE Init
		
		with thisform

			.AutoCenter = .t.
			.Show()
		endwith
	ENDPROC

ENDDEFINE
*------------------------------------------------------------------*
