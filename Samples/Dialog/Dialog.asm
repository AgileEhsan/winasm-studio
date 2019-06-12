; This produces a standard windows exe that will bring up a dialog when About is selected.  Author unknown.

.386

.model flat,stdcall

option casemap:none

Include windows.inc
Include user32.inc
Include kernel32.inc

IncludeLib user32.lib
IncludeLib kernel32.lib

WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
DlgProc PROTO :HWND, :DWORD,:DWORD,:DWORD

.data
ClassName	DB "SimpleWinClass",0
AppName		DB "Our Main Window-WinAsm",0
MenuName	DB "FirstMenu",0
DlgName		DB "MyDialog",0
TestString	DB "Hello, everybody",0

.data?
hInstance	HINSTANCE ?
CommandLine	LPSTR ?

.const
IDM_EXIT	EQU 1
IDM_ABOUT	EQU 2
IDC_EDIT	EQU 3000
IDC_BUTTON	EQU 3001
IDC_EXIT	EQU 3002

.code
start:
	Invoke GetModuleHandle, NULL
	MOV    hInstance,EAX
	Invoke GetCommandLine
	Invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
	Invoke ExitProcess,EAX
	
WinMain Proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
LOCAL wc	:WNDCLASSEX
LOCAL msg	:MSG
LOCAL hwnd	:HWND
	MOV   wc.cbSize,SIZEOF WNDCLASSEX
	MOV   wc.style, CS_HREDRAW or CS_VREDRAW
	MOV   wc.lpfnWndProc, OFFSET WndProc
	MOV   wc.cbClsExtra,NULL
	MOV   wc.cbWndExtra,NULL
	PUSH  hInst
	POP   wc.hInstance
	MOV   wc.hbrBackground,COLOR_WINDOW+1
	MOV   wc.lpszMenuName,OFFSET MenuName
	MOV   wc.lpszClassName,OFFSET ClassName
	Invoke LoadIcon,NULL,IDI_APPLICATION
	MOV   wc.hIcon,EAX
	MOV   wc.hIconSm,EAX
	Invoke LoadCursor,NULL,IDC_ARROW
	MOV   wc.hCursor,EAX
	Invoke RegisterClassEx, addr wc
	Invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,300,200,NULL,NULL,\
           hInst,NULL
	MOV   hwnd,EAX
	Invoke ShowWindow, hwnd,SW_SHOWNORMAL
	Invoke UpdateWindow, hwnd
	.WHILE TRUE
		Invoke GetMessage, ADDR msg,NULL,0,0
		.BREAK .If (!EAX)
		Invoke TranslateMessage, ADDR msg
		Invoke DispatchMessage, ADDR msg
	.ENDW
	MOV     EAX,msg.wParam
	RET
WinMain EndP
WndProc Proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	.If uMsg==WM_DESTROY
		Invoke PostQuitMessage,NULL
	.ElseIf uMsg==WM_COMMAND
		MOV EAX,wParam
		.If AX==IDM_ABOUT
			Invoke DialogBoxParam,hInstance, addr DlgName,hWnd,OFFSET DlgProc,NULL
		.Else
			Invoke DestroyWindow, hWnd
		.EndIf
	.Else
		Invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		RET
	.EndIf
	XOR    EAX,EAX
	RET
WndProc EndP
DlgProc Proc hWnd:HWND,iMsg:DWORD,wParam:WPARAM, lParam:LPARAM
	.If iMsg==WM_INITDIALOG
		Invoke GetDlgItem,hWnd,IDC_EDIT
		Invoke SetFocus,EAX
	.ElseIf iMsg==WM_CLOSE
		Invoke EndDialog,hWnd,NULL
	.ElseIf iMsg==WM_COMMAND
		MOV EAX,wParam
		MOV EDX,EAX
		SHR EDX,16
		.If DX==BN_CLICKED
			.If EAX==IDC_EXIT
				Invoke SendMessage,hWnd,WM_CLOSE,NULL,NULL
			.ElseIf EAX==IDC_BUTTON
				Invoke SetDlgItemText,hWnd,IDC_EDIT,ADDR TestString
			.EndIf
		.EndIf
	.Else
		MOV EAX,FALSE
		RET
	.EndIf
	MOV  EAX,TRUE
	RET
DlgProc EndP
End start
