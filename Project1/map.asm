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
includelib msvcrt.lib

; Custom Header
include draw.inc
include sprite.inc
include player.inc
include config.inc

; C Prototype
fopen  PROTO C :ptr sbyte, :ptr sbyte
fclose PROTO C :ptr DWORD
fscanf PROTO C :ptr DWORD, :ptr sbyte, :VARARG

.data
ROW DWORD ?
COLUMN DWORD ?
mapData BYTE 10000 DUP(?)
mapFile BYTE "map.txt", 0
mapFPTR DWORD ?
mapNum DWORD -1
curMapNum DWORD 0
filemode BYTE "r", 0
inputStr BYTE "%d", 0

eps REAL8 0.000001

.code
; Read map data from file
InitMap Proc
	LOCAL CurRow:DWORD, CurCol:DWORD, MapPos:PTR BYTE
	mov eax, curMapNum
	.IF eax == mapNum
		.IF mapFPTR != 0
			INVOKE fclose, mapFPTR
			mov mapFPTR, 0
		.ENDIF
		mov eax, 0
		RET
	.ENDIF
	.IF mapNum == -1
  		INVOKE fopen, ADDR mapFile, ADDR filemode
		mov mapFPTR, eax
		INVOKE fscanf, mapFPTR, ADDR inputStr, ADDR mapNum
	.ELSE
		INVOKE ClearNPC
	.ENDIF
	INVOKE fscanf, mapFPTR, ADDR inputStr, ADDR ROW
	INVOKE fscanf, mapFPTR, ADDR inputStr, ADDR COLUMN
	inc curMapNum
	mov CurRow, 0
	  ROWLP:
	  mov CurCol, 0
	    COLLP:
		mov eax, COLUMN
        mul CurRow
		add eax, CurCol
		add eax, OFFSET mapData
		mov MapPos, eax
		INVOKE fscanf, mapFPTR, ADDR inputStr, MapPos
		mov eax, MapPos
		mov al, [eax]
		.IF al >= 7
			mov ebx, 0
			mov bl, al
			sub bl, 7
			mov eax, MapPos
			mov BYTE PTR [eax], 0
			INVOKE CreateNPC, CurRow, CurCol, ebx
		.ENDIF
		inc CurCol
		mov eax, COLUMN
        cmp CurCol, eax
	    jne COLLP
	  inc CurRow
	  mov eax, ROW
	  cmp CurRow, eax
	  jne ROWLP
	mov eax, 1
	ret
InitMap ENDP

; check (X, Y) is wall or not
; al = 0, if no walls; else, if wall
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
  
  ; mapData[IndexX * 10 + IndexY]
  mov eax, IndexX
  mul COLUMN
  add eax, IndexY
  add eax, offset mapData

  mov al, [eax]

  RET
CheckPositionValid ENDP

CheckBlockValid Proc, blockX:DWORD, blockY:DWORD
  mov eax, blockX
  mul COLUMN
  add eax, blockY
  add eax, offset mapData

  mov al, [eax]
  RET
CheckBlockValid ENDP

GetBlockID Proc, x:DWORD, y:DWORD, ptrBlockX:DWORD, ptrBlockY:DWORD
  ; BlockX = x / XScale
  mov eax, x
  mov edx, 0
  div XScale
  mov esi, ptrBlockX
  mov [esi], eax
  ; BlockY = y / YScale
  mov eax, y
  mov edx, 0
  div YScale
  mov esi, ptrBlockY
  mov [esi], eax
  RET
GetBlockID ENDP

CheckFloatPositionValid Proc, positionX:REAL8, positionY:REAL8
  Local tempX:DWORD, tempY:DWORD, temp:WORD
  FINIT
  FLD positionX
  FTST 
  FSTSW ax
  SAHF
  jc EXIT_FUN

  FINIT
  FLD positionY
  FTST 
  FSTSW ax
  SAHF
  jc EXIT_FUN

  FINIT
  FLD positionX
  FILD ROW
  FILD XScale
  FMUL
  FSUB
  FTST 
  FSTSW ax
  SAHF
  jnc EXIT_FUN

  FINIT
  FLD positionY
  FILD COLUMN
  FILD YScale
  FMUL
  FSUB
  FTST 
  FSTSW ax
  SAHF
  jnc EXIT_FUN

  ; 向下舍入
  FINIT
  FSTCW temp
  mov bx, temp
  or bx, 011000000000b
  mov temp, bx
  FLDCW temp
  FLD positionX
  FIST tempX
  FLD positionY
  FIST tempY
  INVOKE CheckPositionValid, tempX, tempY
  RET
