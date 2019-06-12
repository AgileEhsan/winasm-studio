comment #

Standard set of macros for the WinAsm Studio package
28 Dec 04

This are the equates included in this file:
	inv
	Inv
	INV
	.block
	.endblock
	.forever

This are the macros included in this file:
	CTEXT
	@invoke
	$invoke
	ENUM
	ENUM_MSG
	@Lower
	@Upper
	$IPADDR
	$PORTNUM
	$RGB
	sz
	bit
	incl

#

IFNDEF WinAsm_Macros
WinAsm_Macros equ TRUE

option dotname

; -------------------------------------------------------------------------
; Some useful equates
; -------------------------------------------------------------------------

inv			equ <invoke>
Inv			equ <invoke>
INV			equ <invoke>
.block  	equ <.repeat>
.endblock   equ <.until 1>
.forever	equ <.until 0>

; -------------------------------------------------------------------------
; The macro definitions
; -------------------------------------------------------------------------

IFNDEF m2m
m2m macro m1:REQ,m2:REQ
	push &m2&
	pop &m1&
endm
ENDIF

IFNDEF x2m
x2m macro m1:REQ,m2:REQ
	push &m1&
	push &m2&
	pop &m1&
	pop &m2&
endm
ENDIF

; From Ultrano's ATM
IFNDEF CTEXT
CTEXT macro Text:VARARG
	local szText
	.data
	szText byte Text, 0
	.code
	exitm <offset szText>
endm
ENDIF

IFNDEF NaN_Invoke_Macros
NaN_Invoke_Macros equ 1

; -----------------------------------------------------------
; String Invoke by NaN (June 2004)
; 
; Masm32 stringed invoke. Example:
;
;   @invoke MessageBox, NULL, "@invoke Demo", "Pretty Cool", MB_OK
; 
; -----------------------------------------------------------

