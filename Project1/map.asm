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

.data
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

XScale DWORD 80
YScale DWORD 60
.code
DrawMap Proc, hdc:HDC
  LOCAL fromX:DWORD, fromY:DWORD, toX:DWORD, toY:DWORD

  mov edi, 0
  mov ebx, offset mapData
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

  RET
DrawMap ENDP

CheckPositionValid Proc, playerX:DWORD, playerY:DWORD
  Local IndexX, IndexY

  mov eax, playerX
  mov edx, 0
  div XScale
  mov IndexX, eax

  mov eax, playerY
  mov edx, 0
  div YScale
  mov IndexY, eax
  
  mov eax, IndexX
  mul COLUMN
  add eax, IndexY
  add eax, offset mapData

  mov al, [eax]
  xor al, 1

  RET
CheckPositionValid ENDP

END