.386
.model	flat,stdcall
option	casemap:none

include		demo.inc

.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke GetCommandLine
	invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess,eax
;=====================================================================
WinMain	proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG
	LOCAL	hwnd:HWND
	
	mov	wc.cbSize,SIZEOF WNDCLASSEX
	mov	wc.style, CS_HREDRAW or CS_VREDRAW
	mov	wc.lpfnWndProc, OFFSET WndProc
	mov	wc.cbClsExtra,NULL
	mov	wc.cbWndExtra,NULL
	push	hInst
	pop	wc.hInstance
	mov	wc.hbrBackground, COLOR_WINDOW+1
	mov	wc.lpszMenuName, OFFSET MenuName
	mov	wc.lpszClassName, OFFSET ClassName
	invoke	LoadIcon, NULL, IDI_APPLICATION
	mov	wc.hIcon,eax
	mov	wc.hIconSm,eax
	invoke	LoadCursor, NULL, IDC_ARROW
	mov	wc.hCursor,eax
	invoke	RegisterClassEx, addr wc
	invoke	CreateWindowEx, WS_EX_CLIENTEDGE, ADDR ClassName, ADDR AppName,\
		WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 300, 200, NULL, NULL,\
		hInst, NULL
	mov   	hwnd,eax
	invoke	ShowWindow, hwnd, SW_SHOWNORMAL
	invoke	UpdateWindow, hwnd
	
	.while	TRUE
		invoke	GetMessage, ADDR msg, NULL, 0, 0
		.break	.if	(!eax)
		invoke	TranslateMessage, ADDR msg
		invoke	DispatchMessage, ADDR msg
	.endw
	
	mov	eax,msg.wParam
	ret
WinMain	endp
;=======================================================================
WndProc	proc	hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

	mov	eax,uMsg
	
	.if	eax == WM_DESTROY
		invoke	PostQuitMessage,NULL
	.elseif	eax == WM_COMMAND
		mov	eax,wParam
		.if	ax==IDM_ABOUT
			invoke	DialogBoxParam, hInstance, addr DlgName, hWnd, OFFSET DlgProc, NULL
		.else
			invoke	DestroyWindow, hWnd
		.endif
	.else
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
	.endif
	xor	eax,eax
	ret
WndProc	endp

DlgProc	proc	hWnd:HWND,iMsg:DWORD,wParam:WPARAM, lParam:LPARAM
	
	.if	iMsg == WM_INITDIALOG
		invoke	GetDlgItem, hWnd, IDC_EDIT
		invoke	SetFocus, eax
	.elseif	iMsg == WM_CLOSE
		invoke	EndDialog, hWnd, NULL
	.elseif iMsg == WM_COMMAND
		mov	eax,wParam
		mov	edx,eax
		shr	edx,16
		
		.if	dx == BN_CLICKED
			.if	eax == IDC_EXIT
				invoke	SendMessage, hWnd, WM_CLOSE, NULL, NULL
			.elseif	eax == IDC_BUTTON
				invoke SetDlgItemText, hWnd, IDC_EDIT, ADDR TestString
			.endif
		.endif
	.else
		mov	eax,FALSE
		ret
	.endif
	
	mov	eax,TRUE
	ret
DlgProc endp

end start
