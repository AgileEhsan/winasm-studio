.386

.MODEL FLAT,STDCALL

OPTION CASEMAP:NONE

Include MDI.inc
Include Misc.asm

.CODE

Start:
	;Invoke LoadLibrary, ADDR szLibName
	;MOV hLib,EAX
	Invoke GetModuleHandle, NULL
	MOV hInstance,EAX
	Invoke InitCommonControls
	Invoke WinMain, hInstance, NULL, NULL, SW_SHOWDEFAULT
    ;Invoke FreeLibrary, hLib
	Invoke ExitProcess, EAX
		
WinMain Proc hInst:HINSTANCE,hPrevInst:HINSTANCE,cmdLine:LPSTR,cmdShow:DWORD
Local wc:WNDCLASSEX
Local msg:MSG
	
	MOV wc.cbSize,SIZEOF WNDCLASSEX
	MOV wc.style,CS_HREDRAW OR CS_VREDRAW
	MOV wc.lpfnWndProc,OFFSET WndProc
	MOV wc.cbClsExtra,NULL
	MOV wc.cbWndExtra,NULL
	PUSH hInst
	POP wc.hInstance
	MOV wc.hbrBackground,COLOR_APPWORKSPACE+1
	MOV wc.lpszMenuName,IDR_MAINMENU
	MOV wc.lpszClassName,OFFSET szClassName
	Invoke LoadIcon, NULL, IDI_APPLICATION
	MOV wc.hIcon,EAX
	MOV wc.hIconSm,EAX
	Invoke LoadCursor, NULL, IDC_ARROW
	MOV wc.hCursor,EAX
	Invoke RegisterClassEx, ADDR wc
	
	MOV wc.lpfnWndProc,OFFSET ChildProc
	MOV wc.hbrBackground,COLOR_BTNFACE+1
	MOV wc.lpszClassName,OFFSET szChildClass
	MOV wc.cbWndExtra,4
	MOV wc.lpszMenuName,IDR_CHILDMENU
	Invoke RegisterClassEx, ADDR wc
	Invoke CreateWindowEx, NULL,ADDR szClassName, ADDR szAppName, WS_OVERLAPPEDWINDOW OR WS_CLIPCHILDREN, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, NULL, 0, hInst,NULL
	MOV hWndMain,EAX
	Invoke LoadMenu, hInst, IDR_CHILDMENU
	MOV hChildMenu,EAX
	Invoke ShowWindow, hWndMain, SW_MAXIMIZE
	Invoke UpdateWindow, hWndMain
	.While TRUE
		Invoke GetMessage, ADDR msg, NULL, 0, 0
	  	.Break .If !EAX
		Invoke TranslateMDISysAccel, hClient, ADDR msg
		.If !EAX
			Invoke TranslateMessage, ADDR msg
			Invoke DispatchMessage, ADDR msg
		.EndIf
	.Endw
	Invoke DestroyMenu, hChildMenu
	MOV	EAX,msg.wParam
	RET
