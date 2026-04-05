;
;
; ACHTUNG !
;
; DIESE MACROS BITTE JE NACH WUNSCH AB�NDERN !
;
;
; -----------------------------------------------------------------
;
;  CODE: PLY-2/TRSi
;
; -----------------------------------------------------------------  
;
; Well, insert you text in the following lines.... This is a
; trainermenu aswell! Change it a bit if you do not need the
; trainer-options or for the case that you prefer a Replayer
;				
; The crunched length is: 4.6 Kilobytes (max. 5 KB) 
;
; For any questions call me or the coder of this, PLY-2
;
;
; Bye, CONtROL/TRSi
;
;
; -----------------------------------------------------------------  



TEXTE	MACRO

text1
	dc.b	0,0,0,0
	dc.b    "680XX PRESENTS AN INTRO FROM",0
	dc.b    "        THE PAST ...",0,0
	dc.b	"* TRISTAR & RED SECTOR INC *",0
	dc.b	"MADE THIS IN 1992",0,0
	dc.b	"FOR SOURCECODE FOLLOW THE LINK",0
	dc.b	"IN THE VIDEO DESCRIPTION!",0,0
	dc.b	"SOURCECODE ADJUSTED FOR MODERN",0
	dc.b 	"VASM ASSEMBLER BY 68K!",0,0

	dc.b	"      -> PRESS LMB",0,-1

text2	dc.b	0,0,0,0
	dc.b	"*** TRAINERMENU ***",0,0,0

trainy	equ	8	;Y-Coordinate der Trainer

	dc.b	"F1 UNLIMITED LIVES       OFF",0
	dc.b	"F2 UNLIMITED AMMO        OFF",0
	dc.b	"F3 UNLIMITED SHIELD      OFF",0
	dc.b	"F4 UNLIMITED SMARTBOMBS  OFF",0
	dc.b	"F5 CHEATKEYS             NAH",0,0
	dc.b	"DA OBEN MUSS NOCH EIN VERNUENFTIG",0
	dc.b	"LOGO HIN, ABER SONST:",0
	DC.B	"A - PASS - PASS..",0,-2


f1n	dc.b	"F1 UNLIMITED LIVES       OFF",0,-3
f2n	dc.b	"F2 UNLIMITED AMMO        OFF",0,-3
f3n	dc.b	"F3 UNLIMITED SHIELD      OFF",0,-3
f4n	dc.b	"F4 UNLIMITED SMARTBOMBS  OFF",0,-3
f5n	dc.b	"F5 CHEATKEYS             NAH",0,-3
f6n
f7n
f8n
f9n
f10n


f1y	dc.b	"F1 UNLIMITED LIVES       ON ",0,-3
f2y	dc.b	"F2 UNLIMITED AMMO        ON ",0,-3
f3y	dc.b	"F3 UNLIMITED SHIELD      ON ",0,-3
f4y	dc.b	"F4 UNLIMITED SMARTBOMBS  ON ",0,-3
f5y	dc.b	"F5 CHEATKEYS             YO!",0,-3
f6y
f7y
f8y
f9y
f10y

trainanz = 5					; ANZAHL: BITTE EINSTELLEN !


traintab blk.b	trainanz,0			;DA SIND NACHHER TRAINERWERTE
						;DRIN !
	EVEN

ttab	dc.l	f1n,f1y,f2n,f2y,f3n,f3y
	dc.l	f4n,f4y,f5n,f5y,f6n,f6y
	dc.l	f7n,f7y,f8n,f8y,f9n,f9y
	dc.l	f10n,f10y

text3
	dc.b	0,0,0
	DC.B	"THIS IS THE THIRD PAGE ...",0,0
	DC.B	"ROOM FOR GREETINGS OR OTHER",0
	DC.B	"TEXT.",0,0
	DC.B	0,-1
	EVEN

	ENDM
			;F�R MUSIK BITTE EINSETZEN !
MT_INIT	MACRO
	rts
	ENDM
MT_exit MACRO
	rts
	ENDM

MT_VBL  MACRO		;NUR FALLS VBLANK-PLAYER
	rts
	ENDM		
	

	INCLUDE "include\hardmacros.s"
	INCLUDE	"include\copper+blittermacros.s"
	include	"include\linemacros.s"
	section	"kl2",code_c
