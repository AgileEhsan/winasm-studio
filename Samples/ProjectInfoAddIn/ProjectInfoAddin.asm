; This is a WinAsm Studio Add-In by originally by Antonis Kyprianou and highly modified by JimG.
; The purpose of this Add-In is to show how to access project information from within an Add-In.
; It adds a menu item to the Add-Ins menu that when selected, will print out the value of the
; project variables to the output window.

.386
.MODEL FLAT,STDCALL
OPTION CASEMAP:NONE
Include windows.inc
Include user32.inc
IncludeLib user32.lib
Include kernel32.inc
IncludeLib kernel32.lib
Include \WinAsm\Inc\WAAddIn.inc

literal MACRO quoted_text:VARARG
LOCAL local_text
.data
  local_text db quoted_text,0
.code
EXITM <local_text>
ENDM

SADD MACRO quoted_text:VARARG
EXITM <ADDR literal(quoted_text)>
ENDM
sadd equ SADD

crlf equ 0dh,0ah

.DATA?
hInstance		HINSTANCE ?	;DLL instance
pHandles		dd ?
MenuID			dd ?
pFeatures		dd ?
hMain			HWND ?
hClient			HWND ?
hAddInsMenu		HWND ?
hOut			HWND ?
hOutParent		HWND ?
CurrentProject	CURRENTPROJECTINFO <?>

Buffer  db 500 dup (?)	; scratch buffer for creating line
ChildCount		dd ?

.DATA
szFriendlyName	DB "Project Information Viewer",0
szDescription	DB "This is a WinAsm Studio example Add-In showing how to access project infomation.  Originally written by Antonis Kyprianou 2004 and modified by JimG.",0

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
	; get information for add-in manager
	Invoke lstrcpy, lpDescription, Offset szDescription
	Invoke lstrcpy, lpFriendlyName, Offset szFriendlyName
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

WAAddInLoad Proc Uses ebx pWinAsmHandles:DWORD, features:PTR DWORD

	;Place Initialization code here e.g.:	
	
	MOV EBX,pWinAsmHandles
	
	MOV pHandles,EBX	;Keep the pointer to WinAsm handles.

	push [EBX].HANDLES.hMain
	pop hMain
	
	push [EBX].HANDLES.hClient
	pop hClient
	
	push [ebx].HANDLES.hOut
	pop hOut
	
	push [ebx].HANDLES.hOutParent
	pop hOutParent
	
	push [ebx].HANDLES.PopUpMenus.hAddInsMenu
	pop hAddInsMenu
	
	Invoke GetMenuItemCount,hAddInsMenu
	.If EAX==1	;If this is the first menu item after "Add-Ins Manager ...", 
		Invoke AppendMenu,hAddInsMenu, MF_SEPARATOR,0, 0	; insert a separator (nicer)
	.EndIf
	
	Invoke SendMessage,[EBX].HANDLES.hMain,WAM_GETNEXTMENUID, 0, 0
	MOV MenuID,EAX
	Invoke AppendMenu,hAddInsMenu, MF_OWNERDRAW,MenuID, offset szFriendlyName

	push features
	pop pFeatures

	XOR EAX,EAX
	RET
WAAddInLoad EndP

; WAAddInConfig-
; This optional procedure is called when "Configure" button on the Add-Ins
; manager is pressed. It's purpose is to allow a user to configure an Add-In
; even if the Add-In is not loaded or the Add-In developer does not want to
; provide a menuitem for letting users to configure the Add-In.
WAAddInConfig Proc pWinAsmHandles:PTR HANDLES, pWinAsmFeatures:PTR FEATURES
	; add configure options code here
	ret
WAAddInConfig EndP

AddLine Proc ; this routine copies the characters in Buffer to the end of hOut

	invoke SendMessage,hOut,WM_GETTEXTLENGTH,0,0
	inc eax
	invoke SendMessage,hOut,EM_SETSEL,eax,eax	;select one past last character
	invoke SendMessage,hOut,EM_REPLACESEL,FALSE,addr Buffer
	ret

AddLine EndP

ProjectFilesList Proc Uses EDI hMDIChildWindow:DWORD, lParam:LPARAM

	Invoke GetWindowLong,hMDIChildWindow,0
	mov EDI,EAX

	MOV EAX,CHILDDATA.hEditor[EDI]
	invoke wsprintf,addr Buffer,sadd('%6lx'),eax
	call AddLine

	MOV EAX,CHILDDATA.hCombo[EDI]
	invoke wsprintf,addr Buffer,sadd('%8lx'),eax
	call AddLine
	
	MOV EAX,CHILDDATA.hTreeItem[EDI]
	invoke wsprintf,addr Buffer,sadd('%10lx'),eax
	call AddLine
	
	MOV EAX,CHILDDATA.TypeOfFile[EDI]
	invoke wsprintf,addr Buffer,sadd('%8i'),eax
	call AddLine

	LEA eax,CHILDDATA.FileName[EDI]
	invoke wsprintf,addr Buffer,sadd('     %s',crlf),eax
	call AddLine

	inc ChildCount	; count child windows found

	MOV EAX,TRUE
	RET
