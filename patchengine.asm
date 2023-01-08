;**********************************************************************************************
;* Example (how to use)                                                                       *
;* ------------------------------------------------------------------------------------------ *
;* search : 2A 45 EB ?? C3 ?? EF                                                              *
;* replace: 2A ?? ?? 10 33 C0 ??                                                              *
;*                                                                                            *
;* .data                                                                                      *
;* SearchPattern   db 02Ah, 045h, 0EBh, 000h, 0C3h, 000h, 0EFh                                *
;* SearchMask      db    0,    0,    0,    1,    0,    1,    0	 ;(1=Ignore Byte)             *
;*                                                                                            *
;* ReplacePattern  db 02Ah, 000h, 000h, 010h, 033h, 0C0h, 000h                                *
;* ReplaceMask     db    0,    1,    1,    0,    0,    0,    1	 ;(1=Ignore Byte)             *
;*                                                                                            *
;* .const                                                                                     *
;* PatternSize     equ 7                                                                      *
;*                                                                                            *
;* .code                                                                                      *
;* push -1                      ;Replace Number (-1=ALL / 2=2nd match ...)                    *
;* push FileSize                ;how many bytes to search from beginning from TargetAdress    *
;* push PatternSize             ;lenght of Pattern                                            *
;* push offset ReplaceMask                                                                    *
;* push offset ReplacePattern                                                                 *
;* push offset SearchMask                                                                     *
;* push offset SearchPattern                                                                  *
;* push TargetAddress           ;the memory address where the search starts                   *
;* call SearchAndReplace                                                                      *
;*                                                                                            *
;* ReturnValue in eax (1=Success 0=Failed)                                                    *
;**********************************************************************************************
.586					
.model flat, stdcall
option casemap :none
include patch.inc

SearchAndReplace PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
PatchFile_SnR PROTO:dword,:dword,:dword,:dword,:dword
;OffsetPatch,addr File1,PatchOffs1,addr PatchBytes1,PatchLen1    
;returns 1 on error, 0 on success
OffsetPatch   PROTO    lpszFile:DWORD,Offs:DWORD,lpBytes:DWORD,cBytelen:DWORD

.data
ofn   OPENFILENAME <> 
FilterString db "Target EXE",0,"*.exe",0 
                     db "All Files",0,"*.*",0,0 
filename db MAX_PATH dup(0) 

SearchPattern1		db 08h, 05h, 03Ah, 0B7h, 5Ch, 00h, 59h, 59h, 74h, 10h
SearchMask1			db 0,      0,     1,        1,         1,      0,      0,      0,     0,      0,	 ;(1=Ignore Byte)

ReplacePattern1		db 0FEh, 05h, 03Ah, 0B7h, 5Ch, 00h, 59h, 59h, 74h, 10h
ReplaceMask1		  	db 0,         1,     1,        1,         1,      1,      1,      1,     1,      1, ;(1=Ignore Byte)

File1   db  '.\win32\9.0-2\lib\jpgprof.dll',0
PatchOffs1  dd  70000h  ; edited
PatchBytes1 db  00h,00h,00h,00h,00h,00h,00h,00h ; edited
PatchLen1   equ $-PatchBytes1

.data?

.code

FileProc_Offset proc hWnd:HWND
	mov ofn.lStructSize,SIZEOF ofn 
     	push hWnd 
      	pop  ofn.hWndOwner 
       	push hInstance 
     	pop  ofn.hInstance 
       	mov  ofn.lpstrFilter, OFFSET FilterString 
      	mov  ofn.lpstrFile, OFFSET filename 
     	mov  ofn.nMaxFile,MAX_PATH 
     	mov  ofn.Flags, OFN_FILEMUSTEXIST or \ 
                                	OFN_PATHMUSTEXIST or OFN_LONGNAMES or\ 
                                	OFN_EXPLORER or OFN_HIDEREADONLY 
	invoke GetOpenFileName, ADDR ofn 
   	.if eax==TRUE 
    		invoke OffsetPatch,addr filename,PatchOffs1,addr PatchBytes1,PatchLen1  
    		.if eax==0 	
		invoke MessageBox,hWnd,chr$("Patching successfull!"),chr$("YAY!!"),MB_ICONINFORMATION
		.else
		invoke MessageBox,hWnd,chr$("Patching failed!"),chr$("BOO!!"),MB_ICONSTOP
		.endif
  	.endif
	Ret
