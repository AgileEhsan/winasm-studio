Include windows.inc

;Include user32.inc
Include kernel32.inc

;-------------------------------------------------------------------
;Needed For Debug Window Only
;Include masm32.inc
;Include debug.inc
;-------------------------------------------------------------------

;IncludeLib user32.lib
IncludeLib kernel32.lib
;-------------------------------------------------------------------
;Needed For Debug Window Only
;IncludeLib masm32.lib
;IncludeLib debug.lib
;-------------------------------------------------------------------


.DATA?
hInstance		HINSTANCE ?	;DLL instance
hMain			HWND ?
pHandles		DWORD ?
MenuID			DWORD ?

.DATA
szFriendlyName	DB "Template WinAsm Add-In",0
szDescription	DB "This is a Template WinAsm Add-In.",0

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
