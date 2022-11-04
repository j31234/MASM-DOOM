IFNDEF MAP_INC
MAP_INC equ <1>

include windows.inc

InitMap Proto
DrawMap Proto, hdc:HDC
DrawWall Proto, hdc:HDC, drawDC:HDC
CheckPositionValid Proto, playerX:DWORD, playerY:DWORD
CheckBlockValid Proto, blockX:DWORD, blockY:DWORD
GetBlockID Proto, x:DWORD, y:DWORD, ptrBlockX:DWORD, ptrBlockY:DWORD

ENDIF