; This is a test application.  It will run with only Skeleton.dll, it
; does not need Skeleton.lib
.386
.model flat,stdcall
option casemap:none

include windows.inc
include user32.inc
include kernel32.inc

includelib kernel32.lib
includelib user32.lib

.data
LibName				db "skeleton.dll",0
FunctionName		db "TestHello",0
DllNotFound			db "Cannot load library",0
AppName				db "Load Library",0
FunctionNotFound	db "TestHello function not found",0

.data?
hLib 			dd ?
TestHelloAddr	dd ?

.code
start:
        invoke LoadLibrary,addr LibName
        .if eax==NULL
                invoke MessageBox,NULL,addr DllNotFound,addr AppName,MB_OK
        .else
                mov hLib,eax
                invoke GetProcAddress,hLib,addr FunctionName
                .if eax==NULL
                        invoke MessageBox,NULL,addr FunctionNotFound,addr AppName,MB_OK
                .else
                        mov TestHelloAddr,eax
                        call [TestHelloAddr]
                .endif
                invoke FreeLibrary,hLib
        .endif
        invoke ExitProcess,NULL
end start
