Define Class msColumn As Column

	FontSize = 8

	HeaderClass = "msHeader"
	HeaderClassLibrary = "msBaseClass.prg"

	Procedure Init()
		If This.ControlCount >= 2
			* Setea el FontSize del TextBox asociado con la columna.
			* Atención: ControlCount es cero si los TextBox de cada una
			* de las columnas de la grilla se definen explicitamente ( Grid.ColumnCount # –1 )
			This.Controls[2].FontSize = This.FontSize
		EndIf 
	EndProc 

EndDefine 

Define Class msHeader As Header

	Alignment = 2 && Middle Center
	FontSize = 8
	nCurrentColumn = 0   && Ultimo numero de columna clickeada en el header por el usuario
	cCurrentOrder = ""   && ASCENDING / DESCENDING

	Function Click()
		This.cCurrentOrder = This.NextOrder()
		This.OrderIt()
	EndFunc 

	Function NextOrder() As String 
		Return Iif( This.cCurrentOrder # [ASCENDING], [ASCENDING], [DESCENDING] )
	EndFunc 

	Function OrderIt() AS VOID 
		Local lcThisColumnName As String, loColumn As Column, lnColumn As Integer 

		If This.IndexIt()

			*... switch the FontBold, FontUnderline and Picture properties
			lcThisColumnName = This.Parent.Name
			lnColumn = 1
			For Each loColumn In This.Parent.Parent.Columns
				If loColumn.Name = lcThisColumnName
					* Set Bold and Picture for this header, normal for any others.
					loColumn.Controls[1].FontBold = .T.
					If This.cCurrentOrder = [ASCENDING]
						loColumn.Controls[1].Picture = 'UPARROW.BMP'
					Else
						loColumn.Controls[1].Picture = 'DNARROW.BMP'
					EndIf 
					This.nCurrentColumn = lnColumn 
				Else 
					loColumn.Controls[1].FontBold = .F.
					loColumn.Controls[1].Picture = ''
				EndIf 
				lnColumn = lnColumn + 1 
			Next
			
			* If succesfully reordered, restores the record pointer
			Locate 
			This.Parent.Parent.AutoFit()
			This.Parent.Parent.Refresh()

		EndIf 
	EndFunc 

	Function IndexIt() As Boolean 
		Local llSuccess As Boolean, lcExpression As String
		llSuccess = .T.
		Try
			lcExpression = This.Parent.ControlSource  && Campo al que está boundeada la columna.
			* Always index strings on uppercase
			If Type(lcExpression) = "C"
				lcExpression = "Upper(" + lcExpression + ")"
			EndIf 
			lcExpression = "Index On " + lcExpression + " Tag SelOrder " + This.cCurrentOrder 
			&lcExpression 
		Catch To oError
			llSuccess = .f.
			* Los Asserts solo se ven en tiempo de desarrollo.
			Assert .f. message "Indexing failed !" + ParseError( oError )
		EndTry
		Return llSuccess
	EndFunc 

EndDefine 
