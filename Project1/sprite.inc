IFNDEF SPRITE_INC
SPRITE_INC equ <1>

include windows.inc

NPC STRUCT
	posX DWORD ?
	posY DWORD ?
	nowIDB DWORD ?
	blood DWORD 10
	attacking DWORD 0
	attackedFrame DWORD 0
	NPCType DWORD 1
NPC ENDS

EXTERNDEF NPCList: NPC
EXTERNDEF NPCNum: DWORD
EXTERNDEF NPCAliveNum: DWORD

GetSprite Proto, posX:PTR DWORD, posY:PTR DWORD, projWidth:PTR DWORD, projHeight:PTR DWORD, normDist:PTR REAL8, normDistInt:PTR DWORD, delta_res:PTR REAL8, dist_res:PTR REAL8, npcID:DWORD
MoveNPC Proto, npcID:DWORD
NPCDamage Proto, damage:DWORD, npcID:DWORD
CreateNPC Proto, currow:DWORD, curcol:DWORD
ENDIF