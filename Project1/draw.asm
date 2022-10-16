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


DrawBitmap Proc, hdc:HDC, drawdc:HDC, DestX:DWORD, DestY:DWORD, nWidth:DWORD, nHeight:DWORD,
				 SrcX:DWORD, SrcY:DWORD, pic:DWORD
	LOCAL oldObject:HGDIOBJ
  INVOKE SelectObject, drawdc, pic
  mov oldObject, eax
  INVOKE StretchBlt, hdc, DestX, DestY, nWidth, nHeight, drawdc, SrcX, SrcY, nWidth, 256, SRCCOPY
  INVOKE SelectObject, drawdc, oldObject
  RET
DrawBitmap ENDP

DrawMain Proc, hdc:HDC, drawdc:HDC
  pushad

  ; INVOKE DrawMap, hdc
  INVOKE DrawPlayer, hdc ; TODO: refactor, DrawPlayer now include update player
  INVOKE DrawWall, hdc, drawdc
  
  ; Reset cursor position to the middle of the window
  INVOKE SetCursorPos, WINDOW_CENTER_X, WINDOW_CENTER_Y

  popad
  RET
DrawMain ENDP

END