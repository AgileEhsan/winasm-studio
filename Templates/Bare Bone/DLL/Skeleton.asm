.386

.MODEL flat,stdcall

OPTION CASEMAP:NONE

Include windows.inc
Include user32.inc
Include kernel32.inc

IncludeLib user32.lib
IncludeLib kernel32.lib

.DATA

AppName			db "DLL Skeleton",0
HelloMsg		db "Hello, you're calling a function in this DLL",0
LoadMsg			db "The DLL is loaded",0
UnloadMsg		db "The DLL is unloaded",0
ThreadCreated	db "A thread is created in this process",0
ThreadDestroyed	db "A thread is destroyed in this process",0

.code
DllEntry proc hInstance:HINSTANCE, reason:DWORD, reserved1:DWORD
	.if reason==DLL_PROCESS_ATTACH
		invoke MessageBox,NULL,addr LoadMsg,addr AppName,MB_OK
	.elseif reason==DLL_PROCESS_DETACH
		invoke MessageBox,NULL,addr UnloadMsg,addr AppName,MB_OK
	.elseif reason==DLL_THREAD_ATTACH
		invoke MessageBox,NULL,addr ThreadCreated,addr AppName,MB_OK
	.else        ; DLL_THREAD_DETACH
		invoke MessageBox,NULL,addr ThreadDestroyed,addr AppName,MB_OK
	.endif
	mov  eax,TRUE
	ret
DllEntry Endp
; See skeleton.def: This is an exported function
TestHello proc
	invoke MessageBox,NULL,addr HelloMsg,addr AppName,MB_OK
	ret	
TestHello endp

End DllEntry
