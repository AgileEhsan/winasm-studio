; This is a sample WinAsm Studio Add_In by Antonis Kyprianou 2003.
; This Add-In will cause the focus to be changed to whatever child window the mouse is over.
; To test, open several windows and display them in a cascade.  As you move the mouse, the
; focus will change.
.386

.MODEL FLAT,STDCALL

OPTION CASEMAP:NONE

Include XWindowsAddIn.inc
Include \WinAsm\Inc\WAAddIn.inc

.CODE

; This is the required entry procedure for the DLL.  Do NOT make changes to this procedure.
DllEntry Proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD
	.If reason==DLL_PROCESS_ATTACH
		PUSH hInst
		POP hInstance
	.EndIf
	MOV EAX,TRUE
	RET
DllEntry EndP

; GetWAAddInData-
; This REQUIRED procedure is called every time Add-In manager is opened.
; It's only purpose is to get a nice name and description for Add-In manager
; to use.  There are two parameters to process.  lpFriendlyName is the offset
; to the name that will appear in the list of Available Add-Ins.
; lpDescription is the offset to the information shown in the description box
; when the add-in is selected.  You must copy the zero-byte terminated strings
; for these two items to the memory locations at the offsets provided.  The
; maximum length of each string is 255 characters.  In this template, these
; strings are stored in the Addin.Inc file.

GetWAAddInData Proc lpFriendlyName:PTR BYTE, lpDescription:PTR BYTE
	Invoke lstrcpy, lpDescription, Offset szDescription
	Invoke lstrcpy, lpFriendlyName, Offset szFriendlyName      ; Name of Add-In
	RET
GetWAAddInData EndP

; WAAddInLoad-
; This REQUIRED procedure is called once, when the Add-In is loaded.  This is
; where you do all the one-time initializations, allocate resources, setup
; menu entries, accelerator keys, create popup menus, create windows, allocate
; memory, and so on.   The two parameters are pWinAsmHandles, which is a
; pointer to the HANDLES structure containing handles to various parts of
; WinAsm Studio, and  features, which is a pointer to the FEATURES structure.
; Both are defined in the WAAddin.inc file.  If all resources are successfully
; allocated, return a zero.  If errors occur, return a -1, and the Add-In will
; be unloaded by WinAsm Studio.

WAAddInLoad Proc pWinAsmHandles:DWORD, features:PTR DWORD	
	;Place Initialization code here e.g.:
	MOV EAX,pWinAsmHandles
	M2M hClient,[EAX].HANDLES.hClient
	M2M hMain,[EAX].HANDLES.hMain
	;Note that I do not want to create any menu for this Add-In.
	;I considered it was not necessary.

	XOR EAX,EAX
	RET
WAAddInLoad EndP

; ChildWindowProc-
; This procedure is called when any message is sent to any MDI child window of
; WinAsm Studio.  The procedure is called with the standard windows message
; parameters, hWnd, uMsg, wParam, and lParam.  To pass this message along to
; any remaining add-ins, and to WinAsm Studio itself, return a zero.  To
; prevent the remaining add-ins and WinAsm Studio from processing this message,
; return a non-zero.  To enable this procedure, you must edit the AddIn.def
; file and uncomment the line for this procedure.

ChildWindowProc Proc hWnd:DWORD, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	.If uMsg==WM_NCMOUSEMOVE
		Invoke SendMessage,hClient,WM_MDIACTIVATE,hWnd,0
		;I do not want WinAsm or any remaining add-ins to process this message.
		MOV EAX,1
		RET
	.EndIf
	XOR EAX,EAX
	RET
ChildWindowProc EndP

; WAAddInUnload-
; This REQUIRED procedure is called when WinAsm Studio closes or when the user
; selects to unload the add-in from the Add-In Manager. Free all internally
; allocated resources, like window classes, files, memory and so on here.

WAAddInUnload Proc
	;Free everything here	
	RET
WAAddInUnload EndP

End DllEntry
