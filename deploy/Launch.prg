****************************************************************************
*  Launch.prg   
*  -- Web Connection Application Launch Helper
**********************************************************
***  This is an optional tool to help you launch Web Connection
***  applications more easily. It's completely optional but makes
***  easier to launch especially modes that require starting up support
***  applications like IISExpress and/or Browser sync.
***
***  You can still do:   
***
***        DO WebdemoMain.prg 
***
***  and then manually switch to a browser and or start IISExpress
***  or BrowserSync manually.
***
***  Function: Launches a Web Connection Server in various modes
***            and opens a Web page to the appropriate Web location.
*** 
***      Pass:  lcType:         "IIS"
***                             "IISEXPRESS"
***                             "WEBCONNECTIONWEBSERVER" or "DOTNETCORE"
***                             "SERVER" or "NONE"
*** 
***             llNoBrowser:    If .T. doesn't open a browser window
*** 
***  Examples:
*** 
***  LAUNCH()                         - Launches IIS and opens browser
***  LAUNCH("IISEXPRESS")             - Launches IIS Express & opens browser
***  LAUNCH("WEBCONNECTIONWEBSERVER") - Launches local .NET Core Web Server
***  LAUNCH("IIS",.T.)                - Launch IIS and don't open browser 
***  LAUNCH("SERVER")                 - Just launch the Server
*********************************************************************************
LPARAMETER lcType, llNoBrowser
LOCAL lcUrl, lcLocalUrl, lcAppName, lcFiles, lcWcPath, lcVirtual,;
      lnIISExpressPort, lnWebConnectionWebServerPort
      
*** Project Names
lcVirtual = "WebDemo"     && used only for IIS
lcAppName = "Webdemo"

lcWcPath = ADDBS("C:\WEBCONNECTION\FOX\")
lcWebPath = LOWER(FULLPATH("..\web"))   && path to Web files 
lcDotnetServerPath = lower(FULLPATH("..\WebConnectionWebServer\"))
llUseSsl = .F.   &&  hard-code. Web Connection Web Server only

*** Change these defaults for plain `Launch()` operation
lcServerType = "IIS7HANDLER"
if (lcServerType == "IIS7HANDLER")
   lcServerType = "IIS"
ENDIF   
lnIISExpressPort = 7000
lnWebConnectionWebServerPort = 5200

lcServerCommand = ""
lcIisDomain = "localhost"

IF EMPTY(lcType)
   lcType = lcServerType
ENDIF
lcType = UPPER(lcType)
DO CASE 
   CASE lcType = "IIS" 
   CASE lcType = "IISEXPRESS" OR lcType == "IE"     
      lcServerType = "IIS Express" 
   CASE lcType == "DOTNETCORE" OR lcType == "WEBCONNECTIONWEBSERVER" OR lcType = "WC"
      lcServerType = "WEBCONNECTIONWEBSERVER"
      lcType = "WEBCONNECTIONWEBSERVER"
   CASE lcType = "NONE" OR lcType = "SERVER" OR lcType == "N"
      lcServerType = "NONE"
      llNoBrowser = .T.
      lcType = "IIS"  && doesn't launch anyting
   CASE lcType = "HELP"
      DO Console WITH "GOURL","https://webconnection.west-wind.com/docs/_5h60q6vu5.htm#launch-modes"
      RETURN
ENDCASE

llNoBrowser = IIF(EMPTY(llNoBrowser),.f.,.t.)

CLEAR

********************************
*** SET UP ENVIRONMENT AND PATHS
********************************

*** Optionally release everything before you run
* RELEASE ALL
* SET PROCEDURE TO
* SET CLASSLIB TO

*** Reference Web Connection Folders 
*** so Web Connection Framework programs can be found
*** GENERATED BY PROJECT WIZARD: Change if paths change
SET PATH TO (lcWcPath + "classes") ADDITIVE
SET PATH TO (lcWcPath) ADDITIVE
SET PATH TO (lcWcPath + "tools") ADDITIVE


***********************************************************
*** START UP WEB SERVER (IIS Express and BrowserSync only)
***********************************************************
lcUrl = "http://localhost/" + lcVirtual
lcServerCommand = ""

IF lcType == "IISEXPRESS"
    *** Launch IIS Express on Port 7001
    DO CONSOLE WITH "IISEXPRESS",lcWebPath,lnIISExpressPort,"/","NONAVIGATE"    
    lcUrl = STRTRAN(lcUrl,"localhost/" + lcVirtual,"localhost:" + TRANSFORM(lnIISExpressPort) )
ENDIF
IF lcType == "IIS"
   IF !EMPTY(lcIisDomain)
       lcUrl = STRTRAN(lcUrl,"/localhost/","/" + lcIisDomain +"/")
   ENDIF
ENDIF
IF lcType == "WEBCONNECTIONWEBSERVER"
   DO CONSOLE WITH "WEBCONNECTIONWEBSERVER",lcWebPath,lnWebConnectionWebServerPort,"/",.t., llUseSsl
   lcUrl = STRTRAN(lcUrl,"localhost/" + lcVirtual,"localhost:" + TRANSFORM(lnWebConnectionWebServerPort))
ENDIF

IF(llUseSsl)
   lcUrl = STRTRAN(lcUrl,"http://","https://")
ENDIF

ACTIVATE SCREEN
CLEAR
lnOldFont = _Screen.FontName
lnOldFontSize =  _Screen.FontSize
_Screen.FontName = "Consolas"
_Screen.FontSize = 18


**********************
*** LAUNCH WEB BROWSER
**********************

IF EMPTY(lcServerType)
	lcServerType = "IIS"
	lcType = "IIS"
ENDIF	

? "Running:" 

IF lcServerType == lcType
  ? [Launch()]
ENDIF

DO CASE
CASE lcType == "WEBCONNECTIONWEBSERVER"
  ? [Launch("WEBCONNECTIONWEBSERVER")]
  lcServerType = ".NET Core Web Connection Web Server"
CASE ATC("IISEXPRESS",lcType) > 0 
  ? [Launch("IISEXPRESS")]
  lcServerType = "IIS Express"
OTHERWISE  
  ? [Launch("IIS")]
ENDCASE

? [* Web Servers    : "IIS","IISEXPRESS","WEBCONNECTIONWEBSERVER"]
? [* Fox Server only: "SERVER","NONE"           More info: "HELP"]

                     
? ""
? "Web Server used:"
? lcServerType 
?

IF lcType == "IISEXPRESS"
   ? "Launched IISExpress with:"
   ? [DO console WITH "IISExpress","..\Web",7000]
   ?
ENDIF
IF lcType == "WEBCONNECTIONWEBSERVER"
   ? "Launched .NET Core Web Server with:"
   ? lcServerCommand
   ?
ENDIF

IF !llNoBrowser
    DO CONSOLE WITH "GOURL",lcUrl
    ? "Launching Web Url:" 
    ? lcUrl
    ? 
ENDIF    

***************************************
*** LAUNCH FOXPRO WEB CONNECTION SERVER
***************************************

? "Server executed:"
? "DO " + lcAppName + "Main.prg"

*** Start Web Connection Server
DO ( lcAppName + "Main.prg")

RETURN