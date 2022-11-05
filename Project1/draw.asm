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
include weapon.inc

.data
renderList renderObject RENDER_LIST_LENGTH DUP(<>)
renderHead DWORD ?
renderTail DWORD ?
l DWORD ?
r DWORD ?


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
	SrcX:DWORD, SrcY:DWORD, SrcWidth:DWORD, SrcHeight:DWORD, pic:DWORD, transparent:DWORD, dist:DWORD
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
  mov eax, dist
  mov (renderObject PTR renderList[edi]).dist, eax

  add edi, TYPE renderObject
  mov renderTail, edi
  RET
PushRenderList ENDP

DrawBitmap Proc, hdc:HDC, drawdc:HDC, DestX:DWORD, DestY:DWORD, nWidth:DWORD, nHeight:DWORD,
				 SrcX:DWORD, SrcY:DWORD, SrcWidth:DWORD, SrcHeight:DWORD, hpic:DWORD, dist:DWORD
	invoke PushRenderList, hdc, drawdc, DestX, DestY, nWidth, nHeight, SrcX, SrcY, SrcWidth, SrcHeight, hpic, 0, dist
  RET
DrawBitmap ENDP

DrawNPCBitmap Proc, hdc:HDC, drawdc:HDC, DestX:DWORD, DestY:DWORD, projWidth:DWORD, projHeight:DWORD, pic:DWORD, dist:DWORD
	LOCAL oldObject:HGDIOBJ, color:DWORD
  INVOKE PushRenderList, hdc,drawdc, DestX, DestY, projWidth, projHeight, 0, 0, 126, 132, pic, 1, dist
  RET
DrawNPCBitmap ENDP

DrawTransparentBitmap  Proc, hdc:HDC, drawdc:HDC, DestX:DWORD, DestY:DWORD, DestWidth:DWORD, DestHeight:DWORD,
	SrcX:DWORD, SrcY:DWORD, SrcWidth:DWORD, SrcHeight:DWORD, hBitmap:DWORD, distance:DWORD
  INVOKE PushRenderList, hdc,drawdc, DestX, DestY, DestWidth, DestHeight, SrcX, SrcY, SrcWidth, SrcHeight, hBitmap, 1, distance
  RET
DrawTransparentBitmap ENDP

swap proc
 pushad
 mov eax, esi
 mov edi, size renderObject
 mul edi
 add eax, offset renderList
 mov esi, eax

 mov eax, ebx
 mov edi, size renderObject
 mul edi
 add eax, offset renderList
 mov ebx, eax

 xor edx, edx
 mov eax, size renderObject
 mov edi, size dword
 div edi
 mov ecx, eax
swap_loop:
 mov edx, DWORD PTR [esi]
 mov edi, DWORD PTR [ebx]
 mov [esi], edi
 mov [ebx], edx
 add esi, 4
 add ebx, 4
 loop swap_loop

 popad
 ret
swap endp

quicksort proc
 mov eax, l
 cmp eax, r
 jg over
 xor esi, esi;
 xor ebx, ebx;
 mov esi, l ;i
 mov ebx, r ;j

 xor edx, edx
 mov eax, esi
 mov edi, SIZE renderObject
 mul edi
 mov edi, eax
 mov eax, (renderObject PTR renderList[edi]).dist

sort_again:
 cmp ebx,esi;    while (i!=j)
 je over_loop;
  loop_j_again:
   cmp esi, ebx;    while(i<j)
   jge over_loop
   ;cmp eax,dat[ebx * type dat];  while (a[j]>=a[l])

    mov ecx, eax
     xor edx, edx
     mov eax, ebx
     mov edi, SIZE renderObject
     mul edi
     mov edi, eax
     mov eax, ecx
   cmp eax, (renderObject PTR renderList[edi]).dist
   jl loop_i_again
   add ebx, -1   ;  j--
   jmp loop_j_again;
  loop_i_again:
   cmp esi, ebx;    while (i<j)
   jge over_loop
   ;cmp eax,dat[esi * type dat];  while (a[l]>=a[i])

 mov ecx, eax
 xor edx, edx
 mov eax, esi
 mov edi, SIZE renderObject
 mul edi
 mov edi, eax
 mov eax, ecx
   cmp eax, (renderObject PTR renderList[edi]).dist


   jg compare;
   add esi, 1;     i++
   jmp loop_i_again;
  compare:
   cmp esi, ebx;   if (i>=j)
   jge over_loop;    break
   call swap;    swap(i,j)
 jmp sort_again
 over_loop:
  mov ebx, l;
  call swap;    swap(i,l)
  push esi; push i
  push r  ;push r
  mov r, esi
  add r, -1
  call quicksort;   quicksort(l, i-1);
  pop r
  pop ebx
  mov l, ebx;
  inc l
  call quicksort;   quicksort(i+1, r);
 over:
  ret
quicksort endp

