.386
.model flat, stdcall
OPTION  CaseMap:None

; MASM32 Headers
include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc

; MASM32 Library
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib

; Custom Header
include draw.inc
include player.inc
include map.inc
include config.inc

.code
GetRGB Proc, red:BYTE, green:BYTE, blue:BYTE
  mov eax, 0
  mov ah, blue
  mov al, green
  shl eax, 8
  mov al, red
  RET
GetRGB ENDP

DrawLine Proc, hdc:HDC, fromX:DWORD, fromY:DWORD, toX:DWORD, toY:DWORD, RGB: DWORD
  INVOKE SetDCPenColor, hdc, RGB
  INVOKE MoveToEx, hdc, fromX, fromY, 0
  INVOKE LineTo, hdc, toX, toY
  RET
DrawLine ENDP

DrawMain Proc, hdc:HDC
  pushad

  INVOKE DrawMap, hdc
  INVOKE DrawPlayer, hdc

  popad
  RET
DrawMain ENDP

END