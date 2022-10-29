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
include sprite.inc

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

DrawBackground Proc, hdc:HDC, drawdc:HDC, SrcX:DWORD, SrcY:DWORD
	LOCAL oldObject:HGDIOBJ, temp: SDWORD
  FINIT
  FLD playerAngle
  FLDPI
  mov temp, 2
  FIMUL temp
  FDIV
  mov temp, BACKGOUND_WIDTH
  FIMUL temp
  FCHS
  FIST temp

  mov edx, 0
  mov eax, temp
  cdq
  mov ebx, BACKGOUND_WIDTH
  idiv ebx
  mov temp, edx

  
  INVOKE SelectObject, drawdc, hBackground
  mov oldObject, eax
  INVOKE StretchBlt, hdc, temp, 0, BACKGOUND_WIDTH, BACKGOUND_HEIGHT, drawdc, SrcX, SrcY, BACKGOUND_WIDTH, BACKGOUND_HEIGHT, SRCCOPY
  mov eax, temp
  cmp eax, 0
  jl ADD_WIDTH
  sub eax, BACKGOUND_WIDTH
  jmp END_ADD
ADD_WIDTH:
    add eax, BACKGOUND_WIDTH
END_ADD:
  INVOKE StretchBlt, hdc, eax, 0, BACKGOUND_WIDTH, 300, drawdc, SrcX, SrcY, BACKGOUND_WIDTH, 300, SRCCOPY
  INVOKE SelectObject, drawdc, oldObject
  RET
DrawBackground ENDP

DrawFloor Proc, hdc:HDC
	LOCAL color:DWORD
  INVOKE GetRGB, 160, 160, 160
  mov color, eax
  INVOKE SetDCBrushColor, hdc, color
  INVOKE Rectangle, hdc, 0, WINDOW_HALF_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT
  RET
DrawFloor ENDP

DrawMain Proc, hdc:HDC, drawdc:HDC
  pushad

  ; INVOKE DrawMap, hdc
  INVOKE DrawPlayer, hdc ; TODO: refactor, DrawPlayer now include update player
  INVOKE DrawBackground, hdc, drawdc, 0, 0
  INVOKE DrawFloor, hdc
  INVOKE DrawWall, hdc, drawdc
  INVOKE GetSprite, hdc, drawdc, 500, 500
  
  ; Reset cursor position to the middle of the window
  INVOKE SetCursorPos, WINDOW_CENTER_X, WINDOW_CENTER_Y

  popad
  RET
DrawMain ENDP

END