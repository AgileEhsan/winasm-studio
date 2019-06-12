; This is a test program.  It requires both Skeleton.lib and Skeleton.dll
.386
.model flat,stdcall
option casemap:none

include windows.inc
include kernel32.inc

includelib skeleton.lib
includelib kernel32.lib

TestHello PROTO

.code
start:
        invoke TestHello
        invoke ExitProcess,NULL
end start
