.386
.model flat, stdcall
OPTION  CaseMap:None

; MASM32 Headers
include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include msimg32.inc

; MASM32 Library
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib msimg32.lib

; Custom Header
include weapon.inc
include map.inc
include sprite.inc
include draw.inc
include config.inc
include sound.inc

.data
weaponState DWORD WEAPON_IDLE
frameCount DWORD 0

.code
OnWeaponFired Proc
  LOCAL soundType:DWORD
  mov soundType, 0
  ; TODO: Bullet Collision Detection
  INVOKE ShotgunSound
  mov esi, 0
  .WHILE esi < NPCNum
    INVOKE NPCDamage, WEAPON_HURT, esi
	.IF eax > soundType
	  mov soundType, eax
    .ENDIF
	inc esi
  .ENDW
  .IF soundType == 1
    INVOKE NPCPainSound
  .ELSEIF soundType == 2
    INVOKE NPCDeathSound
  .ENDIF
  RET
OnWeaponFired ENDP

DrawWeapon Proc, hdc:HDC, drawdc:HDC
  mov eax, weaponState
  mov eax, hWeaponBitmapList[eax * TYPE hWeaponBitmapList]

  ; draw weapon image
  ; different state animation has different shape ...
  .IF weaponState < 3
    ; 970 * 1050
    INVOKE DrawTransparentBitmap, hdc,drawdc, WINDOW_WIDTH / 2 - WEAPON_WIDTH / 2, WINDOW_HEIGHT - WEAPON_HEIGHT, WEAPON_WIDTH, WEAPON_HEIGHT, 
	  0, 0, 970, 1050, eax, 0
  .ELSE
    ; 939 * 1042
    INVOKE DrawTransparentBitmap, hdc,drawdc, WINDOW_WIDTH / 2 - WEAPON_WIDTH / 2, WINDOW_HEIGHT - WEAPON_HEIGHT, WEAPON_WIDTH, WEAPON_HEIGHT, 
	  0, 0, 939, 1042, eax, 0
  .ENDIF
  
  ; update weapon state
  mov eax, frameCount
  inc eax
  mov frameCount, eax

  ; when weapon fired
  INVOKE GetAsyncKeyState, VK_LBUTTON
  shr ax, 15
  .IF ax != 0 && weaponState == WEAPON_IDLE 
    mov weaponState, WEAPON_FIRE_0
	mov frameCount, 0
	INVOKE OnWeaponFired
  .ENDIF

  .IF frameCount == WEAPON_FRAME_PER_TRANS
	; weaponState = (weaponState + 1) % 6
	mov eax, weaponState
	.IF eax == WEAPON_RELOAD_2
	  mov eax, WEAPON_IDLE
	.ELSEIF eax != WEAPON_IDLE
	  inc eax
	.ENDIF
	mov weaponState, eax

	mov frameCount, 0
	.IF weaponState >= WEAPON_RELOAD_0
	  mov frameCount, -WEAPON_FRAME_PER_TRANS
	.ENDIF 
  .ENDIF
  RET
DrawWeapon ENDP


END