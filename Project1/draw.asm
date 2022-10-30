.386
.model flat, stdcall
OPTION  CaseMap:None

; MASM32 Headers
include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include msimg32.inc

; MASM32 Library
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib msimg32.lib

; Custom Header
include draw.inc
include player.inc
include map.inc
include config.inc
include sprite.inc

.data
renderList renderObject RENDER_LIST_LENGTH DUP(<>)
renderHead DWORD ?
renderTail DWORD ?


.code
GetRGB Proc, red:BYTE, green:BYTE, blue:BYTE
  mov eax, 0
  mov ah, blue
  mov al, green
  shl eax, 8
  mov al, red
  RET
GetRGB ENDP

DrawLine Proc, hdc:HDC, fromX:DWORD, fromY:DWORD, toX:DWORD, toY:DWORD, RGB: DWORD
  INVOKE SetDCPenColor, hdc, RGB
  INVOKE MoveToEx, hdc, fromX, fromY, 0
  INVOKE LineTo, hdc, toX, toY
  RET
DrawLine ENDP

PushRenderList Proc, hdc:HDC, drawdc:HDC, DestX:DWORD, DestY:DWORD, nWidth:DWORD, nHeight:DWORD,
	SrcX:DWORD, SrcY:DWORD, SrcWidth:DWORD, SrcHeight:DWORD, pic:DWORD, transparent:DWORD
  mov edi, renderTail 

  mov eax, DestX
  mov (renderObject PTR renderList[edi]).destX, eax
  mov eax, DestY
  mov (renderObject PTR renderList[edi]).destY, eax
  mov eax, nWidth
  mov (renderObject PTR renderList[edi]).destWidth, eax
  mov eax, nHeight
  mov (renderObject PTR renderList[edi]).destHeight, eax
  mov eax, SrcX
  mov (renderObject PTR renderList[edi]).srcX, eax
  mov eax, SrcY
  mov (renderObject PTR renderList[edi]).srcY, eax
  mov eax, SrcWidth
  mov (renderObject PTR renderList[edi]).srcWidth, eax
  mov eax, SrcHeight
  mov (renderObject PTR renderList[edi]).srcHeight, eax
  mov eax, pic
  mov (renderObject PTR renderList[edi]).hPic, eax
  mov eax, transparent
  mov (renderObject PTR renderList[edi]).transparent, eax

  add edi, TYPE renderObject
  mov renderTail, edi
  RET
PushRenderList ENDP

DrawBitmap Proc, hdc:HDC, drawdc:HDC, DestX:DWORD, DestY:DWORD, nWidth:DWORD, nHeight:DWORD,
				 SrcX:DWORD, SrcY:DWORD, pic:DWORD
	invoke PushRenderList, hdc, drawdc, DestX, DestY, nWidth, nHeight, SrcX, SrcY, nWidth, 256, pic, 0
  RET
DrawBitmap ENDP

DrawNPC Proc, hdc:HDC, drawdc:HDC, DestX:DWORD, DestY:DWORD, projWidth:DWORD, projHeight:DWORD, pic:DWORD
	LOCAL oldObject:HGDIOBJ, color:DWORD
  INVOKE PushRenderList, hdc,drawdc, DestX, DestY, projWidth, projHeight, 0, 0, 126, 132, hNPC1, 1
  RET
DrawNPC ENDP

Render Proc, hdc:HDC, drawdc:HDC
	LOCAL oldObject:HGDIOBJ
	
	mov esi, 0
	INVOKE SelectObject, drawdc, (renderObject PTR renderList[esi]).hPic
	mov oldObject, eax
	.WHILE esi < renderTail
		INVOKE SelectObject, drawdc, (renderObject PTR renderList[esi]).hPic
		mov eax, (renderObject PTR renderList[esi]).transparent
		.IF eax == 0
			INVOKE StretchBlt, hdc, (renderObject PTR renderList[esi]).destX, (renderObject PTR renderList[esi]).destY,
				(renderObject PTR renderList[esi]).destWidth, (renderObject PTR renderList[esi]).destHeight, drawdc,
				(renderObject PTR renderList[esi]).srcX, (renderObject PTR renderList[esi]).srcY,
				(renderObject PTR renderList[esi]).srcWidth, (renderObject PTR renderList[esi]).srcHeight, SRCCOPY
		.ELSE
			INVOKE GetRGB, 255, 255, 255
			INVOKE TransparentBlt, hdc, (renderObject PTR renderList[esi]).destX, (renderObject PTR renderList[esi]).destY,
				(renderObject PTR renderList[esi]).destWidth, (renderObject PTR renderList[esi]).destHeight, drawdc,
				(renderObject PTR renderList[esi]).srcX, (renderObject PTR renderList[esi]).srcY,
				(renderObject PTR renderList[esi]).srcWidth, (renderObject PTR renderList[esi]).srcHeight, eax
		.ENDIF
		add esi, TYPE renderObject
	.ENDW
	INVOKE SelectObject, drawdc, oldObject
	RET
Render ENDP

DrawBackground Proc, hdc:HDC, drawdc:HDC, SrcX:DWORD, SrcY:DWORD
	LOCAL oldObject:HGDIOBJ, temp: SDWORD
  FINIT
  FLD playerAngle
  FLDPI
  mov temp, 2
  FIMUL temp
  FDIV
  mov temp, BACKGOUND_WIDTH
  FIMUL temp
  FCHS
  FIST temp

  mov edx, 0
  mov eax, temp
  cdq
  mov ebx, BACKGOUND_WIDTH
  idiv ebx
  mov temp, edx

  
  INVOKE SelectObject, drawdc, hBackground
  mov oldObject, eax
  INVOKE StretchBlt, hdc, temp, 0, BACKGOUND_WIDTH, BACKGOUND_HEIGHT, drawdc, SrcX, SrcY, BACKGOUND_WIDTH, BACKGOUND_HEIGHT, SRCCOPY
  mov eax, temp
  cmp eax, 0
  jl ADD_WIDTH
  sub eax, BACKGOUND_WIDTH
  jmp END_ADD
ADD_WIDTH:
    add eax, BACKGOUND_WIDTH
END_ADD:
  INVOKE StretchBlt, hdc, eax, 0, BACKGOUND_WIDTH, 300, drawdc, SrcX, SrcY, BACKGOUND_WIDTH, 300, SRCCOPY
  INVOKE SelectObject, drawdc, oldObject
  RET
DrawBackground ENDP

DrawFloor Proc, hdc:HDC
	LOCAL color:DWORD
  INVOKE GetRGB, 160, 160, 160
  mov color, eax
  INVOKE SetDCBrushColor, hdc, color
  INVOKE Rectangle, hdc, 0, WINDOW_HALF_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT
  RET
DrawFloor ENDP

DrawMain Proc, hdc:HDC, drawdc:HDC
  pushad

  mov renderHead, 0
  mov renderTail, 0

  ; INVOKE DrawMap, hdc
  INVOKE DrawPlayer, hdc ; TODO: refactor, DrawPlayer now include update player
  INVOKE DrawBackground, hdc, drawdc, 0, 0
  INVOKE DrawFloor, hdc
  INVOKE DrawWall, hdc, drawdc
  INVOKE GetSprite, hdc, drawdc, 500, 500; TODO: temperarily set a position
  
  INVOKE Render, hdc, drawdc
  
  ; Reset cursor position to the middle of the window
  INVOKE SetCursorPos, WINDOW_CENTER_X, WINDOW_CENTER_Y

  popad
  RET
DrawMain ENDP

END