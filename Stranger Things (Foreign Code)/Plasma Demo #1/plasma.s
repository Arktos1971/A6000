***********************************************************
* This is the plasma routine from the Silents demo
* "Global Trash".  The original version of this code, which
* should be included in this archive, was send to me via
* e-mail by Mattias Myrberg (m92mmy@megrez.tdb.uu.se).
*
* The version of the source that you are now looking at was
* fixed up (and optimized a little bit) by the Dancing Fool
* of Epsilon.
***********************************************************
* Includes
***********************************************************
;		opt	o+,c+,w-,p-,a-
		
		incdir	"l:\Amiga\include"
		include	"exec/execbase.i"
		include	"graphics/gfxbase.i"
		include	"graphics/graphics_lib.i"
		include	"hardware/custom.i"
		include	"exec/exec_lib.i"
		;incdir	'miscsource:'

***********************************************************
* Other Equates
***********************************************************

;PAL		equ	1		; 0 = NTSC, 1 = PAL

Bits		equ	352
_Scan		equ	44

Rasters		equ	263
;Rasters		equ	290

Bpsize		equ	Rasters*_Scan

***********************************************************
* Other Macros
***********************************************************

CALL		MACRO
		jsr	_LVO\1(a6)
		ENDM

BltWait		Macro				Wait for blitter
Bltbusy\@:	btst.b	#6,2(a6)
		bne.b	Bltbusy\@
		Endm

Sync:		Macro				Syncronizise
Rastwait\@	move.l	4(a6),d0
		and.l	#$1ff00,d0
		lsr.l	#8,d0
		cmp.w	#\1,d0
		bne.b	Rastwait\@
		Endm

***********************************************************

		Section	Program,code

TakeSystem:	movea.l	4.w,a6		; exec base
		lea	$dff000,a5	; custom chip base + 2

		lea	GfxName(pc),a1	; "graphics.library"
		moveq	#0,d0		; any version
		CALL	OpenLibrary	; open it.
		move.l	d0,gfx_base	; save pointer to gfx base
		movea.l	d0,a6		; for later callls...

		move.l  gb_ActiView(a6),OldView	; save old view

		move.w	#0,a1		; clears full long-word
		CALL	LoadView	; Open a NULL view (resets display
					;   on any Amiga)

		CALL	WaitTOF		; Wait twice so that an interlace
		CALL	WaitTOF		;   display can reset.

		CALL	OwnBlitter	; take over the blitter and...
		CALL	WaitBlit	;   wait for it to finish so we
					;   can safely use it as we please.

		movea.l	4.w,a6		; exec base
		CALL	Forbid		; kill multitasking

		bsr.w	GetVBR		; get the vector base pointer
		move.l	d0,VectorBase	; save it for later.

		move.w	dmaconr(a5),d0	; old DMACON bits
		ori.w	#$8000,d0	; or it set bit for restore
		move.w	d0,OldDMACon	; save it

		move.w	intenar(a5),d0	; old INTEna bits
		ori.w	#$c000,d0	; or it set bit for restore
		move.w	d0,OldINTEna	; save it

		move.l	#$7fff7fff,intena(a5)	; kill all ints
		move.w	#$7fff,dmacon(a5)	; kill all dma

		lea	BmapPtrs+2,a0
		move.l	#Screen1,d0
		move.w	d0,4(a0)
		swap	d0
		move.w	d0,(a0)
		move.l	#Screen1+Bpsize,d0
		move.w	d0,12(a0)
		swap	d0
		move.w	d0,8(a0)
		move.l	#Screen1+(Bpsize*2),d0
		move.w	d0,20(a0)
		swap	d0
		move.w	d0,16(a0)
		move.l	#Screen1+(Bpsize*3),d0
		move.w	d0,28(a0)
		swap	d0
		move.w	d0,24(a0)

		move.l	VectorBase,a0
		move.l	$6c(a0),OldLevel3
		move.l	#Level3,$6c(a0)
		move.l	#Copperlist,$80(a5)	; Our Copperlist
		move.w	#0,$88(a5)
		move.w	#$83c0,dmacon(a5)	; Turn on cop,bitplane,blt
		move.w	#$c020,intena(a5)	; Allow interrupt

		bsr.w	Init			; Initiation

		lea	Pattern1(pc),a6
		bsr.w	Main
		lea	Pattern2(pc),a6
		bsr.w	Main
		lea	Pattern3(pc),a6
		bsr.w	Main
		lea	Pattern4(pc),a6
		bsr.w	Main
		lea	Pattern5(pc),a6
		bsr.w	Main
		lea	Pattern6(pc),a6
		bsr.w	Main
		lea	Pattern7(pc),a6
		bsr.w	Main
		lea	Pattern8(pc),a6
		bsr.w	Main