WinMain EndP
WndProc Proc hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
Local clientStrc	:CLIENTCREATESTRUCT
Local rcClFrame		:RECT
Local rcTlbar		:RECT
Local rcStatus		:RECT
Local ptTlbar		:POINT
Local ptStatus		:POINT

	.If uMsg==WM_CREATE
		Invoke GetMenu,hWnd
		MOV hMainMenu,EAX
		Invoke GetSubMenu,hMainMenu,4
		MOV clientStrc.hWindowMenu,EAX
		MOV clientStrc.idFirstChild,401
		Invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR szClientName, NULL, WS_CHILD OR WS_VISIBLE OR WS_CLIPCHILDREN, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, hWnd, NULL, hInstance, ADDR clientStrc
		MOV hClient,EAX
		
		MOV mdiCreate.szClass, offset szChildClass
		MOV mdiCreate.szTitle, offset szChildTitle
		PUSH hInstance
		POP mdiCreate.hOwner
		;MOV mdiCreate.style,MDIS_ALLCHILDSTYLES
		MOV mdiCreate.x,CW_USEDEFAULT
		MOV mdiCreate.y,CW_USEDEFAULT
		MOV mdiCreate.lx,CW_USEDEFAULT
		MOV mdiCreate.ly,CW_USEDEFAULT
		Invoke CreateToolbarEx, hWnd, WS_CHILD OR WS_CLIPCHILDREN OR WS_CLIPSIBLINGS OR TBSTYLE_TOOLTIPS OR CCS_TOP, ID_TOOLBAR, 1, hInstance, IDB_TOOLBAR, ADDR tbb, 21, 16, 16, 16, 16, SizeOf TBBUTTON
		MOV hToolbar,EAX
    	Invoke SendMessage, hToolbar, TB_SETSTYLE, 0, TBSTYLE_FLAT OR CCS_TOP
    	Invoke ShowWindow, hToolbar, TRUE
		Invoke CreateStatus, hWnd
	.ElseIf uMsg==WM_COMMAND
		MOV EAX,wParam
		.If AX==IDM_FILE_EXIT
			Invoke SendMessage, hWnd, WM_CLOSE, 0, 0
		.ElseIf AX==IDM_WIN_TILEHORZ
			Invoke SendMessage, hClient, WM_MDITILE, MDITILE_HORIZONTAL, 0 
		.ElseIf AX==IDM_WIN_TILEVERT
			Invoke SendMessage, hClient, WM_MDITILE, MDITILE_VERTICAL, 0
		.ElseIf AX==IDM_WIN_CASCADE
			Invoke SendMessage, hClient, WM_MDICASCADE, MDITILE_SKIPDISABLED, 0
		.ElseIf AX==IDM_FILE_NEW
			Invoke SendMessage, hClient, WM_MDICREATE, 0, ADDR mdiCreate 
		.ElseIf AX==IDM_FILE_CLOSE
			Invoke SendMessage, hClient, WM_MDIGETACTIVE, 0, 0
			MOV EDX,EAX
			Invoke SendMessage, EDX, WM_CLOSE, 0, 0
		.Else
			Invoke DefFrameProc, hWnd, hClient, uMsg, wParam, lParam	
			RET
		.EndIf
	.ElseIf uMsg==WM_SIZE
		.If hClient!=NULL
			Invoke GetClientRect, hWnd, ADDR rcClFrame
			Invoke SendMessage, hToolbar, TB_AUTOSIZE, 0, 0
			Invoke MoveWindow, hStatus, 0, 0, 0, 0, TRUE
			Invoke GetWindowRect, hToolbar, ADDR rcTlbar
			Invoke GetWindowRect, hStatus, ADDR rcStatus
			MOV ptStatus.x,0
			MOV ptTlbar.x,0
			PUSH rcStatus.top
			POP ptStatus.y
			Invoke ScreenToClient, hWnd, ADDR ptStatus
			PUSH rcTlbar.bottom
			POP ptTlbar.y
			Invoke ScreenToClient, hWnd, ADDR ptTlbar
			MOV EAX,ptStatus.y
			SUB EAX,ptTlbar.y             ;EAX=MDIClient height
			MOV EDX,EAX
			Invoke MoveWindow, hClient, 0, ptTlbar.y, rcClFrame.right, EDX, TRUE
		.EndIf
	
	.ElseIf uMsg==WM_DESTROY
		Invoke PostQuitMessage,NULL		
	.Else
		Invoke DefFrameProc, hWnd, hClient, uMsg, wParam, lParam		
		RET
	.EndIf
	XOR EAX,EAX
	RET
WndProc EndP
ChildProc Proc hChild:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
Local nWidth	:DWORD
Local nHeight	:DWORD

	.If uMsg==WM_MDIACTIVATE
		MOV EAX,lParam
		.If EAX==hChild
			Invoke GetSubMenu,hChildMenu,3
			MOV EDX,EAX
			Invoke SendMessage,hClient,WM_MDISETMENU,hChildMenu,EDX
		.Else
			Invoke GetSubMenu,hMainMenu,3   
			MOV EDX,EAX 
			Invoke SendMessage,hClient,WM_MDISETMENU,hMainMenu,EDX 
		.EndIf
		Invoke DrawMenuBar,hWndMain 
;------------------------------------------------------------------------------		
	.ElseIf uMsg==WM_CREATE
;------------------------------------------------------------------------------
	.ElseIf uMsg==WM_SIZE
		LOWORD lParam
		MOV nWidth,EAX
		HIWORD lParam
		MOV nHeight,EAX
		
		;Move any children windows of the MDI Child here
		;Using GetWindowLong ?
		;-----------------------------------------------

		Invoke DefMDIChildProc,hChild,uMsg,wParam,lParam    
		RET 
;------------------------------------------------------------------------------
	.ElseIf uMsg==WM_CLOSE
			Invoke SendMessage,hClient,WM_MDIDESTROY,hChild,0 
;------------------------------------------------------------------------------	
	.ElseIf uMsg==WM_DESTROY
;------------------------------------------------------------------------------	
	.Else 	
		Invoke DefMDIChildProc,hChild,uMsg,wParam,lParam    
		RET 
	.EndIf
	XOR EAX,EAX
	RET
ChildProc EndP

End Start