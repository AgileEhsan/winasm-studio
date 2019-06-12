; Dialog As Main demo program

.386
.model flat,stdcall
option casemap:none

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

include windows.inc
Include gdi32.inc
include user32.inc
include kernel32.inc
Include comctl32.inc
;Include masm32.inc
;include debug.inc

IncludeLib GDI32.LIB
includelib user32.lib
includelib kernel32.lib
IncludeLib COMCTL32.LIB
;IncludeLib masm32.lib
;IncludeLib debug.lib

.DATA
ClassName	DB "DLGCLASS",0
MenuName	DB "MyMenu",0
DlgName		DB "MyDialog",0
AppName		DB "Dialog As Main",0

.DATA?
hInstance	HINSTANCE ?
CommandLine	LPSTR ?
buffer		DB 512 DUP(?)

.CONST
IDC_EDIT        EQU 3000
IDC_TOOLBAR		EQU 3001
IDM_GETTEXT     EQU 32000
IDM_CLEAR       EQU 32001
IDM_EXIT        EQU 32002

tbMain	TBBUTTON <0, IDM_GETTEXT, TBSTATE_ENABLED,TBSTYLE_BUTTON, 0, 0>
		TBBUTTON <1, IDM_CLEAR, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0, 0>
		TBBUTTON <0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0, 0>			
		TBBUTTON <2, IDM_EXIT, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0, 0>

LOWORD MACRO DoubleWord	;;Retrieves the low WORD from double WORD argument
	MOV	EAX,DoubleWord
	AND	EAX,0FFFFh		;;Set to low word 
ENDM
HIWORD MACRO DoubleWord	;;Retrieves the high word from double word 
	MOV	EAX,DoubleWord
	SHR	EAX,16			;;Shift 16 for high word to set to high WORD
ENDM

.CODE
start:
	Invoke GetModuleHandle, NULL
	MOV    hInstance,EAX
	Invoke GetCommandLine
	Invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
	Invoke ExitProcess,EAX
	
WinMain Proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
LOCAL wc		:WNDCLASSEX
LOCAL msg		:MSG
LOCAL hDlg		:HWND
Local hImgList	:DWORD

	MOV wc.cbSize,SizeOf WNDCLASSEX
	MOV wc.style, CS_HREDRAW or CS_VREDRAW
	MOV wc.lpfnWndProc, Offset WndProc
	MOV wc.cbClsExtra,NULL
	MOV wc.cbWndExtra,DLGWINDOWEXTRA
	PUSH hInst
	POP wc.hInstance
	MOV wc.hbrBackground,COLOR_BTNFACE+1
	MOV wc.lpszMenuName,Offset MenuName
	MOV wc.lpszClassName,Offset ClassName
	Invoke LoadIcon,NULL,IDI_APPLICATION
	MOV wc.hIcon,EAX
	MOV wc.hIconSm,EAX
	Invoke LoadCursor,NULL,IDC_ARROW
	MOV wc.hCursor,EAX
	Invoke RegisterClassEx, addr wc
	
	Invoke InitCommonControls
	Invoke CreateDialogParam,hInstance,ADDR DlgName,NULL,NULL,NULL
	MOV hDlg,EAX

	Invoke SendDlgItemMessage,hDlg,IDC_TOOLBAR,TB_BUTTONSTRUCTSIZE,SizeOf TBBUTTON,0
	Invoke SendDlgItemMessage,hDlg,IDC_TOOLBAR,TB_ADDBUTTONS,4,ADDR tbMain
	Invoke ImageList_Create, 16, 16, ILC_COLOR 	, 15, 0
	MOV hImgList,EAX
	Invoke LoadImage,  hInstance,700, IMAGE_BITMAP, 0, 0, LR_DEFAULTCOLOR
	PUSH EAX	
	Invoke ImageList_Add,hImgList,EAX,NULL
	POP EAX
	Invoke DeleteObject,EAX

	Invoke SendDlgItemMessage,hDlg,IDC_TOOLBAR,TB_SETIMAGELIST,0,hImgList

	
    Invoke GetDlgItem,hDlg,IDC_EDIT
	Invoke SetFocus,EAX	
	Invoke ShowWindow, hDlg,SW_SHOWNORMAL
	Invoke UpdateWindow, hDlg
	.While TRUE
		Invoke GetMessage, ADDR msg,NULL,0,0
		.Break .If (!EAX)
		Invoke IsDialogMessage, hDlg, ADDR msg
		.If EAX==FALSE
			Invoke TranslateMessage, ADDR msg
			Invoke DispatchMessage, ADDR msg
		.EndIf
	.EndW
	Invoke ImageList_Destroy,hImgList
	MOV EAX,msg.wParam
	RET
WinMain EndP

WndProc Proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	.If uMsg==WM_DESTROY
		Invoke PostQuitMessage,NULL
	.ElseIf uMsg==WM_COMMAND
		HIWORD wParam
		.If EAX == 0 || 1 ; 0 is a menu, 1 is an accelerator. Toolbar messages act like menu messages...
			LOWORD wParam
			.If AX==IDM_GETTEXT
				Invoke GetDlgItemText,hWnd,IDC_EDIT,ADDR buffer,512
				Invoke MessageBox,hWnd,ADDR buffer,ADDR AppName,MB_OK
			.ElseIf AX==IDM_CLEAR
				Invoke SetDlgItemText,hWnd,IDC_EDIT,NULL
			.ElseIf AX==IDM_EXIT
				Invoke DestroyWindow,hWnd
			.EndIf
		.EndIf
	.Else
		Invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		RET
	.EndIf
	XOR EAX,EAX
	RET
WndProc EndP

End start
