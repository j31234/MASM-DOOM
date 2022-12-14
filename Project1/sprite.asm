.386
.model flat, stdcall
OPTION  CaseMap:None

; MASM32 Headers
include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include msvcrt.inc

; MASM32 Library
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib msvcrt.lib

; Custom Header
include player.inc
include draw.inc
include config.inc
include map.inc
include sprite.inc
include sound.inc
include queue.inc

.data
NPCList NPC 100 DUP(<,,,,,,>) ;<600,210,,100,0,0>, <250,800,,100,0,0>
NPCNum DWORD 0
NPCAliveNum DWORD 0

IMAGE_WIDTH DWORD 126
IMAGE_HALF_WIDTH DWORD 63
IMAGE_HEIGHT DWORD 132
IMAGE_RATIO REAL8 0.9545f

SPRITE_SCALE REAL8 60.0f
SPRITE_HEIGHT_SHIFT REAL8 0.20f

NPC_MOVE_STEP = 3
NPC_BOX_SIZE = 30

; 4 Direction Move
NPC_MOVE_ACTION_COUNT = 4
NPC_MOVE_DX SDWORD 0, 0, 1, -1
NPC_MOVE_DY SDWORD 1, -1, 0, 0

BFSPreNode_SIZE = 128 * 128

.data?
BFSPreNode POINT BFSPreNode_SIZE DUP(<?,?>) ; 1024 * 1024, for fast index

.code
ClearNPC PROC
	mov NPCNum, 0
	RET
ClearNPC ENDP

CreateNPC PROC, currow:DWORD, curcol:DWORD, NPCtype:DWORD
	local npcindex:DWORD
	
	mov eax, NPCNum
	mov ebx, SIZE NPC
	mul ebx
	mov npcindex, eax
	
	mov eax, currow
	mov ebx, XScale
	mul ebx
	mov ebx, eax
	mov eax, npcindex
	mov (NPC PTR NPCList[eax]).posX, ebx
	
	mov eax, curcol
	mov ebx, YScale
	mul ebx
	mov ebx, eax
	mov eax, npcindex
	mov (NPC PTR NPCList[eax]).posY, ebx

	mov ebx, NPCtype
	mov eax, npcindex
	mov (NPC PTR NPCList[eax]).NPCType, ebx
	
	mov eax, NPCtype
	mov ebx, 50
	mul ebx
	add eax, 100
	mov ebx, eax
	mov eax, npcindex
	mov (NPC PTR NPCList[eax]).blood, ebx

	inc NPCNum
	inc NPCAliveNum
	RET
CreateNPC ENDP

AngleClip PROC, angle:REAL8, ptrClipedAngle:DWORD
; Clip angle to [0, 2pi]
; Result passed by ptrClipedAngle
  LOCAL temp:DWORD
  pushad
  angleGreater2Pi:
	 FINIT
	 FLD angle
	 FLDPI
	 mov temp, 2
	 FIMUL temp
	 FCOM
	 FSTSW ax
	 SAHF
	 jnc angleLess2Pi
	 FSUB
	 FST angle
	 jmp angleGreater2Pi
angleLess2Pi:
	 NOP
angleLess0:
	 FINIT
	 FLD angle
	 mov temp, 0
	 FILD temp
	 FCHS
	 FCOM
	 FSTSW ax
	 SAHF
	 jc angleGreater0
	 FINIT
	 FLD angle
	 FLDPI
	 mov temp, 2
	 FIMUL temp
	 FADD
	 FST angle
	 jmp angleLess0
angleGreater0:

	 mov esi, ptrClipedAngle
	 FINIT
	 FLD angle
	 FST REAL8 PTR [esi]
	 popad
	 RET
AngleClip ENDP