scrw	equ	352
scrbw	equ	scrw/8
scrh	equ	280
zomanz	equ	336
anf
	defpln
	defblit
	init	cop0,inter,0
	sproff
	genmulw	multab,0,scrbw,scrh


				**** SINTAB EXPANDEN ***
	lea	sinorig,a0
	lea	sin,a1
	lea	sin+1026,a2
	lea	sin+1024,a3
	lea	sin+2050,a4
	move.w	#256,d0
.sinl	move.w	(a0)+,d1
	move.w	d1,(a1)+
	move.w	d1,-(a2)
	neg.w	d1
	move.w	d1,(a3)+
	move.w	d1,-(a4)
	dbf	d0,.sinl	
	lea	sin,a0
	lea	sin+2048,a1
	lea	sin+4096,a2
	move.w	#511,d0
.sinl2
	move.l	(a0)+,d1
	move.l	d1,(a1)+
	move.l	d1,(a2)+
	dbf	d0,.sinl2	


	move.l	#-2,cop1
	move.l	#-2,cop2
	move.l	#-2,cop1x
	move.l	#-2,cop2x
	bsr	gwaitc


	lea	ccoltab,a0
	move.w	#zomanz-1,d0
	moveq	#0,d1
.cclop	
	move.w	d1,d2
	mulu	#5,d2
	divu	#zomanz,d2
	mulu	#$111,d2
	add.w	#$222,d2
	move.w	d2,(a0)+
	addq.w	#1,d1
	dbf	d0,.cclop

	moveq	#31,d0
	lea	$180(a6),a0
.cblop	move.w	#0,(a0)+
	dbf	d0,.cblop	



	startc	#copper
	wvbl
	bsr	calczom
	wvbl
	move.l	$68.w,okey
	move.l	#kinter,$68.w
	move.w	#$8008,$9a(a6)
	bsr	mti
	wvbl
	clr.w	frco

;;
mainloop

	wvbl
	bsr	calccol
					;5. Plane bearbeiten
	cmp.w	#100,frco
	bcs.w	.nothing
	cmp.w	#164,frco
	bcc.s	.nlogin
					;Logo reinblitten
	;bsr	blitlog
.nlogin	

	cmp.w	#180,frco		;"P" rein
	bcs.s	.np2
	cmp.w	#180+4*7,frco
	bcc.s	.np2

	move.w	frco,d0
	sub.w	#180,d0
	bsr	drawp

.np2
	cmp.w	#250,frco		;"P" raus
	bcs.s	.np22
	cmp.w	#249+4*6,frco
	bcc.s	.np22

	move.w	#250+4*6,d0
	sub.w	frco,d0
	bsr	drawp
.np22
					;TEXT
	cmp.w	#50,frco
	bcs.s	.txtx


	move.l	ocurs,a1
	moveq	#0,d0
	bsr	drwcurs	
	tst.w	ftxtco
	beq.s	.dtxt
	bsr	fadetxt
	bra.s	.txtx
.dtxt
	bsr	drawtext
	bsr	drawtext
	btst	#6,$bfe001
	bne.s	.txtx
	bsr	drawtext
	bsr	drawtext
	bsr	drawtext
	bsr	drawtext
.txtx
.nothing	
	move.l	zstab1,a0
	lea	zomsiz1(pc),a2
	bsr	calccop

	move.l	zstab2,a0
	lea	zomsiz2(pc),a2
	bsr	calccop

	move.l	zstab3,a0
	lea	zomsiz3(pc),a2
	bsr	calccop

	move.l	zstab4,a0
	lea	zomsiz4(pc),a2
	bsr	calccop

	startc	coptab
	lea	zstab1(pc),a0
	bsr	swaps
	lea	zstab2(pc),a0
	bsr	swaps
	lea	zstab3(pc),a0
	bsr	swaps
	lea	zstab4(pc),a0
	bsr	swaps
	lea	coptab(pc),a0
	bsr	swaps
	tst.w	curstat
	bne.w	.ncons
					;CONSOLE
	move.b	omous,d1
	move.b	$bfe001,d0
	move.b	d0,omous
	btst	#6,d1
	beq.s	.nlmb
	btst	#6,d0
	bne.s	.nlmb
	move.w	#23*8,ftxtco
	clr.l	curwrt
	move.l	#text2,currd
	tst.w	page
	beq.s	.pg2
	move.l	#text3,currd
