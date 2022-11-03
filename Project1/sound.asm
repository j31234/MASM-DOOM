.386
.model flat, stdcall
OPTION  CaseMap:None

; MASM32 Headers
include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include msimg32.inc

; MASM32 Library
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib msimg32.lib

; Custom Header
include sound.inc

.data
SUINFO STARTUPINFO <>
PRCINFO PROCESS_INFORMATION <>
processName BYTE "soundplayer.exe", 0
shotgunName BYTE "player_shotgun.wav", 0

.code
ShotgunSound PROC
  INVOKE CreateProcess, ADDR processName, ADDR shotgunName, NULL, NULL, FALSE, 0, NULL, NULL, ADDR SUINFO, ADDR PRCINFO
  RET
ShotgunSound ENDP
END