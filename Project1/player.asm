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

.data
playerX DWORD 150
playerY DWORD 150
playerAngle REAL8 -0.785
speedX DWORD 0
speedY DWORD 0

.code
UpdatePlayerState PROC, hdc: HDC
  LOCAL scale:DWORD, playerDx:DWORD, playerDy:DWORD
  pushad
  
  ; scale speed by PLAYER_SPEED * DELTA_TIME
  mov eax, PLAYER_SPEED
  mov edx, DELTA_TIME
  mul edx
  mov scale, eax

  ; calc sin / cos of speed
  FINIT
  FLD playerAngle
  FCOS
  FIMUL scale
  FIST speedX
  FLD playerAngle
  FSIN
  FIMUL scale
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

  popad
  RET
UpdatePlayerState ENDP

.data
playerRect RECT <>
playerRadius = 5
.code
DrawPlayer PROC, hdc: HDC
  INVOKE UpdatePlayerState, hdc

  ; debug: draw player angle
  mov eax, playerX
  add eax, speedX
  add eax, speedX
  mov ebx, playerY
  add ebx, speedY
  add ebx, speedY
  INVOKE DrawLine, hdc, playerX, playerY, eax, ebx, 00ff0000h

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
  
  ; draw player position
  INVOKE SetDCBrushColor, hdc, 000000ffh
  INVOKE Ellipse, hdc, playerRect.left, playerRect.top, playerRect.right, playerRect.bottom

  RET
DrawPlayer ENDP

END