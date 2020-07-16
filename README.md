# Web Connection Step By Step Samples

This repository contains the fully completed samples for the [Step By Step guides in the West Wind Web Connection documentation](http://www.west-wind.com/webconnection/docs/?page=_0nb1al6fm.htm).


* **[Step by Step: Getting Started](http://www.west-wind.com/webconnection/docs/?page=_0nb1al6fm.htm)**  
This is the basic walk-through of using Web Connection to get started, create a new project and run a number of data operations using mostly code based logic.

## Setup
To set up this project you'll need to:

* Clone or Download this project
* Fix the Startup Shortcut
* Make sure your Web Server is configured

### Clone or Download the project
If you have Git installed the easiest way to get the project is to clone it. 

To clone the project into the `WebConnectionProjects` folder:

```ps
cd \WebConnectionProjects
git clone https://github.com/RickStrahl/WebConnection-WebDemo.git WebDemo
```

Alternately you can use the GitHub **Download as Zip File** button to download the zip file and unpack in this folder:

```ps
\WebConnection\WebDemo
```

The location can be anywhere, but that's the default location for projects where Web Connection creates new projects.

### Fix the Startup Shortcut
It's important that you start FoxPro in the correct folder, so that `config.fpw` can set up the environment properly. The easiest way to do this is to fix the Shortcut `Webdemo - Start FoxPro IDE with Web Connection`.

* Target    
 **c:\program files (x86)\Microsoft Visual FoxPro\vfp9.exe  -c"c:\webconnectionprojects\webdemo\deploy\config.fpw"**
* Start in    
 **c:\webconnectionprojects\webdemo\deploy**

Adjust the paths as needed to point at `VFP9.exe` and the location of the `config.fpw` file and the `Deploy` folder.

Start FoxPro using this shortcut.

### Configure the Web Server
Depending on what Web Server you use you'll need to configure the application.

#### IIS
IIS requires a bunch of configuration, but it's automated. To do this:

* Launch FoxPro from the Shortcut using **Run As Administrator**
* `DO WebDemo_ServerConfig`

This runs the local server configuration that creates a virtual directory, sets various IIS site settings and directory permissions. 

To use IIS:

```foxpro
Launch("IIS")

Launch()   && Default for install
```

#### IIS Express
IIS Express doesn't require any special configuration but make sure IIS Express is installed.

[Download IIS Express](https://www.microsoft.com/en-us/download/details.aspx?id=48264)

To use IIS Express:  

```foxpro
launch("IISEXPRESS")
```

#### Web Connection Web Server
The built-in Web Connection Web Server is a new self-contained Web Server. And while it `just works` you need to make sure you have the Dotnet Core SDK installed.

[Install the Dotnet Core SDK](https://dotnet.microsoft.com/download) <small>(choose .NET Core SDK)</small>

```foxpro
Launch("WebConnectionWebServer")
```

#### Set the Default Web Server
The application is set up for full IIS. You can change the default that is used when you call `Launch()` without parameters.

To do this open `Launch.prg` and change the following line near the top:

```foxpro
lcServerType = "WEBCONNECTIONWEBSERVER"  && "IIS", "IISEXPRESS", "IISHANDLER"
```

Once changed you can then just use `Launch()` with the server you want to use.

## Start the Application
To run the application, make sure you start FoxPro in the `Deploy` folder of the project - preferrably using the shortcut as mentioned above.

From the IDE

```foxpro
Launch()
```

This should launch:

* The FoxPro Server
* The Web Server if it's not running (IISEXPRESS and WEBCONNECTIONWEBSERVER)
* Opens the Web Browser to the Web site

You're good to go!