Wait:		btst.b	#6,$bfe001
		bne.b	Wait


RestoreSystem:	lea	$dff000,a5	; custom chip base + 2

	; You must do these in this order or you're asking for trouble!
		move.l	#$7fff7fff,intena(a5)	; kill all ints
		move.w	#$7fff,dmacon(a5)	; kill all dma
		move.l	VectorBase,a0
		move.l	OldLevel3,$6c(a0)
		move.w	OldDMACon,dmacon(a5)	; restore old dma bits
		move.w	OldINTEna,intena(a5)	; restore old int bits

		movea.l	OldView,a1	; old Work Bench view
		movea.l	gfx_base,a6	; gfx base
		CALL	LoadView	; Restore the view
		CALL	DisownBlitter	; give blitter back to the system.

		move.l	gb_copinit(a6),$80(a5) ; restore system clist
		movea.l	a6,a1
		movea.l	4.w,a6		; exec base
		CALL	CloseLibrary

	; there is no call to Permit() because it is implied by the return
	; to AmigaDOS! :^)
		rts

GfxName:	GRAFNAME		; name of gfx library
		EVEN

***********************************************************

Init:		lea	Copper(pc),a0
		lea	Copperlist,a1		; Copper

		move.l	(a0)+,d0
Find_end:	move.l	d0,(a1)+
		move.l	(a0)+,d0
		bne.b	Find_end

		lea	6(a1),a0		; Start of color setting
		move.l	a0,Copcol
		move.w	#Rasters-1,d7		; No of Copper rasters
		move.l	#$17b1fffe,d0		; WAIT
Fill_copper:	move.l	d0,(a1)+
		addi.l	#$01000000,d0
		move.l	#$1820000,(a1)+		; move	
		move.l	#$1840000,(a1)+
		move.l	#$1860000,(a1)+
		move.l	#$1880000,(a1)+
		move.l	#$18a0000,(a1)+
		move.l	#$18c0000,(a1)+
		move.l	#$18e0000,(a1)+
		move.l	#$1900000,(a1)+
		move.l	#$1920000,(a1)+
		move.l	#$1940000,(a1)+
		move.l	#$1960000,(a1)+
		move.l	#$1980000,(a1)+
		move.l	#$19a0000,(a1)+
		move.l	#$19c0000,(a1)+
		move.l	#$19e0000,(a1)+
		dbf	d7,Fill_copper
		moveq	#-2,d7
		move.l	d7,(a1)+
		rts

Bit_pointer:	dc.w	0

***********************************************************
* Draw screen
* a6 = pattern

Main:		lea	Bitplane0,a0		; Screen planes
		lea	Bitplane1,a1
		lea	Bitplane2,a2
		lea	Bitplane3,a3
		move.l	(a6)+,a4		; Bitmaps
		lea	Cosinus(pc),a5		; Cosinus
		movem.w	(a6)+,d1-d4		; Start values

		move.w	#Rasters-1,d6		; No of scanlines
		moveq	#7,d0			; Bit
Next_scan:	move.w	#Bits-1,d7		; No of bits in one scan

Next_bit:	move.b	d0,Bit_pointer		

		move.w	(a5,d1.w),d5
		addi.w	#$4000,d5
		lsr.w	#7,d5			; d5 = Cos(d1)

		move.w	(a5,d2.w),d0
		addi.w	#$4000,d0
		lsr.w	#7,d0
		add.w	d0,d5			; + Cos(d2)

		move.w	(a5,d3.w),d0
		addi.w	#$4000,d0
		lsr.w	#7,d0
		add.w	d0,d5			; + Cos(d3)

		move.w	(a5,d4.w),d0
		addi.w	#$4000,d0
		lsr.w	#7,d0
		add.w	d0,d5			; + Cos(d4)

		lsr.w	#1,d5
		add.w	d5,d5

Plot_bit:	move.w	(a4,d5.w),d5		; d5 = bitmap
		move.b	Bit_pointer(pc),d0
		bclr	d0,(a3)			; Set or clear bits in all
		btst	#3,d5			; planes
		beq.b	Plane2
		bset	d0,(a3)

