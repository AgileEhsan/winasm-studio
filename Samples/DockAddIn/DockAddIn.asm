; This is a sample of how to create a docking window from an Add-In.  Written by Antonis Kyprianou.

.386

.MODEL FLAT,STDCALL

OPTION CASEMAP:NONE

Include DockAddIn.inc
;Include \WinAsm\Inc\WAAddIn.inc

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

SizeEditBox Proc 
Local Rect	:RECT

	Invoke SendMessage,hAddIn,WAM_GETCLIENTRECT,0,ADDR Rect
	MOV EAX,Rect.right
	SUB EAX,Rect.left
	MOV ECX,Rect.bottom
	SUB ECX,Rect.top
	Invoke MoveWindow,hEditBox,Rect.left,Rect.top,EAX,ECX,TRUE

	RET
SizeEditBox EndP

NewAddInProc Proc hWin:DWORD, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

	.If uMsg == WM_SIZE
		Invoke SizeEditBox
	.EndIf
	Invoke CallWindowProc,OldProc,hWin,uMsg,wParam,lParam	
	RET
NewAddInProc EndP

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

	; Place Initialization code here:	
	PUSH EBX
	MOV EBX,pWinAsmHandles
	
	; Keep the pointer to WinAsm handles. (Most probably you will need it in your Add-In)
	MOV pHandles,EBX
	M2M hMain,[EBX].HANDLES.hMain

	;----------------------------------------------------------------------------
	; Let's set the initialization values for the new docking window 
	MOV AddInDockData.lpCaption, Offset szFriendlyName
	MOV AddInDockData.fDockedTo,NODOCK
	MOV AddInDockData.NoDock.dLeft,40
	MOV AddInDockData.NoDock.dTop,100
	MOV AddInDockData.NoDock.dWidth,600
	MOV AddInDockData.NoDock.dHeight,120
	MOV AddInDockData.DockTopHeight,60
	MOV AddInDockData.DockBottomHeight,120
	MOV AddInDockData.DockRightWidth,180
	MOV AddInDockData.DockLeftWidth,180
	
	; Let's create it
	Invoke SendMessage,hMain,WAM_CREATEDOCKINGWINDOW,WS_VISIBLE OR WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_CHILD or STYLE_GRADIENTTITLE,ADDR AddInDockData
	MOV hAddIn,EAX
	
	; Let's subclass it 
	Invoke SetWindowLong,hAddIn,GWL_WNDPROC,ADDR NewAddInProc
	MOV OldProc,EAX
	
	; Let's do an edit control just for demonstration.
	Invoke CreateWindowEx,WS_EX_CLIENTEDGE,CTEXT("edit"),Offset szHelp,WS_CHILD or WS_VISIBLE or ES_MULTILINE or WS_VSCROLL,0,0,0,0,hAddIn,NULL,hInstance,NULL
	MOV hEditBox,EAX
	; Let's size it
	Invoke SizeEditBox
	;----------------------------------------------------------------------------
	; Let's create a new menu item. Not really neccessary but just as a means to show
	; the docking window if it is hidden.
	M2M hAddInsMenu,[ebx].HANDLES.PopUpMenus.hAddInsMenu ; handle to the AddIns menu item
	Invoke GetMenuItemCount,hAddInsMenu
	.If EAX==1	;This is the first menu item after "Add-Ins Manager ...", so
		Invoke AppendMenu,hAddInsMenu, MF_SEPARATOR,0, 0	;insert a separator (nicer)
	.EndIf

	Invoke SendMessage,[EBX].HANDLES.hMain,WAM_GETNEXTMENUID, 0, 0
	MOV MenuID,EAX
	Invoke AppendMenu,hAddInsMenu, MF_OWNERDRAW,MenuID, offset szFriendlyName
	;----------------------------------------------------------------------------

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
				Invoke ShowWindow,hAddIn,SW_SHOW
				MOV EAX,TRUE	; I do not want WinAsm or Other remaining Add-Ins to process this message
				RET
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

	; Here, You can store the AddInDockData values (e.g. in the WAAddins.ini)
	; so that you retrieve them when you need them.
	
	; Let's destroy our docking window
	Invoke SendMessage,hAddIn,WAM_DESTROYDOCKINGWINDOW,0,0
	
	; Remove the menu item and the separator(if we *must* do so)	
	Invoke GetMenuItemCount,hAddInsMenu
	.If EAX==3	; This is the first menu item after "Add-Ins Manager ...", so
		Invoke DeleteMenu,hAddInsMenu,1,MF_BYPOSITION	; Remove separator (nicer)
	.EndIf

	Invoke DeleteMenu,hAddInsMenu,MenuID,MF_BYCOMMAND

	RET
WAAddInUnload EndP

End DllEntry
