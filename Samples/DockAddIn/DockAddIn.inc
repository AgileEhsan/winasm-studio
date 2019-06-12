
Include windows.inc

Include user32.inc
Include kernel32.inc

;-------------------------------------------------------------------
;Needed For Debug Window Only
;Include masm32.inc
;Include debug.inc
;-------------------------------------------------------------------

IncludeLib user32.lib
IncludeLib kernel32.lib
;-------------------------------------------------------------------
;Needed For Debug Window Only
;IncludeLib masm32.lib
;IncludeLib debug.lib
;-------------------------------------------------------------------
Include \WinAsm\Inc\WAAddIn.inc

.DATA?
hInstance		HINSTANCE ?	;DLL instance
hMain			HWND ?
pHandles		DWORD ?
MenuID			DWORD ?
hAddIn			HWND ?
AddInDockData	DOCKINGDATA <>
hEditBox		HWND ?
OldProc			DWORD ?
hAddInsMenu		HMENU ?
hClient			HWND ?

.DATA
szFriendlyName	DB "DockAddIn",0

szDescription	DB "This is a demonstration AddIn using Docking Windows. By Antonis Kyprianou",0

szHelp			DB "This is a simple Add-In hosted in a docking window. The key points to have in mind when you are creating such an Add-In are:",13,10,13,10
				DB "a)WAM_CREATEDOCKINGWINDOW: Send this message to ***hMain*** to create a new docking window; The return value is the window handle of the newly created Add-In,",13,10,13,10
				DB "b)WAM_GETCLIENTRECT: Send this message to the handle you obtained from (a) above the get the client rectangle of the docking window. Do not use any other method you are aware of to get this rectangle!",13,10,13,10
				DB "c)WAM_DESTROYDOCKINGWINDOW: Send this message to the handle you obtained from (a) above to destroy your Docking window. DO NOT USE any other method you are aware of to destroy it!",13,10,13,10
				DB "Pressing x on the Docking window does NOT destroy your docking window. It simply hides it. Use (c) above to destroy it if you so wish!",13,10,13,10
				DB "Do not hesitate to ask for any help you might need! Antonis Kyprianou 2003.",0
				
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