EXIT_FUN:
  mov eax, 1; TODO: now the edge texture type fix to 1
  RET
CheckFloatPositionValid ENDP


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

; Casting Ray with angle from (playerX, playerY) to a wall
RayCasting PROC, angle:REAL8, pWallX:PTR DWORD, pWallY:PTR DWORD, pWallDistance:PTR REAL8, pOffset:PTR REAL8, pTextureType: PTR DWORD
  LOCAL angleCos:REAL8, angleSin:REAL8
  LOCAL mapX:REAL8, mapY:REAL8
  LOCAL horX:REAL8, horY:REAL8, horDepth:REAL8
  LOCAL verX:REAL8, verY:REAL8, verDepth:REAL8
  LOCAL deltaX:REAL8, deltaY:REAL8, deltaDepth:REAL8
  LOCAL temp:DWORD, tempX:DWORD, tempY:DWORD, tempw:WORD
  LOCAL tempf1:REAL8, tempf2:REAL8
  LOCAL sinpositive:DWORD, cospositive:DWORD
  LOCAL horTextureType:DWORD, verTextureType:DWORD

  pushad

  ; mapX是XScale的整数倍
  mov eax, playerX
  mov edx, 0
  div XScale
  mov temp, eax
  
  FINIT
  FILD temp
  FILD XScale
  FMUL
  FST mapX

  mov eax, playerY
  mov edx, 0
  div YScale
  mov temp, eax
  FINIT
  FILD temp
  FILD YScale
  FMUL
  FST mapY


  ; store as float
  FINIT
  ; calc sin/cos
  FLD angle
  FCOS
  FST angleCos
  FLD angle
  FSIN
  FST angleSin

; horizontal

  ; 查看sin的正负
  FINIT
  FLD angleSin
  FTST 
  FSTSW ax
  SAHF
  jnc SIN_POSITIVE
  jmp SIN_NEGATIVE

SIN_POSITIVE:
  mov eax, 1
  mov sinpositive, eax
  FINIT
  FLD mapY
  FILD YScale
  FADD
  FST horY
  FILD YScale
  FST deltaY
  jmp SIN_EXIT
SIN_NEGATIVE:
  mov eax, 0
  mov sinpositive, eax
  FINIT
  FLD mapY
  FLD eps
  FSUB
  FST horY
  FILD YScale
  FCHS
  FST deltaY
  jmp SIN_EXIT
SIN_EXIT:
  ;depth_hor = (y_hor - oy) / sin_a
  FINIT
  FLD horY
  FILD playerY
  FSUB
  FLD angleSin
  FDIV
  FST horDepth

  ;x_hor = ox + depth_hor * cos_a
  FINIT
  FLD horDepth
  FLD angleCos
  FMUL
  FILD playerX
  FADD
  FST horX
  
  ;delta_depth = dy / sin_a
  FINIT
  FLD deltaY
  FLD angleSin 
  FDIV
  FST deltaDepth
  
  ;dx = delta_depth * cos_a
  FINIT
  FLD deltaDepth
  FLD angleCos
  FMUL
  FST deltaX
  
  xor eax, eax
  INVOKE CheckFloatPositionValid, horX, horY
.WHILE al == 0
  FINIT
  FLD horX
  FLD deltaX
  FADD
  FST horX
  FLD horY
  FLD deltaY
  FADD
  FST horY
  FLD horDepth
  FLD deltaDepth
  FADD
  FST horDepth  

  INVOKE CheckFloatPositionValid, horX, horY
.ENDW
  xor ebx, ebx
  mov bl, al
  mov horTextureType, ebx
  ;test al, al ; al = 0 if no walls
  ;jne LOOP_COLUMN ; jump if no walls


; vertical
  FINIT
  FLD angleCos
  FTST 
  FSTSW ax
  SAHF
  jnc COS_POSITIVE
  jmp COS_NEGATIVE

COS_POSITIVE:  
  mov eax, 1
  mov cospositive, eax
  FINIT
  FLD mapX
  FILD XScale
  FADD
  FST verX
  FILD XScale
  FST deltaX
  jmp COS_EXIT
COS_NEGATIVE:  
  mov eax, 0
  mov cospositive, eax
  FINIT
  FLD mapX
  FLD eps
  FSUB
  FST verX
  FILD XScale
  FCHS
  FST deltaX
  jmp COS_EXIT
