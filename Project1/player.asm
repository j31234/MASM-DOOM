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
include config.inc
include map.inc
include sprite.inc

.data
playerX DWORD 150
playerY DWORD 220
playerAngle REAL8 3.6
playerBlood DWORD 100
playerProtectedFrame DWORD 200
speedX DWORD 0
speedY DWORD 0
.code
UpdatePlayerAngle PROC
  LOCAL cursorPos:POINT, dAngle: DWORD
  INVOKE GetCursorPos, ADDR cursorPos

  ; calc delta angle
  mov eax, cursorPos.x
  sub eax, WINDOW_CENTER_X
  mov dAngle, eax

  ; playerAngle += dAngle * MOUSE_SENSITIVITY / 100
  ; FINIT
  FLD playerAngle
  FILD dAngle
  FLD MOUSE_SENSITIVITY
  FMUL
  FADD
  FST playerAngle
  RET
UpdatePlayerAngle ENDP

UpdatePlayerPosition PROC
  LOCAL tmp:DWORD, scale:REAL8, playerDx:DWORD, playerDy:DWORD

  ; scale speed by PLAYER_SPEED * DELTA_TIME
  mov tmp, DELTA_TIME
  FINIT
  FILD tmp
  FMUL PLAYER_SPEED
  FST scale

  ; calc sin / cos of speed
  FINIT
  FLD playerAngle
  FCOS
  FMUL scale
  FIST speedX
  FLD playerAngle
  FSIN
  FMUL scale
  FIST speedY
  
  mov playerDx, 0
  mov playerDy, 0
  ; check W
  INVOKE GetAsyncKeyState, VK_W
  shr ax, 15
  .IF ax != 0 ; W pressed
	mov eax, speedX
    add playerDx, eax
	mov eax, speedY
	add playerDy, eax
  .ENDIF
  ; check S
  INVOKE GetAsyncKeyState, VK_S
  shr ax, 15
  .IF ax != 0
    mov eax, speedX
    sub playerDx, eax
	mov eax, speedY
	sub playerDy, eax
  .ENDIF
  ; check A
  INVOKE GetAsyncKeyState, VK_A
  shr ax, 15
  .IF ax != 0
    mov eax, speedY
    add playerDx, eax
	mov eax, speedX
	sub playerDy, eax
  .ENDIF
  ; check D
  INVOKE GetAsyncKeyState, VK_D
  shr ax, 15
  .IF ax != 0
    mov eax, speedY
    sub playerDx, eax
	mov eax, speedX
	add playerDy, eax
  .ENDIF

  ; position += delta
  mov eax, playerDx
  add playerX, eax
  mov eax, playerDy
  add playerY, eax

  INVOKE CheckPositionValid, playerX, playerY
  .IF al != 0
    ; invalid position, go back
	mov eax, playerDx
	sub playerX, eax
	mov eax, playerDy
	sub playerY, eax
  .ENDIF
  RET
UpdatePlayerPosition ENDP

UpdatePlayerState PROC
  INVOKE UpdatePlayerAngle
  INVOKE UpdatePlayerPosition
  RET
UpdatePlayerState ENDP

.data
playerRect RECT <>
playerRadius = 5
.code
DrawPlayer PROC, hdc: HDC
  INVOKE UpdatePlayerState

  ; draw player position
  mov eax, playerX
  mov playerRect.left, eax
  sub playerRect.left, playerRadius
  mov playerRect.right, eax
  add playerRect.right, playerRadius

  mov eax, playerY
  mov playerRect.top, eax
  sub playerRect.top, playerRadius
  mov playerRect.bottom, eax
  add playerRect.bottom, playerRadius
  
  ;INVOKE SetDCBrushColor, hdc, 000000ffh
  ;INVOKE Ellipse, hdc, playerRect.left, playerRect.top, playerRect.right, playerRect.bottom

  RET
DrawPlayer ENDP

checkAttack PROC
	LOCAL temp:DWORD, deltaX: REAL8, deltaY: REAL8
	mov esi, 0
	.WHILE esi < NPCAliveNum
		FINIT
		FILD (NPC PTR NPCList[esi]).posX
		FILD playerX
		FSUB
		FST deltaX
		FILD (NPC PTR NPCList[esi]).posY
		FILD playerY
		FSUB
		FST deltaY
		FLD deltaX
		FMUL deltaX
		FLD deltaY
		FMUL deltaY
		FADD
		FSQRT
		mov temp, ATTACK_RADIUM
		FILD temp
		FCOM
		FSTSW ax
		SAHF
		jc NO_ATTACKED
		mov eax, playerBlood
		.IF eax < ATTACK_HURT
			mov eax, 0
		.ELSE
			sub eax, ATTACK_HURT
		.ENDIF
		mov playerBlood, eax
		mov playerProtectedFrame, ATTACK_INTERVAL
	NO_ATTACKED:
		inc esi
	.ENDW
	RET
checkAttack ENDP

; 0 for dead, 1 for alive, 2 for protected-frame state, 3 for win 
playerStateCheck PROC
	; dead check
	mov eax, playerBlood
	cmp eax, 0
	je ExitPlayerStateCheck

	; protected state check
	mov eax, playerProtectedFrame
	.IF eax > 0
		dec eax
		mov playerProtectedFrame, eax
		mov eax, 2
		jmp ExitPlayerStateCheck
	.ENDIF

	; win check
	mov eax, NPCAliveNum
	.IF eax == 0
		mov eax, 3
		jmp ExitPlayerStateCheck
	.ENDIF

	; be attacked check
	invoke checkAttack

	; dead check
	mov eax, playerBlood
	cmp eax, 0
	je ExitPlayerStateCheck

	mov eax, 1
ExitPlayerStateCheck:
	RET
playerStateCheck ENDP

END