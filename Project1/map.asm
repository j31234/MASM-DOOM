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
CheckPositionValid Proc, positionX:DWORD, positionY:DWORD
  Local IndexX, IndexY

  mov eax, positionX
  mov edx, 0
  div XScale
  mov IndexX, eax

  mov eax, positionY
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

RayCasting PROC, hdc:HDC, angle:REAL8
  LOCAL rayX:REAL8, rayY:REAL8
  ; LOCAL rayDx:REAL8, rayDy:REAL8
  LOCAL angleCos:REAL8, angleSin:REAL8
  LOCAL positionX:DWORD, positionY

  ; store as float
  FINIT
  FILD playerX
  FST rayX
  FILD playerY
  FST rayY

  ; calc sin/cos
  FLD angle
  FCOS
  FST angleCos
  FLD angle
  FSIN
  FST angleSin
  

RAY_STEP:
  FINIT
  FLD rayX
  FADD angleCos
  FST rayX
  FLD rayY
  FADD angleSin
  FST rayY

  FLD rayX
  FIST positionX
  FLD rayY
  FIST positionY

  INVOKE CheckPositionValid, positionX, positionY
  test al, al
  jne RAY_STEP

  INVOKE DrawLine, hdc, playerX, playerY, positionX, positionY, 00ff0000h

  RET
RayCasting ENDP


DrawWall PROC, hdc:HDC
  LOCAL FOVAngle:REAL8, HalfFOVAngle:REAL8, deltaAngle:REAL8
  LOCAL tmp:DWORD, angle:REAL8

  ; FOVAngle = FOV * pi / 180
  FINIT
  mov tmp, FOV
  FILD tmp
  FLDPI
  FMUL
  mov tmp, 180
  FIDIV tmp
  FST FOVAngle

  ; deltaAngle = FOVAngle / WINDOW_WIDTH
  FLD FOVAngle
  mov tmp, WINDOW_WIDTH
  FIDIV tmp
  FST deltaAngle

  ; angle = playerAngle - FOVAngle / 2
  FLD playerAngle
  FLD FOVAngle
  mov tmp, 2
  FIDIV tmp
  FSUB
  FST angle

  mov ecx, WINDOW_WIDTH
LOOP_ANGLE:
  push ecx
  INVOKE RayCasting, hdc, angle
  pop ecx

  ; angle += deltaAngle
  FINIT
  FLD angle
  FADD deltaAngle
  FST angle
  LOOP LOOP_ANGLE

  RET
DrawWall ENDP

END