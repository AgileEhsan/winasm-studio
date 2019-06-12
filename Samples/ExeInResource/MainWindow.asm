; This program will load the executable defined in the resource file (in this case \res\dialog.exe),
; write it to a local file when the menu item is selected, and execute the file just written.
 
.386

.MODEL FLAT,STDCALL

OPTION CASEMAP:NONE

WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD

Include SDI.inc

.CODE

Start:
;-----
	Invoke GetModuleHandle, NULL
	MOV hInstance,EAX
	Invoke GetCommandLine
	MOV CommandLine,EAX
	Invoke WinMain,hInstance,NULL, CommandLine, SW_SHOWDEFAULT
	Invoke ExitProcess,EAX
	
WinMain Proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
Local wc:WNDCLASSEX
Local msg:MSG
Local hwnd:HWND

	MOV wc.cbSize,SizeOf WNDCLASSEX
	MOV wc.style, CS_HREDRAW or CS_VREDRAW
	MOV wc.lpfnWndProc, Offset WndProc
	MOV wc.cbClsExtra,NULL
	MOV wc.cbWndExtra,NULL
	PUSH hInst
	POP wc.hInstance
	MOV wc.hbrBackground,COLOR_WINDOW+1
	MOV wc.lpszMenuName,NULL
	MOV wc.lpszClassName,Offset ClassName
	Invoke LoadIcon,NULL,IDI_APPLICATION
	MOV wc.hIcon,EAX
	MOV wc.hIconSm,0
	Invoke LoadCursor,NULL,IDC_ARROW
	MOV wc.hCursor,EAX
	Invoke RegisterClassEx, addr wc
	Invoke LoadMenu, hInst, Offset MenuName
	MOV hMenu,EAX
	Invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR szAppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,hMenu,\
           hInst,NULL
	MOV hwnd,EAX
	Invoke ShowWindow, hwnd,SW_SHOWNORMAL
	Invoke UpdateWindow, hwnd
	.While TRUE
		Invoke GetMessage, ADDR msg,NULL,0,0
		.Break .If (!EAX)
		Invoke TranslateMessage,ADDR msg
		Invoke DispatchMessage, ADDR msg
	.EndW
	MOV EAX, msg.wParam
	RET
WinMain EndP

WndProc Proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
Local Buffer[MAX_PATH]:BYTE
Local BytesWritten:DWORD

	.If uMsg==WM_DESTROY
		Invoke PostQuitMessage,NULL
	.ElseIf uMsg==WM_COMMAND
		MOV EAX,wParam
		.If AX==IDM_FILE_CREATEFILE
			Invoke GetCurrentDirectory,MAX_PATH,ADDR Buffer
			Invoke lstrcat,ADDR Buffer,Offset szDemoNameEXE
			
			Invoke CreateFile,ADDR Buffer,GENERIC_READ OR GENERIC_WRITE,FILE_SHARE_READ OR FILE_SHARE_WRITE,0,CREATE_NEW,FILE_ATTRIBUTE_NORMAL,0
			.if EAX!=INVALID_HANDLE_VALUE
				PUSH EBX
				PUSH EDI
				MOV EDI,EAX
				Invoke FindResource,0,1001,RT_RCDATA
				MOV EBX,EAX
				Invoke LoadResource,0,EAX
				PUSH EAX
				Invoke SizeofResource,0,EBX
				POP ECX
				LEA EDX,BytesWritten
				Invoke WriteFile,EDI,ECX,EAX,EDX,0
				
				Invoke CloseHandle,EDI
				
				POP EDI
				POP EBX
			.Endif
			
			Invoke ShellExecute,NULL,Offset szOpen,ADDR Buffer ,NULL,NULL,SW_SHOWDEFAULT
			
		.Else
			Invoke DestroyWindow,hWnd
		.EndIf
	.Else
		Invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		RET
	.EndIf
	XOR EAX,EAX
	RET
WndProc EndP

End Start