.386
.model flat, stdcall
option casemap: none

include windows.inc
include winmm.inc
include kernel32.inc
include user32.inc
include masm32.inc
includelib winmm.lib
includelib kernel32.lib
includelib user32.lib
includelib masm32.lib

.data
soundFileName BYTE 100 dup(?)

.code
main:
  INVOKE GetConsoleWindow
  INVOKE ShowWindow, eax, SW_HIDE
  INVOKE GetCL, 0, ADDR soundFileName
  ;INVOKE StdOut, ADDR soundFileName
  INVOKE PlaySound, ADDR soundFileName, NULL, SND_SYNC OR SND_FILENAME
  ret
END main