UpdateNPCAnimation PROC, npcID:DWORD, npcDx:DWORD, npcDy:DWORD, npcType:DWORD
  LOCAL npcAngle:REAL8, angleDelta:REAL8, angleDeltaClipped:REAL8
  LOCAL minAngle:REAL8, minIndex:DWORD, tmp:DWORD
  pushad
  ; npcAngle = atan(npcDy / npcDx)
  FINIT
  FILD npcDy
  FILD npcDx
  FPATAN
  FST npcAngle

  ; angleDelta = pi + (npcAngle - playerAngle)
  FINIT
  FLDPI
  FADD npcAngle
  FSUB playerAngle
  FST angleDelta

  INVOKE AngleClip, angleDelta, ADDR angleDeltaClipped

  FINIT
  FLDPI
  FST minAngle
  ; get argmin(abs(i*pi/4 - angleDeltaClipped))
  mov ecx, 0
  .WHILE ecx < 8
    FINIT
	FLDPI
	mov tmp, 4
	FIDIV tmp
	mov tmp, ecx
	FIMUL tmp

	FSUB angleDeltaClipped
	FABS

	FCOM minAngle
	FNSTSW ax
	sahf
	jnb UPDATE_END

	FST minAngle
	mov minIndex, ecx

  UPDATE_END:
    inc ecx
  .ENDW

  mov esi, minIndex
  .IF npcType == 0
	mov eax, hCacoBitmapList[esi * 4]
  .ELSEIF npcType == 1
    mov eax, hCocoBitmapList[esi * 4]
  .ELSE
	mov eax, hCucoBitmapList[esi * 4]
  .ENDIF
  mov esi, npcID

  mov (NPC PTR NPCList[esi]).nowIDB, eax
  popad
  RET
UpdateNPCAnimation ENDP

MoveNPC PROC, npcID:DWORD
  ; Move NPC towards player.
  ; BFS to get to the shortest path.
  LOCAL npcX:DWORD, npcY:DWORD, nowX:DWORD, nowY:DWORD, nextX:DWORD, nextY:DWORD
  LOCAL npcBlockX:DWORD, npcBlockY:DWORD, playerBlockX:DWORD, playerBlockY:DWORD
  LOCAL npcDx:DWORD, npcDy:DWORD, signedZero:SDWORD
  LOCAL npcAngle:DWORD, npcType:DWORD
  LOCAL tmp:DWORD
  pushad
  mov signedZero, 0

  ; Get npcX, npcY
  mov esi, npcID
  mov eax, (NPC PTR NPCList[esi]).posX
  mov npcX, eax
  mov eax, (NPC PTR NPCList[esi]).posY
  mov npcY, eax
  mov eax, (NPC PTR NPCList[esi]).NPCType
  mov npcType, eax

  ; Get Block ID for npc and player
  INVOKE GetBlockID, npcX, npcY, ADDR npcBlockX, ADDR npcBlockY
  INVOKE GetBlockID, playerX, playerY, ADDR playerBlockX, ADDR playerBlockY

  ; if belongs to the same block
  mov eax, npcBlockX
  sub eax, playerBlockX
  mov ebx, npcBlockY
  sub ebx, playerBlockY
  .IF eax == 0 && ebx == 0
    ; calc npcDx
    mov eax, playerX
	sub eax, npcX
	.IF eax != 0
	  .IF eax < signedZero ; signed compare
	    mov npcDx, -NPC_MOVE_STEP
	  .ELSE
	    mov npcDx, NPC_MOVE_STEP
	  .ENDIF
    .ELSE
	  mov npcDx, 0
	.ENDIF

	; calc npcDy
	mov eax, playerY
	sub eax, npcY
	.IF eax != 0
	  .IF eax < signedZero
	    mov npcDy, -NPC_MOVE_STEP
	  .ELSE
	    mov npcDy, NPC_MOVE_STEP
	  .ENDIF
    .ELSE
	  mov npcDy, 0
	.ENDIF

	; update npc position
	jmp UPDATE_NPC_POSITION

    RET
  .ENDIF

  ; npc and player belongs to different block
  ; use bfs

  ; Initialize BFS State
  INVOKE crt_memset, offset BFSPreNode, 0ffh, BFSPreNode_SIZE * TYPE BFSPreNode ; x = y = 0xffffffff = -1
  INVOKE QueueReset

  ; search from (npcBlockX, npcBlockY)
  INVOKE QueuePush, npcBlockX, npcBlockY

  ; BFSPreNode[npcBlockX, npcBlockY] = Point(-2, -2)
  ; esi = offset = (npcBlockX + npcBlockY * 128) * sizeof(BFSPreNode)
  mov esi, npcBlockX
  shl esi, 7
  add esi, npcBlockY
  shl esi, 3
  mov BFSPreNode[esi].x, -2
  mov BFSPreNode[esi].y, -2

