IFNDEF QUEUE_INC
QUEUE_INC equ <1>

QueueReset Proto
QueuePush Proto, x:DWORD, y:DWORD
QueuePop Proto, ptrX:DWORD, ptrY:DWORD
QueueIsEmpty Proto
ENDIF