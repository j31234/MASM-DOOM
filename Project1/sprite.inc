IFNDEF SPRITE_INC
SPRITE_INC equ <1>

include windows.inc


DrawNPC Proto, hdc:HDC, drawdc:HDC, DestX:DWORD, DestY:DWORD, projWidth:DWORD, projHeight:DWORD, pic:DWORD
GetSprite Proto, hdc:HDC, drawdc:HDC, x:DWORD, y:DWORD
ENDIF