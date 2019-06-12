Include windows.inc
Include user32.inc
Include kernel32.inc
Include shell32.inc
;-------------------------------------------------------------------
;Needed For Debug Window Only
Include masm32.inc
Include debug.inc
;-------------------------------------------------------------------
IncludeLib user32.lib
IncludeLib kernel32.lib
IncludeLib SHELL32.LIB
;-------------------------------------------------------------------
;Needed For Debug Window Only
IncludeLib masm32.lib
IncludeLib debug.lib

.DATA
szOpen			DB "open",0
szDemoNameEXE	DB "\DemoName.exe",0
ClassName		DB "MainWinClass",0
szAppName		DB "Raw Data Demo",0
MenuName		DB "FirstMenu",0

.DATA?
hInstance		HINSTANCE ?
CommandLine		LPSTR ?
hMenu			HMENU ?

.CONST
IDM_FILE_CREATEFILE	EQU 2
IDM_FILE_EXIT		EQU 4