FileProc_Offset EndP

FileProc_SnR proc hWnd:HWND
       	mov ofn.lStructSize,SIZEOF ofn 
     	push hWnd 
      	pop  ofn.hWndOwner 
       	push hInstance 
     	pop  ofn.hInstance 
       	mov  ofn.lpstrFilter, OFFSET FilterString 
      	mov  ofn.lpstrFile, OFFSET filename 
     	mov  ofn.nMaxFile,MAX_PATH 
     	mov  ofn.Flags, OFN_FILEMUSTEXIST or \ 
                                	OFN_PATHMUSTEXIST or OFN_LONGNAMES or\ 
                                	OFN_EXPLORER or OFN_HIDEREADONLY 
	invoke GetOpenFileName, ADDR ofn 
        
   	.if eax==TRUE 
    		invoke PatchFile_SnR,addr filename, addr SearchPattern1, addr SearchMask1,addr ReplacePattern1,addr ReplaceMask1 
 	
		invoke MessageBox,hWnd,chr$("Patching successfull!"),chr$("YAY!!"),MB_ICONINFORMATION
  	.endif
	Ret
FileProc_SnR EndP

PatchFile_SnR proc _targetfile:dword,SearchPattern:dword,SearchMask:dword,ReplacePattern:dword,ReplaceMask:dword
	LOCAL local_hFile	:DWORD
	LOCAL local_hFileMapping:DWORD
	LOCAL local_hViewOfFile :DWORD
	LOCAL local_retvalue	:DWORD
	LOCAL local_filesize	:DWORD
	pushad
	mov local_retvalue,0
	invoke CreateFile,_targetfile,GENERIC_READ+GENERIC_WRITE,FILE_SHARE_WRITE,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL+FILE_ATTRIBUTE_HIDDEN,0
	.if eax!=INVALID_HANDLE_VALUE
		mov local_hFile,eax
		invoke CreateFileMapping,eax,0,PAGE_READWRITE,0,0,0
		.if eax!=NULL
			mov local_hFileMapping,eax
			invoke MapViewOfFile,eax,FILE_MAP_WRITE,0,0,0
			.if eax!=NULL
				mov local_hViewOfFile,eax
				invoke GetFileSize,local_hFile,0
				mov local_filesize,eax
				push 1
				push local_filesize
				push sizeof SearchPattern
				push  ReplaceMask
				push ReplacePattern
				push  SearchMask
				push  SearchPattern
				push local_hViewOfFile
				call SearchAndReplace
				mov local_retvalue,eax
				invoke UnmapViewOfFile,local_hViewOfFile
			.endif
			invoke CloseHandle,local_hFileMapping
		.endif
		invoke CloseHandle,local_hFile
	.endif
	popad
	mov eax,local_retvalue
	ret
PatchFile_SnR endp