COS_EXIT:
  ;depth_vert = (x_vert - ox) / cos_a
  FINIT
  FLD verX
  FILD playerX
  FSUB
  FLD angleCos
  FDIV
  FST verDepth
  
  FINIT
  ;y_vert = oy + depth_vert * sin_a
  FLD verDepth
  FLD angleSin
  FMUL
  FILD playerY
  FADD
  FST verY
  
  ;delta_depth = dx / cos_a
  FINIT
  FLD deltaX
  FLD angleCos 
  FDIV
  FST deltaDepth
  
  ;dy = delta_depth * sin_a
  FINIT
  FLD deltaDepth
  FLD angleSin
  FMUL
  FST deltaY

  xor eax, eax
  INVOKE CheckFloatPositionValid, verX, verY
.WHILE al == 0
;LOOP_ROW:  
  FINIT
  FLD verX
  FLD deltaX
  FADD
  FST verX
  FLD verY
  FLD deltaY
  FADD
  FST verY
  FLD verDepth
  FLD deltaDepth
  FADD
  FST verDepth

  INVOKE CheckFloatPositionValid, verX, verY
  ;test al, al ; al = 1 if no walls
  ;jne LOOP_ROW ; jump if no walls
.ENDW
  xor ebx, ebx
  mov bl, al
  mov verTextureType, ebx

  FINIT
  FLD verDepth
  FLD horDepth
  FCOM
  FSTSW ax
  SAHF
  jc verGhor
  jmp verLhor
verGhor: 
  FINIT
  FLD horDepth
  mov esi, pWallDistance
  FST REAL8 PTR [esi]

  mov eax, horTextureType
  mov esi, pTextureType
  mov [esi], eax
  FINIT
  FSTCW tempw
  mov bx, tempw
  or bx, 011000000000b
  mov tempw, bx
  FLDCW tempw
  FLD horX
  FILD XScale
  FDIV
  FIST tempX
  FINIT
  FLD horX
  FILD tempX
  FILD XScale
  FMUL
  FSUB
  FILD XScale
  FDIV
  FST horX
  mov eax, sinpositive
  mov esi, pOffset
  .IF eax == 1
	FINIT
	mov tempX, eax
	FILD tempX
	FLD horX
	FSUB
	FST REAL8 PTR [esi]
  .ELSE
	FINIT
	FLD horX
	FST REAL8 PTR [esi]
  .ENDIF

  jmp RAY_EXIT
verLhor: 
  FINIT
  FLD verDepth
  mov esi, pWallDistance
  FST REAL8 PTR [esi]
  mov eax, verTextureType
  mov esi, pTextureType
  mov [esi], eax

  FINIT


  FSTCW tempw
  mov bx, tempw
  or bx, 011000000000b
  mov tempw, bx
  FLDCW tempw
  FLD verY
  FILD YScale
  FDIV
  FIST tempX

  FINIT
  FLD verY
  FILD tempX
  FILD YScale
  FMUL
  FSUB  
  FILD YScale
  FDIV
  FST verY
  mov eax, cospositive
  mov esi, pOffset
  .IF eax == 1
	FINIT
	FLD verY
	FST REAL8 PTR [esi]
  .ELSE
	FINIT
	mov eax, 1
	mov tempX, eax
	FILD tempX
	FLD verY
	FSUB
	FST REAL8 PTR [esi]
  .ENDIF

  jmp RAY_EXIT
RAY_EXIT:
  popad
  RET
RayCasting ENDP