Render Proc, hdc:HDC, drawdc:HDC
	LOCAL oldObject:HGDIOBJ

	xor edx, edx
	mov eax, renderTail
	mov ebx, SIZE renderObject
	div ebx
	dec eax
	mov l, 0
	mov r, eax
	call quicksort

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
			; blt white background
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

DrawNPC Proc, hdc:HDC, drawdc:HDC
	LOCAL posX:DWORD, posY:DWORD, projWidth:DWORD, projHeight:DWORD, normDistInt:DWORD, delta:REAL8, normDist:REAL8
	LOCAL npcID:DWORD
	mov ecx, NPCNum
NPC_LOOP:
	mov eax, ecx
	dec eax
	mov ebx, SIZE NPC
	mul ebx
	mov edx, (NPC PTR NPCList[eax]).blood
	.IF edx > 0
		; Move NPC
		pushad
		mov npcID, eax
		INVOKE MoveNPC, eax
		popad
		; Get NPC position
		pushad
		INVOKE GetSprite, ADDR posX, ADDR posY, ADDR projWidth, ADDR projHeight, ADDR normDist, ADDR normDistInt, ADDR delta, eax

		mov esi, npcID
		mov eax, (NPC PTR NPCList[esi]).nowIDB
		; Draw NPC
		INVOKE DrawNPCBitmap, hdc, drawdc, posX, posY, projWidth, projHeight, eax, normDistInt

		popad
	.ENDIF
	loop NPC_LOOP
	RET
DrawNPC ENDP

DrawEnd PROC,  hdc:HDC, drawdc:HDC
	INVOKE DrawBitmap, hdc, drawdc, 0, 0, 800, 600, 50, 50, 1600, 800, hEnd, 0
	RET
DrawEnd ENDP

DrawWin PROC,  hdc:HDC, drawdc:HDC
	INVOKE DrawTransparentBitmap, hdc, drawdc, 0, 0, 800, 600, 50, 50, 1600, 800, hWin, 0
	RET
DrawWin ENDP

DrawBlood PROC, hdc:HDC, drawdc:HDC
	; hundred
	xor edx, edx
	mov eax, playerBlood
	mov ebx, 100
	div ebx
	.IF eax == 1
		mov esi, 1
		mov esi, hBloodBitmapList[esi * TYPE hBloodBitmapList]
		INVOKE DrawTransparentBitmap, hdc, drawdc, 10, 10, 64, 64, 0, 0, 64, 64, esi, 0
	.ENDIF

	; ten
	xor edx, edx
	mov eax, playerBlood
	mov ebx, 10
	div ebx
	.IF eax == 0
		jmp DRAW_SINGLE
	.ELSEIF eax == 10
		mov eax, 0
	.ENDIF
	mov esi, hBloodBitmapList[eax * TYPE hBloodBitmapList]
	INVOKE DrawTransparentBitmap, hdc, drawdc, 80, 10, 64, 64, 0, 0, 64, 64, esi, 0

DRAW_SINGLE:
	; single
	xor edx, edx
	mov eax, playerBlood
	mov ebx, 10
	div ebx
	mov esi, hBloodBitmapList[edx * TYPE hBloodBitmapList]
	INVOKE DrawTransparentBitmap, hdc, drawdc, 150, 10, 64, 64, 0, 0, 64, 64, esi, 0

	; percent
	mov eax, 10
	mov esi, hBloodBitmapList[eax * TYPE hBloodBitmapList]
	INVOKE DrawTransparentBitmap, hdc, drawdc, 220, 10, 64, 64, 0, 0, 64, 64, esi, 0

	RET
DrawBlood ENDP

DrawMain Proc, hdc:HDC, drawdc:HDC
  pushad

  mov renderHead, 0
  mov renderTail, 0

  INVOKE playerStateCheck ; 0 for dead, 1 for alive, 2 for no-attracked state, 3 for win

  ; dead
  .IF eax == 0
	INVOKE DrawEnd, hdc, drawdc
	jmp StartRender
  ; no-attracked
  .ELSEIF eax == 3
	INVOKE DrawWin, hdc, drawdc
  .ENDIF


  ; INVOKE DrawMap, hdc
  INVOKE DrawPlayer, hdc ; TODO: refactor, DrawPlayer now include update player
  INVOKE DrawBlood, hdc, drawdc
  INVOKE DrawBackground, hdc, drawdc, 0, 0
  INVOKE DrawFloor, hdc
  INVOKE DrawNPC, hdc, drawdc
  INVOKE DrawWall, hdc, drawdc

  ; Draw Weapon
  INVOKE DrawWeapon, hdc, drawdc

  ; Reset cursor position to the middle of the window
  INVOKE SetCursorPos, WINDOW_CENTER_X, WINDOW_CENTER_Y

StartRender:
  INVOKE Render, hdc, drawdc


  popad
  RET
DrawMain ENDP

END