include		windows.inc
include		kernel32.inc
include		user32.inc

includelib	user32.lib
includelib	kernel32.lib

.data
MsgCaption      db "WinAsm Template",0
MsgBoxText      db "This is a bare bones exe application.",0

.data?