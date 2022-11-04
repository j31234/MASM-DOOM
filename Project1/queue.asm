.386
.model flat, stdcall
OPTION  CaseMap:None

; MASM32 Headers
include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include msvcrt.inc

; MASM32 Library
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib msvcrt.lib

; Custom Header
include queue.inc

.data
; TODO: change max length of BFS queue to `MAP_WIDTH * MAP_HEIGHT`
BFSQueue POINT 20005 DUP(<?,?>)
queueBegin DWORD ?
queueEnd DWORD ?

.code
QueueReset PROC
  mov eax, offset BFSQueue
  mov queueBegin, eax
  mov queueEnd, eax
  RET
QueueReset ENDP

QueuePush Proc, x:DWORD, y:DWORD
  mov eax, x
  mov esi, queueEnd
  mov (POINT PTR [esi]).x, eax
  mov eax, y
  mov (POINT PTR [esi]).y, eax

  ; queueEnd += 1
  mov eax, queueEnd
  add eax, TYPE BFSQueue
  mov queueEnd, eax

  RET
QueuePush ENDP

QueuePop Proc, ptrX:DWORD, ptrY:DWORD
  mov esi, queueBegin
  mov eax, (POINT PTR [esi]).x
  mov esi, ptrX
  mov [esi], eax

  mov esi, queueBegin
  mov eax, (POINT PTR [esi]).y
  mov esi, ptrY
  mov [esi], eax

  ; queueBegin += 1
  mov eax, queueBegin
  add eax, TYPE BFSQueue
  mov queueBegin, eax
  RET
QueuePop ENDP

QueueIsEmpty Proc
  mov esi, queueBegin
  mov edi, queueEnd
  .IF esi == edi
    mov eax, 1
  .ELSE
    mov eax, 0
  .ENDIF

  RET
QueueIsEmpty ENDP

END