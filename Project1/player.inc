IFNDEF PLAYER_INC
PLAYER_INC equ <1>

include windows.inc

SetPlayerPos Proto, newX:DWORD, newY:DWORD
DrawPlayer Proto, hdc: HDC
playerStateCheck Proto

EXTERNDEF playerX:DWORD
EXTERNDEF playerY:DWORD
EXTERNDEF playerAngle:REAL8
EXTERNDEF playerBlood:DWORD

ENDIF