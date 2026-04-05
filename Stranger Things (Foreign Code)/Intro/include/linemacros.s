; flineinit (#)Scrw
; lineinit (#)Scrw
; fline     (?)Screen D0-D3, A3=Multab
; clipfline (?)Screen,(#)scrw,(#)scrh, sonst wie filline
; line     (?)Screen D0-D3, A3=Multab

	
;;************* LINEDRAW ROUTINE *******************
;                 LINEDRAW ROUTINE FOR USE WITH FILLING:
; Preload:  d0=X1  d1=Y1  d2=X2  d3=Y2 A3=Multab
; $dff060=Screenwidth (word)  $dff072=-$8000 (longword)  $dff044=-1 (longword)
; Verbrät d0-d5

fline MACRO 			;(?)Screen
	cmp.w   d1,d3
	bgt.s   .line1
	exg     d0,d2
	exg     d1,d3
	beq.s   .out
.line1	moveq	#0,d4
	move.w  d1,d4
	add.w	d4,d4
	move.w	(a3,d4.w),d4
	move.w  d0,d5
	asr.w   #3,d5
	add.w   d5,d4
	add.l   \1,d4
	moveq   #0,d5
	sub.w   d1,d3
	sub.w   d0,d2
	bpl.s   .line2
	moveq   #1,d5
	neg.w   d2
.line2	move.w  d3,d1
	add.w   d1,d1
	cmp.w   d2,d1
	dbhi    d3,.line3
.line3	move.w  d3,d1
	sub.w   d2,d1
	bpl.s   .line4
	exg     d2,d3
.line4	addx.w  d5,d5
	add.w   d2,d2
	move.w  d2,d1
	sub.w   d3,d2
	addx.w  d5,d5
	and.w   #15,d0
	ror.w   #4,d0
	or.w    #$a4a,d0
	LWBLIT
	move.w  d2,$52(a6)
	sub.w   d3,d2
	lsl.w   #6,d3
	addq.w  #2,d3
	move.w  d0,$40(a6)
 	move.b  .oct(PC,d5.w),$43(a6)
	move.l  d4,$48(a6)
	move.l  d4,$54(a6)
	movem.w d1/d2,$62(a6)
	move.w  d3,$58(a6)
.out	rts
.oct	dc.l    $3431353,$b4b1757
	ENDM

;;
clipfline MACRO 	;(?)Screen,(#)scrw,(#)scrh ,sonst wie filline
	
	cmp.w   d0,d2
	bgt.s   .line0
	exg     d0,d2
	exg     d1,d3
.line0			;D0<=D2
	tst.w	d2
	bmi.w	.out

	tst.w	d0		;Links clippen
	bpl.s	.nlclip
	sub.w	d2,d0
	sub.w	d3,d1
	muls	d2,d1
	divs	d0,d1
	neg.w	d1
	add.w	d3,d1	
	moveq	#0,d0
.nlclip
	cmp.w	#(\2)-1,d0
	bgt.s	.fullrclip
	cmp.w	#(\2),d2	;Rechts clippen (für Filled!)
	blo.s	.nrclip
	move.w	#(\2)-1,d4
	sub.w	d0,d4
	move.w	d3,d5
	sub.w	d0,d2
	sub.w	d1,d3
	muls	d4,d3
	divs	d2,d3
	add.w	d1,d3	
	move.w	#(\2)-1,d2
	movem.w	d0-d3,-(sp)
	move.w	d2,d0
	move.w	d5,d1
	bsr	.yexecute
	movem.w	(sp)+,d0-d3	
	bra.s	.yexecute
.fullrclip
	move.w	#(\2)-1,d0
	move.w	#(\2)-1,d2
.nrclip

.yexecute
	cmp.w   d1,d3
	beq.w   .out
	bgt.s   .line1
	exg     d0,d2
	exg     d1,d3
.line1			;D1<D3
	tst.w	d3		;Linie ganz oberhalb oder unterhalb ?
	bmi.w	.out
	cmp.w	#(\3)-1,d1
	bgt.w	.out

	tst.w	d1
	bpl.s	.ntclip
				;Oben clippen
	tst.w	d3
	beq.w	.out
	sub.w	d2,d0
	sub.w	d3,d1
	muls	d3,d0
	divs	d1,d0
	neg.w	d0
	add.w	d2,d0	
	moveq	#0,d1
.ntclip
	cmp.w	#(\3),d3	;Unten clippen
	blo.s	.nbclip
	move.w	#(\3)-1,d4
	sub.w	d1,d4
	beq.w	.out
	sub.w	d0,d2
	sub.w	d1,d3
	muls	d4,d2
	divs	d3,d2
	add.w	d0,d2	
	move.w	#(\3)-1,d3
.nbclip
	moveq	#0,d4
	move.w  d1,d4
	add.w	d4,d4
	move.w	(a3,d4.w),d4
	move.w  d0,d5
	asr.w   #3,d5
	add.w   d5,d4
	add.l   \1,d4
	moveq   #0,d5
	sub.w   d1,d3
	sub.w   d0,d2
	bpl.s   .line2
	moveq   #1,d5
	neg.w   d2
.line2	move.w  d3,d1
	add.w   d1,d1
	cmp.w   d2,d1
	dbhi    d3,.line3
.line3	move.w  d3,d1
	sub.w   d2,d1
	bpl.s   .line4
	exg     d2,d3
.line4	addx.w  d5,d5
	add.w   d2,d2
	move.w  d2,d1
	sub.w   d3,d2
	addx.w  d5,d5
	and.w   #15,d0
	ror.w   #4,d0
	or.w    #$a4a,d0
	LWBLIT
	move.w  d2,$52(a6)
	sub.w   d3,d2
	lsl.w   #6,d3
	addq.w  #2,d3
	move.w  d0,$40(a6)
 	move.b  .oct(PC,d5.w),$43(a6)
	move.l  d4,$48(a6)
	move.l  d4,$54(a6)
	movem.w d1/d2,$62(a6)
	move.w  d3,$58(a6)
.out	rts
.oct	dc.l    $3431353,$b4b1757
	ENDM
;;
flineinit MACRO		;(#)Scrw
	PROCOFF
	LWBLIT
	PROCON
	move.w	#(\1)/8,$60(a6)
	move.l	#-$8000,$72(a6)
	move.l	#-1,$44(a6)
	ENDM

;;
lineinit MACRO		;(#)Scrw

	PROCOFF
	LWBLIT
	PROCON
	move.w	#(\1)/8,$60(a6)
	move.l	#-$8000,$72(a6)
	move.l	#-1,$44(a6)
	ENDM

;;
line	MACRO	;(?)Screen D0-D3, A3=Multab

	cmp.w	d0,d2		;Start&Endpunkte gleich ?
	bne.s	.noeq
	cmp.w	d1,d3
	bne.s	.noeq
	rts
.noeq
	move.w	d1,d4
	add.w	d4,d4
	move.w	(a3,d4.w),d4
	moveq	#-$10,d5
	and.w	d0,d5
	lsr.w	#3,d5
	add.w	d5,d4
	add.l	a1,d4
	clr.l	d5
	sub.w	d1,d3
	roxl.b	#1,d5
	tst.w	d3
	bge.s	.y2gy1
	neg.w	d3
.y2gy1	sub.w	d0,d2
	roxl.b	#1,d5
	tst.w	d2
	bge.s	.x2gx1
	neg.w	d2
.x2gx1	move.w	d3,d1
	sub.w	d2,d1
	bge.s	.dygdx
	exg	d2,d3
.dygdx	roxl.b	#1,d5
	move.b	okttab(pc,d5),d5
	add.w	d2,d2
	WBLIT
	move.w	d2,$62(a6)		;BLTBMOD
	sub.w	d3,d2
	bge.s	.signnl
	or.b	#$40,d5
.signnl	move.w	d2,$52(a6)		;BLTAPTL
	sub.w	d3,d2
	move.w	d2,$64(a6)		;BLTAMOD
	move.w	#$8000,$74(a6)		;BLTADAT
	move.w	#-1,$72(a6)		;BLTBDAT
	move.w	#$ffff,$44(a6)		;BLTAFWM
	and.w	#$f,d0
	ror.w	#4,d0
	or.w	#$0bca,d0
	move.w	d0,$40(a6)		;BLTCON0
	move.w	d5,$42(a6)		;BLTCON1
	move.l	d4,$48(a6)		;BLTCPT
	move.l	d4,$54(a6)		;BLTDPT
	move.w	#scrbw*planz,$60(a6)	;BLTCMOD
	move.w	#scrbw*planz,$66(a6)	;BLTDMOD
	lsl.w	#6,d3
	addq.w	#2,d3
	move.w	d3,$58(a6)		;BLTSIZE
	rts
okttab	dc.b	0*4+1,4*4+1,2*4+1,5*4+1,1*4+1,6*4+1,3*4+1,7*4+1
	ENDM

