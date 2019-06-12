.CODE
CreateStatus Proc hParent:DWORD
LOCAL sbParts[4] :DWORD

    Invoke CreateStatusWindow, WS_CHILD OR WS_VISIBLE OR SBS_SIZEGRIP, NULL, hParent, 200
    MOV hStatus, EAX
	;-------------------------------------
	;sbParts is a DWORD array of 4 members
	;-------------------------------------
    MOV [sbParts +  0], 120
    MOV [sbParts +  4], 240
    MOV [sbParts +  8], 360
    MOV [sbParts + 12], -1
    Invoke SendMessage, hStatus, SB_SETPARTS, 4, ADDR sbParts
    RET
CreateStatus EndP