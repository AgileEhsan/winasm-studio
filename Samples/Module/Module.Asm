; This is a demonstration of calling a Public procedure in another module.

.386 
.MODEL FLAT, STDCALL
OPTION CASEMAP:NONE

Include Module.inc

.CODE

Start:

	Invoke GetModuleHandle,NULL
	MOV		hInstance,EAX

    Invoke InitCommonControls
	Invoke DialogBoxParam,hInstance,IDD_DIALOG1,NULL,addr DlgProc,NULL
	Invoke ExitProcess,0

;########################################################################

DlgProc Proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	MOV EAX,uMsg
	.If EAX==WM_COMMAND
		MOV		EDX,wParam
		MOVZX	EAX,DX
		SHR		EDX,16
		.If EDX==BN_CLICKED
			.If EAX==1001
				Invoke ModuleOne,hWin
			.ElseIf EAX==1002
				Invoke ModuleTwo,hWin
			.EndIf
		.EndIf
	.ElseIf EAX==WM_CLOSE
		Invoke EndDialog,hWin,0
	.Else
		MOV		EAX,FALSE
		RET
	.EndIf
	MOV		EAX,TRUE
	RET

DlgProc EndP

End Start
