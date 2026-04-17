        section code,code_c

EXECBase       EQU 4
allocmem       EQU -198
freemem        EQU -210
forbid         EQU -132
permit         EQU -138
disable        EQU -120
enable         EQU -126

init:
start:
        movem.l d0-d7/a0-a6,-(a7)
        move.l  EXECBase,a6
        jsr     disable(a6)
        jsr     forbid(a6)
        move.w  #$03e0,$dff096

Clear:
        lea     $70000,a0
        lea     $7a000,a1

clop:
        clr.l   (a0)+
        cmpa.l  a0,a1
        bne     clop
        lea     $7c000,a0
        lea     $7e000,a1

clop2:
        clr.l   (a0)+
        cmpa.l  a0,a1
        bne     clop2
        jsr     copperinit
        move.w  #%1000011111100000,$dff096

loopmaus:
        move.w  $dff004,d0
        btst    #0,d0
        beq     loopmaus
        bsr     bringtext
        btst    #6,$bfe001
        bne     loopmaus

ende:
        move.w  #0,$dff0a8
        move.w  #0,$dff0b8
        move.l  EXECBase,a6
        move.l  #gfxname,a1
        clr.l   d0
        jsr     -552(a6)        ; OpenLibrary
        move.l  d0,a4
        move.l  38(a4),$dff080  ; Restore old Copper
        clr.w   $dff088
        move.w  #$8060,$dff096
        jsr     permit(a6)
        jsr     enable(a6)
        movem.l (a7)+,d0-d7/a0-a6
        rts

gfxname:
        dc.b    "graphics.library",0
        even

dosname:
        dc.b    "dos.library",0
        even

clz:    dc.l    0
ps:     dc.l    0
xps:    dc.l    0
mssz:   dc.l    0

bringtext:
        move.w  #138,$dff064
        move.w  #44,$dff066
        move.w  #44,$dff062
        move.l  #$ffffffff,$dff044
        move.w  #0,$dff042
        lea     bobxcoor,a0
        lea     bobycoor,a1
        moveq   #0,d5
        moveq   #20,d6

bringtext1:
        jsr     unblittext
        add.b   #6,d5
        dbra    d6,bringtext1
        lea     bobytable,a1
        lea     bobyz,a2
        lea     bobycoor,a3
        lea     bobxcoor,a0
        jsr     chtext
        lea     bobxcoor,a0
        lea     bobycoor,a1
        moveq   #0,d5
        moveq   #20,d6

bringtext2:
        jsr     blittext
        add.b   #6,d5
        dbra    d6,bringtext2
        rts

chtext:
        moveq   #20,d0
chtexty1:
        move.w  (a2)+,d1
        rol     #1,d1
        move.w  (a1,d1.w),d1
        move.w  #1,d2
        add.w   d1,d2
        move.w  d2,(a3)+
        dbra    d0,chtexty1
        lea     bobyz,a1
        moveq   #20,d0
chtexty2:
        move.w  (a1),d1
        add.b   #1,d1
        cmp.b   #100,d1
        beq     chtexty3
        bgt     chtexty5
chtexty4:
        move.w  d1,(a1)+
        dbra    d0,chtexty2
        moveq   #0,d2
        move.l  #20,d0
chtext1:
        move.w  (a0),d1
        sub.w   speedcontrol,d1
        cmp.w   #0,d1
        ble     chtext2
chtext3:
        move.w  d1,(a0)+
        addq    #1,d2
        dbra    d0,chtext1
        rts
chtext2:
        jsr     nextchar
        move.w  #336,d1
        bra     chtext3
chtexty3:
        move.w  #0,d1
        bra     chtexty4
chtexty5:
        sub.b   #38,d1
        bra     chtexty4

speedcontrol:
        dc.w    2

nextchar:
        lea     bobyz,a5
        move.l  d2,d4
        cmp.b   #0,d4
        beq     nextchary1
        rol     #1,d4
        move.w  -2(a5,d4.w),d5
        add.w   #2,d5
        move.w  d5,(a5,d4.w)
nextchary2:
        move.l  d2,d4
        mulu    #6,d4
        lea     message,a1
        move.l  messpointer,d3
        add.w   #1,d3
        move.l  d3,messpointer
        add.w   d3,a1
        clr.l   d3
        move.b  (a1),d3
        cmp.b   #2,d3
        beq     speedtotwo
        cmp.b   #4,d3
        beq     speedtofour
        cmp.b   #32,d3
        beq     spacechar
        cmp.b   #0,d3
        beq     newstart
        move.w  #0,d6
        sub.b   #65,d3
        cmp.b   #20,d3
        blt     nnxx1
        cmp.b   #39,d3
        bgt     nnxx2
        move.w  #640,d6
nnxx1:
        rol     #1,d3
        lea     font,a2
        add.w   d6,a2
        move.l  #$70000,a3
        move.l  #15,d5
copychar1:
        move.w  (a2,d3.w),(a3,d4.w)
        add.w   #40,a2
        add.w   #144,a3
        dbra    d5,copychar1
        rts
speedtotwo:
        move.w  #2,speedcontrol
        bra     speedweiter
speedtofour:
        move.w  #4,speedcontrol
speedweiter:
        rts
nnxx2:
        move.w  #1280,d6
        bra     nnxx1
nextchary1:
        move.w  40(a5),d5
        add.b   #2,d5
        move.w  d5,(a5)
        bra     nextchary2
newstart:
        move.l  #0,messpointer
        rts
