.386
.model flat, stdcall
OPTION  CaseMap:None

; MASM32 Headers
include windows.inc
include winmm.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include msimg32.inc

; MASM32 Library
includelib winmm.lib
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib msimg32.lib

; Custom Header
include sound.inc

.data
SUINFO STARTUPINFO <>
PRCINFO PROCESS_INFORMATION <>

bgmName      BYTE "DoomTheme.wav", 0

processName  BYTE "soundplayer.exe", 0
shotgunName  BYTE "player_shotgun.wav", 0
plpainName   BYTE "player_pain.wav", 0
pldeathName  BYTE "player_death.wav", 0
npcpainName  BYTE "npc_pain.wav", 0
npcdeathName BYTE "npc_death.wav", 0
npcatkName   BYTE "npc_attack.wav", 0

.code
PlayBGM PROC
  ; Play background music
  pushad
  INVOKE PlaySound, ADDR bgmName, NULL, SND_ASYNC OR SND_LOOP OR SND_FILENAME
  popad
  RET
PlayBGM ENDP

StopBGM PROC
  ; Stop background music
  pushad
  INVOKE PlaySound, NULL, NULL, SND_ASYNC OR SND_LOOP OR SND_FILENAME
  popad
  RET
StopBGM ENDP

ShotgunSound PROC
  pushad
  INVOKE CreateProcess, ADDR processName, ADDR shotgunName, NULL, NULL, FALSE, 0, NULL, NULL, ADDR SUINFO, ADDR PRCINFO
  popad
  RET
ShotgunSound ENDP

PlayerPainSound PROC
  pushad
  INVOKE CreateProcess, ADDR processName, ADDR plpainName, NULL, NULL, FALSE, 0, NULL, NULL, ADDR SUINFO, ADDR PRCINFO
  popad
  RET
PlayerPainSound ENDP

PlayerDeathSound PROC
  pushad
  INVOKE CreateProcess, ADDR processName, ADDR pldeathName, NULL, NULL, FALSE, 0, NULL, NULL, ADDR SUINFO, ADDR PRCINFO
  popad
  RET
PlayerDeathSound ENDP

NPCPainSound PROC
  pushad
  INVOKE CreateProcess, ADDR processName, ADDR npcpainName, NULL, NULL, FALSE, 0, NULL, NULL, ADDR SUINFO, ADDR PRCINFO
  popad
  RET
NPCPainSound ENDP

NPCDeathSound PROC
  pushad
  INVOKE CreateProcess, ADDR processName, ADDR npcdeathName, NULL, NULL, FALSE, 0, NULL, NULL, ADDR SUINFO, ADDR PRCINFO  
  popad
  RET
NPCDeathSound ENDP

NPCATKSound PROC
  pushad
  INVOKE CreateProcess, ADDR processName, ADDR npcatkName, NULL, NULL, FALSE, 0, NULL, NULL, ADDR SUINFO, ADDR PRCINFO  
  popad
  RET
NPCATKSound ENDP

END