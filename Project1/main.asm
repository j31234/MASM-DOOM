.386
.model flat, stdcall
OPTION  CaseMap:None

; MASM32 Headers
include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc

; MASM32 Library
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib

; Custom Header
include config.inc
include map.inc
include draw.inc
include player.inc
include sound.inc

FUNCPROTO       TYPEDEF PROTO
FUNCPTR         TYPEDEF PTR FUNCPROTO

;==================== DATA =======================
.data

ErrorTitle  BYTE "Error",0
WindowName  BYTE "ASM Windows App",0
className   BYTE "ASMWin",0
bgmName     BYTE "DoomTheme.wav", 0

; Define the Application's Window class structure.
MainWin WNDCLASS <NULL,WinProc,NULL,NULL,NULL,NULL,NULL, \
	COLOR_WINDOW,NULL,className>

msg	      MSG <>
winRect   RECT <>
hMainWnd  DWORD ?
hInstance DWORD ?
WINDOW_STYLE = WS_POPUP
indexState DWORD 1 ; 01-39 for index page & 00 for begin

;=================== CODE =========================
.code
WinMain PROC
; Get a handle to the current process.
	INVOKE GetModuleHandle, NULL
	mov hInstance, eax
	mov MainWin.hInstance, eax

; Load the program's icon and cursor.
	IDI_ICON1 = 101
	INVOKE LoadIcon, hInstance, IDI_ICON1
	mov MainWin.hIcon, eax

	IDB_TEXTURE1 = 103
	INVOKE LoadBitmap, hInstance, IDB_TEXTURE1
	mov hTexture1, eax

	IDB_TEXTURE2 = 104
	INVOKE LoadBitmap, hInstance, IDB_TEXTURE2
	mov hTexture2, eax

	IDB_TEXTURE3 = 106
	INVOKE LoadBitmap, hInstance, IDB_TEXTURE3
	mov hTexture3, eax

	IDB_BACKGROUND = 109
	INVOKE LoadBitmap, hInstance, IDB_BACKGROUND
	mov hBackground, eax

	IDB_INDEX1 = 177
	INVOKE LoadBitmap, hInstance, IDB_INDEX1
	mov hIndex1, eax

	IDB_INDEX2 = 178
	INVOKE LoadBitmap, hInstance, IDB_INDEX2
	mov hIndex2, eax

	IDB_NEXTSTAGE = 203
	INVOKE LoadBitmap, hInstance, IDB_NEXTSTAGE
	mov hNextStage, eax

	IDB_NPC1 = 111
	INVOKE LoadBitmap, hInstance, IDB_NPC1
	mov hNPC1, eax

	IDB_NPC1_ATTACK = 174
	INVOKE LoadBitmap, hInstance, IDB_NPC1_ATTACK
	mov hCacoAttack, eax

	IDB_NPC1_DEATH = 175
	INVOKE LoadBitmap, hInstance, IDB_NPC1_DEATH
	mov hCacoDeath, eax

	IDB_NPC1_HURT = 176
	INVOKE LoadBitmap, hInstance, IDB_NPC1_HURT
	mov hCacoHurt, eax

	IDB_NPC2 = 178
	INVOKE LoadBitmap, hInstance, IDB_NPC2
	mov hNPC2, eax

	IDB_NPC2_ATTACK = 188
	INVOKE LoadBitmap, hInstance, IDB_NPC2_ATTACK
	mov hCocoAttack, eax

	IDB_NPC2_DEATH = 189
	INVOKE LoadBitmap, hInstance, IDB_NPC2_DEATH
	mov hCocoDeath, eax

	IDB_NPC2_HURT = 190
	INVOKE LoadBitmap, hInstance, IDB_NPC2_HURT
	mov hCocoHurt, eax

	IDB_NPC3 = 191
	INVOKE LoadBitmap, hInstance, IDB_NPC3
	mov hNPC3, eax

	IDB_NPC3_ATTACK = 200
	INVOKE LoadBitmap, hInstance, IDB_NPC3_ATTACK
	mov hCucoAttack, eax

	IDB_NPC3_DEATH = 201
	INVOKE LoadBitmap, hInstance, IDB_NPC3_DEATH
	mov hCucoDeath, eax

	IDB_NPC3_HURT = 202
	INVOKE LoadBitmap, hInstance, IDB_NPC3_HURT
	mov hCucoHurt, eax

	; Load 6 bitmaps for weapon animation
	mov ebx, 0
	.WHILE ebx < 6
		mov eax, weaponIDBList[ebx * TYPE weaponIDBList]
		INVOKE LoadBitmap, hInstance, eax
		mov hWeaponBitmapList[ebx * TYPE hWeaponBitmapList], eax
		inc ebx
	.ENDW

	; Load 8 bitmaps for caco animation
	mov ebx, 0
	.WHILE ebx < 8
		mov eax, cacoIDBList[ebx * TYPE cacoIDBList]
		INVOKE LoadBitmap, hInstance, eax
		mov hCacoBitmapList[ebx * TYPE hCacoBitmapList], eax
		inc ebx
	.ENDW

	; Load 8 bitmaps for coco animation
	mov ebx, 0
	.WHILE ebx < 8
		mov eax, cocoIDBList[ebx * TYPE cocoIDBList]
		INVOKE LoadBitmap, hInstance, eax
		mov hCocoBitmapList[ebx * TYPE hCocoBitmapList], eax
		inc ebx
	.ENDW

	; Load 8 bitmaps for cuco animation
	mov ebx, 0
	.WHILE ebx < 8
		mov eax, cucoIDBList[ebx * TYPE cucoIDBList]
		INVOKE LoadBitmap, hInstance, eax
		mov hCucoBitmapList[ebx * TYPE hCucoBitmapList], eax
		inc ebx
	.ENDW

	; Load 11 blood for weapon animation
	mov ebx, 0
	.WHILE ebx < 11
		mov eax, bloodIDBList[ebx * TYPE bloodIDBList]
		INVOKE LoadBitmap, hInstance, eax
		mov hBloodBitmapList[ebx * TYPE hBloodBitmapList], eax
		inc ebx
	.ENDW

	IDB_END = 161
	INVOKE LoadBitmap, hInstance, IDB_END
	mov hEnd, eax

	IDB_WIN = 173
	INVOKE LoadBitmap, hInstance, IDB_WIN
	mov hWin, eax

	INVOKE LoadCursor, NULL, IDC_ARROW
	mov MainWin.hCursor, eax

