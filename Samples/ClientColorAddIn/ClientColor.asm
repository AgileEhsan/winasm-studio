; This is a sample Add-In by Antonis Kyprianou.
; This Add-In will allow you to change the background color for the main WinAsm Studio window.
; A new menu item is added to the Add-Ins menu.
; Note:  The color will only show when using non-maximized child windows.

.386

.MODEL FLAT,STDCALL

OPTION CASEMAP:NONE

Include ClientColor.inc
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
	Invoke lstrcpy, lpFriendlyName, Offset szFriendlyName
	RET
GetWAAddInData EndP

NewClientProcedure Proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
Local ps:PAINTSTRUCT
Local hBrush:HWND

	.If uMsg==WM_PAINT
		Invoke BeginPaint,hWnd,ADDR ps
		Invoke CreateSolidBrush,ClientColor
		MOV hBrush,EAX
		Invoke FillRect,ps.hdc,addr ps.rcPaint,EAX

;		Uncomment the following if you so wish:
;		Invoke SetBkMode,ps.hdc,TRANSPARENT
;		Invoke SetTextColor,ps.hdc,0FFFFFFh
;		MOV ps.rcPaint.left,0
;		MOV ps.rcPaint.top,0
;		Invoke DrawText,ps.hdc,Offset szFriendlyName,-1,ADDR ps.rcPaint,DT_LEFT

		Invoke DeleteObject,hBrush
		Invoke EndPaint,hWnd,ADDR ps
	.ElseIf uMsg==WM_SHOWWINDOW
		Invoke UpdateWindow,hClient
	.Else
		;PrintHex uMsg
		Invoke CallWindowProc,OldProc,hClient,uMsg,wParam,lParam
		RET
	.EndIf 
	XOR EAX,EAX
	RET 
NewClientProcedure EndP

SelectColor Proc Color:DWORD
Local ccc:CHOOSECOLOR
	MOV	ccc.lStructSize,SizeOf CHOOSECOLOR
	M2M ccc.hwndOwner,hMain
	MOV EAX,hInstance
	MOV	ccc.hInstance,eax
	MOV	ccc.lpCustColors,Offset CustColors
	MOV	ccc.Flags, CC_FULLOPEN or CC_RGBINIT
	MOV	ccc.lCustData,0
	MOV	ccc.lpfnHook,0
	MOV	ccc.lpTemplateName,0

	MOV EAX,Color
	MOV	ccc.rgbResult,EAX
	Invoke ChooseColor,addr ccc
	.If EAX
		MOV EAX, ccc.rgbResult
	.Else
		MOV EAX, Color
	.EndIf
	RET
SelectColor EndP

FrameWindowProc Proc hWnd:DWORD, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	.If uMsg == WM_COMMAND
		HIWORD wParam
		.If EAX == 0 || 1 ; 0 is a menu, 1 is an accelerator. Toolbar messages act like menu messages...
			LOWORD wParam
			.If EAX == MenuID
				Invoke SelectColor,ClientColor
				MOV ClientColor,EAX
				Invoke InvalidateRect,hClient,NULL,TRUE
				RET
			.EndIf
		.EndIf
	.EndIf
	XOR EAX,EAX
	RET
FrameWindowProc EndP

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
Local hDC					:HDC
Local IsActiveChildMaximized:DWORD

	PUSH EBX
	MOV EBX,pWinAsmHandles
	M2M hMain,[EBX].HANDLES.hMain
	M2M hClient,[EBX].HANDLES.hClient
	
	;SubClass the Client
	Invoke SetWindowLong,hClient,GWL_WNDPROC,Offset NewClientProcedure
	MOV OldProc,EAX
	
	Invoke InvalidateRect,hClient,NULL,TRUE
		
	;Here we will add a new menu item. In this case it will be appended in the
	;Add-Ins menu, although we can put it anywhere we want.
	push [ebx].HANDLES.PopUpMenus.hAddInsMenu ; handle to the AddIns menu item
	pop hAddInsMenu
	Invoke GetMenuItemCount,hAddInsMenu
	.If EAX==1	;This is the first menu item after "Add-Ins Manager ...", so
		Invoke AppendMenu,hAddInsMenu, MF_SEPARATOR,0, 0	;insert a separator (nicer)
	.EndIf
	
	;Get a valid Menu ID from WinAsm
	Invoke SendMessage,[EBX].HANDLES.hMain,WAM_GETNEXTMENUID, 0, 0
	MOV MenuID,EAX
	
	;Add the new item with the ID provided by WinAsm
	Invoke AppendMenu,hAddInsMenu,MF_OWNERDRAW,MenuID, offset szFriendlyName

	POP EBX
	
	XOR EAX,EAX
	RET
WAAddInLoad EndP

; WAAddInUnload-
; This REQUIRED procedure is called when WinAsm Studio closes or when the user
; selects to unload the add-in from the Add-In Manager. Free all internally
; allocated resources, like window classes, files, memory and so on here.

WAAddInUnload Proc
;	;UnSubclass the Client
	Invoke SetWindowLong,hClient,GWL_WNDPROC,OldProc
	Invoke InvalidateRect,hClient,NULL,TRUE
	
	;Remove the menu item and the separator(if we must do so)	
	Invoke GetMenuItemCount,hAddInsMenu
	.If EAX==3	;This is the first menu item after "Add-Ins Manager ...", so
		Invoke DeleteMenu,hAddInsMenu,1,MF_BYPOSITION	;Remove separator (nicer)
	.EndIf
	Invoke DeleteMenu,hAddInsMenu,MenuID,MF_BYCOMMAND

	RET
WAAddInUnload EndP

End DllEntry