DrawWallColumn PROC, hdc:HDC, drawdc:HDC, screenX:DWORD, screenDistance:REAL8, wallDistance:REAL8, textureOffset:REAL8, textureType:DWORD
  LOCAL screenHeight:DWORD, columnBegin:DWORD, columnEnd:DWORD, color:DWORD,
		param1:DWORD, param2:DWORD, tempcolor:BYTE, tempoffset:DWORD, wallDistanceInt:DWORD, temp :DWORD
  ; screenHeight = wallHeight * (screenDistance / wallDistance)
  ; use XScale = wallHeight
  pushad
  FINIT 
  FILD XScale
  FLD screenDistance
  FLD wallDistance
  FDIV
  FMUL
  FIST screenHeight

  ; columnBegin = WINDOW_HEIGHT / 2 - screenDistance / 2
  ; columnEnd = WINDOW_HEIGHT / 2 + screenDistance / 2
  mov eax, WINDOW_HEIGHT
  shr eax, 1
  mov ecx, screenHeight
  shr ecx, 1
  sub eax, ecx
  mov columnBegin, eax
  add eax, ecx
  add eax, ecx
  mov columnEnd, eax

  ; color = color - color / (1 + dist ^ 5 * eps), where eps is a proper small number
  mov eax, 0ffh
  mov color, eax  
  mov eax, 200000
  mov param1, eax
  mov eax, 1
  mov param2, eax
  FINIT
  FILD color
  FILD color
  FLD wallDistance
  FLD wallDistance
  FLD wallDistance
  FMUL
  FMUL
  FILD param1
  FDIV
  FLD wallDistance
  FMUL
  FILD param1
  FDIV
  FILD param2
  FADD
  FDIV
  FSUB
  FIST color

  mov eax, color
  mov tempcolor, al

  INVOKE GetRGB, tempcolor, tempcolor, tempcolor
  mov color, eax

  ;INVOKE DrawLine, hdc, screenX, columnBegin, screenX, columnEnd, color
  mov eax, columnEnd
  sub eax, columnBegin
  FINIT
  FLD textureOffset
  FILD XScale
  FMUL
  FIST tempoffset

  FINIT
  FLD wallDistance
  mov temp, 1100 ;avoid float number comparison
  FIMUL temp
  FIST wallDistanceInt

  mov ebx, textureType
  .IF ebx == 1
	INVOKE DrawBitmap, hdc, drawdc, screenX, columnBegin, 1, eax, tempoffset, 0, 1, 256, hTexture1, wallDistanceInt
  .ELSE 
	.IF ebx == 2
		INVOKE DrawBitmap, hdc, drawdc, screenX, columnBegin, 1, eax, tempoffset, 0, 1, 256, hTexture2, wallDistanceInt
	.ELSE
		INVOKE DrawBitmap, hdc, drawdc, screenX, columnBegin, 1, eax, tempoffset, 0, 1, 256, hTexture3, wallDistanceInt
	.ENDIF
  .ENDIF
  popad
  RET
DrawWallColumn ENDP

DrawWall PROC, hdc:HDC, drawdc:HDC
  LOCAL FOVAngle:REAL8, HalfFOVAngle:REAL8, deltaAngle:REAL8, screenDistance:REAL8
  LOCAL tmp:DWORD, angle:REAL8, angleScreenDistance:REAL8
  LOCAL wallX:DWORD, wallY:DWORD, wallDistance:REAL8, textureOffset:REAL8
  LOCAL textureType:DWORD
  pushad
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

  ; HalfFOVAngle = FOVAngle / 2
  FLD FOVAngle
  mov tmp, 2
  FIDIV tmp
  FST HalfFOVAngle

  ; screenDistance = (WINDOW_WIDTH / 2) / (sin(HalfFOVAngle) / cos(HalfFOVAngle))
  ; each ray is a column on screen
  mov tmp, WINDOW_WIDTH
  shr tmp, 1
  FILD tmp
  FLD HalfFOVAngle
  FSIN
  FLD HalfFOVAngle
  FCOS
  FDIV
  FDIV
  FST screenDistance

  ; angle = playerAngle - FOVAngle / 2
  FLD playerAngle
  FLD FOVAngle
  mov tmp, 2
  FIDIV tmp
  FSUB
  FST angle

  mov ecx, WINDOW_WIDTH
LOOP_ANGLE: ;  for ray in range(NUM_RAYS):
  push ecx

  ; invoke ratcasting
  INVOKE RayCasting, angle, ADDR wallX, ADDR wallY, ADDR wallDistance, ADDR textureOffset, ADDR textureType
  mov eax, WINDOW_WIDTH
  sub eax, ecx

  ; angleScreenDistance = screenDistance / cos(angle - playerAngle)
  FINIT
  FLD screenDistance
  FLD angle
  FLD playerAngle
  FSUB
  FCOS
  FDIV
  FST angleScreenDistance

  ; draw wall column 
  INVOKE DrawWallColumn, hdc, drawdc, eax, angleScreenDistance, wallDistance, textureOffset, textureType
  ; INVOKE DrawLine, hdc, playerX, playerY, wallX, wallY, 00ff0000h

  pop ecx

  ; angle += deltaAngle
  FINIT
  FLD angle
  FADD deltaAngle
  FST angle

  mov eax, WINDOW_WIDTH / 2
  sub eax, ecx
  mov tmp, eax
  FINIT
  FILD tmp
  FLD screenDistance
  FPATAN
  FADD playerAngle
  FST angle

  sub ecx, 1
  test ecx, ecx
  jne LOOP_ANGLE
  ; LOOP LOOP_ANGLE
  popad
  RET
DrawWall ENDP

END