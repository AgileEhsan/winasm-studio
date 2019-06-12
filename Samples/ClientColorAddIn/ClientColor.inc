Include windows.inc

Include user32.inc
Include comdlg32.inc
Include kernel32.inc
Include gdi32.inc
;-------------------------------------------------------------------
;Needed For Debug Window Only
Include masm32.inc
Include debug.inc
;-------------------------------------------------------------------

IncludeLib user32.lib
includelib COMDLG32.LIB
IncludeLib kernel32.lib
IncludeLib GDI32.LIB
;-------------------------------------------------------------------
;Needed For Debug Window Only
IncludeLib masm32.lib
IncludeLib debug.lib
;-------------------------------------------------------------------

.DATA?
hInstance		HINSTANCE ?	;DLL instance
MenuID			DWORD ?
OldProc			DWORD ?
hMain			HWND ?
hClient			HWND ?
hAddInsMenu		HWND ?
CustColors		DD 16 DUP(?)

.DATA
szFriendlyName	DB "Client Color Add-In",0
szDescription	DB "This is Client Color WinAsm Add-In. By Antonis Kyprianou 2003.",0
ClientColor		DD 0C08000h
;-------------------------------------------------------------------
CTEXT MACRO Text
LOCAL szText

	.DATA
	szText BYTE Text, 0
	.CODE
	ExitM < Offset szText >
ENDM
;-------------------------------------------------------------------
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
;Return MACRO arg
;	MOV EAX,arg
;	RET
;ENDM
;-------------------------------------------------------------------
