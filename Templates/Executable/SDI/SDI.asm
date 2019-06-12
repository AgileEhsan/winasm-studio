.386

.MODEL FLAT,STDCALL

OPTION CASEMAP:NONE

WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD

Include SDI.inc

.CODE
Start:
	Invoke GetModuleHandle, NULL
	MOV hInstance,EAX
	Invoke GetCommandLine
	MOV CommandLine, EAX
	Invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
	Invoke ExitProcess,EAX
	
WinMain Proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
Local wc:WNDCLASSEX
Local msg:MSG
Local hwnd:HWND

	MOV wc.cbSize, SizeOf WNDCLASSEX
	MOV wc.style, CS_HREDRAW or CS_VREDRAW
	MOV wc.lpfnWndProc, Offset WndProc
	MOV wc.cbClsExtra,NULL
	MOV wc.cbWndExtra,NULL
	PUSH hInst
	POP wc.hInstance
	MOV wc.hbrBackground, COLOR_WINDOW+1
	MOV wc.lpszMenuName, NULL
	MOV wc.lpszClassName, Offset ClassName
	Invoke LoadIcon, NULL, IDI_APPLICATION
	MOV wc.hIcon,EAX
	MOV wc.hIconSm,0
	Invoke LoadCursor, NULL, IDC_ARROW
	MOV wc.hCursor,EAX
	Invoke RegisterClassEx, addr wc
	Invoke LoadMenu, hInst, Offset MenuName
	MOV hMenu,EAX
	Invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR ClassName, ADDR szAppName,\
           WS_OVERLAPPEDWINDOW, CW_USEDEFAULT,\
           CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, NULL, hMenu,\
           hInst, NULL
	MOV hwnd,EAX
	Invoke ShowWindow, hwnd, SW_SHOWNORMAL
	Invoke UpdateWindow, hwnd
	.While TRUE
		Invoke GetMessage, ADDR msg, NULL, 0, 0
		.Break .If (!EAX)
		Invoke TranslateMessage, ADDR msg
		Invoke DispatchMessage, ADDR msg
	.EndW
	MOV EAX, msg.wParam
	RET
WinMain endp
WndProc Proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	.If uMsg==WM_DESTROY
		Invoke PostQuitMessage, NULL
	.ElseIf uMsg==WM_COMMAND
		MOV EAX,wParam
		.If AX==IDM_FILE_NEW
			Invoke MessageBox, NULL, ADDR szFileNew, Offset szAppName, MB_OK
		.ElseIf AX==IDM_FILE_OPEN
			Invoke MessageBox, NULL, ADDR szFileOpen, Offset szAppName, MB_OK
		.ElseIf AX==IDM_HELP_ABOUT
			Invoke MessageBox, NULL,ADDR szHelpAbout, Offset szAppName, MB_OK
		.Else
			Invoke DestroyWindow, hWnd
		.EndIf
	.Else
		Invoke DefWindowProc, hWnd, uMsg, wParam, lParam
		RET
	.EndIf
	XOR EAX,EAX
	RET
WndProc EndP

End Start