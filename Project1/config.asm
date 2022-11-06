.386
.model flat, stdcall
OPTION CaseMap:None

include config.inc

.data
MOUSE_SENSITIVITY REAL8 0.002
PLAYER_SPEED REAL8 0.5
hIndex1 DWORD ?
hIndex2 DWORD ?
hTexture1 DWORD ?
hTexture2 DWORD ?
hTexture3 DWORD ?
hBackground DWORD ?
hNPC1 DWORD ?
hNPC2 DWORD ?
hNPC3 DWORD ?
weaponIDBList DWORD 131, 132, 133, 134, 135, 136
hWeaponBitmapList DWORD 6 DUP(?)
cacoIDBList DWORD 153, 154, 155, 156, 157, 158, 159, 160
hCacoBitmapList DWORD 8 DUP(?)
hCacoAttack DWORD ?
hCacoHurt DWORD ?
hCacoDeath DWORD ?
cocoIDBList DWORD 180, 181, 182, 183, 184, 185, 186, 187
hCocoBitmapList DWORD 8 DUP(?)
hCocoAttack DWORD ?
hCocoHurt DWORD ?
hCocoDeath DWORD ?
cucoIDBList DWORD 192, 193, 194, 195, 196, 197, 198, 199
hCucoBitmapList DWORD 8 DUP(?)
hCucoAttack DWORD ?
hCucoHurt DWORD ?
hCucoDeath DWORD ?
bloodIDBList DWORD 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172
hBloodBitmapList DWORD 11 DUP(?)
hEnd DWORD ?
hWin DWORD ?
hNextStage DWORD ?
XScale DWORD 80
YScale DWORD 80

END