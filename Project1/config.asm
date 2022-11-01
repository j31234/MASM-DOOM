.386
.model flat, stdcall
OPTION CaseMap:None

include config.inc

.data
MOUSE_SENSITIVITY REAL8 0.002
PLAYER_SPEED REAL8 0.5
hTexture1 DWORD ?
hTexture2 DWORD ?
hTexture3 DWORD ?
hBackground DWORD ?
hNPC1 DWORD ?
weaponIDBList DWORD 131, 132, 133, 134, 135, 136
hWeaponBitmapList DWORD 6 DUP(?)

END