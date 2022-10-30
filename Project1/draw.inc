IFNDEF DRAW_INC
DRAW_INC equ <1>

include windows.inc

GetRGB Proto, red:BYTE, green:BYTE, blue:BYTE
DrawLine Proto, hdc:HDC, fromX:DWORD, fromY:DWORD, toX:DWORD, toY:DWORD, RGB: DWORD
DrawMain Proto, hdc:HDC, drawdc:HDC
DrawBitmap Proto, hdc:HDC, drawdc:HDC, DestX:DWORD, DestY:DWORD, nWidth:DWORD, nHeight:DWORD, SrcX:DWORD, SrcY:DWORD, hBitmap:DWORD
DrawNPC Proto, hdc:HDC, drawdc:HDC, DestX:DWORD, DestY:DWORD, projWidth:DWORD, projHeight:DWORD, pic:DWORD

renderObject STRUCT
  destX DWORD ?
  destY DWORD ?
  destWidth DWORD ?
  destHeight DWORD ?
  srcX DWORD ?
  srcY DWORD ?
  srcWidth DWORD ?
  srcHeight DWORD ?
  hPic DWORD ?
  transparent DWORD ?
renderObject ENDS; ¹²32¸ö×Ö½Ú

EXTERNDEF renderList: renderObject
EXTERNDEF renderHead: DWORD
EXTERNDEF renderTail: DWORD

ENDIF