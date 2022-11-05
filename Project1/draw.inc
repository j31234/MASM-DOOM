IFNDEF DRAW_INC
DRAW_INC equ <1>

include windows.inc

GetRGB Proto, red:BYTE, green:BYTE, blue:BYTE
DrawLine Proto, hdc:HDC, fromX:DWORD, fromY:DWORD, toX:DWORD, toY:DWORD, RGB: DWORD
DrawMain Proto, hdc:HDC, drawdc:HDC
DrawBitmap Proto, hdc:HDC, drawdc:HDC, DestX:DWORD, DestY:DWORD, nWidth:DWORD, nHeight:DWORD, SrcX:DWORD, SrcY:DWORD, SrcWidth:DWORD, SrcHeight:DWORD, hBitmap:DWORD, dist:DWORD
DrawNPCBitmap Proto, hdc:HDC, drawdc:HDC, DestX:DWORD, DestY:DWORD, projWidth:DWORD, projHeight:DWORD, pic:DWORD, dist:DWORD
DrawTransparentBitmap  Proto, hdc:HDC, drawdc:HDC, DestX:DWORD, DestY:DWORD, DestWidth:DWORD, DestHeight:DWORD,
	SrcX:DWORD, SrcY:DWORD, SrcWidth:DWORD, SrcHeight:DWORD, hBitmap:DWORD, distance:DWORD
RayCasting Proto, angle:REAL8, pWallX:PTR DWORD, pWallY:PTR DWORD, pWallDistance:PTR REAL8, pOffset:PTR REAL8, pTextureType: PTR DWORD

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
  dist DWORD ?
renderObject ENDS; ¹²11*4¸ö×Ö½Ú

EXTERNDEF renderList: renderObject
EXTERNDEF renderHead: DWORD
EXTERNDEF renderTail: DWORD

ENDIF