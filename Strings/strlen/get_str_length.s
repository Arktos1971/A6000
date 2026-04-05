**
** Date: 17.03.2026
**
** Description: Determine the length of a string. This value is needed
**              to write the string to the cli window using AmigaDOS
**              output function
**
                        machine 68080

ExecBase        equ 4
OpenLib         equ -552
CloseLib        equ -414
Write           equ -48
Output          equ -60

                        code_f

                        lea     textstring,a0
                        bsr.s   strlen
                        move.l  d0,d3                   ; string length be needed later

*************** Open DOS-Lib **************************************************

                        movea.L ExecBase,a6             ; Exec-Lib Base
                        lea     dosname,a1              ; DOS-Lib Name
                        clr.L   d0                      ; Version doesn't matter
                        jsr     OpenLib(a6)             ; Open Lib
                        tst.L   d0                      ; Error opening?
                        beq     exit                    ; yes then quit
                        move.L  d0,dosbase              ; Save dosbase address

*************** Get Output-Handle for the CLI Window **************************

                        movea.L dosbase,a6              ; Set dosbase
                        jsr     Output(a6)              ; Get Output-Handle
                        move.L  d0,clihandle            ; Save Handle

*************** Output Text ***************************************************

                        move.L  clihandle,d1            ; Load Handle in d1
                        move.l  #textstring,d2          ; Address of text in memory
                        jsr     Write(a6)               ; Call DOS Write

*************** Close Lib *****************************************************

                        movea.L dosbase,a1              ; DOS Lib Base Address
                        movea.L 4,a6                    ; Set Exec Base
                        jsr     CloseLib(a6)            ; Close DOS Lib

exit:                   rts                  

*************** strlen - get string length ************************************
** -> a0 = string buffer start address
** <- d0 = string length

strlen:                 movem.L a0,-(sp)        ; save registers
                        moveq.L  #0,d0          ; string length counter
.loop:                  tst.b   (a0)+           ; test if character = 0
                        beq.s   .done           ; yes -> string end
                        addq.l  #1,d0           ; add 1 to string lenhth counter
                        bra.s   .loop           ; next character
.done:                  movem.L (sp)+,a0        ; restore registers
                        rts                    

*************** Data Area *****************************************************

                        data_f

dosname:                dc.b    "dos.library",0
                        even
textstring:             dc.b    "Assembler",0
dosbase:                ds.L    1
clihandle:              ds.L    1