IFNDEF @invoke
@invoke macro funct:REQ, args:VARARG
	LOCAL sz1
	sz1 TEXTEQU <funct>
	for arg, <args>
		if @InStr(1,arg,<!">)
			sz1 CATSTR sz1, <,>, ____CStr(arg)
		else
			sz1 CATSTR sz1, <,>, <arg> 
		endif
	endm
	%invoke sz1
	sz1 TEXTEQU <>
endm
ENDIF

; -----------------------------------------------------------
; $ String Invoke by NaN (June 2004)
; 
; Masm32 stringed invoke. Example:
;
;   mov ReturnVal, $invoke( MessageBox, NULL, "@invoke Demo", "Pretty Cool", MB_OK )
; 
; -----------------------------------------------------------

IFNDEF $invoke
$invoke macro funct:REQ, args:VARARG
	LOCAL sz1
	sz1 TEXTEQU <funct>
	for arg, <args>
		if @InStr(1,arg,<!">)
			sz1 CATSTR sz1, <,>, ____CStr(arg)
		else
			sz1 CATSTR sz1, <,>, <arg> 
		endif
	endm
	%invoke sz1
	sz1 TEXTEQU <>
	exitm <eax>
endm
ENDIF

; -----------------------------------------------------------
; String background macros, used by @invoke and $invoke
; by NaN (June 2004)
; -----------------------------------------------------------
IFNDEF ____CStr
____CStr macro Text:REQ
    local TextReference
    .const
		TextReference ____ConvertString(Text)
    .code
    exitm <offset TextReference>
endm
ENDIF
IFNDEF ____ConvertString
____ConvertString MACRO Text:REQ
	LOCAL sz1
	y = 2
	x = 1
	z = 1
	sz1 TEXTEQU <>
	while x ne 0	
		x = @InStr(x, <Text>, <\n>)
		if x ne 0
			if (x ne y)
				z = 0
				sz1 CATSTR sz1, <,!">, @SubStr(<Text>,y,x-y), <!">
			endif			
			sz1 CATSTR sz1, <,13,10>
			y = x + 2
			x = y
		else
			if (z eq 0)
				if @InStr(1, @SubStr(<Text>,y), <!">) gt 1
					sz1 CATSTR sz1, <,!">, @SubStr(<Text>,y)
				endif					
			else
				sz1 CATSTR sz1, <,>, <Text>
			endif
		endif		
	endm
	sz1 SUBSTR sz1, 2
	exitm <db sz1,0>
endm
ENDIF

ENDIF	;NaN_Invoke_Macros

;Enum macros by NaN
;
;You would use it like so:
;	ENUM  Data1, Data2, Data3, Data4
;
;Will produce:
;	Data1 EQU 0
;	Data2 EQU 1
;	Data3 EQU 2
;	Data4 EQU 3
;
;To adjust the starting number, do the following:
;	ENUM Data5:=10, Data6, Data7:=20, Data8
;
;Which would then produce:
;	Data5 EQU 10
;	Data6 EQU 11
;	Data7 EQU 20
;	Data8 EQU 21
;
;Additionally, i made a copy of this routine specifically to WM_USER messages.
; The same 'features' apply. Only the generated equates would look like:
;	[Label]  EQU WM_USER + [autoValue]
IFNDEF ENUM
ENUM    MACRO   args:VARARG
    LOCAL a1, x1, sz1, sz2, sz3
    x1 = 0
    for arg, <args>
        a1 equ @InStr(1,arg,<:=> )
        if a1 ne 0
          x1 = @SubStr(arg,a1+2)
          sz1 EQU @SubStr(arg,1,a1-1)
        else
          sz1 EQU arg
        endif
        sz3 TEXTEQU %x1
        sz2 EQU @CatStr(sz1,< EQU >, sz3)
        x1 = x1 + 1
;        %echo sz2
        sz2
    endm
endm
ENDIF

IFNDEF ENUM_MSG
ENUM_MSG    MACRO   args:VARARG
    LOCAL a1, x1, sz1, sz2, sz3
    x1 = 0
    for arg, <args>
        a1 equ @InStr(1,arg,<:=> )
        if a1 ne 0
          x1 = @SubStr(arg,a1+2)
          sz1 EQU @SubStr(arg,1,a1-1)
        else
          sz1 EQU arg
        endif
        sz3 TEXTEQU %x1
        sz2 EQU @CatStr(sz1,< EQU WM_USER + >, sz3)
        x1 = x1 + 1
;        %echo sz2
        sz2
    endm
endm
ENDIF

; by Biterider
; ————————————————————————————————————————
; Macro:     @Lower
; Purpose:   Converts a symbol string to lowercase.
; Arguments: Symbol string.
IFNDEF @Lower
@Lower macro String:req
    local LowerStr, Letter, Pos, Character

    LowerStr textequ <>
    % forc Letter, <String>
      Pos InStr <ABCDEFGHIJKLMNOPQRSTUVWXYZ>, <Letter>
      if Pos gt 0
        Character SubStr <abcdefghijklmnopqrstuvwxyz>, Pos, 1
      else
        Character textequ <Letter>
      endif
      LowerStr CatStr LowerStr, Character
    endm
    exitm LowerStr
endm
ENDIF

; by Biterider
; ————————————————————————————————————————
; Macro:     @Upper
; Purpose:   Converts a symbol string to uppercase.
; Arguments: Symbol string.
IFNDEF @Upper
@Upper macro String:req
    local UpperStr, Letter, Pos, Character

    UpperStr textequ <>
    % forc Letter, <String>
      Pos InStr <abcdefghijklmnopqrstuvwxyz>, <Letter>
      if Pos gt 0
        Character SubStr <ABCDEFGHIJKLMNOPQRSTUVWXYZ>, Pos, 1
      else
        Character textequ <Letter>
      endif
      UpperStr CatStr LowerStr, Character
    endm
    exitm UpperStr
endm
ENDIF

; Returns IP address as DWORD in network byte order
; Usage: $IPADDR(192,168,0,1)
; by Exagone [Thomas Bleeker]
IFNDEF $IPADDR
$IPADDR	MACRO IPP1:REQ,IPP2:REQ,IPP3:REQ,IPP4:REQ
LOCAL	@val
	@val = IPP1 + (IPP2 SHL 8) + (IPP3 SHL 16) + (IPP4 SHL 24)
	EXITM	<&@val>
ENDM
ENDIF

; Returns port number as WORD in network byte order
; Usage: $PORTNR(1234)
; by Exagone [Thomas Bleeker]
IFNDEF $PORTNR
$PORTNR	MACRO PORTNUMBER:REQ
LOCAL	@val
	@val = (PORTNUMBER SHR 8) + ((PORTNUMBER AND 0FFh) SHL 8)
	EXITM	<&@val>
ENDM
ENDIF

;by QvasiModo
;needs immediate values as params
;returns 00bbggrr (COLORREF order)
$RGB MACRO red:req,green:req,blue:req
	EXITM %(((blue) SHL 16) OR ((green) SHL 8) OR (red))
ENDM

; Define ASCIIZ string
; by QvasiModo
IFNDEF sz
sz macro arg:req
	sz&arg& db "&arg&",0
endm
ENDIF

; Returns a single bit mask
; by QvasiModo
IFNDEF bit
bit macro arg:req
	exitm %(1 shl &arg&)
endm
ENDIF

; Include API library
; by QvasiModo
IFNDEF incl
incl macro var:VARARG
	local count,countmax
	countmax = 0
	for arg, <var>
		countmax = countmax + 1
	endm
	if countmax eq 0
		exitm
	endif
	count = 1
:incl_loop
	incfile textequ @ArgI ( count, <var> )
	@CatStr ( <include >, %incfile, <.inc> )
	@CatStr ( <includelib >, %incfile, <.lib> )
	if count eq countmax
		exitm
	endif
	count = count + 1
	goto incl_loop
endm
ENDIF

ENDIF