.pg2	
	move.w	#1,curstat
	addq.w	#1,page
	cmp.w	#3,page
	beq.s	prgx
	bra.s	.ncons
.nlmb
	tst.w	curstat
	bne.s	.ncons
	tst.w	tmode
	bpl.w	.ncons
	cmp.w	#1,page
	bne.s	.ncons
	moveq	#trainanz-1,d2
	moveq	#0,d0
	lea	traintab(pc),a0
	lea	otrtab(pc),a1
.loop
	move.b	(a0,d0.w),d1
	cmp.b	(a1,d0.w),d1
	bne.s	.dotrn
	addq.w	#1,d0
	dbf	d2,.loop	
	bra.s	.ncons
.dotrn
	move.b	d1,(a1,d0.w)
	move.w	d0,d2
	add.w	d0,d0
	and.w	#1,d1
	add.w	d1,d0
	asl.w	#2,d0
	lea	ttab(pc),a0
	move.l	(a0,d0.w),currd

	add.w	#trainy-1,d2
	mulu	#scrbw*8,d2
	move.l	d2,curwrt
	not.w	curstat
.ncons
;	move.w	#$c,$180(a6)
	bra	mainloop
prgx
	bsr	fadout
	wvbl
	move.l	okey,$68.w
	bsr	mte
	wvbl
	wvbl
	exit
okey	dc.l	0
page	dc.w	0
omous	dc.w	0

fadout	;

	startc	#copr1
	wvbl
	wvbl
	lea	txtsc,a0
	move.w	#scrbw*scrh/4-1,d0
.cl	move.l	#-1,(a0)+
	dbf	d0,.cl
	startc	#copr2
	wvbl	
	wvbl	
	moveq	#scrbw/4-1,d0
	lea	txtsc,a0
	lea	scrbw-2(a0),a1
.xlop
	wvbl
	move.w	#scrh-1,d1
	lea	(a0),a2
	lea	(a1),a3
	moveq	#0,d2
	moveq	#scrbw,d3
.ylop
	move.w	d2,(a2)
	move.w	d2,(a3)
	add.w	d3,a2
	add.w	d3,a3
	dbf	d1,.ylop
	addq.l	#2,a0
	subq.l	#2,a1
	sub.w	#$111,c2c+2
	dbf	d0,.xlop
	wvbl	
	startc	#cop0
	wvbl	
	wvbl	
	rts
	

kinter
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
	beq.s	.noke
	ror.b	d0
	not.b	d0
	move.b	d0,key
	tst.w	tmode
	bpl.w	.noke
	moveq	#0,d0
	move.b	key,d0
	sub.b	#$50,d0		;F1
	cmp.b	#trainanz,d0	;Fx
	bcc.s	.noke
	lea	traintab(pc),a0
	not.b	(a0,d0.w)	
.noke
.fintr
	movem.l	(sp)+,d0-a6
	move.w	#$8,$dff09c
	rte

key	dc.b	0,0	

swaps	movem.l	(a0),d0/d1
	move.l	d0,4(a0)
	move.l	d1,(a0)
	rts

drawp
	lea	txtsc+265*scrbw+40,a0
	lea	p2log(pc),a1
	and.w	#-4,d0
	lea	patt(pc),a2
	movem.w	(a2,d0.w),d1/d2
	moveq	#6,d0
.pp2log
	move.w	(a1)+,d3
	and.w	d1,d3
	move.w	d3,(a0)
	exg	d1,d2
	add.w	#scrbw,a0
	dbf	d0,.pp2log
	rts

zomsiz1	dc.w	0 ;zomanz-1
	dc.w	0,bpl1pth,bpl1ptl,0,0,10,0,34
zomsiz2	dc.w	zomanz/4			
	dc.w	8,bpl2pth,bpl2ptl,0,0,10,0,34
zomsiz3	dc.w	2*zomanz/4			
	dc.w	16,bpl3pth,bpl3ptl,0,0,10,0,34
zomsiz4	dc.w	3*zomanz/4			
	dc.w	24,bpl4pth,bpl4ptl,0,0,10,0,34

