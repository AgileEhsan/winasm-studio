; alternate combined asm and include example
.386

.model flat, stdcall

option casemap:none

include windows.inc
include kernel32.inc
include user32.inc

includelib user32.lib
includelib kernel32.lib

.data
MsgCaption      db "WinAsm Template",0
MsgBoxText      db "This is a bare bone exe application.",0

.code
start:
	invoke MessageBox, NULL,addr MsgBoxText, addr MsgCaption, MB_OK
	invoke ExitProcess,NULL
end start