spacechar:
        move.l  #$70000,a3
        move.l  #15,d5
spaceit1:
        move.w  #0,(a3,d4.w)
        add.w   #144,a3
        dbra    d5,spaceit1
        rts

messpointer:
        dc.l    0

unblittext:
        move.w  (a1)+,d2
        add.w   #50,d2
        mulu    #50,d2
        move.w  (a0)+,d0
        add.w   #384,d0
        move.l  d0,d1
        and.w   #$000f,d1
        rol.w   #8,d1
        rol.w   #4,d1
        add.w   #%0000100100000000,d1
        lsr     #3,d0
        jsr     waitblt
        move.l  #$70000,a4
        add.w   d5,a4
        move.l  #$72000,a5
        add.w   d0,a5
        add.w   d2,a5
        move.l  a5,$dff054
        move.l  a5,$dff04c
        move.l  a4,$dff050
        move.w  d1,$dff040
        move.w  #$0403,$dff058
        rts

blittext:
        move.w  (a1)+,d2
        add.w   #50,d2
        mulu    #50,d2
        move.w  (a0)+,d0
        add.w   #384,d0
        move.l  d0,d1
        and.w   #$000f,d1
        rol.w   #8,d1
        rol.w   #4,d1
        add.w   #%0000110111111100,d1
        lsr     #3,d0
        jsr     waitblt
        move.l  #$70000,a4
        add.w   d5,a4
        move.l  #$72000,a5
        add.w   d0,a5
        add.w   d2,a5
        move.l  a5,$dff054
        move.l  a5,$dff04c
        move.l  a4,$dff050
        move.w  d1,$dff040
        move.w  #$0403,$dff058
        rts

bobxcoor:
        dc.w    4,20,36,52,68,84,100,116,132,148,164,180,196,212,228,244
        dc.w    260,276,292,308,324,340

bobycoor:
        dcb.w   21,180

bobytable:
        dc.w    60,60,59,59,57,56,54,52,50,48,45,42,39,36,33,30
        dc.w    27,24,21,18,15,12,10,8,6,4,3,1,1,0,0,0
        dc.w    1,1,3,4,6,8,10,12,15,18,21,24,27,30,33,36
        dc.w    39,42,45,48,50,52,54,56,57,59,59,60
        dc.w    60,60,59,57,54,51,48,44,39,35,30,25,21,16,12,9
        dc.w    6,3,1,0,0,0,1,3,6,9,12,16,21,25,30,35
        dc.w    39,44,48,51,54,57,59,60

bobyz:
        dc.w    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20

waitblt: 
        btst #14,$dff002
        bne waitblt
        rts  

copperinit:
        lea     copperlist,a0
        move.l  a0,$dff080
        clr.w   $dff088
        rts

        section data_c,data_c  ;

copperlist:
        dc.w    $0120
sp1:    dc.w    $0000,$0122
sp2:    dc.w    $0000,$0124,$0000,$0126,$0000
        dc.w    $0128,$0000,$012A,$0000,$012C,$0000,$012E,$0000
        dc.w    $0130,$0000,$0132,$0000,$0134,$0000,$0136,$0000
        dc.w    $0138,$0000,$013A,$0000,$013C,$0000,$013E,$0000
        dc.w    $008e,$25d0,$0090,$33e0,$0092,$0038,$0094,$00d0
        dc.w    $0100,$1200
        dc.w    $00e0,$0007,$00e2,$2000
        dc.w    $0180,$0000,$0182,$0FFF,$0184,$0DDE,$0186,$0CCD
        dc.w    $008e,$24d0,$0090,$33e0,$0092,$0038,$0094,$00d0,$0108,$000a
        dc.w    $010a,$000a
        dc.w    $0102,$0000,$0104,$0000
        dc.w    $0096,$8100
        dc.w    $ffff,$fffe

message:

        dc.b "          "
        dc.b "SIXTY[EIGHT[K PROUDLY PRESENTS THE SOURCECODE FOR A SINUSSCROLLER]]"
        dc.b "   ORIGINAL CODE BY SAVAGE AND MADE VASM READY BY ARKTOS]]"
        dc.b "   GITHUB LINK IS IN THE DESCRIPTION]]   "
        dc.b "   GREETINGS FLY TO[   THE WHOLE APOLLO TEAM [[ THANK YOU FOR THE "
        dc.b "VAMPIRES AND THE UNICORNS]]   TALENTED PEOPLE I MET ON THE APOLLO "
        dc.b "DISCORD SERVER[   [[BIGGUN[[   [[KAMELITO[[   [[TOMMO[[   [[WILLEMDRIJVER[[   "
        dc.b "[[TJOMP[[   [[PISKLAK[[   [[PAULTHETALL[[   [[NIHIRASH]   "
        dc.b "[[PHIL[[   [[LASKO[[   "
        dc.b "AND MANY MANY MORE]   PLEASE DONT BE UPSET IF I FORGOT TO MENTION SOMEONE]"
        dc.b "   THIS SCROLLER WAS CAPTURED ON REAL HARDWARE] AN UNICORN]"
        dc.b "   PRAISE [[ CRITICISM [[ IDEAS AND REQUESTS[ PLEASE WRITE THEM IN THE "
        dc.b "COMMENTS. NEW VIDEO TUTORIALS ARE IN THE WORKS] STAY TUNED AND LET "
        dc.b "YOURSELVES BE SURPRISED]               "
        dc.b 0 ; End
        even

font:   incbin "onecolfont.dat"
        even