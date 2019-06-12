
Include windows.inc
Include kernel32.inc
Include user32.inc
Include Comctl32.inc
Include shell32.inc

IncludeLib kernel32.lib
IncludeLib user32.lib
IncludeLib Comctl32.lib
IncludeLib shell32.lib

DlgProc			PROTO	:HWND,:UINT,:WPARAM,:LPARAM
ModuleOne		PROTO	:HWND
ModuleTwo		PROTO	:HWND


.const

IDD_DIALOG1		equ 101
IDC_BTN1		equ 1001
IDC_BTN2		equ 1002

;#########################################################################

.data?

hInstance		dd ?

;#########################################################################
