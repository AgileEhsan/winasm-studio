; This is a WinAsm Studio Addin by Antonis Kyprianou.
; This Add-In lets you use the toolbar, menu item and Project tree images you like.
.386

.MODEL FLAT,STDCALL

OPTION CASEMAP:NONE

Include SetImages.inc
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

ChangeMDIChildIcon Proc hMDIChildWindow:DWORD, lParam:LPARAM
	;lParam holds the handle to the image list to use
	Invoke GetWindowLong,hMDIChildWindow,0
	MOV EAX,[EAX].CHILDDATA.TypeOfFile
	.If EAX==1 || EAX==101
		MOV EAX,26
	.ElseIf EAX==2 || EAX==102
		MOV EAX,27
	.ElseIf EAX==3 || EAX==103
		MOV EAX,28
	.ElseIf EAX==4 || EAX==104
		MOV EAX,37
	.ElseIf EAX==5 || EAX==105
		MOV EAX,39
	.ElseIf EAX==6 || EAX==106
		MOV EAX,40
	.ElseIf EAX==7 || EAX==107
		MOV EAX,38
	.Else;If EAX==51 i.e. module
		MOV EAX,47
	.Endif
	Invoke ImageList_GetIcon,lParam,EAX,ILD_NORMAL
	Invoke SendMessage,hMDIChildWindow,WM_SETICON,ICON_BIG,EAX
	
	;Return TRUE to continue enumeration, FALSE to stop
	MOV EAX,TRUE
	RET
	
ChangeMDIChildIcon EndP


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

WAAddInLoad Proc pWinAsmHandles:DWORD, 	 pFeatures:PTR FEATURES
	
	PUSH EBX
	MOV EBX,pWinAsmHandles
	;Keep the pointer to WinAsm handles.
	MOV pHandles,EBX
	
	;pFeatures is a pointer to the FEATURES structure.
	;Use it to get WinAsm version number (decimal, for example version 1.2.3.4 is 1234).
	MOV EAX,pFeatures
	.If [EAX].FEATURES.Version < 3021
		.DATA
		szNotSupported DB "This Add-In requires WinAsm Studio version 3.0.2.1 or above.",0
		.CODE
		@@:
		Invoke MessageBox,[EBX].HANDLES.hMain,Offset szNotSupported,Offset szFriendlyName,MB_OK or MB_ICONERROR or MB_TASKMODAL
		
		POP EBX	;Balance the stack
		
		;Return -1 to indicate that Add-In loading was not successful
		MOV EAX,-1
		RET
	.Else
		
		Invoke ImageList_Create, 16, 16, ILC_COLOR4 or ILC_MASK, 60, 0
		MOV hNewImgList,EAX
		Invoke LoadBitmap,hInstance,101
		PUSH EAX	
		Invoke ImageList_AddMasked,hNewImgList,EAX,0C0C0C0h
		POP EAX
		Invoke DeleteObject,EAX
		
		;Uncomment the following if you want a different set for disabled images
		
		;Invoke ImageList_Create, 16, 16, ILC_COLOR4 or ILC_MASK, 60, 0
		;MOV hNewDisabledImgList,EAX
		;Invoke LoadBitmap,hInstance, ?
		;PUSH EAX	
		;Invoke ImageList_AddMasked,hNewDisabledImgList,EAX,0C0C0C0h
		;POP EAX
		;Invoke DeleteObject,EAX
		
		
		Invoke SendMessage,[EBX].HANDLES.hMainTB,TB_SETIMAGELIST,0,hNewImgList
		Invoke SendMessage,[EBX].HANDLES.hMainTB,TB_SETDISABLEDIMAGELIST,0,0
		
		Invoke SendMessage,[EBX].HANDLES.hEditTB,TB_SETIMAGELIST,0,hNewImgList
		Invoke SendMessage,[EBX].HANDLES.hEditTB,TB_SETDISABLEDIMAGELIST,0,0
		
		Invoke SendMessage,[EBX].HANDLES.hMakeTB,TB_SETIMAGELIST,0,hNewImgList
		Invoke SendMessage,[EBX].HANDLES.hMakeTB,TB_SETDISABLEDIMAGELIST,0,0
		
		Invoke SendMessage,[EBX].HANDLES.hProjTree,TVM_SETIMAGELIST,0,hNewImgList
		
		Invoke InvalidateRect,[EBX].HANDLES.hMainTB,NULL,TRUE
		Invoke InvalidateRect,[EBX].HANDLES.hEditTB,NULL,TRUE
		Invoke InvalidateRect,[EBX].HANDLES.hMakeTB,NULL,TRUE
		
		MOV ECX,[EBX].HANDLES.phImlNormal
		MOV EAX,[ECX]
		MOV hImlNormal,EAX	;Keep the original "Enabled" image list for later use 
		MOV EAX,hNewImgList	;Change this to MOV EAX,NULL if you don't want normal images for Menu items
		MOV [ECX],EAX		;Set the new "Enabled" image list
		
		MOV ECX,[EBX].HANDLES.phImlMonoChrome
		MOV EAX,[ECX]
		MOV hImlMonoChrome,EAX	;Keep the original "disabled" image list for later use
		MOV EAX,NULL	;i.e I don't want disabled images for Menu items. Change this to hNewDisabledImgList if you do.
		MOV [ECX],EAX	;Set the new "Disabled" image list
		
		Invoke SendMessage,[EBX].HANDLES.hMain,	WAM_ENUMCURRENTPROJECTFILES, Offset ChangeMDIChildIcon,hNewImgList
		Invoke SendMessage,[EBX].HANDLES.hMain,	WAM_ENUMEXTERNALFILES, Offset ChangeMDIChildIcon,hNewImgList
		Invoke DrawMenuBar,[EBX].HANDLES.hMain	;in case any child is maximized
		
	.EndIf
	
	POP EBX
	
	XOR EAX,EAX
	RET
