#Include MS.h

Define Class MereReportManager As AbstractReportManager of AbstractReportManager.prg

	lToolbarPrint = .t.
	lToolbarPreview = .t.
	lToolbarExport = .t.
	lToolbarMail = .t.
	
	Protected cReportClauses
	cReportClauses = ""
	
	oMERE = Null
	oRPT = Null

	lDoNotShowMEREPreview = .T.  	&& DO NOT AUTOMATICALLY DISPLAY THE MERE PREVIEW
	lShowAsTopLevelForm = .F.
	lDynamicLineHeight = .T.

	nLanguageIndexID = 1 && 0=English, 1=Spanish

	*------------------------------------------------------------------
	Protected Function Init() As Boolean
		
		If DoDefault()
			Set Classlib To MindsEyeReportPreviewForms Additive
			Set Classlib To MERE_ReportListener Additive

			this.cAvailableFileTypes = this.cAvailableFileTypes + "|PDF"
		Else
			Return .f.
		EndIf 
	EndFunc 

	*------------------------------------------------------------------
	Protected Function GenerateOtherFileTypes( tcExtension as String ) as Boolean
		
		Do case
		Case tcExtension = "PDF"
			This.cTargetDevice = "PDF"
			this.GenerateReport()
		Otherwise
			Return .f.
		EndCase 
		
	EndFunc
	
	
	*------------------------------------------------------------------
	Function GenerateReport() as Boolean
		
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
		
		If This.lShowAsTopLevelForm Then
		   This.oRPT = CreateObject('MindsEyeReportPreviewTopLevelForm')
*		   This.oRPT = NewObject('taMEREPreviewTopLevelForm','taMERE_PreviewForms.vcx')
		Else 
		   This.oRPT = CreateObject('MindsEyeReportPreviewForm')
*		   This.oRPT = NewObject('taMEREPreviewForm','taMERE_PreviewForms.vcx')
		EndIf 

		With This.oRPT
			.Width = _SCREEN.Width - 100
			.Height = _SCREEN.Height - 100
			.AutoCenter = .T.
			With .oReportEngine
				.DisplayHelpButton = .F.
				.DisplayPageScroller = .F.
				.DisplayEmailButton = .F.
				.DisplayPDFButton = .F.
				.LanguageIndexID = This.nLanguageIndexID
				.DisplayLicenseInfo = .F.
			EndWith 
		EndWith 

		If Vartype(This.oRPT) = 'O' Then 
*		   This.oMERE = CreateObject('MERE_ReportListener',This.oRPT,This.lDoNotShowMEREPreview)
		   This.oMERE = NewObject('taMEREReportListener','taMERE_ReportListener.vcx','',This.oRPT,This.lDoNotShowMEREPreview)
		Else 
*		   This.oMERE = CreateObject('MERE_ReportListener',,This.lDoNotShowMEREPreview)
		   This.oMERE = NewObject('taMEREReportListener','taMERE_ReportListener.vcx','',,This.lDoNotShowMEREPreview)
		EndIf 
		
		With This.oMERE
		   .DynamicLineHeight = This.lDynamicLineHeight
		EndWith 

		* private variable to be used on Reports
		Private pnCopy As Integer, poPrintContext As Object 
		pnCopy = 1

		* poPrintContext está para referenciar dentro de un reporte al form actual
		* dado que no se puede utilizar Thisform.
		* Otra forma podría ser _SCREEN.oApp.oReportManager.CurrentContext
		poPrintContext = This.oCurrentContext

		Local llSuccess As Boolean 
		llSuccess = .t.
		Try
			For pnCopy = 1 to this.nCopies
				This.oMERE.nReportPlacement = Iif( pnCopy = 1, 0, 1 )  && (0 = NEW REPORT, 1 = APPEND REPORT, -1 = INSERT REPORT)  
				Select ( this.cDetailAlias )
				Report Form ( this.cReportName ) Object This.oMERE NoDialog 
			Next 
		Catch to loError
			llSuccess = .f.
			If _SCREEN.oApp.lDebugMode And Confirm( ParseError( loError ), "¿Suspend?" )
				Suspend 
			Else 
				Warning( "Missing or misconfigured report format:";
				 +CR+ this.cReportName )
				Exit
			EndIf
		Finally
		EndTry

		If llSuccess 

			Do Case 

				Case This.cTargetDevice = "PREVIEW"

*!*					This.oRPT.Show()	&& Modeless
					This.oRPT.Show(1)	&& Modal

				Case This.cTargetDevice = "PRINTER"

					This.oRPT.oReportEngine.PrintReport(-1)  && Prints to the Default Printer  

				Case This.cTargetDevice = "PDF"

					Local lcSaveAsFileName As String 
					lcSaveAsFileName = this.cSaveAsFileName
					This.oRPT.oReportEngine.SaveToPDF( &lcSaveAsFileName )

				Case This.cTargetDevice = "EMAIL"

					Local lcEventType As String, loEmailContext As Object 

					If PemStatus( This.oCurrentContext, "oEmailContext", 5 ) ;
					 And Vartype( This.oCurrentContext.oEmailContext ) = "O"
						loEmailContext = This.oCurrentContext.oEmailContext
					Else
						loEmailContext = NewObject( "GeneralEmailContext", "GeneralEmailContext.prg" )
					EndIf

					loEmailContext.Setup()

					If loEmailContext.Valid()
						This.CopyDataFromEmailContext(loEmailContext)
					    If This.oRPT.oReportEngine.SendMail() = 0
					    	Information( "El email ha sido enviado" )
					    Else
					    	Warning( "El email no pudo ser enviado" )
					    EndIf 
				    EndIf 

			EndCase 

		EndIf 

	EndFunc 

	Function CopyDataFromEmailContext( toEmailContext As Object ) As VOID
		With This.oRPT.oReportEngine 
			* Copy data from the EmailContext to the ReportEngine
		    .EmailFromAddress 			= toEmailContext.cSender
		    .EmailRecipients 			= toEmailContext.cRecipients
		    .EmailCCAddresses 			= toEmailContext.cCC
		    .EmailBCCAddresses 			= toEmailContext.cBCC
		    .EmailSubject 				= toEmailContext.cSubject
		    .EmailBody 					= toEmailContext.cBody
			.EmailMessagingType 		= toEmailContext.nMessagingType
		    .EmailSMTPHost 				= toEmailContext.cSMTPHost
			.EmailSMTPAuthorizationType = toEmailContext.nSMTPAuthorizationType
			.EmailSMTPUserID 			= toEmailContext.cSMTPUserID
			.EmailSMTPPassword 			= toEmailContext.cSMTPPassword
			.EmailReturnReceipt 		= toEmailContext.lReturnReceipt
		EndWith 
		Return
	EndFunc 

EndDefine 
