*
*****  COPPERMACROS  *******************************
*
; WAIT-Befehl
;		>=X,Y
wait	MACRO
	 dc.w	((\1)>>1)!((\2)<<8)!1,$fffe
	ENDM
; Bildschirmfarbe setzen
;		>=Farbe NR,Wert
copcol  MACRO
	 dc.w	$180+((\1)*2),\2
	ENDM
; DIW festlegen(als Copperliste)
;		>= winx,winy,winw,winh
copwin  MACRO
	dc.w	$8E,(\1)+((\2)<<8)
	dc.w	$90,(\3)+((\1)&255)+((((\2)+(\4)-1)&255)<<8)
	ENDM
; DDF	festlegen(als Clist)
;		>= winx,winy,winw in PIX.,winh,hresmode
copddf	MACRO
	IFEQ \5-0		;Lores
	 dc.w	$92,(((\1)-17)/2)&$fff8
	 dc.w   $94,((((\1)-17)/2)&$fff8)+((\3)/2)-8
	ENDC
	IFEQ \5-1		;Hires
	 dc.w	$92,(((\1)-9)/2)&$fffc
	 dc.w   $94,((((\1)-9)/2)&$fffc)+((\3)/4)-8
	ENDC
	ENDM
; Bitplane festlegen
;		>= planenr(1-6),startadresse
coppln	MACRO
	dc.w	$DC+((\1)*4),(\2)/65536
	dc.w	$DE+((\1)*4),(\2)&$FFFF
	ENDM
; Sprite festlegen
;		>= Spritenr(1-8),startadresse
copspr	MACRO
	dc.w	$11C+((\1)*4),(\2)/65536
	dc.w	$11E+((\1)*4),(\2)&$FFFF
	ENDM
; coppln-Befehl initialisieren
;		>= Coppln-Adresse,Screen-Adresse,dx wird verbraten
initcoppln MACRO
	move.l	#(\2),\3
	move.w	\3,\1+6
	swap	\3
	move.w	\3,\1+2
	ENDM
; Modulos festlegen
;		>=Wert
copemod MACRO
	dc.w	$10a,(\1)
	ENDM
copomod	MACRO
	dc.w	$108,(\1)
	ENDM
; Bildschirmmodus(BPLCON0) festlegen
;		>= BPLANZ,HIRES,DPLF,HAM,INTERLACE
copmode	MACRO
	dc.w	$100,((\1)<<12)+((\2)<<15)+((\3)<<10)+((\4)<<11)+((\5)<<2)
	ENDM
cprocoff MACRO
	dc.w	$96,$8400
	ENDM
cprocon	MACRO
	dc.w	$96,$400
	ENDM

; Copperliste starten
;		>= ?Adresse

initc	MACRO			;Komplettstart
	move.w	#$80,$96(a6)
	move.l	\1,$80(a6)
	clr.w	$88(a6)
	move.w	#$83c0,$96(a6)
	ENDM
startc  MACRO			;Nurstart
	move.l	\1,$80(a6)
	ENDM
*
****  Blittermacros  *****************************
*
; Auf Blitter warten
wblit   MACRO
.loop\@	btst	#14,$2(a6)
	bne.s	.loop\@
	ENDM
lwblit   MACRO
	wblit
	ENDM

; Prozessor während des Blittens an/aus
procoff MACRO
	move.w	#$8400,$96(a6)
	ENDM
procon	MACRO
	move.w	#$400,$96(a6)
	ENDM
; Blitter adjustieren
;		>= ABshift(FIX),ABCDDMA,Miniterm,Descend
fixadj	MACRO 
	move.l	#((\1)<<28)+((\2)<<24)+((\3)<<16)+((\1)<<12)+((\4)*2),$40(a6)
	ENDM
;		>= ABshift (Dx mampf) ,ABCDDMA,Miniterm,Descend
regadj	MACRO
	swap	\1
	move.w	#((\2)<<12)+((\3)<<4),\1
	lsr.l	#4,\1
	move.w  \1,$40(a6)
	and.w	#$f000,\1
	IFNE	\4
	 addq.w	#1,\1
	ENDC 
	move.w	\1,$42(a6)
	ENDM	

; Blitterposition festlegen
;		>=?Adresse
blita	MACRO
	move.l \1,$50(a6)
	ENDM
blitb	MACRO
	move.l \1,$4c(a6)
	ENDM
blitc	MACRO
	move.l \1,$48(a6)
	ENDM
blitd	MACRO
	move.l \1,$54(a6)
	ENDM
;		>=?Adresse,?Modulo
mblita	MACRO
	move.l \1,$50(a6)
	move.w \2,$64(a6)
	ENDM
mblitb	MACRO
	move.l \1,$4c(a6)
	move.w \2,$62(a6)
	ENDM
mblitc	MACRO
	move.l \1,$48(a6)
	move.w \2,$60(a6)
	ENDM
mblitd	MACRO
	move.l \1,$54(a6)
	move.w \2,$66(a6)
	ENDM
; Modulos
;	>=AMOD,DMOD
setadmod MACRO
	move.l	#((\1)<<16)+(\2),$64(a6)
	ENDM
;	>=BMOD,CMOD
setbcmod MACRO	
	move.l	#((\2)<<16)+(\1),$60(a6)
	ENDM
