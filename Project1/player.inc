IFNDEF PLAYER_INC
PLAYER_INC equ <1>

include windows.inc

DrawPlayer Proto, hdc: HDC
EXTERNDEF playerX:DWORD
EXTERNDEF playerY:DWORD
EXTERNDEF playerAngle:REAL8


ENDIF