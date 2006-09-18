*------------------------------------------------------------------*
* Author........: Martín Salías
* Date..........: 06/12/2001
*)Notes.........: Logo application
*)              : Subclass it to indicate logo characteristics
* See also......:
*
Define Class AppLogo As msImage

	Picture = ""
	BackStyle = 0
	BorderStyle = 0
	Stretch = 1
	Anchor = 12  && Right and bottom absolute
	
	* 0 = Centered
	* 1 = Bottom right
	nPosition = 0
	
	Function Init() as Boolean 
		
		Bindevent(_Screen,"Resize",This,"Redraw")
		This.Redraw()
	EndFunc 
	
	Function Redraw() as VOID 
		
		Do case
		Case this.nPosition = 0
			This.Left = (_Screen.Width/2) - ( This.Width/2)
			This.Top = (_Screen.Height/2) - ( This.Height/2)
			
		Case this.nPosition = 1
			This.Left = _Screen.Width - ( This.Width + 30 )
			This.Top = _Screen.Height - ( This.Height + 30 )
		EndCase 
	EndFunc 

Enddefine

*------------------------------------------------------------------*