; Blitterfenster festlegen & Blitter starten
;		>=(#)Breite(in W.),(#)Höhe		
doblit	MACRO
	move.w #((\2)*64)+(\1),$58(a6)
	ENDM
*
******  VARSMACROS  ************************
*
; Blittervariablen definieren
defblit	MACRO
bltsize	equ	$58
bltcpth	equ	$48
bltcptl	equ	$4a
bltbpth	equ	$4c
bltbptl	equ	$4e
bltapth	equ	$50
bltaptl	equ	$52
bltdpth	equ	$54
bltdptl	equ	$56
bltcmod	equ	$60
bltbmod	equ	$62
bltamod	equ	$64
bltdmod	equ	$66
bltafwm	equ	$44
bltalwm	equ	$46
bltcon0	equ	$40
bltcon1	equ	$42
bltadat	equ	$74
bltbdat	equ	$72
bltcdat	equ	$70
	ENDM
; Playfieldvars definieren
defpln	MACRO
diwstrt	equ	$8e
diwstop	equ	$90
ddfstrt	equ	$92
ddfstop	equ	$94
bpl1pth	equ	$e0
bpl1ptl	equ	$e2
bpl2pth	equ	$e4
bpl2ptl	equ	$e6
bpl3pth	equ	$e8
bpl3ptl	equ	$ea
bpl4pth	equ	$ec
bpl4ptl	equ	$ee
bpl5pth	equ	$f0
bpl5ptl	equ	$f2
bpl6pth	equ	$f4
bpl6ptl	equ	$f6
bplcon0	equ	$100
bplcon1	equ	$102
bplsft	equ	$102
	ENDM
defspr	MACRO
spr0pth	equ	$120
spr0ptl	equ	$122
spr1pth	equ	$124
spr1ptl	equ	$126
spr2pth	equ	$128
spr2ptl	equ	$12a
spr3pth	equ	$12c
spr3ptl	equ	$12e
spr4pth	equ	$130
spr4ptl	equ	$132
spr5pth	equ	$134
spr5ptl	equ	$136
spr6pth	equ	$138
spr6ptl	equ	$13a
spr7pth	equ	$13c
spr7ptl	equ	$13e
spr0pos	equ	$140
spr0ctl	equ	$142
spr0data equ	$144
spr0datb equ	$146
spr1pos	equ	$148
spr1ctl	equ	$14a
spr1data equ	$14c
spr1datb equ	$14e
spr2pos	equ	$150
spr2ctl	equ	$152
spr2data equ	$154
spr2datb equ	$156
spr3pos	equ	$158
spr3ctl	equ	$15a
spr3data equ	$15c
spr3datb equ	$15e
spr4pos	equ	$160
spr4ctl	equ	$162
spr4data equ	$164
spr4datb equ	$166
spr5pos	equ	$168
spr5ctl	equ	$16a
spr5data equ	$16c
spr5datb equ	$16e
spr6pos	equ	$170
spr6ctl	equ	$172
spr6data equ	$174
spr6datb equ	$176
spr7pos	equ	$178
spr7ctl	equ	$17a
spr7data equ	$17c
spr7datb equ	$17e
	ENDM
; Sprite zeichnen
; 	>=?x,?y,?xadd,?yadd,?Höhe,(#)Sprctrl,(#)Attach
;	Verbrät d0-d3, diese nicht für ?-Werte benutzen !

calcsprite MACRO
	move.w	\2,d1
	add.w	\4,d1
	move.w	\1,d0
	add.w	\3,d0
	move.w	d0,d3
	and.w	#1,d3
	lsr.w	#1,d0
	move.w	d0,d2
	andi.w	#$ff,d2
	move.w	d1,d0
	add.l	\5,d0	;Höhe
	asl.w	#8,d1
	bcc.s	scne8\@
	bset	#2,d3
scne8\@	or.w	d1,d2
	asl.w	#8,d0
	bcc.s	scnl8\@
	bset	#1,d3
scnl8\@ or.w	d0,d3
	ifne	\7
	 bset	#7,d3
	endc
        move.w	d2,\6
	move.w	d3,(\6)+2
	ENDM
; Sprite zeichnen
; 	>=?x,?y,?xadd,?yadd,?Höhe,(#)Sprctrl,(#)Attach
;	Verbrät d0-d3, diese nicht für ?-Werte benutzen !

calcspritenowd MACRO
	move.w	\2,d1
	add.w	\4,d1
	move.w	\1,d0
	add.w	\3,d0
	move.w	d0,d3
	and.w	#1,d3
	lsr.w	#1,d0
	move.w	d0,d2
	andi.w	#$ff,d2
	move.w	d1,d0
	add.l	\5,d0	;Höhe
	asl.w	#8,d1
	bcc.s	scne8\@
	bset	#2,d3
scne8\@	or.w	d1,d2
	asl.w	#8,d0
	bcc.s	scnl8\@
	bset	#1,d3
scnl8\@ or.w	d0,d3
	ifne	\7
	 bset	#7,d3
	endc
	ENDM
******* FADEROUTINE **************

; Copper-Liste Faden 
;	=> Fadestrcut in a1, Copperliste in a2
cfadeirq MACRO
	subq.w	#1,8(a1)
	bne.s	fiend\@
	move.w	6(a1),8(a1)
	move.w	(a1),d1
	move.l	2(a1),a0
fadl\@	clr.w	d6
	move.w	#$f,d4
	move.w	#$1,d5
	bsr.s	dofad\@
	bsr.s	dofad\@
	bsr.s	dofad\@
	addq.l	#2,a2
	move.w	d6,(a2)+
	addq.l	#2,a0
	dbf	d1,fadl\@
fiend\@	rts
dofad\@	move.w	(a0),d2		;Wish in d2
	move.w	2(a2),d3	;Real in d3
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
	ENDM
fadestruct MACRO		;wishpalette,anz,speed
	dc.w (\2)-1	;(0) Anz
	dc.l \1 	;(2) Pal*
	dc.w \3		;(6) Speed
	dc.w 1		;(8) Co
	ENDM
setfadestruct MACRO		;?Palptr,?Speed,*Struct
	move.l	\1,\3+2
	move.w	\2,\3+6
	ENDM
