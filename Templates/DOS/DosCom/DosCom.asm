;  A 16-bit DOS HelloWorld program originally by RedOx.  Produces a tiny model .com executable.

; To assemble and link from within WinAsm Studio, you must have a special 16-bit linker, 
; such as the one in the archive at this URL- http://win32assembly.online.fr/files/Lnk563.exe
; Run the archive to unpack Link.exe, rename the Link.exe file to Link16.exe and copy it
; into the \masm32\bin folder.
;
; To produce a .COM file, .model must be tiny, also you must add /tiny to the linker command line

.model tiny
.data
      msg   db "This is a 16-bit DOS .COM executable",13,10,"Hello World!",13,10,"$" ; The string must ends with a $
.code
	.startup
	mov   dx,offset msg ; Get the address of our message in the DX
	mov   ah,9			; Function 09h in AH means "WRITE STRING TO STANDARD OUTPUT"	
	int   21h			; Call the DOS interrupt (DOS function call)
	
	mov   ah,0			; Call bios function "GET KEYSTROKE"
	int   16h
	.exit
end