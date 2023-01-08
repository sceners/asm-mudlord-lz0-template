.386
.model	flat, stdcall
option	casemap :none
include	patch.inc
include    dlg_colors.asm

.code
start:
	invoke	GetModuleHandle, NULL
	mov		hInstance, eax
	invoke	InitCommonControls
	invoke	DialogBoxParam, hInstance, IDD_MAIN, 0, offset DlgProc, 0
	invoke	ExitProcess, eax

DlgProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
        LOCAL ps:PAINTSTRUCT

	mov	eax,uMsg
	.if	eax == WM_INITDIALOG
		invoke	LoadIcon,hInstance,200
		invoke 	MakeOwnerDraw,hWin,IDB_PATCH
		invoke 	MakeOwnerDraw,hWin,IDB_ABOUTBOX
		invoke 	MakeOwnerDraw,hWin,IDB_EXIT
		invoke	SendMessage, hWin, WM_SETICON, 1, eax
		invoke 	uFMOD_PlaySong,addr table,xmSize,XM_MEMORY
		m2m scr.scroll_hwnd,hWin
		mov scr.scroll_text, offset ScrollerText
		mov scr.scroll_x,3
		mov scr.scroll_y,0
		mov scr.scroll_width,280
		mov scr.scroll_textcolor,00FFFFFFh
		invoke FindResource,NULL,ID_FONT,RT_RCDATA
		mov hFontRes,eax
		invoke LoadResource,NULL,eax
		.if eax
			invoke LockResource,eax
			mov ptrFont,eax
			invoke SizeofResource,NULL,hFontRes
			invoke AddFontMemResourceEx,ptrFont,eax,0,addr nFont
		.endif
		invoke CreateFontIndirect,addr lfFont
		mov scr.scroll_hFont,eax
		invoke CreateScroller,addr scr

	.elseif eax==WM_DRAWITEM
		invoke 	DrawButtonColor,hWin,lParam,BUTTON_COLOR,BUTTON_TEXT_COLOR,BUTTON_FRAME_COLOR
		ret
	.elseif eax==WM_CTLCOLORDLG
		invoke 	GetWindowDC,hWin
		invoke 	SelectObject,eax,hWin
		invoke 	CreateSolidBrush,000000h
	         ret
	.elseif eax == WM_COMMAND
		mov	eax,wParam
		.if	eax == IDB_EXIT
			invoke	SendMessage, hWin, WM_CLOSE, 0, 0
		.endif
		.if       eax==IDB_ABOUTBOX
		         invoke	DialogBoxParam, hInstance, IDD_ABOUT, 0, offset AboutProc, 0
	         .endif
		.if       eax==IDB_PATCH
		         invoke FileProc_Offset,hWin
	         .endif
	.elseif	eax == WM_CLOSE
		invoke	EndDialog, hWin, 0
	.endif
	xor	eax,eax
	ret
DlgProc endp

end start