**
** Date:    11.03.2026
** Author:  Kai Kruschinski
**
** Description:
** 
** This code was inspired by BlueScreenFast from Tomas Jacobsen.
** Instead of blue pixel the code now shows a picture (1280x720 - 16 Bit Color)
** and is waiting for left mouse button. Actually not really  exciting,
** but a starting point for my rusted 68k skills.
**			
**

                    machine 68080					; Apollo 68080 Chip

                    incdir	"L:\Amiga\Include"
                    include	"exec\exec_lib.i"

GFXCON		    equ	$dff1f4
GFXCONR		    equ	$dfe1f4
BPLHMOD		    equ	$dff1e6
BPLHMODR	    equ	$dfe1e6
BPLHPTH		    equ	$dff1ec
BPLHPTHR	    equ	$dfe1ec
SPRHSTRT	    equ	$dff1d0

                    code_f

                    movea.l	4.w,a6                      ; Disable Interrupt Processing
                    jsr	_LVODisable(a6)                 ; so mouse cannot move

                    move.w	GFXCONR,store_gfxcon
                    move.w	BPLHMODR,store_bplhmod
                    move.l	BPLHPTHR,store_bplhpth

                    clr.l	SPRHSTRT				    ; Clear mousepointers sprite 0
                    move.w	#$0a02,GFXCON			    ; 0a = 1280x720, 02 = 16 bit chunky 
                    clr.w	BPLHMOD					    ; Clear AGA modulo

                    lea	_FrameBuffer,a0                 ; Pointer to Framebuffer
                    add.l	#32,a0                      ; align the Screenpointer to 32 bits
                    and.l	#$ffffff80,a0               ; in the _Framebuffer -> faster data access!
                    move.l	a0,_ScreenPointer

                    move.l	a0,BPLHPTH

lmbLoop          	btst	#6,$bfe001  				; Wait for left mousebutton
                    bne.s	lmbLoop

                    move.w	store_gfxcon,GFXCON
                    move.w	store_bplhmod,BPLHMOD
                    move.l	store_bplhpth,BPLHPTH

                    movea.l	4.w,a6                      ; Enable Interrupt Processing
                    jsr	_LVOEnable(a6)

                    rts

                    bss_f

store_gfxcon		ds.w	1
store_bplhmod		ds.w	1
store_bplhpth		ds.l	1
_ScreenPointer		ds.l	1				            ; Aligned and populated at runtime


                    data_f
			
_FrameBuffer		incbin "test-rgb565.raw"			; Image data loads here
