include windows.inc
include user32.inc
include kernel32.inc
include comctl32.inc	;windows common controls
include masm32.inc
include comdlg32.inc 
include libs/ufmod.inc
include winmm.inc
include libs/TextScroller.inc
includelib libs/TextScroller.lib
includelib libs/ufmod.lib
include \masm32\macros\macros.asm


includelib winmm.lib
includelib ufmod.lib
includelib	user32.lib
includelib	kernel32.lib
includelib	comctl32.lib	;windows common controls
includelib comdlg32.lib 
include gdi32.inc
includelib gdi32.lib

DlgProc		PROTO	:DWORD,:DWORD,:DWORD,:DWORD
AboutProc	PROTO	:DWORD,:DWORD,:DWORD,:DWORD
FileProc_SnR PROTO:HWND
FileProc_Offset PROTO:HWND

.const
IDD_MAIN				equ	1000
IDD_ABOUT     				equ 1004
IDB_ABOUTBOX     			equ 1005
IDB_EXIT					equ	1001
IDB_PATCH 				equ 1003
BUTTON_COLOR			equ 00000000h
BUTTON_TEXT_COLOR		equ 00FFFFFFh
BUTTON_FRAME_COLOR	equ 00FFFFFFh
ID_FONT					equ	2000

.data
include result.inc
xmSize equ $ - table

ScrollerText TCHAR "Enjoy this fine Linezer0 release! Please support the developer if you like this app.........",
				"Greetz fly out to all our friends in the scene.......",0
lfFont  LOGFONT	<8,0,0,0,FW_DONTCARE,0,0,0,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,\
									DEFAULT_QUALITY	,DEFAULT_PITCH or FF_DONTCARE,'ACKNOWLEDGE -BRK-'>
nFont				dd		1


.data?
hInstance	dd	?
scr				SCROLLER_STRUCT <>
hFontRes				dd		?
ptrFont				dd		?
