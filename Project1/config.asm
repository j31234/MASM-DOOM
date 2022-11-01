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
weapnIDBList DWORD 125, 126, 127, 128, 129, 130
hWeaponBitmapList DWORD 6 DUP(?)

END