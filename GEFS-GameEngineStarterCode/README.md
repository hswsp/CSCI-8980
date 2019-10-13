Building Guideline
===========================

Dependent Library
-----------------------
You must first install the SDL2 Libraries for your system.

For getting started, I like the tutorials here: [https://lazyfoo.net/tutorials/SDL/01_hello_SDL/](https://lazyfoo.net/tutorials/SDL/01_hello_SDL/), but to summarize:

Linux:
```
  apt install libsdl2-dev
```
Mac OS X:

 -Download Mac OS X Development Libraries (not the runtime libraries!):  
 
 [http://www.libsdl.org/download-2.0.php#source](http://www.libsdl.org/download-2.0.php#source)
    
 -Open the .dmg file, move SDL2.framework to /Library/Frameworks
 
   If you need help finding /Library/Frameworks you can press cmd-shift-g in finder a type it in
   
 -You may be asked to sign the lib if so:
 
 Goto /Library/Frameworks/SDL2.framework/ in terminal
 
 Type: ```codesign -f -s - SDL2```

Windows:

-Download Windows Development Libraries (not the runtime libraries!):  

[http://www.libsdl.org/download-2.0.php#source](http://www.libsdl.org/download-2.0.php#source)

-Open the .zip file and place it in a known directory. The cmake files here assume the contents of the folder are placed in the C:/SDL2/ directory.

-Place the file SDL2.dll in the GEFS-GameEngineStarterCode/GEFS/ directory (where the executable will be built to) or in C:\WINDOWS\SYSTEM32 (for 32 bit builds) or C:\Windows\SysWOW64 (for 64 bit builds). It just needs to be in one of these locations.

-If you unzipped the content of SDL2 somewhere besides C:/SDL2/, then update lines 27 and 28 of the file CMakeLists.txt 

Compile & Run - All Systems
-------------------------------
After you finish the above steps go to GEFS-GameEngineStarterCode/build/ directory in the terminal. Now run:
```
  cmake ..   
```  
or for win64
```
  cmake -G "Visual Studio 15 2017 Win64" ..   
```  
Then, for Linux or OS X command line, run make
```
  make
```  
Or for MS Visual Studios or X Code compile by selecting build from the menu.

Lastly, in a terminal, navigate  to the directory  GEFS-GameEngineStarterCode/GEFS/ and run:
```
   ./engine SimpleExample/ [Linux or OS X command line]
   
  Debug/engine.exe SimpleExample/ [Windows MSVS]
  
  ./Debug/engine SimpleExample/ [X Code]
 ```   
