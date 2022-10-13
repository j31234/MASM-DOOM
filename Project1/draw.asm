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

.data
count DWORD 0
ROW DWORD 10
COLUMN DWORD 10
mapData BYTE 1,1,1,1,1,1,1,1,1,1
        BYTE 1,0,0,0,1,0,0,0,0,1
		BYTE 1,0,0,0,1,0,0,0,0,1
		BYTE 1,0,0,0,1,0,1,1,1,1
		BYTE 1,0,0,0,0,0,0,0,0,1
		BYTE 1,1,1,1,0,1,1,1,0,1
		BYTE 1,0,0,0,0,1,0,0,0,1
		BYTE 1,0,0,0,0,1,0,0,0,1
		BYTE 1,0,0,0,0,1,0,0,0,1
		BYTE 1,1,1,1,1,1,1,1,1,1
fromX DWORD 0
fromY DWORD 0
toX DWORD 0
toY DWORD 0
XScale DWORD 80
YScale DWORD 60

.code
DrawMain Proc, hdc:HDC
  pushad

; draw map
  mov edi, 0
  mov ebx, OFFSET mapData
LOOP_X:
  mov esi, 0
LOOP_Y:
  mov al, [ebx]
  inc ebx
  .IF al == 1 ; draw wall
    mov eax, edi
	mul XScale
	mov fromX, eax

	mov eax, edi
	inc eax
	mul XScale
	mov toX, eax

	mov eax, esi
	mul YScale
	mov fromY, eax

	mov eax, esi
	inc eax
	mul YScale
	mov toY, eax

    INVOKE DrawLine, hdc, fromX, fromY, fromX, toY, 0
	INVOKE DrawLine, hdc, toX, fromY, toX, toY, 0
	INVOKE DrawLine, hdc, fromX, fromY, toX, fromY, 0
	INVOKE DrawLine, hdc, fromX, toY, toX, toY, 0
  .ENDIF

  ; loop
  inc esi
  cmp esi, COLUMN
  jl LOOP_Y
  ; loop
  inc edi
  cmp edi, ROW
  jl LOOP_X
  
  INVOKE DrawPlayer, hdc

  popad
  RET
DrawMain ENDP

END