Plane2:		bclr	d0,(a2)
		btst	#2,d5
		beq.b	Plane1
		bset	d0,(a2)

Plane1:		bclr	d0,(a1)
		btst	#1,d5
		beq.b	Plane0
		bset	d0,(a1)

Plane0:		bclr	d0,(a0)
		btst	#0,d5
		beq.b	Ready
		bset	d0,(a0)

Ready:		subq.b	#1,d0
		bpl.b	No_underflow

		addq.b	#8,d0			; Perform calculations
		addq.w	#1,a0			; on bit #7
		addq.w	#1,a1			; in next byte
		addq.w	#1,a2
		addq.w	#1,a3

No_underflow:	add.w	(a6),d1
		add.w	2(a6),d2
		add.w	4(a6),d3
		add.w	6(a6),d4

		move.w	#$1ffe,d5
		and.w	d5,d1
		and.w	d5,d2
		and.w	d5,d3
		and.w	d5,d4
		dbf	d7,Next_bit

		sub.w	8(a6),d1
		sub.w	10(a6),d2
		sub.w	12(a6),d3
		sub.w	14(a6),d4
		and.w	d5,d1
		and.w	d5,d2
		and.w	d5,d3
		and.w	d5,d4
		dbf	d6,Next_scan
		rts

***********************************************************

Level3:		movem.l	d0-a6,-(sp)

		lea	$dff000,a6
		move.w	#$8400,$96(a6)
		movea.l	Copcol(pc),a0		; Copper
		lea	Cosinus(pc),a1
		move.l	#Area,d3
		move.w	#$1ffe,d0
		move.w	#$4000,d1
		moveq	#15-1,d7		; 16 colors

		movem.w	Rgb(pc),d4-d6
		addi.w	#20,d4
		addi.w	#26,d5
		addi.w	#-30,d6
		and.w	d0,d4
		and.w	d0,d5
		and.w	d0,d6
		movem.w	d4-d6,Rgb

Next_colreg:	addi.w	#36,d4
		addi.w	#-30,d5
		addi.w	#24,d6
		and.w	d0,d4			; 0-8192
		and.w	d0,d5
		and.w	d0,d6
		movea.l	d3,a2
		movea.l	d3,a3
		movea.l	d3,a4

		move.w	(a1,d4.w),d2
		add.w	d1,d2
		lsr.w	#7,d2
		add.w	d2,d2			; d2 = 0-512
		adda.w	d2,a2

		move.w	(a1,d5.w),d2
		add.w	d1,d2
		lsr.w	#7,d2
		add.w	d2,d2
		adda.w	d2,a3

		move.w	(a1,d6.w),d2
		add.w	d1,d2
		lsr.w	#7,d2
		add.w	d2,d2
		adda.w	d2,a4

		bsr	BlitWait
		move.l	#$8ffe4000,$40(a6)	; D=(A+8)+(B+4)+C
		move.l	#-1,$44(a6)
		move.l	a3,$48(a6)		; C => red
		move.l	a4,$4c(a6)		; B => green
		move.l	a2,$50(a6)		; A => blue
		move.l	a0,$54(a6)		; D => copper
		move.l	#0,$60(a6)		; Mod A,B,C = 0
		move.l	#62,$64(a6)		; Mod D = 62
		move.w	#(Rasters*64)+1,$58(a6)
		addq.w	#4,a0
		dbf	d7,Next_colreg

		movem.l	(sp)+,d0-a6
		move.w	#$7fff,$dff09c
		rte
BlitWait	btst	#14,$dff002
		bne.s	BlitWait
		rts
		
***********************************************************
* This function provides a method of obtaining a pointer to the base of the
* interrupt vector table on all Amigas.  After getting this pointer, use
* the vector address as an offset.  For example, to install a level three
* interrupt you would do the following:
*
*		bsr	_GetVBR
*		move.l	d0,a0
*		move.l	$6c(a0),OldIntSave
*		move.l	#MyIntCode,$6c(a0)
*
***********************************************************
* Inputs: none
* Output: d0 contains vbr.

GetVBR:		move.l	a5,-(sp)		; save it.
		moveq	#0,d0			; clear
		movea.l	4.w,a6			; exec base
		btst.b	#AFB_68010,AttnFlags+1(a6); are we at least a 68010?
		beq.b	.1			; nope.
		lea.l	vbr_exception(pc),a5	; addr of function to get VBR
		CALL	Supervisor		; supervisor state