coptab	dc.l	cop1,cop2
zstab1	dc.l	zscr11,zscr21
zstab2	dc.l	zscr12,zscr22
zstab3	dc.l	zscr13,zscr23
zstab4	dc.l	zscr14,zscr24

pri	dc.w	0


;; ********* TEXT FADEN *******
fadetxt
	tst.w	ftxtco
	beq.w	.out

	subq.w	#8,ftxtco
	move.w	#23*8,d0
	sub.w	ftxtco,d0
	move.w	d0,d1
	and.w	#7,d0
	mulu	#10,d0
	lea	cpatt,a0

	lsr.w	#3,d1
	mulu	#scrbw*8,d1
	add.l	#txtsc+6+59*scrbw,d1

	move.l	d1,-(sp)

	moveq	#7,d2
	wblit
	fixadj	0,%1001,%11000000,0
	move.l	#-1,bltafwm(a6)
.loop	wblit
	move.w	(a0,d0.w),bltbdat(a6)
	move.w	#0,bltbdat(a6)
	blita	d1
	blitd	d1
	doblit	(scrbw-8)/2,1
	add.l	#scrbw,d1
	addq.w	#2,d0
	dbf	d2,.loop

	move.l	(sp)+,a1
	add.w	#9*scrbw,a1
	moveq	#-2,d0
	bsr	drwcurs

.out	rts
ftxtco	dc.w	0
;; ********* LOGO BLITTEN *******
blitlog
	move.w	frco,d0
	sub.w	#100,d0
	add.w	d0,d0
	lea	sin,a0
	asl.w	#2,d0
	move.w	(a0,d0.w),d0
	lsr.w	#3,d0
	add.w	#1,d0
	procoff
	wblit
	setadmod 0,2*scrbw-32
	fixadj	0,%1001,%11000000,0
	blita	#logo
	move.w	#33,d1
	sub.w	d0,d1
	mulu	#scrbw*2,d1
	add.l	#txtsc+10*scrbw+6,d1
	blitd	d1
	
	move.w	#$5555,bltbdat(a6)
	move.l	#-1,bltafwm(a6)
	asl.w	#6,d0
	add.w	#16,d0
	move.w	d0,bltsize(a6)
	
	nop
	rts

;; ********* FARBEN ************
calccol
	move.w	#15,d0
	lea	$180(a6),a0
	moveq	#0,d1
	lea	zomsiz1,a1
	lea	ccoltab,a2
.cclop
	moveq	#0,d2

	move.w	pri,d4
	moveq	#0,d4
	move.w	d4,d5
	move.w	d4,d6
	move.w	d4,d7
	addq.w	#1,d5	
	addq.w	#1,d6
	addq.w	#1,d7
	and.w	#3,d4
	and.w	#3,d5
	and.w	#3,d6
	and.w	#3,d7

	btst	#0,d1
	beq.w	.npl1
	move.w	(a1),d3
	bsr	.cadd
.npl1	
	btst	#1,d1
	beq.w	.npl2
	move.w	18(a1),d3
	bsr	.cadd
.npl2	
	btst	#2,d1
	beq.w	.npl3
	move.w	2*18(a1),d3
	bsr	.cadd
.npl3	
	btst	#3,d1
	beq.w	.npl4
	move.w	3*18(a1),d3
	bsr	.cadd
.npl4	
	addq.w	#1,d1
	cmp.w	#$fff,d2
	bcs.s	.nov
	move.w	#$fff,d2
.nov
	
	sub.w	fadc,d2
	bpl.s	.nfov
	moveq	#0,d2
.nfov
	move.w	d2,(a0)+
	move.w	d2,d3
	and.w	#$e0e,d2
	lsr.w	#1,d2
	and.w	#$0f0,d3
	add.w	d3,d3
	add.w	#$070,d3
	cmp.w	#$0f0,d3
	bcs.s	.nov2
	move.w	#$0f0,d3
.nov2
	or.w	d3,d2
	move.w	d2,30(a0)
	dbf	d0,.cclop	
	tst.w	fadc
	beq.s	.nadf
	sub.w	#$111,fadc
.nadf	
	rts
.cadd
	add.w	d3,d3
	add.w	(a2,d3.w),d2
	rts
fadc	dc.w	$fff
;; ******* WAITCOP ERSTELLEN ******
gwaitc
	lea	cop1,a0
	bsr	.doit
	lea	cop2,a0