ProjectFilesList EndP

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
		MOV	EAX,wParam
		SHR	EAX,16
		.If EAX == 0 || 1 ; 0 is a menu, 1 is an accelerator. Toolbar messages act like menu messages...
			MOV	EAX,wParam
			AND	EAX,0FFFFh 
			.If EAX == MenuID

				; That's our call, get everything about the current project
				
				Invoke SendMessage,hOut,WM_SETTEXT,0,NULL	; Clear the Output window
				Invoke SendMessage,hOut,EM_SCROLLCARET,0,0	; Start at the beginning
				mov eax,pFeatures
				mov eax,FEATURES.Version[eax]
				invoke wsprintf,addr Buffer,sadd('WinAsm Studio Version %i',crlf,crlf),eax
				call AddLine
				
				mov ChildCount,0
				Invoke SendMessage,hMain,WAM_GETCURRENTPROJECTINFO,ADDR CurrentProject,0
				
				.If eax
					
					invoke wsprintf,addr Buffer,sadd('Project Information from CURRENTPROJECTINFO Structure:',crlf,crlf)
					call AddLine
					
					mov eax,CurrentProject.pszFullProjectName
					invoke wsprintf,addr Buffer,sadd('pszFullProjectName=%s',crlf),eax
					call AddLine
					
					mov eax,CurrentProject.pbModified	; Get the POINTER to the flag
					mov eax,[eax]	; Now EAX is TRUE if project is modified/FALSE if not.
					.if eax==0
						invoke wsprintf,addr Buffer,sadd('Project has not been modified',crlf) 
						call AddLine
					.else
						invoke wsprintf,addr Buffer,sadd('Project has been modified',crlf) 
						call AddLine
					.endif
					
					mov eax,CurrentProject.pszCompileRCCommand
					invoke wsprintf,addr Buffer,sadd('pszCompileRCCommand=%s',crlf),eax
					call AddLine

					mov eax,CurrentProject.pszResToObjCommand
					invoke wsprintf,addr Buffer,sadd('pszResToObjCommand=%s',crlf),eax
					call AddLine
				
					mov eax,CurrentProject.pszReleaseAssembleCommand
					invoke wsprintf,addr Buffer,sadd('pszReleaseAssembleCommand=%s',crlf),eax
					call AddLine

					mov eax,CurrentProject.pszReleaseLinkCommand
					invoke wsprintf,addr Buffer,sadd('pszReleaseLinkCommand=%s',crlf),eax
					call AddLine

					mov eax,CurrentProject.pszReleaseOUTCommand
					invoke wsprintf,addr Buffer,sadd('pszReleaseOUTCommand=%s',crlf),eax
					call AddLine

					mov eax,CurrentProject.pProjectType	;get POINTER to the project type
					mov eax,[eax]   ;get the project type
					invoke wsprintf,addr Buffer,sadd('Project Type=%i',crlf),eax
					call AddLine

					mov eax,CurrentProject.pszDebugAssembleCommand
					invoke wsprintf,addr Buffer,sadd('pszDebugAssembleCommand=%s',crlf),eax
					call AddLine

					mov eax,CurrentProject.pszDebugLinkCommand
					invoke wsprintf,addr Buffer,sadd('pszDebugLinkCommand=%s',crlf),eax
					call AddLine

					mov eax,CurrentProject.pszDebugOUTCommand
					invoke wsprintf,addr Buffer,sadd('pszDebugOUTCommand=%s',crlf),eax
					call AddLine

					mov eax,CurrentProject.pszProjectTitle
					invoke wsprintf,addr Buffer,sadd('pszProjectTitle=%s',crlf),eax
					call AddLine

					mov eax,CurrentProject.pszReleaseCommandLine
					invoke wsprintf,addr Buffer,sadd('pszReleaseCommandLine=%s',crlf),eax
					call AddLine

					mov eax,CurrentProject.pszDebugCommandLine
					invoke wsprintf,addr Buffer,sadd('pszDebugCommandLine=%s',crlf),eax
					call AddLine

					invoke wsprintf,addr Buffer,sadd(crlf,crlf,'Child Window Information from CHILDDATA Structure:',crlf,crlf,'hEditor hCombo  hTreeItem TypeOfFile FileName',crlf)
					call AddLine

					Invoke SendMessage,hMain,WAM_ENUMCURRENTPROJECTFILES,ADDR ProjectFilesList,0
					
					invoke wsprintf,addr Buffer,sadd(crlf,'External Files loaded:',crlf)
					call AddLine
					
					mov ChildCount,0
					Invoke SendMessage,hMain,WAM_ENUMEXTERNALFILES,ADDR ProjectFilesList,0
					.if ChildCount==0
						invoke wsprintf,addr Buffer,sadd(' none',crlf)
						call AddLine
					.endif
					
				.else
					invoke wsprintf,addr Buffer,sadd('No Project Information is available',crlf)
					call AddLine
				.EndIf
				
				invoke IsWindowVisible,hOutParent	; if hOut isn't visible, make it so
				.if eax==0	; is hOut visible?
					invoke ShowWindow,hOutParent,SW_SHOWNORMAL
				.endif
				; Scroll to top of output window here
				Invoke SendMessage,hOut,EM_SETSEL,0,0
				Invoke SendMessage,hOut,EM_SCROLLCARET,0,0

				mov EAX,TRUE ; I do not want WinAsm or any remaining Add-Ins to process this message
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

WAAddInUnload Proc Uses ebx

	; Remove our menu item
	; Also remove the separator if no other menu items have been added by other Add-Ins.	
	Invoke GetMenuItemCount,hAddInsMenu
	.If EAX==3	; We were the only ones to add menu items, so it is safe to remove the separator
		Invoke DeleteMenu,hAddInsMenu,1,MF_BYPOSITION	; Remove separator
	.EndIf

	Invoke DeleteMenu,hAddInsMenu,MenuID,MF_BYCOMMAND	; Delete our menu item
	RET

WAAddInUnload EndP

End DllEntry
