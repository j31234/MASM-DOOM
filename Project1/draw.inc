IFNDEF DRAW_INC
DRAW_INC equ <1>

include windows.inc

GetRGB Proto, red:BYTE, green:BYTE, blue:BYTE
DrawLine Proto, hdc:HDC, fromX:DWORD, fromY:DWORD, toX:DWORD, toY:DWORD, RGB: DWORD
DrawMain Proto, hdc:HDC

ENDIF