.1:		move.l	(sp)+,a5		; restore it.
		rts				; return

vbr_exception:
	; movec vbr,Xn is a priv. instr.  You must be supervisor to execute!
;		movec   vbr,d0
	; many assemblers don't know the VBR, if yours doesn't, then use this
	; line instead.
		dc.l	$4e7a0801
		rte				; back to user state code

***********************************************************

Copper:		dc.l	$008e1771
		dc.w	$0090
		dc.b	(($17+Rasters)&$ff),$d1
		dc.l	$00920030,$009400d8	; 46 bytes/raster
		dc.l	$01060000,$01080000,$010a0000
		dc.l	$01fc0000
BmapPtrs:	dc.l	$00e00000,$00e20000,$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000,$00ec0000,$00ee0000
Sprite:		dc.l	$01200000,$01220000,$01240000,$01260000
		dc.l	$01280000,$012a0000,$012c0000,$012e0000
		dc.l	$01300000,$01320000,$01340000,$01360000
		dc.l	$01380000,$013a0000,$013c0000,$013e0000
		dc.l	$01800000
		dc.l	$01004200
Copend:		dc.l	0


Pattern1:	dc.l	Col1
		dc.w	7616,768,7040,960
		dc.w	8,12,-4,-16
		dc.w	8*Bits+12
		dc.w	12*Bits-16
		dc.w	-4*Bits+24
		dc.w	-16*Bits-20

Pattern2:	dc.l	Col1
		dc.w	200,468,2040,196
		dc.w	6,-30,2,16
		dc.w	6*Bits-12
		dc.w	-30*Bits+16
		dc.w	2*Bits-24
		dc.w	16*Bits+20

Pattern3:	dc.l	Col1
		dc.w	10,10,10,10
		dc.w	2,8,16,32
		dc.w	2*Bits-2
		dc.w	8*Bits-8
		dc.w	16*Bits-16
		dc.w	32*Bits-32

Pattern4:	dc.l	Col1
		dc.w	0,-20,40,-80
		dc.w	2,2,2,2
		dc.w	2*Bits-2
		dc.w	2*Bits-2
		dc.w	2*Bits-2
		dc.w	2*Bits-2

Pattern5:	dc.l	Col1
		dc.w	344,-100,346,2
		dc.w	18,-2,58,8
		dc.w	18*Bits-34
		dc.w	-2*Bits-4
		dc.w	58*Bits+24
		dc.w	8*Bits-20
		dc.l	-1

Pattern6:	dc.l	Col1
		dc.w	0,0,0,0
		dc.w	8,8,8,8
		dc.w	8*Bits-8
		dc.w	8*Bits+8
		dc.w	8*Bits+8
		dc.w	8*Bits-2

Pattern7:	dc.l	Col1
		dc.w	344,-100,346,2
		dc.w	10,-2,28,4
		dc.w	10*Bits-18
		dc.w	-2*Bits-2
		dc.w	28*Bits+12
		dc.w	4*Bits-10

Pattern8:	dc.l	Col1
		dc.w	346,102,-368,104
		dc.w	4,6,-32,-78
		dc.w	4*Bits-24
		dc.w	6*Bits+14
		dc.w	-32*Bits-68
		dc.w	-78*Bits-10

Copcol:		dc.l	0
Rgb:		ds.w	3
Cosinus:	incbin	'Plasma.dat'

***********************************************************

		section	CopperBars,data_c
		;incdir	df0:
		include	'CopperBars.i'

***********************************************************

		section	OldPointers_and_such,bss

gfx_base	ds.l	1		; pointer to graphics base
OldView		ds.l    1		; old Work Bench view addr.
VectorBase:	ds.l	1		; pointer to the Vector Base

OldDMACon:	ds.w	1		; old dmacon bits
OldINTEna:	ds.w	1		; old intena bits
OldLevel3:	ds.l	1		; old level 3 int ptr

***********************************************************

		section	ScreAndCopper,bss_c

Copperlist:	ds.b	64*1024
Screen1:	ds.b	_Scan
Bitplane0	ds.b	Bpsize
Bitplane1	ds.b	Bpsize
Bitplane2	ds.b	Bpsize
Bitplane3	ds.b	Bpsize
		END
