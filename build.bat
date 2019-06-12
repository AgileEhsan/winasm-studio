cls
set INCLUDE=C:\masm32\include
set LIB=C:\masm32\lib
set LIBPATH=C:\masm32\lib
set MASM=C:\masm32\bin
set PATH=C:\masm32\bin;%PATH%

if exist WinAsm.exe 	del WinAsm.exe
if exist WinAsm.obj 	del WinAsm.obj
if exist Resource.res	del Resource.res
if exist Resource.obj	del Resource.obj 

rc /v /I%INCLUDE% Resource.rc
cvtres /machine:ix86 Resource.RES
ML /c /coff /Cp /nologo /Fm /Zi /Zd /I%INCLUDE% WinAsm.asm
ML /c /coff /Cp /nologo /Fm /Zi /Zd /I%INCLUDE% modMisc.asm
ML /c /coff /Cp /nologo /Fm /Zi /Zd /I%INCLUDE% modFileIO.asm
Link  /SUBSYSTEM:WINDOWS /DEBUG /VERSION:4.0 "/LIBPATH:%LIBPATH%" WinAsm.obj modMisc.obj modFileIO.obj Resource.res

if exist WinAsm.obj  	 del WinAsm.obj
if exist Resource.obj	 del Resource.obj
if exist Resource.res	 del Resource.res
pause