.doit
	lea	caddt,a1
	move.w	#scrh-1,d0
	move.l	#$1f01fffe,d4
.loop
	move.w	#36,(a1)+
	add.l	#1<<24,d4
	bcc.s	.njmp2
	move.l	#$ffdffffe,(a0)+
	move.w	#40,-2(a1)
.njmp2	
	move.l	d4,(a0)+
	add.w	#32,a0
	dbf	d0,.loop
	move.w	#4,caddt
	rts		


;; ******* COPPER ERSTELLEN ******
;D1:Xoff
;D2:Yoff
;A0:Zscr
;A2:Zomsiz
calccop
	move.w	10(a2),d0
	add.w	12(a2),d0
	and.w	#2046,d0
	move.w	d0,10(a2)
	lea	sin,a1
	move.w	(a1,d0.w),d1
	asl.w	#2,d1
	lea	400(a1),a1
	move.w	(a1,d0.w),d2
	asl.w	#2,d2

	move.w	14(a2),d0
	add.w	16(a2),d0
	and.w	#2046,d0
	move.w	d0,14(a2)
	lea	sin,a1
	add.w	(a1,d0.w),d1
	lea	800(a1),a1
	add.w	(a1,d0.w),d2
	move.w	frco,d3
	asl.w	#4,d3
	sub.w	d3,d2

	addq.w	#1,(a2)
	cmp.w	#zomanz-1,(a2)
	bne.s	.znov
	move.w	#0,(a2)
	addq.w	#1,pri
.znov
	move.w	(a2),d0
	add.w	d0,d0
	lea	cstab,a1
	moveq	#0,d6
	move.w	(a1,d0.w),d6

	muls	cstabe,d2
	divs	d6,d2
	move.w	d2,d5
	add.w	#-scrh/2,d5

	muls.w	d6,d5

				;Erstmal blitten
	muls	cstabe,d1
	divs	d6,d1
	ext.l	d1
	add.l	#scrw/2,d1
	
	move.l	#65536*256,d4
	move.l	#65536*2,d3
	divu	d6,d3
.mxpl	tst.w	d1
	bpl.s	.mxpx
	add.w	d3,d1
	bra.s	.mxpl
.mxpx

.gslop
	move.l	d4,d3
	lsr.l	#1,d4

	divu	d6,d3		->Kachelgr��e
	ext.l	d1
	divu	d3,d1
	swap	d1
	cmp.w	#scrw,d1
	bcc.s	.gslop

	mulu	#scrbw,d0
	add.l	#zomscr,d0
	move.l	d0,a1
	move.w	d1,d3
	not.w	d3
	lsr.w	#4,d1
	add.w	d1,d1
	add.w	d1,a1
	wblit
	procon
	setadmod 0,0
	blita	a1
	regadj	d3,%1001,%11110000,0
	move.l	#-1,bltafwm(a6)	
	blitd	a0
	doblit	scrbw/2+1,1
	addq.l	#2,a0
	move.l	a0,a1
	wblit
	fixadj	0,%1001,%00000000,0
	blita	a0
	add.w	#scrbw,a0
	blitd	a0
	doblit	scrbw/2,1

	move.l	a0,d0
	move.l	a0,d1
	move.w	4(a2),d0
	swap	d0
	and.l	#$ffff,d1
	or.l	6(a2),d1

	move.l	a1,d2
	move.l	a1,d3
	move.w	4(a2),d2
	swap	d2
	and.l	#$ffff,d3
	or.l	6(a2),d3

	move.l	coptab,a0
	add.w	2(a2),a0

	move.w	#scrh-1,d7

	lea	caddt,a1
.loop
	add.w	(a1)+,a0
	add.l	d6,d5
	btst	#16,d5
	beq.s	.eq	
	move.l	d0,(a0)
	move.l	d1,4(a0)
	dbf	d7,.loop
	move.l	#-2,(a0)
	rts

.eq
	move.l	d2,(a0)
	move.l	d3,4(a0)

	dbf	d7,.loop
	move.l	#-2,(a0)
	rts
;; ******* ZOOMEN BERECHNEN ******
calczom
	move.w	#zomanz-1,d0
	lea	zomscr,a0
	move.l	#1<<14,d5
	lea	cstab,a1
