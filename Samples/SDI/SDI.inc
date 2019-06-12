Include windows.inc
Include user32.inc
Include kernel32.inc
;-------------------------------------------------------------------
;Needed For Debug Window Only
Include masm32.inc
Include debug.inc
;-------------------------------------------------------------------
IncludeLib user32.lib
IncludeLib kernel32.lib
;-------------------------------------------------------------------
;Needed For Debug Window Only
IncludeLib masm32.lib
IncludeLib debug.lib

.DATA
ClassName		DB "MainWinClass",0
szAppName		DB "SDI Application",0
MenuName		DB "FirstMenu",0
szFileNew		DB "You selected 'New'.",0
szFileOpen		DB "You selected 'Open'.",0
szHelpAbout		DB "You selected 'About'.",0

.DATA?
hInstance		HINSTANCE ?
CommandLine		LPSTR ?
hMenu			HMENU ?

.CONST
IDM_FILE_NEW	EQU 1
IDM_FILE_OPEN	EQU 2
IDM_HELP_ABOUT	EQU 3
IDM_FILE_EXIT	EQU 4
