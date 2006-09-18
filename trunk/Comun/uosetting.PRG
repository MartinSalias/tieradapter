* RR, 14/08/2004
* Entity: Setting
* Tier: User
* 
Define Class uoSetting AS uoSystem of uoSystem.prg

cTierClass  = "boSetting"     && Nombre de la clase con los que hace la instanciación.

cSelectorFields = "cDomain, cSection, cParameter, IdSetting"
cSelectorCaptions = "Domain, Section, Parameter, Setting"

cFormName = "Setting"

EndDefine 
