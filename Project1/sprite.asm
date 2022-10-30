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
include player.inc
include draw.inc
include config.inc
include map.inc

.data
NPCX DWORD 80
NPCY DWORD 100
IMAGE_WIDTH DWORD 126
IMAGE_HALF_WIDTH DWORD 63
IMAGE_HEIGHT DWORD 132
IMAGE_RATIO REAL8 0.9545f

SPRITE_SCALE REAL8 80.0f
SPRITE_HEIGHT_SHIFT REAL8 0.27f


.code

GetSprite PROC, hdc:HDC, drawdc:HDC, x:DWORD, y:DWORD
	LOCAL deltaX:SDWORD, deltaY:SDWORD, theta:REAL8, delta:REAL8, temp:DWORD
	LOCAL deltaRays:SDWORD, screenX:SDWORD
	LOCAL dist:REAL8, normDist:REAL8
	LOCAL FOVAngle:REAL8, deltaAngle:REAL8
	LOCAL HalfFOVAngle:REAL8, screenDistance:REAL8
	LOCAL proj:REAL8, projWidth:DWORD, projHeight:DWORD
	LOCAL posX: DWORD, posY: DWORD
	mov eax, x
	sub eax, playerX
	mov deltaX, eax
	mov eax, y
	sub eax, playerY
	mov deltaY, eax

	; theta = arctan(y/x)
	FINIT
	FILD deltaY
	FILD deltaX
	FPATAN 
	FST theta

	FINIT
	FLD theta
	FLD playerAngle
	FSUB
	FST delta

	FINIT
	FLD theta
	FLDPI
	FCOM
	FSTSW ax
	SAHF
	jc thetaGreaterPi
	jmp thetaLessPi
thetaGreaterPi:
	; if deltaX > 0
	mov eax, deltaX
	cmp eax, 0
	jg addDelta

thetaLessPi:
	; if deltaX < 0 && deltaY < 0
	mov eax, deltaX
	cmp eax, 0
	jge finishAddDelta
	
	mov eax, deltaY
	cmp eax, 0
	jge finishAddDelta

addDelta:
	FINIT
	FLD delta
	FLDPI
	mov temp, 2
	FMUL temp
	FADD
	FST delta
finishAddDelta:
	FINIT
	mov temp, FOV
	FILD temp
	FLDPI
	FMUL
	mov temp, 180
	FIDIV temp
	FST FOVAngle

	; deltaAngle = FOVAngle / WINDOW_WIDTH
	FLD FOVAngle
	mov temp, WINDOW_WIDTH
	FIDIV temp
	FST deltaAngle

	; delta_rays = delta / DELTA_ANGLE
	FINIT
	FLD delta
	FLD deltaAngle
	FDIV
	FIST deltaRays


	
	mov eax, WINDOW_HALF_WIDTH
	add eax, deltaRays
	mov screenX, eax

	; dist = sqrt(dx ^ 2 + dy ^ 2)
	FINIT
	FILD deltaX
	FILD deltaX
	FMUL
	FILD deltaY
	FILD deltaY
	FMUL
	FADD
	FSQRT
	FST dist

	; self.norm_dist = self.dist * math.cos(delta)
	FINIT
	FLD dist
	FLD delta
	FCOS
	FMUL
	FST normDist

	mov eax,IMAGE_HALF_WIDTH
	neg eax
	cmp eax, screenX
	jge exit_get_sprite

	mov eax, WINDOW_WIDTH
	add eax, IMAGE_HALF_WIDTH
	cmp eax, screenX
	jle exit_get_sprite


	; HalfFOVAngle = FOVAngle / 2
	FLD FOVAngle
	mov temp, 2
	FIDIV temp
	FST HalfFOVAngle

	; screenDistance = (WINDOW_WIDTH / 2) / (sin(HalfFOVAngle) / cos(HalfFOVAngle))
	; each ray is a column on screen
	mov temp, WINDOW_WIDTH
	shr temp, 1
	FILD temp
	FLD HalfFOVAngle
	FSIN
	FLD HalfFOVAngle
	FCOS
	FDIV
	FDIV
	FST screenDistance

	; proj = SCREEN_DIST / self.norm_dist * self.SPRITE_SCALE
	FINIT
	FLD screenDistance
	FLD normDist
	FDIV
	FLD SPRITE_SCALE
	FMUL
	FIST projHeight

	; projWidth = proj * self.IMAGE_RATIO
	FINIT
	FILD projHeight
	FLD IMAGE_RATIO
	FMUL
	FIST projWidth

	; posX = self.screen_x - self.sprite_half_width
	FINIT
	FILD screenX
	FILD projWidth
	mov temp, 2
	FIDIV temp
	FSUB
	FIST posX

	; posY = HALF_HEIGHT - proj_height // 2 + height_shift
	FINIT
	mov temp, WINDOW_HALF_HEIGHT
	FILD temp
	FILD projHeight
	mov temp, 2
	FIDIV temp
	FSUB ; TODO:HEIGHT_SHIFT
	FIST posY

	
	INVOKE DrawNPC, hdc, drawdc, posX, posY, projWidth, projHeight, hNPC1
exit_get_sprite:
	RET
GetSprite ENDP
END