BFS_START:
  INVOKE QueuePop, ADDR nowX, ADDR nowY

  ; check target
  mov eax, nowX
  sub eax, playerBlockX
  mov ebx, nowY
  sub ebx, playerBlockY
  .IF eax == 0 && ebx == 0
    jmp BFS_END
  .ENDIF

  ; For each action
  mov ecx, 0
  .WHILE ecx < NPC_MOVE_ACTION_COUNT
    ; calc nextX, nextY
    mov eax, nowX
	add eax, NPC_MOVE_DX[ecx * 4]
	mov nextX, eax
	mov eax, nowY
	add eax, NPC_MOVE_DY[ecx * 4]
	mov nextY, eax

	mov esi, nextX
	shl esi, 7
	add esi, nextY
	shl esi, 3
	INVOKE CheckBlockValid, nextX, nextY
	mov ebx, BFSPreNode[esi].x
	.IF al == 0 && ebx == -1  ; NO WALL and not visited
	  INVOKE QueuePush, nextX, nextY

	  ; BFSPreNode[nextX][nextY] = POINT(nowX, nowY)
	  mov esi, nextX
	  shl esi, 7
	  add esi, nextY
	  shl esi, 3
	  mov eax, nowX
	  mov BFSPreNode[esi].x, eax
	  mov eax, nowY
	  mov BFSPreNode[esi].y, eax
	.ENDIF

	inc ecx
  .ENDW

  INVOKE QueueIsEmpty
  .IF eax == 1
    ; wtf
	;RET
  .ENDIF
  jmp BFS_START

BFS_END:
TRACEBACK_START:
  ; traceback from (nowX, nowY) to (npcBlockX, npcBlockY)
  mov esi, nowX
  shl esi, 7
  add esi, nowY
  shl esi, 3

  mov eax, BFSPreNode[esi].x
  mov nextX, eax
  mov eax, BFSPreNode[esi].y
  mov nextY, eax

  mov eax, nextX
  sub eax, npcBlockX
  mov ebx, nextY
  sub ebx, npcBlockY
  .IF eax == 0 && ebx == 0
	jmp TRACEBACK_END
  .ELSE
    mov eax, nextX
	mov nowX, eax
	mov eax, nextY
	mov nowY, eax
    jmp TRACEBACK_START
  .ENDIF

TRACEBACK_END:
  ; calc npcDx, npcDy
  mov eax, nowX
  sub eax, npcBlockX
  mov ebx, NPC_MOVE_STEP
  mul ebx
  mov npcDx, eax

  mov eax, nowY
  sub eax, npcBlockY
  mov ebx, NPC_MOVE_STEP
  mul ebx
  mov npcDy, eax

UPDATE_NPC_POSITION:
  INVOKE UpdateNPCAnimation, npcID, npcDx, npcDy, npcType
  ; if npc is too close to player, stop moving
  mov eax, playerX
  sub eax, npcX
  INVOKE crt_abs, eax
  mov ebx, eax

  mov eax, playerY
  sub eax, npcY
  INVOKE crt_abs, eax
  add ebx, eax
  .IF ebx < NPC_BOX_SIZE
    RET
  .ENDIF

  mov eax, npcX
  add eax, npcDx
  mov esi, npcID
  mov (NPC PTR NPCList[esi]).posX, eax

  mov eax, npcY
  add eax, npcDy
  mov esi, npcID
  mov (NPC PTR NPCList[esi]).posY, eax
  popad
  RET
MoveNPC ENDP

