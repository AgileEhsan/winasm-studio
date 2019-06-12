Include windows.inc

Include user32.inc
Include kernel32.inc
include shell32.inc
Include gdi32.inc
Include comctl32.inc
Include comdlg32.inc
Include ole32.inc

;-------------------------------------------------------------------
;Needed For Debug Window Only
;Include masm32.inc
;Include debug.inc
;-------------------------------------------------------------------

IncludeLib USER32.LIB
IncludeLib KERNEL32.LIB
includelib SHELL32.LIB
IncludeLib GDI32.LIB
IncludeLib COMCTL32.LIB
IncludeLib COMDLG32.LIB
IncludeLib OLE32.LIB
;-------------------------------------------------------------------
;Needed For Debug Window Only
;IncludeLib masm32.lib
;IncludeLib debug.lib
;-------------------------------------------------------------------


.DATA?
hInstance		HINSTANCE ?	;DLL instance
pHandles		DWORD ?
hImlNormal		DWORD ?
hImlMonoChrome	DWORD ?

.DATA
hNewImgList		DWORD 0
;hNewDisabledImgList	DWORD 0
szFriendlyName	DB "SetImages WinAsm Studio Add-In",0
szDescription	DB "SetImages WinAsm Studio Add-In lets you use toolbar, menu item and Project tree images you like. By Antonis Kyprianou",0

;-------------------------------------------------------------------
CTEXT MACRO Text
LOCAL szText

	.DATA
	szText BYTE Text, 0
	.CODE
	ExitM < Offset szText >
ENDM

M2M MACRO M1, M2
	PUSH M2
	POP M1
ENDM

;-------------------------------------------------------------------
LOWORD MACRO DoubleWord	;;Retrieves the low WORD from double WORD argument
	MOV	EAX,DoubleWord
	AND	EAX,0FFFFh		;;Set to low word 
ENDM

;-------------------------------------------------------------------
HIWORD MACRO DoubleWord	;;Retrieves the high word from double word 
	MOV	EAX,DoubleWord
	SHR	EAX,16			;;Shift 16 for high word to set to high WORD
ENDM
;-------------------------------------------------------------------
