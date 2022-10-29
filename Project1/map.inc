IFNDEF MAP_INC
MAP_INC equ <1>

include windows.inc

DrawMap Proto, hdc:HDC
DrawWall Proto, hdc:HDC, drawDC:HDC
CheckPositionValid Proto, playerX:DWORD, playerY:DWORD

ENDIF