
;******************************************************************************
;* PROTOTYPES                                                                 *
;******************************************************************************	
DrawControlFrame			PROTO :DWORD,:DWORD,:DWORD,:DWORD
DrawButtonColor				PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MakeOwnerDraw				PROTO :DWORD,:DWORD


;******************************************************************************
;* CODE                                                                       *
;******************************************************************************
.code
;---use on WM_INITDIALOG
MakeOwnerDraw proc _dlghandle:dword,_id:dword
	pushad
	
	;---make button owner draw---
	invoke GetDlgItem,_dlghandle,_id
	invoke SendMessage,eax,BM_SETSTYLE,BS_OWNERDRAW,TRUE
	
	popad
	ret
MakeOwnerDraw endp


;---use on WM_DRAWITEM---
DrawButtonColor proc uses esi _dialoghandle:dword,_lparam:dword,_background_color:dword,_text_color:dword,_frame_color:dword

	LOCAL sBtnText [256]:BYTE
	
	;use "MakeOwnerDraw" function on WM_INITDIALOG before!
	
	;---Button Colors---
	mov esi,_lparam
	assume esi:ptr DRAWITEMSTRUCT
	
	.if [esi].CtlType==ODT_BUTTON
	
		;---frame color---
		invoke CreatePen,PS_INSIDEFRAME,1,_frame_color
		invoke SelectObject,[esi].hdc,eax
		
		;---Background Color---
		invoke CreateSolidBrush,_background_color		
		invoke SelectObject,[esi].hdc,eax
		
		;---draw frame---
		invoke RoundRect,[esi].hdc,[esi].rcItem.left,[esi].rcItem.top,[esi].rcItem.right,[esi].rcItem.bottom,5,5
		
		.if [esi].itemState & ODS_SELECTED
		    invoke OffsetRect,addr [esi].rcItem,1,1
		.endif
		
		;---write the text---
		invoke GetDlgItemText,_dialoghandle,[esi].CtlID,addr sBtnText,sizeof sBtnText
		invoke SetBkMode,[esi].hdc,TRANSPARENT
		invoke SetTextColor,[esi].hdc,_text_color		;ButtonText Color
		invoke DrawText,[esi].hdc,addr sBtnText,-1,addr [esi].rcItem,DT_CENTER or DT_VCENTER or DT_SINGLELINE
		
		;---move text when button pressed---
		.if [esi].itemState & ODS_SELECTED
		    invoke OffsetRect,addr [esi].rcItem,-1,-1
		.endif
		
	.endif
	
	assume esi:nothing
	
	mov eax,TRUE
	ret
DrawButtonColor endp