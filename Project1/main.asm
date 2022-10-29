.386
.model flat, stdcall
OPTION  CaseMap:None

; MASM32 Headers
include windows.inc
include winmm.inc
include user32.inc
include kernel32.inc
include gdi32.inc

; MASM32 Library
includelib winmm.lib
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib

; Custom Header
include config.inc
include draw.inc

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

; Show and draw the window.
	INVOKE ShowWindow, hMainWnd, SW_SHOW
	INVOKE UpdateWindow, hMainWnd

; Display a greeting message.
;	INVOKE MessageBox, hMainWnd, ADDR GreetText,
;	  ADDR GreetTitle, MB_OK

; Frame timer
    INVOKE SetTimer, hMainWnd, NULL, DELTA_TIME, NULL

; Play background music
	INVOKE PlaySound, ADDR bgmName, NULL, SND_ASYNC OR SND_LOOP OR SND_FILENAME

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
	  INVOKE DrawMain, memHdc, drawHdc

	  ; Alt the true device context
	  INVOKE BitBlt, hdc, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, memHdc, 0, 0, SRCCOPY

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
