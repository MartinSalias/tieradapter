*!* Program: DemoApp
*!* Author: Martin Salias
*!* Date: 06/14/04 12:30:37 AM
*!* Copyright: 2004, Salias & Rovira
*!* Description: Application Objects Subclass for this project
*!* Revision Information: 1.0 Base level subclass

Define Class DemoApp As msApp Of ..\comun\msApp.prg

	cSplashClass = "DemoSplashScreen"
	cSplashClassLibrary = "source\DemoSplashScreen.vcx"

	cAppLogoClass = "DemoLogo"
	cAppLogoClassLibrary = "Source\DemoLogo.Prg"

	nInitialWindowState = 2 && Maximized

Enddefine
