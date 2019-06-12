;  A 16-bit DOS HelloWorld program originally by RedOx.  Produces a small model .EXE executable.

; To assemble and link from within WinAsm Studio, you must have a special 16-bit linker, 
; such as the one in the archive at this URL- http://win32assembly.online.fr/files/Lnk563.exe
; Run the archive to unpack Link.exe, rename the Link.exe file to Link16.exe and copy it
; into the \masm32\bin folder.

.MODEL	small
.stack	100h

.data 
	msg		db "This is a 16-bit DOS .EXE executable",13,10,"Hello, World!",13,10,"$"; The string must end with a $

.code
start:
	mov		ax,@data		; Get the address of the data segment
	mov		ds,ax			; Set the DS segment
     
	mov		dx,offset msg	; Get the address of our message in the DX
	mov		ah,9			; Function 09h in AH means "WRITE STRING TO STANDARD OUTPUT"
	int		21h				; Call the DOS interrupt (DOS function call)
	
	mov		ax,0C07h		; Function 0Ch = "FLUSH BUFFER AND READ STANDARD INPUT"
	int		21h				; Waits for a key to be pressed.
	
	mov		ax, 4C00h		; the exit fuction  [4C+no error (00)]
	int		21h				; call DOS interrupt 21h
end start