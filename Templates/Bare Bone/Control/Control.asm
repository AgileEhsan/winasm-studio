.386

.MODEL FLAT,STDCALL

OPTION CASEMAP:NONE

;-------------------------------------------------------------------------
Include WINDOWS.INC
Include user32.inc
;Include kernel32.inc
;Include gdi32.inc
;Include shell32.inc

;Needed for debug
;----------------
;Include masm32.inc
;Include debug.inc
;-------------------------------------------------------------------------
IncludeLib user32.lib
;IncludeLib kernel32.lib
;IncludeLib gdi32.lib
;IncludeLib shell32.lib

;Needed for debug
;----------------
;IncludeLib masm32.lib
;IncludeLib debug.lib
;-------------------------------------------------------------------------

Include Control.inc


.DATA
szControlClass		DB "MyControl",0

.CODE

InitCustomControl Proc hInst:HINSTANCE
Local wc	:WNDCLASSEX

	MOV wc.cbSize,SizeOf WNDCLASSEX
	MOV wc.style,CS_GLOBALCLASS
	MOV wc.lpfnWndProc,Offset CustomControlProc
	MOV wc.cbClsExtra,0
	MOV wc.cbWndExtra,4
	
	MOV EAX,hInst
	MOV wc.hInstance,EAX
	
	Invoke LoadCursor,NULL,IDC_ARROW
	MOV wc.hCursor,EAX
	MOV wc.hbrBackground,COLOR_WINDOW+1;NULL <---depending on what you want to do
	MOV wc.lpszMenuName,NULL
	MOV wc.lpszClassName,Offset szControlClass
	MOV wc.hIcon,NULL
	MOV wc.hIconSm,NULL
	
	Invoke RegisterClassEx,ADDR wc
	
	RET
InitCustomControl EndP

DllEntry Proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD

	.If reason==DLL_PROCESS_ATTACH
		Invoke InitCustomControl,hInst
	.ElseIf reason==DLL_PROCESS_DETACH
		Invoke UnregisterClass,Offset szControlClass,hInst
	.EndIf
	MOV EAX,TRUE
	RET

DllEntry EndP


CustomControlProc Proc hCtrl:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

	MOV EAX,uMsg
	.If EAX==WM_CREATE
	.Else
		Invoke DefWindowProc,hCtrl,uMsg,wParam,lParam
		RET
	.EndIf
	XOR EAX,EAX
	RET
	
CustomControlProc EndP

End DllEntry