.zolop

	move.w	d5,(a1)+
	
	move.w	#scrw*2-1,d1
	moveq	#0,d2
	moveq	#7,d3

	move.w	d5,d4
	muls	#-scrw,d4

.zxlop
	move.l	d4,d6
	add.l	d5,d4

	swap	d2

	bclr	d3,(a0,d2.w)
	btst	#16,d4
	beq.s	.kset
	btst	#15,d4
	beq.s	.kset
	bset	d3,(a0,d2.w)
.kset
	swap	d2
	add.l	#1<<13,d2
	subq.w	#1,d3
	dbf	d1,.zxlop
	sub.l	#1<<14/(zomanz+1),d5
	add.w	#scrbw*2,a0
	dbf	d0,.zolop

	rts

;; ******* TEXT MALEN *********
;A0:Text A1:GFX
drawtext
	move.l	currd,a0
	move.w	curwrt,d0
	move.w	curwrt+2,d1
	add.w	d0,d1
	lea	txtsc+6+60*scrbw,a1
	add.w	d1,a1

	moveq	#-2,d0
	btst	#2,frco+1
	beq.s	.con
	moveq	#0,d0
.con	
	bsr	drwcurs
	tst.w	curstat
	beq.s	.out
	
	moveq	#0,d0
	move.b	(a0)+,d0
	move.l	a0,currd
	tst.b	d0
	beq.s	.linex
	lea	font,a3
	sub.b	#32,d0
	add.w	d0,a3
.found
	move.l	a1,a2
	clr.b	-scrbw(a1)
	clr.b	5*scrbw(a1)

.ylop
	move.b	(a3),d1
	move.b	d1,(a2)
	move.b	1*60(a3),d1
	move.b	d1,1*scrbw(a2)
	move.b	2*60(a3),d1
	move.b	d1,2*scrbw(a2)
	move.b	3*60(a3),d1
	move.b	d1,3*scrbw(a2)
	move.b	4*60(a3),d1
	move.b	d1,4*scrbw(a2)

.nfnd	addq.w	#1,curwrt
	addq.w	#1,a1
	moveq	#-2,d0
	bsr	drwcurs
.out	rts
.linex
	moveq	#0,d0
	bsr	drwcurs
	clr.w	curwrt
	add.w	#8*scrbw,curwrt+2


	tst.b	(a0)
	bpl.s	.procx
	clr.w	curstat
	cmp.b	#-1,(a0)
	beq.s	.procx
	move.b	(a0),tmode
	cmp.b	#-2,(a0)
	beq.s	.setcp
	move.l	tcurp,curwrt	
.procx
	move.w	curwrt,d0
	move.w	curwrt+2,d1
	add.w	d0,d1
	lea	txtsc+6+60*scrbw,a1
	add.w	d1,a1
	moveq	#-2,d0
	bsr	drwcurs
	rts
.setcp
	move.l	curwrt,tcurp
	rts

drwcurs	
	move.b	d0,-1*scrbw(a1)
	move.b	d0,(a1)
	move.b	d0,1*scrbw(a1)
	move.b	d0,2*scrbw(a1)
	move.b	d0,3*scrbw(a1)
	move.b	d0,4*scrbw(a1)
	move.b	d0,5*scrbw(a1)
	move.l	a1,ocurs
	rts	
ocurs	dc.l	txtsc
curstat	dc.w	1
curwrt	dc.w	0,0
currd	dc.l	text1
tmode	dc.w	0
tcurp	dc.w	0,0
inter
	irqin
	lea	$dff000,a6
	move.l	#txtsc,bpl1pth(a6)
	move.l	#txtsc,bpl5pth(a6)
	addq.w	#1,frco
	bcc.s	.nfrx
	move.w	#65535,frco
.nfrx	
	bsr	mtm
	irqout
frco	dc.w	0
frcx	dc.w	0
patt

	dc.w	%0000000000000000
	dc.w	%1000100010001000

	dc.w	%0000000000000000
	dc.w	%1010101010101010

	dc.w	%0101010101010101
	dc.w	%1010101010101010

	dc.w	%0101010101010101
	dc.w	%1111111111111111

	dc.w	%0111011101110111
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%1111111111111111

