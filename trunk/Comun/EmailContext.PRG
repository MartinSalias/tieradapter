Define Class EmailContext As Session
	
	DataSession = 1

	cSender = ""
	cRecipients = ""
	cCC = ""
	cBCC = ""
	cSubject = ""
	cBody = ""
	_Memberdata = [<VFPData>]+;
            + [<memberdata name="csender"       type="property" display="cSender"/>]+;
            + [<memberdata name="crecipients"   type="property" display="cRecipients"/>]+;
            + [<memberdata name="ccc"           type="property" display="cCC"/>]+;
            + [<memberdata name="cbcc"          type="property" display="cBCC"/>]+;
            + [<memberdata name="csubject"      type="property" display="cSubject"/>]+;
            + [<memberdata name="cbody"         type="property" display="cBody"/>]+;
            + [<memberdata name="addattachment" type="method"   display="AddAttachment"/>]+;
            + [</VFPData>]

	nMessagingType = 0              && 0=SMTP or 1=MAPI
    cSMTPHost = ""                  && (Optional) Name or IP Address of the SMTP Host Email Server. 
	nSMTPAuthorizationType = 0      && Set to 1 if authorization is required.
	cSMTPUserID = ""
	cSMTPPassword = ""
	lReturnReceipt = .F. 			&& Specifies that a Return Receipt will be requested.

	oAttachements = Null
	
	*---------------------------------------------
	Protected Function Init() As Boolean
		
		If DoDefault()
			oAttachements = NewObject( "taCollection", "taCollection.prg" )
		Else
			Return .f.
		EndIf 
	EndFunc
	
	*---------------------------------------------
	Protected Function AddAttachment( tcFileName as String ) As Boolean
		
		If File( tcFileName )
			this.oAttachements.Add( tcFileName )
		Else
			Return .f.
		EndIf 
		
	EndFunc

EndDefine 