; damage targeted npc. return 1 if hurted, 2 if dead, 0 otherwise
NPCDamage PROC damage:DWORD, npcID:DWORD
	LOCAL posX:DWORD, posY:DWORD, projWidth:DWORD, projHeight:DWORD, normDist:REAL8, normDistInt:DWORD, delta_res:REAL8, spriteDist:REAL8
	LOCAL pWallX:DWORD, pWallY:DWORD, pWallDistance:REAL8, pOffset:REAL8, pTextureType:DWORD
	local npcindex:DWORD
	pushad
	mov eax, npcID
	mov ebx, SIZE NPC
	mul ebx
	mov npcindex, eax
	mov eax, (NPC PTR NPCList[eax]).blood
	.IF eax == 0
		jmp DEAD_BODY
	.ENDIF

	; bullet collision check
	pushad
	invoke GetSprite, addr posX, addr posY, addr projWidth, addr projHeight, addr normDist, addr normDistInt, addr delta_res, addr spriteDist, npcindex
	invoke RayCasting, playerAngle, addr pWallX, addr pWallY, addr pWallDistance, addr pOffset, addr pTextureType
	popad
	; check shot angle
	FINIT
	FILD IMAGE_HALF_WIDTH ; NPC half width
	FLD spriteDist
	FPATAN
	FILD IMAGE_HALF_WIDTH 
	FLD spriteDist
	FPATAN
	FMUL; normDist^2
	FLD delta_res
	FMUL delta_res ;delta_res^2
	FCOM
	FSTSW ax
	SAHF
	jnc BULLET_MISS ; arctan|width / normDist| < |delta|
	; check if walls block the bullet
	FINIT
	FLD pWallDistance
	FLD normDist
	FCOM
	FSTSW ax
	SAHF
	jnc BULLET_MISS

	popad
	mov eax, npcindex
	mov eax, (NPC PTR NPCList[eax]).blood
	.IF eax <= damage
		mov eax, npcindex
		mov (NPC PTR NPCList[eax]).blood, 0
		mov (NPC PTR NPCList[eax]).attackedFrame, 40
		dec NPCAliveNum
		mov eax, 2
	.ELSE
		mov ebx, damage
		mov eax, npcindex
		sub (NPC PTR NPCList[eax]).blood, ebx
		mov (NPC PTR NPCList[eax]).attackedFrame, 20
		mov eax, 1
	.ENDIF
	
	RET
BULLET_MISS:
	mov eax, 0
	RET
DEAD_BODY:
	RET
NPCDamage ENDP

GetSprite PROC posX:PTR DWORD, posY:PTR DWORD, projWidth:PTR DWORD, projHeight:PTR DWORD, normDist:PTR REAL8, normDistInt:PTR DWORD, delta_res:PTR REAL8, dist_res:PTR REAL8, npcID:DWORD
	LOCAL deltaX:SDWORD, deltaY:SDWORD, theta:REAL8, delta:REAL8, temp:DWORD
	LOCAL deltaRays:SDWORD, screenX:SDWORD
	LOCAL dist:REAL8
	LOCAL FOVAngle:REAL8, deltaAngle:REAL8
	LOCAL HalfFOVAngle:REAL8, screenDistance:REAL8
	LOCAL proj:REAL8
	LOCAL tempPlayerAngle:REAL8
	LOCAL x:DWORD, y:DWORD
	pushad

	mov eax, npcID
	mov ebx, (NPC PTR NPCList[eax]).posX
	mov x, ebx
	
	mov eax, npcID
	mov ebx, (NPC PTR NPCList[eax]).posY
	mov y, ebx

	mov eax, x
	sub eax, playerX
	mov deltaX, eax
	mov eax, y
	sub eax, playerY
	mov deltaY, eax

	; theta = arctan(y/x)
	FINIT
	FILD deltaY
	FILD deltaX
	FPATAN
	FST theta

	FINIT
	FLD playerAngle
	FST tempPlayerAngle

	; set player angle to [0, 2pi]
angleGreater2Pi:
	 FINIT
	 FLD tempPlayerAngle
	 FLDPI
	 mov temp, 2
	 FIMUL temp
	 FCOM
	 FSTSW ax
	 SAHF
	 jnc angleLess2Pi
	 FSUB
	 FST tempPlayerAngle
	 jmp angleGreater2Pi
angleLess2Pi:
	 NOP
angleLess0:
	 FINIT
	 FLD tempPlayerAngle
	 mov temp, 0
	 FILD temp
	 FCHS
	 FCOM
	 FSTSW ax
	 SAHF
	 jc angleGreater0
	 FINIT
	 FLD tempPlayerAngle
	 FLDPI
	 mov temp, 2
	 FIMUL temp
	 FADD
	 FST tempPlayerAngle
	 jmp angleLess0
angleGreater0:

	FINIT
	FLD theta
	FLD tempPlayerAngle
	FSUB
	FST delta

	FINIT
	FLD tempPlayerAngle
	FLDPI
	FCOM
	FSTSW ax
	SAHF
	jc playerAngleGreaterPi
	jmp playerAngleLessPi
