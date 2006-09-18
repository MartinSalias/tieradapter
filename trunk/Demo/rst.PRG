On Shutdown 
Clear All
clos all
clea reso
set sysmenu to defa
If Wexist('standard')
	Show Window standard
Endif
clear
Set Procedure To msbaseclass ADDITIVE
_SCREEN.Caption = "Visual FoxPro " + Str(Int(Version(5)/100),1,0) + " - Develop Mode"
_SCREEN.Icon = ""