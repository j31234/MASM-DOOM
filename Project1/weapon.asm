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
include draw.inc
include config.inc

.data
weaponState DWORD WEAPON_IDLE

.code
DrawWeapon Proc, hdc:HDC, drawdc:HDC
  mov eax, weaponState
  mov eax, hWeaponBitmapList[eax]
  INVOKE DrawTransparentBitmap, hdc,drawdc, WINDOW_WIDTH / 2 - WEAPON_WIDTH / 2, WINDOW_HEIGHT - WEAPON_HEIGHT, WEAPON_WIDTH, WEAPON_HEIGHT, 
	0, 0, 970, 1050, eax, 0
  RET
DrawWeapon ENDP


END