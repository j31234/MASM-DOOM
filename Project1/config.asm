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
cacoIDBList DWORD 153, 154, 155, 156, 157, 158, 159, 160
hCacoBitmapList DWORD 8 DUP(?)
hCacoAttack DWORD ?
bloodIDBList DWORD 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172
hBloodBitmapList DWORD 11 DUP(?)
hEnd DWORD ?
hWin DWORD ?

END