; Register the window class.
	INVOKE RegisterClass, ADDR MainWin
	.IF eax == 0
	  call ErrorHandler
	  jmp Exit_Program
	.ENDIF

; Create the application's main window.
; Returns a handle to the main window in EAX.
	INVOKE CreateWindowEx, 0, ADDR className,
	  ADDR WindowName,WINDOW_STYLE,
	  WINDOW_X,WINDOW_Y,
	  WINDOW_WIDTH,WINDOW_HEIGHT,
	  NULL,NULL,hInstance,NULL
	mov hMainWnd,eax

	; Hide Mouse Cursor
	INVOKE ShowCursor, 0

	; Reset cursor position to the middle of the window
	INVOKE SetCursorPos, WINDOW_CENTER_X, WINDOW_CENTER_Y

; If CreateWindowEx failed, display a message & exit.
	.IF eax == 0
	  call ErrorHandler
	  jmp  Exit_Program
	.ENDIF

; Read map data from file
	INVOKE InitMap

; Start playing bgm
	INVOKE PlayBGM

; Show and draw the window.
	INVOKE ShowWindow, hMainWnd, SW_SHOW
	INVOKE UpdateWindow, hMainWnd

; Display a greeting message.
;	INVOKE MessageBox, hMainWnd, ADDR GreetText,
;	  ADDR GreetTitle, MB_OK

; Frame timer
    INVOKE SetTimer, hMainWnd, NULL, DELTA_TIME, NULL

; Begin the program's message-handling loop.
Message_Loop:
	; Get next message from the queue.
	INVOKE GetMessage, ADDR msg, NULL,NULL,NULL

	; Quit if no more messages.
	.IF eax == 0
	  jmp Exit_Program
	.ENDIF

	; Relay the message to the program's WinProc.
	INVOKE DispatchMessage, ADDR msg
    jmp Message_Loop


Exit_Program:
	  INVOKE ExitProcess,0
WinMain ENDP

.data
hdc       HDC ?
memHdc    HDC ?
drawHdc    HDC ?
memBitmap HBITMAP ?
oldPen    HGDIOBJ ?
oldBrush  HGDIOBJ ?
oldObject HGDIOBJ ?
ps PAINTSTRUCT <>

