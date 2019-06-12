include		windows.inc
include		user32.inc
include		kernel32.inc

includelib	user32.lib
includelib	kernel32.lib

WinMain		PROTO	:DWORD,:DWORD,:DWORD,:DWORD
DlgProc		PROTO	:HWND, :DWORD, :DWORD, :DWORD

.data
ClassName	db	"SimpleWinClass",0
AppName		db	"Our Main Window",0
MenuName	db	"FirstMenu",0
DlgName		db	"MyDialog",0
TestString	db	"Hello, everybody",0

.data?
hInstance	HINSTANCE	?
CommandLine	LPSTR		?

.const
IDM_EXIT	equ 1
IDM_ABOUT	equ 2
IDC_EDIT	equ 3000
IDC_BUTTON	equ 3001
IDC_EXIT	equ 3002