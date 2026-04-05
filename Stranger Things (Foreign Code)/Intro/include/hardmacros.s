;System initialisieren
; 			>=(#)newcopper,(#)newint,(#)startadr
coldinit MACRO
hm_coldf equ 1
	ENDM
init 	MACRO
	IF \3<>0
	jmp	\3		
	org	\3
	load	\3
	ENDC
init_lab
	bsr	hm_owndesk
	bra.w	init_x
hm_owndesk
	lea	gfxname(pc),a1			;Save sys
	move.l	4.w,a6
	jsr	-408(a6)	;Openlib
	move.l	d0,a1
	move.l	38(a1),oldcopper
	move.l	34(a1),oldview
	move.l	a1,a6
	ifnd	hm_coldf
	 sub.l	a1,a1
	 jsr	-222(a6)	;Loadview
	 jsr	-270(a6)	;Waittof
	 jsr	-270(a6)
	Endc
	move.l	a6,a1
	move.l	4.w,a6
	jsr	-414(a6)	;Closelib
	move.w	#$8000,d0
	lea	$dff000,a6
	move.w	$2(a6),olddma			;save dma
	or.w	d0,olddma
	move.w	$1c(a6),oldena			;save irq enable
	or.w	d0,oldena
	move.l	$6c.w,oldint			;save interupt vector
	wblit
	move.w	#$7fff,d0
	move.w	d0,$9a(a6)
	move.w	d0,$96(a6)
	move.l	#\2,$6c.w
	move.w	#$c020,$9a(a6)			;start interupt
	move.w	$7c(a6),d0
	cmp.b	#$f8,d0
	bne.s	.ecs		;AGA?
	move.w	#$c00,$106(a6)
	clr.w	$1fc(a6)
.ecs	
	move.l	#\1,$80(a6)
	move.w	#$83f0,$96(a6)			;start copper
	rts
init_x
	ENDM
;System verlassen+Datenpuffer anlegen
exit 	MACRO
	bsr	hm_sysdesk
	moveq	#0,d0
	rts					;back to cli
hm_sysdesk
	lea	$dff000,a6
	wblit
	move.w	#$7fff,$9a(a6)
	move.w	#$7fff,$96(a6)
	wblit
	move.l	oldint(pc),$6c.w
	move.l	oldcopper(pc),$80(a6)
	move.w	oldena(pc),d0
	or.w	#$8000,d0
	move.w	d0,$9a(a6)
	move.w	olddma(pc),d0
	or.w	#$8000,d0
	move.w	d0,$96(a6)
	lea	gfxname(pc),a1
	move.l	4.w,a6
	jsr	-408(a6)	;Openlib
	move.l	d0,a6
	move.l	oldview,a1
	jsr	-222(a6)	;Loadview
	move.l	a6,a1
	move.l	4.w,a6
	jsr	-414(a6)	;Closelib
	lea	$dff000,a6
	rts
olddma		dc.w	0
oldena		dc.w	0
oldint		dc.l	0
oldcopper	dc.l	0
oldview		dc.l	0
gfxname		dc.b	'graphics.library',0,0
	ENDM
OWNDESK MACRO
	bsr	hm_owndesk	
	ENDM
SYSDESK MACRO
	bsr	hm_sysdesk	
	ENDM
	

; Maustaste überprüfen, zu \1 falls noch nicht 
msloop  MACRO	
	btst	#6,$bfe001
	bne	\1
	ENDM
; Sprites ausknipsen
sproff	MACRO
	move.w	#32,$96(a6)
	move.w	#15,d0
	lea.l	$dff140,a0
sl\@	clr.l	(a0)+
	dbf	d0,sl\@
	ENDM
; Multiplikationstabelle (long/word) generieren
;		>= (#)Dest(label),(#)Startwert,(#)Schrittw,(#)Anz
genmull	MACRO
	lea	\1,a0
	move.w	#(\4)-1,d1
	move.l	#\2,d0
gmll\@	move.l	d0,(a0)+
	addi.l	#\3,d0
	dbf	d1,gmll\@
	ENDM
genmulw	MACRO
	lea	\1,a0
	move.w	#(\4)-1,d1
	move.w	#\2,d0
gmlw\@	move.w	d0,(a0)+
	addi.w	#\3,d0
	dbf	d1,gmlw\@
	ENDM
*
********  INTERRUPTSMACROS  ********************
*
irqin   MACRO
	movem.l	d0-a6,-(a7)
	ENDM
;Faderinterruptroutine (mit JSR Aufrufen)
fadeirq	MACRO		
	subq.w	#1,hmfadcnt
	bne.s	fiend\@
	move.w	hmfadpau,hmfadcnt
	move.w	hmfadanz,d1
	move.l	hmwishcol,a0
 	lea	hmfadcolt,a1
	lea	$dff180,a2
fadl\@	clr.w	d6
	move.w	#$f,d4
	move.w	#$1,d5
	jsr	dofad\@
	jsr	dofad\@
	jsr	dofad\@
	move.w	d6,(a1)+
	move.w	d6,(a2)+
	addq.l	#2,a0
	dbf	d1,fadl\@
fiend\@	rts
dofad\@	move.w	(a0),d2		;Wish in d2
	move.w	(a1),d3		;Real in d3
	and.w	d4,d2
	and.w	d4,d3
	cmp.w	d3,d2
	beq.s	dofend\@
	bhi.s	addit\@
	sub.w	d5,d3
	bra.s	dofend\@
addit\@	add.w	d5,d3	
dofend\@ or.w	d3,d6
	asl.w	#4,d4
	asl.w	#4,d5
	rts
hmfadanz	dc.w 0
hmwishcol	dc.l 0
hmfadpau	dc.w 0
hmfadcnt	dc.w 0
hmfadcolt	blk.w 32,0
	ENDM
irqout  MACRO
	clr.w	wvblflg
	movem.l	(a7)+,d0-a6
	move.w	#$20,$dff09c
	rte
wvblflg	dc.w	0
	ENDM

; auf VBL warten
wvbl	MACRO
	move.w	#1,wvblflg
.wv\@	tst.w	wvblflg
	bne.s	.wv\@
	ENDM		
lwvbl	MACRO
	wvbl
	ENDM		

; per VBL faden
;		>= ?Farbtab.Pointer,?anz-1,?Speed(AnzVBLsPause)(>0)    ben. IRQIN
fade	MACRO
	move.w	\3,hmfadcnt
	move.w	\3,hmfadpau
	move.l	\1,hmwishcol
	move.w	\2,hmfadanz 
	ENDM
; Palette benutzen
;		>= (#)Fabtab.pointer,(#)anz
usepal	MACRO
	movem.l	d0/a0-a1,-(sp)
	move.w	#\2,d0
	move.w	d0,hmfadanz
	lea.l	\1,a0
	move.l	a0,hmwishcol
	lea.l	hmfadcolt,a1
upl\@	move.w	(a0),(a1)+
	dbf	d0,upl\@	
	movem.l	(sp)+,d0/a0-a1	
	ENDM
; Auf Rasterstrahl warten
;		>=X,Y
rasterwait MACRO
rl\@	cmp.w	#((\2)<<8)+(\1),$6(a6)
	bcs.s	rl\@
	ENDM

; TASTATURINTERRUPT  Instkey *inter, remkey

instkey MACRO
; 			>=(#)IRQ (-> D0:Tastaturcode)

	move.l	$68.w,oldkint
	move.l	#key_inter,$68.w
	move.w	#$8008,$9a(a6)
	bra.s	instkey_x

key_inter
	movem.l	d0-a6,-(sp)
	move.b	$bfed01,d0
	btst	#3,d0
	beq.s	.fintr
	move.b	$bfec01,d0
	bset	#6,$bfee01
	moveq	#2,d2
.lop2	move.b	$dff006,d1
.lop1	move.b	#$ff,$bfec01
	cmp.b	$dff006,d1
	beq.s	.lop1
	dbf	d2,.lop2

	bclr	#6,$bfee01
	tst.b	d0
	beq.s	.fintr
	ror.b	d0
	not.b	d0
	move.b	d0,key
	jsr	\1
.fintr
	movem.l	(sp)+,d0-a6
	move.w	#$8,$dff09c
	rte
key	dc.b	0,0	
oldkint	dc.l	0
instkey_x
	ENDM


remkey	MACRO
	move.l	oldkint,$68.w
	ENDM

; 	Screentab rotieren
;>=(#)scrtab,(#)scranz (2-8)
swapscr MACRO
	IF (\2)>1
	lea	\1(pc),a0
	ENDC
	IF (\2)=2
	movem.l	(a0),d0/d1
	move.l	d0,4(a0)
	move.l	d1,(a0)
	ENDC
	IF (\2)=3
	movem.l	(a0),d0-d2
	movem.l	d1-d2,(a0)
	move.l	d0,8(a0)
	ENDC
	IF (\2)=4
	movem.l	(a0),d0-d3
	movem.l	d1-d3,(a0)
	move.l	d0,12(a0)
	ENDC
	IF (\2)=5
	movem.l	(a0),d0-d4
	movem.l	d1-d4,(a0)
	move.l	d0,16(a0)
	ENDC
	IF (\2)=6
	movem.l	(a0),d0-d5
	movem.l	d1-d5,(a0)
	move.l	d0,20(a0)
	ENDC
	IF (\2)=7
	movem.l	(a0),d0-d6
	movem.l	d1-d6,(a0)
	move.l	d0,24(a0)
	ENDC
	IF (\2)=8
	movem.l	(a0),d0-d7
	movem.l	d1-d7,(a0)
	move.l	d0,28(a0)
	ENDC
	IF (\2)>8
	PRINTT "Fehler bei SWAPSCRMCR: Max 8 Screens!"
	move.w	#not_defined\@,d0
	ENDC
	ENDM
