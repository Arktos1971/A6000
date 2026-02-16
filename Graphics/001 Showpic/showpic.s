**
**	$VER: BlueScreenFast.s v1.0 release (9 February 2026)
**	Platform: Apollo Vampire (SAGA Graphics)
**	Assemble command:
**	Programs:Developer/VASM/vasmm68k_mot BlueScreenFast.s -Fhunkexe
**	
**	Author: Tomas Jacobsen - Bedroomcoders.com
**	Description: 
**	This code is similar to BlueScreenSlow which explains each step in more detail.
**	In this source, the fill routine is optimized for the Vampires AC68080 CPU.
**			
**


			opt d+
			
			machine 68080					; NOTE - Tells the assembler to treat this source as 68080 code.

			incdir	"Programs:vasm\Include"
			include	"exec\exec_lib.i"

			output	showpic.exe


			
DMACON		equ	$dff096
DMACONR		equ	$dff002
GFXCON		equ	$dff1f4
GFXCONR		equ	$dfe1f4
BPLHMOD		equ	$dff1e6
BPLHMODR	equ	$dfe1e6
BPLHPTH		equ	$dff1ec
BPLHPTHR	equ	$dfe1ec
SPRHSTRT	equ	$dff1d0



			section mycode,code

			
_Init		movea.l	4.w,a6
			jsr	_LVODisable(a6)

			move.w	DMACONR,store_dmacon
			move.w	GFXCONR,store_gfxcon
			move.w	BPLHMODR,store_bplhmod
			move.l	BPLHPTHR,store_bplhpth

			move.w	#$7fff,DMACON			; Disable all DMA (Interrups, audio, disk, etc)
			clr.l	SPRHSTRT				; Clear mousepointers sprite
			move.w	#$0a02,GFXCON			; 0a = 1280x720, 02 = 16 bit chunky 
			clr.w	BPLHMOD					; Clear modulo

			lea	_FrameBuffer,a0
			add.l	#32,a0
			and.l	#$ffffff80,a0
			move.l	a0,_ScreenPointer		; This trick aligns the Screenpointer to 32 bits in the Framebuffer = Quicker access to the data

			move.l	a0,BPLHPTH

.lmbLoop	btst	#6,$bfe001				; Wait for left mousebutton
			bne.s	.lmbLoop


			move.w	store_dmacon,DMACON
			move.w	store_gfxcon,GFXCON
			move.w	store_bplhmod,BPLHMOD
			move.l	store_bplhpth,BPLHPTH

			movea.l	4.w,a6
			jsr	_LVOEnable(a6)
			rts

			section	mydata,bss

store_dmacon		ds.w	1
store_gfxcon		ds.w	1
store_bplhmod		ds.w	1
store_bplhpth		ds.l	1
_ScreenPointer		ds.l	1				; Aligned and populated at runtime


			section myscreen,data			; Place Screen/Framebuffer in it's own section always works best
			
_FrameBuffer		incbin "test-rgb565.raw"			