cpatt
	dc.w	0,0,0,0,0
	dc.w	%1010101010101010
	dc.w	%0101010101010101
	dc.w	%1010101010101010
	dc.w	%0101010101010101
	dc.w	%1010101010101010

	dc.w	%1111111111111111
	dc.w	%0111011101110111
	dc.w	%1111111111111111
	dc.w	%0111011101110111
	dc.w	%1111111111111111

	dc.w	%1111111111111111
	dc.w	%0101010101010101
	dc.w	%1111111111111111
	dc.w	%0101010101010101
	dc.w	%1111111111111111

	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000

	dc.w	%1010101010101010
	dc.w	%0101010101010101
	dc.w	%1010101010101010
	dc.w	%0101010101010101
	dc.w	%1010101010101010


	dc.w	%1010101010101010
	dc.w	%0000000000000000
	dc.w	%1010101010101010
	dc.w	%0000000000000000
	dc.w	%1010101010101010



	dc.w	%1000100010001000
	dc.w	%0000000000000000
	dc.w	%1000100010001000
	dc.w	%0000000000000000
	dc.w	%1000100010001000

	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000



	dc.w	%0001111100011111
	dc.w	%0001111100011111
	dc.w	%1111111111111111
	dc.w	%1111111111111111
	dc.w	%1111111111111111

	dc.w	%0001111100011111
	dc.w	%0001111100011111
	dc.w	%1111111111111111
	dc.w	%0001111100011111
	dc.w	%0001111100011111

	dc.w	%0001111100011111
	dc.w	%0001111100011111
	dc.w	%1111111111111111
	dc.w	%0001000000010000
	dc.w	%0001000000010000

	dc.w	%0001000000010000
	dc.w	%0001000000010000
	dc.w	%1111111111111111
	dc.w	%0001000000010000
	dc.w	%0001000000010000

	dc.w	%0001000000010000
	dc.w	%0001000000010000
	dc.w	%0001111100011111
	dc.w	%0001000000010000
	dc.w	%0001000000010000

	dc.w	%0001000000010000
	dc.w	%0001000000010000
	dc.w	%0001000000010000
	dc.w	%0001000000010000
	dc.w	%0001000000010000

	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0001000000010000
	dc.w	%0001000000010000
	dc.w	%0001000000010000

	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	


	TEXTE
otrtab	blk.b	trainanz,0
	EVEN
cop0	copmode	0,0,0,0,0
	dc.w	$180,0
	dc.l	-2


copper	copmode	5,0,0,0,0
	copddf	97,32,scrw,scrh
	copwin	113,32,scrw,scrh

	dc.w	$102,$ff
	copemod	0
	copomod	0
	dc.l	-2

copr1	copmode	0,0,0,0,0
	dc.w	$180,$fff
	dc.l	-2
copr2	copmode	1,0,0,0,0
	dc.w	$180,$0
c2c	dc.w	$182,$fff
	copddf	97,32,scrw,scrh
	copwin	113,32,scrw,scrh
	dc.l	-2



font	incbin	"data\tal8x5.font"
logo
	incbin	"data\trsi-future.gfx"
sinorig	incbin	"data\wsintab1024",514

p2log
	dc.w	%11111111111100
	dc.w	%10000110110100
	dc.w	%11110010110100
	dc.w	%10000110110100
	dc.w	%10011110110100
	dc.w	%10011110110100
	dc.w	%11111111111100
mti	MT_INIT
mte	MT_exit
mtm	MT_VBL

ende	
	printt	"Soviel is schon wech:"
	printv	ende-anf
	section	"Würg",bss_c
multab	ds.w	scrh

caddt	ds.w	scrh

ccoltab	ds.w	zomanz
cstab	ds.w	zomanz-2
cstabe	ds.w	1

cop1	ds.l	scrh*9+20
cop1x	ds.l	1
cop2	ds.l	scrh*9+20
cop2x	ds.l	1

logosc	ds.w	32*scrbw
txtsc	ds.w	scrbw*scrh/2

zomscr	ds.w	zomanz*scrbw


zscr11	ds.w	scrbw+2
zscr12	ds.w	scrbw+2
zscr13	ds.w	scrbw+2
zscr14	ds.w	scrbw+2
zscr21	ds.w	scrbw+2
zscr22	ds.w	scrbw+2
zscr23	ds.w	scrbw+2
zscr24	ds.w	scrbw+2

	ds.w	100
sin	ds.w	3072
memx