WAAddInLoad EndP

; WAAddInUnload-
; This REQUIRED procedure is called when WinAsm Studio closes or when the user
; selects to unload the add-in from the Add-In Manager. Free all internally
; allocated resources, like window classes, files, memory and so on here.

WAAddInUnload Proc
	PUSH EBX
	MOV EBX,pHandles
	
	MOV ECX,[EBX].HANDLES.phImlNormal
	MOV EAX,hImlNormal
	MOV [ECX],EAX
	
	MOV ECX,[EBX].HANDLES.phImlMonoChrome
	MOV EAX,hImlMonoChrome
	MOV [ECX],EAX

	Invoke SendMessage,[EBX].HANDLES.hMainTB,TB_SETIMAGELIST,0,hImlNormal
	Invoke SendMessage,[EBX].HANDLES.hMainTB,TB_SETDISABLEDIMAGELIST,0,hImlMonoChrome
	Invoke InvalidateRect,[EBX].HANDLES.hMainTB,NULL,TRUE

	Invoke SendMessage,[EBX].HANDLES.hEditTB,TB_SETIMAGELIST,0,hImlNormal
	Invoke SendMessage,[EBX].HANDLES.hEditTB,TB_SETDISABLEDIMAGELIST,0,hImlMonoChrome
	Invoke InvalidateRect,[EBX].HANDLES.hEditTB,NULL,TRUE

	Invoke SendMessage,[EBX].HANDLES.hMakeTB,TB_SETIMAGELIST,0,hImlNormal
	Invoke SendMessage,[EBX].HANDLES.hMakeTB,TB_SETDISABLEDIMAGELIST,0,hImlMonoChrome
	Invoke InvalidateRect,[EBX].HANDLES.hMakeTB,NULL,TRUE
	
	;Optional
	Invoke SendMessage,[EBX].HANDLES.hProjTree,TVM_SETIMAGELIST,0,hImlNormal

	;Optional
	Invoke SendMessage,[EBX].HANDLES.hMain,WAM_ENUMCURRENTPROJECTFILES, Offset ChangeMDIChildIcon,hImlNormal
	Invoke SendMessage,[EBX].HANDLES.hMain,	WAM_ENUMEXTERNALFILES, Offset ChangeMDIChildIcon,hImlNormal
	Invoke DrawMenuBar,[EBX].HANDLES.hMain	;in case any child is maximized

	POP EBX
	
	
	.If hNewImgList
		Invoke DeleteObject,hNewImgList
	.EndIf

	RET
WAAddInUnload EndP

End DllEntry
