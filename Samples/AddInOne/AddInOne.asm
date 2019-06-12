; This is a sample Add-In for WinAsm Studio by Antonis Kyprianou.
; This Add-In will bring up a messagebox when loaded, unloaded, when it's menu is
; selected, and when a project is assembled. 

.386

.MODEL FLAT,STDCALL

OPTION CASEMAP:NONE

Include AddInOne.inc
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
Local IsActiveChildMaximized:DWORD

	;Place Initialization code here e.g.:	
	PUSH EBX
	MOV EBX,pWinAsmHandles
	;Keep the pointer to WinAsm handles. (Most probably you will need it in your Add-In)
	MOV pHandles,EBX

	M2M hMain,[EBX].HANDLES.hMain	; copy the main handle to our variable hMain
	Invoke MessageBox, hMain, Offset szMessageLoad, Offset szFriendlyName, MB_OK or MB_ICONINFORMATION or MB_APPLMODAL

	M2M hAddInsMenu,[ebx].HANDLES.PopUpMenus.hAddInsMenu ; handle to the AddIns menu item

	Invoke GetMenuItemCount,hAddInsMenu
	.If EAX==1	;This is the first menu item after "Add-Ins Manager ...", so
		Invoke AppendMenu,hAddInsMenu, MF_SEPARATOR,0, 0	;insert a separator (nicer)
	.EndIf

	Invoke SendMessage,hMain,WAM_GETNEXTMENUID, 0, 0
	MOV MenuID,EAX
	Invoke AppendMenu,hAddInsMenu, MF_OWNERDRAW, MenuID, offset szFriendlyName
	POP EBX

	XOR EAX,EAX
	RET
WAAddInLoad EndP


; FrameWindowProc-
; This procedure is called when any message is sent to the Main (MDI) window
; of WinAsm Studio.  The procedure is called with the standard windows message
; parameters, hWnd, uMsg, wParam, and lParam.  To pass this message along to
; any remaining add-ins, and to WinAsm Studio itself, return a zero.  To
; prevent the remaining add-ins and WinAsm Studio from processing this message,
; return a non-zero.  To enable this procedure, you must edit the AddIn.def
; file and uncomment the line for this procedure.

FrameWindowProc Proc hWnd:DWORD, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	.If uMsg == WM_COMMAND
		HIWORD wParam
		.If EAX == 0 || 1 ; 0 is a menu, 1 is an accelerator. Toolbar messages act like menu messages...
			LOWORD wParam
			.If EAX == MenuID
				Invoke MessageBox, hMain, CTEXT("Wow! My menu item has been selected."), Offset szFriendlyName, MB_OK or MB_ICONINFORMATION
				MOV EAX,TRUE	;I do not want WinAsm or Other Add-Ins to process this message
				RET
			.EndIf
		.EndIf
	.ElseIf uMsg==WAE_COMMANDFINISHED
		HIWORD wParam
		.If EAX == 0 || 1 ; 0 is a menu, 1 is an accelerator. Toolbar messages act like menu messages...
			LOWORD wParam
			.If EAX == IDM_MAKE_ASSEMBLE	;Just an example
				Invoke MessageBox, hMain, CTEXT("Wow! The current project just Assembled! This is just a demo (-:annoying :-) Add-In. Go Add-Ins, Add-In Manager ... and unload me."),Offset szFriendlyName,MB_OK or MB_ICONINFORMATION
				;For the WAE_COMMANDFINISHED it doesn't make any sense whatever you return.
			.EndIf
		.EndIf
	.EndIf
	XOR EAX,EAX
	RET
FrameWindowProc EndP

; WAAddInUnload-
; This REQUIRED procedure is called when WinAsm Studio closes or when the user
; selects to unload the add-in from the Add-In Manager. Free all internally
; allocated resources, like window classes, files, memory and so on here.

WAAddInUnload Proc
	;Free everything here
	Invoke MessageBox, hMain, Offset szMessageUnload, Offset szFriendlyName, MB_OK

	;Remove the menu item and the separator(if we must do so)	
	Invoke GetMenuItemCount,hAddInsMenu
	.If EAX==3	;This is the first menu item after "Add-Ins Manager ...", so
		Invoke DeleteMenu,hAddInsMenu,1,MF_BYPOSITION	;Remove separator (nicer)
	.EndIf

	Invoke DeleteMenu,hAddInsMenu,MenuID,MF_BYCOMMAND
	RET
WAAddInUnload EndP

End DllEntry
