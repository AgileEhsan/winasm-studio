include windows.inc
;include masm32.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include shell32.inc
include comctl32.inc
include comdlg32.inc
;include debug.inc	

;includelib masm32.lib
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib shell32.lib
includelib comctl32.lib
includelib comdlg32.lib
;includelib debug.lib

WinMain					PROTO :DWORD,:DWORD,:DWORD,:DWORD

.CONST
IDB_TOOLBAR				equ 51
IDR_MAINMENU			equ	101
IDR_CHILDMENU			equ	102
IDM_FILE_NEW			equ	201
IDM_FILE_OPEN			equ 202
IDM_FILE_CLOSE			equ	203
IDM_FILE_SAVE			equ 204
IDM_FILE_SAVEAS			equ 205
IDM_FILE_SETUP			equ 206
IDM_FILE_PREVIEW		equ 207
IDM_FILE_PRINT			equ 208
IDM_FILE_EXIT 			equ	210
IDM_EDIT_CUT			equ 211
IDM_EDIT_COPY			equ 212
IDM_EDIT_PASTE			equ 213
IDM_VIEW_TOOLBAR		equ 217
IDM_VIEW_STATUS			equ 218
IDM_FORMAT_BOLD			equ 220
IDM_FORMAT_ITALIC		equ 221
IDM_FORMAT_UNDERLINE	equ 222
IDM_FORMAT_LEFT			equ 223
IDM_FORMAT_CENTER		equ 224
IDM_FORMAT_RIGHT		equ 225
IDM_WIN_TILEHORZ		equ	229
IDM_WIN_TILEVERT		equ	230
IDM_WIN_CASCADE			equ	231
IDM_HELP_CONTENTS		equ 232
IDM_HELP_ABOUT			equ 233
ID_TOOLBAR				equ 250

.DATA
szClassName				db "FrameClass",0
szClientName			db "MDICLIENT",0
szChildClass			db "ChildClass",0
szChildTitle			db "Child Window",0
szAppName				db "MDI Template",0
;szLibName           	db "somedll.dll",0
tbClass             	db "ToolbarWindow32",0

tbb		TBBUTTON <0, IDM_FILE_NEW,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,0>
		TBBUTTON <1, IDM_FILE_OPEN,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,0>
		TBBUTTON <2, IDM_FILE_SAVE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,0>
		TBBUTTON <0, 0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0,0>
		TBBUTTON <3, IDM_FILE_PREVIEW,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,0>
		TBBUTTON <4, IDM_FILE_PRINT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,0>
		TBBUTTON <0, 0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0,0>
		TBBUTTON <5, IDM_EDIT_CUT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,0>
		TBBUTTON <6, IDM_EDIT_COPY,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,0>
		TBBUTTON <7, IDM_EDIT_PASTE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,0>
		TBBUTTON <0, 0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0,0>
		TBBUTTON <8, IDM_FORMAT_BOLD,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,0>
		TBBUTTON <9, IDM_FORMAT_ITALIC,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,0>
		TBBUTTON <10,IDM_FORMAT_UNDERLINE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,0>
		TBBUTTON <0, 0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0,0>
		TBBUTTON <11,IDM_FORMAT_LEFT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,0>
		TBBUTTON <12,IDM_FORMAT_CENTER,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,0>
		TBBUTTON <13,IDM_FORMAT_RIGHT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,0>
		TBBUTTON <0, 0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0,0>
		TBBUTTON <14,IDM_HELP_ABOUT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0,0>
		TBBUTTON <0, 0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0,0>

.data?
hInstance			dd ?
hMainMenu			dd ?
hChildMenu			dd ?
hClient				dd ?
hWndMain			dd ?
hStatus             dd ?
hToolbar            dd ?
hLib				dd ?

mdiCreate			MDICREATESTRUCT <>
;---------------------------------------------
LOWORD MACRO bigword  
       mov  eax,bigword
       and  eax,0FFFFh      
ENDM
;---------------------------------------------
HIWORD MACRO bigword  
       mov  eax,bigword
       shr  eax,16
ENDM       
;---------------------------------------------