playerAngleGreaterPi:
	; if deltaX > 0
	mov eax, deltaX
	cmp eax, 0
	jg addDelta

playerAngleLessPi:
	; if deltaX < 0 && deltaY < 0
	mov eax, deltaX
	cmp eax, 0
	jge finishAddDelta

	mov eax, deltaY
	cmp eax, 0
	jge finishAddDelta

addDelta:
	FINIT
	FLD delta
	FLDPI
	mov temp, 2
	FIMUL temp
	FADD
	FST delta
finishAddDelta:
	FINIT
	mov temp, FOV
	FILD temp
	FLDPI
	FMUL
	mov temp, 180
	FIDIV temp
	FST FOVAngle

	; deltaAngle = FOVAngle / WINDOW_WIDTH
	FLD FOVAngle
	mov temp, WINDOW_WIDTH
	FIDIV temp
	FST deltaAngle

	; delta_rays = delta / DELTA_ANGLE
	FINIT
	FLD delta
	FLD deltaAngle
	FDIV
	FIST deltaRays



	mov eax, WINDOW_HALF_WIDTH
	add eax, deltaRays
	mov screenX, eax

	; dist = sqrt(dx ^ 2 + dy ^ 2)
	FINIT
	FILD deltaX
	FILD deltaX
	FMUL
	FILD deltaY
	FILD deltaY
	FMUL
	FADD
	FSQRT
	FST dist

	; self.norm_dist = self.dist * math.cos(delta)
	FINIT
	FLD dist
	FLD delta
	FCOS
	FMUL
	mov esi, normDist
	FST REAL8 PTR [esi]

	mov eax,IMAGE_HALF_WIDTH
	neg eax
	cmp eax, screenX
	jge exit_get_sprite

	mov eax, WINDOW_WIDTH
	add eax, IMAGE_HALF_WIDTH
	cmp eax, screenX
	jle exit_get_sprite


	; HalfFOVAngle = FOVAngle / 2
	FLD FOVAngle
	mov temp, 2
	FIDIV temp
	FST HalfFOVAngle

	; screenDistance = (WINDOW_WIDTH / 2) / (sin(HalfFOVAngle) / cos(HalfFOVAngle))
	; each ray is a column on screen
	mov temp, WINDOW_WIDTH
	shr temp, 1
	FILD temp
	FLD HalfFOVAngle
	FSIN
	FLD HalfFOVAngle
	FCOS
	FDIV
	FDIV
	FST screenDistance

	; proj = SCREEN_DIST / self.norm_dist * self.SPRITE_SCALE
	FINIT
	FLD screenDistance
	mov esi, normDist
	FLD REAL8 PTR [esi]
	FDIV
	FLD SPRITE_SCALE
	FMUL
	mov esi, projHeight
	FIST DWORD PTR [esi]

	; projWidth = proj * self.IMAGE_RATIO
	FINIT
	mov esi, projHeight
	FILD DWORD PTR [esi]
	FLD IMAGE_RATIO
	FMUL
	mov esi, projWidth
	FIST DWORD PTR [esi]

	; posX = self.screen_x - self.sprite_half_width
	FINIT
	FILD screenX
	mov esi, projWidth
	FILD DWORD PTR [esi]
	mov temp, 2
	FIDIV temp
	FSUB
	mov esi, posX
	FIST DWORD PTR [esi]

	; posY = HALF_HEIGHT - proj_height // 2 + height_shift
	FINIT
	mov temp, WINDOW_HALF_HEIGHT
	FILD temp
	mov esi, projHeight
	FILD DWORD PTR [esi]
	mov temp, 2
	FIDIV temp
	FSUB ; TODO:HEIGHT_SHIFT
	mov temp, 10
	FILD temp
	FADD
	mov esi, posY
	FIST DWORD PTR [esi]

	FINIT
	FLD dist  
	mov temp, 1000 ;avoid float number comparison
	FIMUL temp
	mov esi, normDistInt
	FIST DWORD PTR [esi]
	
exit_get_sprite:
	FINIT
	FLD delta
	mov esi, delta_res
	FST REAL8 PTR [esi]
	FLD dist
	mov esi, dist_res
	FST REAL8 PTR [esi]
	popad
	RET
GetSprite ENDP
END