.code
;-----------------------------------------------------
WinProc PROC,
	hWnd:DWORD, localMsg:DWORD, wParam:DWORD, lParam:DWORD
; The application's message handler, which handles
; application-specific messages. All other messages
; are forwarded to the default Windows message
; handler.
;-----------------------------------------------------
	mov eax, localMsg

COMMENT @
	.IF eax == WM_LBUTTONDOWN		; mouse button?
	  INVOKE MessageBox, hWnd, ADDR PopupText,
	    ADDR PopupTitle, MB_OK
	  jmp WinProcExit
@
	.IF eax == WM_TIMER
	  ; Get HDC

	  INVOKE GetDC, hMainWnd
	  mov hdc, eax

	  ; Double Buffering
	  INVOKE CreateCompatibleDC, hdc
	  mov memHdc, eax
	  INVOKE CreateCompatibleBitmap, hdc, WINDOW_WIDTH, WINDOW_HEIGHT
	  mov memBitmap, eax
	  INVOKE SelectObject, memHdc, memBitmap

	  INVOKE CreateCompatibleDC, hdc
	  mov drawHdc, eax

	  ; Set up DC pen / brush
	  INVOKE GetStockObject, DC_PEN
	  INVOKE SelectObject, memHdc, eax
	  mov oldPen, eax
	  INVOKE GetStockObject, DC_BRUSH
	  INVOKE SelectObject, memHdc, eax
	  mov oldBrush, eax


	  ; Background = white
	  INVOKE BitBlt, memHdc, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, hdc, 0, 0, WHITENESS
	  .IF indexState == 0
		; Draw Main
		INVOKE DrawMain, memHdc, drawHdc
		; Index
	  .ELSE
		; every 10 frames change the index1 <-> index2
		xor edx, edx
	    mov eax, indexState
		mov ebx, 10
		div ebx
		.IF eax < 2
			INVOKE SelectObject, drawHdc, hIndex1
			mov oldObject, eax
		.ELSEIF eax >= 2 && eax <= 3
			INVOKE SelectObject, drawHdc, hIndex2
			mov oldObject, eax
		.ELSE
			INVOKE SelectObject, drawHdc, hIndex2
			mov oldObject, eax
			mov indexState, 0
		.ENDIF
		add indexState, 1
		INVOKE StretchBlt, memHdc, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, drawHdc, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, SRCCOPY
		INVOKE SelectObject, drawHdc, oldObject
	  .ENDIF
	  
	  ; Alt the true device context
	  INVOKE BitBlt, hdc, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, memHdc, 0, 0, SRCCOPY

ReleaseResources:
	  ; Release Resources: double buffer, brush/pen, dc
	  INVOKE DeleteObject, memBitmap
	  INVOKE DeleteDC, memHdc
	  INVOKE SelectObject, memHdc, oldBrush
	  INVOKE SelectObject, memHdc, oldPen
	  INVOKE ReleaseDC, hMainWnd, hdc
	  INVOKE ReleaseDC, hMainWnd, drawHdc

	  jmp WinProcExit
	.ELSEIF eax == WM_KEYDOWN
	  .IF wParam == VK_ESCAPE
	    INVOKE PostQuitMessage,0
	  .ELSEIF wParam == VK_SPACE
		mov indexState, 0
	  .ENDIF
	  
	  jmp WinProcExit
	.ELSE		; other message?
	  INVOKE DefWindowProc, hWnd, localMsg, wParam, lParam
	  jmp WinProcExit
	.ENDIF

WinProcExit:
	ret
WinProc ENDP

;---------------------------------------------------
ErrorHandler PROC
; Display the appropriate system error message.
;---------------------------------------------------
.data
pErrorMsg  DWORD ?		; ptr to error message
messageID  DWORD ?
.code
	INVOKE GetLastError	; Returns message ID in EAX
	mov messageID,eax

	; Get the corresponding message string.
	INVOKE FormatMessage, FORMAT_MESSAGE_ALLOCATE_BUFFER + \
	  FORMAT_MESSAGE_FROM_SYSTEM,NULL,messageID,NULL,
	  ADDR pErrorMsg,NULL,NULL

	; Display the error message.
	INVOKE MessageBox,NULL, pErrorMsg, ADDR ErrorTitle,
	  MB_ICONERROR+MB_OK

	; Free the error message string.
	INVOKE LocalFree, pErrorMsg
	ret
ErrorHandler ENDP

END WinMain