OffsetPatch   proc    lpszFile:DWORD,Offs:DWORD,lpBytes:DWORD,cBytelen:DWORD
    LOCAL filehandle:DWORD    
    LOCAL BytesWritten:DWORD
    LOCAL local_retvalue	:DWORD
    pushad
    INVOKE CreateFile,lpszFile,GENERIC_READ or GENERIC_WRITE,NULL,NULL,OPEN_EXISTING,\	
                      FILE_ATTRIBUTE_NORMAL,NULL
    .IF eax==INVALID_HANDLE_VALUE
        popad   ; error, exit procedure
        mov eax,1
        ret
    .ENDIF
    mov filehandle,eax
    INVOKE SetFilePointer,filehandle,Offs,0,FILE_BEGIN
    .IF eax==-1
        popad   ; error, exit procedure
       mov eax,1
        ret
    .ENDIF
    INVOKE WriteFile,filehandle,lpBytes,cBytelen,addr BytesWritten,NULL
    .IF eax==0
        popad   ; error, exit procedure
        mov eax,1
        ret
    .ENDIF                    
    INVOKE CloseHandle,filehandle
    popad             
    mov eax,0 ;yay!
    ret
OffsetPatch    endp

SearchAndReplace proc	_targetadress:dword,_searchpattern:dword,_searchmask:dword,_replacepattern:dword,
			_replacemask:dword,_patternsize:dword,_searchsize:dword,_patchnumber:dword
			
	LOCAL local_returnvalue	:byte 	;returns if something was patched
	LOCAL local_match	:dword	;counts how many matches
	pushad
	mov local_returnvalue,0
	mov local_match,0
	mov edi,_targetadress
	mov esi,_searchpattern
	mov edx,_searchmask
	mov ebx,_patternsize
	xor ecx,ecx
	.while ecx!=_searchsize
		@search_again:
		;---check if pattern exceed memory---
		mov eax,ecx		;ecx=raw offset
		add eax,ebx		;raw offset + patternsize
		cmp eax,_searchsize
		ja @return		;if (raw offset + patternsize) > searchsize then bad!
		push ecx		;counter
		push esi		;searchpattern
		push edi		;targetaddress
		push edx		;searchmask
		mov ecx,ebx		;ebx=patternsize
		@cmp_mask:
		test ecx,ecx
		je @pattern_found
		cmp byte ptr[edx],1	;searchmask
		je @ignore
		lodsb			;load searchbyte to al & inc esi
		scasb			;cmp al,targetadressbyte & inc edi
		jne @skip
		inc edx			;searchmask
		dec ecx			;patternsize
		jmp @cmp_mask
		@ignore:
		inc edi			;targetadress
		inc esi			;searchpattern
		inc edx			;searchmask
		dec ecx			;patternsize
		jmp @cmp_mask
		@skip:
		pop edx
		pop edi			;targetadress
		pop esi			;searchpattern
		pop ecx
		inc edi			;targetadress
		inc ecx			;counter
	.endw
	;---scanned whole memory size---
	jmp @return	
	@pattern_found:
	inc local_match
	pop edx
	pop edi				;targetadress
	pop esi
	mov eax,_patchnumber
	cmp eax,-1
	je @replace			
	cmp local_match,eax
	je @replace
	pop ecx				;counter
	inc edi				;targetadress
	jmp @search_again
	;---replace pattern---
	@replace:
	mov esi,_replacepattern
	mov edx,_replacemask
	xor ecx,ecx
	.while ecx!=ebx			;ebx=patternsize
		@cmp_mask_2:
		cmp byte ptr[edx],1
		je @ignore_2
		lodsb			;load replacebyte to al from esi & inc esi
		stosb			;mov byte ptr[edi],al & inc edi
		jmp @nextbyte
		@ignore_2:
		inc edi			;targetadress
		inc esi			;replacepattern
		@nextbyte:
		inc edx			;replacemask
		inc ecx			;counter
	.endw
	mov local_returnvalue,1		;yes, something was patched
	;---search again?---
	pop ecx				;counter-->scanned size
	cmp _patchnumber,-1
	jne @return
	sub edi,ebx			;edi=targetadress ; countinue where stopped
	inc edi				;...
	inc ecx				;ecx=counter(pointer to offset)  /bug fixed in v2.07
	mov esi,_searchpattern
	mov edx,_searchmask
	jmp @search_again
	;---return---
	@return:
	popad
	movzx eax,local_returnvalue
	ret
SearchAndReplace endp

END

