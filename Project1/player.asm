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
playerAngle REAL8 0.785

.code
UpdatePlayerState PROC
  pushad

  

  mov eax, PLAYER_SPEED
  mov edx, DELTA_TIME
  mul edx
  mov ebx, eax

  INVOKE crt_cos, playerAngle

  ; check W
  INVOKE GetAsyncKeyState, VK_W
  shr ax, 15
  .IF ax != 0
    mov eax, playerY
	sub eax, ebx
	mov playerY, eax
  .ENDIF
  ; check S
  INVOKE GetAsyncKeyState, VK_S
  shr ax, 15
  .IF ax != 0
    mov eax, playerY
	add eax, ebx
	mov playerY, eax
  .ENDIF
  ; check A
  INVOKE GetAsyncKeyState, VK_A
  shr ax, 15
  .IF ax != 0
    mov eax, playerX
	sub eax, ebx
	mov playerX, eax
  .ENDIF
  ; check D
  INVOKE GetAsyncKeyState, VK_D
  shr ax, 15
  .IF ax != 0
    mov eax, playerX
	add eax, ebx
	mov playerX, eax
  .ENDIF

  popad
  RET
UpdatePlayerState ENDP

.data
playerRect RECT <>
playerRadius = 5
.code
DrawPlayer PROC, hdc: HDC
  INVOKE UpdatePlayerState

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
  
  INVOKE SetDCBrushColor, hdc, 000000ffh
  INVOKE Ellipse, hdc, playerRect.left, playerRect.top, playerRect.right, playerRect.bottom
  RET
DrawPlayer ENDP

END