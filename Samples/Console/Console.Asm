; This is a sample Console program, author unknown.
; This program will request input for a string and print out the string reversed in upper case.

Include Console.Inc

.CODE

Start:

	Invoke Main
	Invoke ExitProcess,0

Main Proc
	XOR EAX,EAX
	Get_Input Msg1, inbuf
	Invoke ReverseText,Offset inbuf,Offset textbuf2
	Invoke Ucase,Offset textbuf2
	;Invoke ClearScreen
	Print_Text Msg2
	Print_Text inbuf
	Print_Text Msg3
	Print_Text textbuf2
	Print_Text CRLF
	Get_Input Msg4,inbuf
	RET
Main EndP

; Reverses source string to destination string
ReverseText Proc Uses EBX,_src:PTR,_dst:PTR
	Invoke GetStrLen,_src		; Get the string lenghth returned in EAX
	MOV ECX,_src				; Move source string pointer into ECX (cannot do memory indirection fromm emory operand)
	MOV EDX,_dst				; Move destination string pointer into EDX(cannot do memory indirection fromm emory operand)
	MOV BYTE PTR[EDX+EAX],NULL	; Set the end of the string
next_char:
	MOV BL,BYTE PTR[ECX+EAX-1]	; Copy last BYTE of source string to BL
	MOV [EDX],BL				; Copy BL to first BYTE of destination string
	INC EDX						; Increment destination pointer
	DEC EAX						; Decrement source pointer index
	JG	next_char				; When index is zero exit
	RET
ReverseText EndP

;Converts a string to upper case
Ucase Proc,_str:PTR
	Invoke GetStrLen,_str			; Get the string length returned in EAX
	MOV ECX,_str					; Initialize source strng pointer
next_char:
	CMP BYTE PTR[ECX+EAX-1],"a"		; Compare BYTE value with ascii "a"(61H)
	JB inc_char
	CMP BYTE PTR[ECX+EAX-1],"z"		; Compare BYTE value with ascii "z"(7AH)
	JA inc_char
	ADD BYTE PTR[ECX+EAX-1],"A"-"a"	; 61H<=BYTE value<=7AH
inc_char:
	DEC EAX							; Update index
	JG next_char					; if index is >=0 do the next char
	RET
Ucase EndP

; Gets the length of a string(not including the NULL terminator)
GetStrLen Proc ,_str:PTR
	MOV ECX,_str				; Move source pointer to ECX
	MOV EAX,-1					; Start of at -1 so we can build a faster loop
next_char:
	INC EAX						; EAX==NULL	
	CMP BYTE PTR[ECX+EAX],NULL
	JNE next_char				; If BYTE is not equal to NULL process next .
	RET							; Returns string length in EAX
GetStrLen EndP

End Start
