**
** Date: 03.03.2026
**
** Description: converts the decimal number 269488144 to hex-string
**              and writes this hexstring to cli window
**
                        machine 68080			        ; treat this source as 68080 code.

                
ExecBase        equ 4
OpenLib         equ -552
CloseLib        equ -414
Write           equ -48
Output          equ -60

                        code_f

                        move.L  #269488144,d0
                        move.L  #hexstring,a0
                        bsr     number_to_hexstring
                        bsr     strlen
                        move.L  d1,str_length

*************** Open DOS-Lib **************************************************

                        move.L  ExecBase,a6             ; Exec-Lib Base
                        lea     dosname,a1              ; DOS-Lib Name
                        clr.L   d0                      ; Version doesn't matter
                        jsr     OpenLib(a6)             ; Open Lib
                        tst.L   d0                      ; Error opening?
                        beq     exit                    ; yes then quit
                        move.L  d0,dosbase              ; Save dosbase address

*************** Get Output-Handle for the CLI Window **************************

                        move.L  dosbase,a6              ; Set dosbase
                        jsr     Output(a6)              ; Get Output-Handle
                        move.L  d0,clihandle            ; Save Handle

*************** Output Text ***************************************************

                        move.L  clihandle,d1            ; Load Handle in d1
                        move.L  #hexstring,d2           ; Address of text in memory
                        move.L  str_length,d3           ; Text length in d3
                        jsr     Write(a6)               ; Call DOS Write

*************** Close Lib *****************************************************

                        move.L  dosbase,a1              ; DOS Lib Base Address
                        move.L  4,a6                    ; Set Exec Base
                        jsr     CloseLib(a6)            ; Close DOS Lib

exit:                   rts

*************** strlen - get string length ************************************
** <-> a0 = string buffer start address
** <- d1 = string length

strlen:                 movem.L d0/a0,-(sp)     ; save registers
                        move.L  #0,d1           ; string length counter
loop:                   move.b  (a0)+,d0        ; get next character
                        tst.b   d0              ; 0?
                        beq.s   done            ; yes -> string end
                        addq.l  #1,d1           ; add 1 to string lenhth counter
                        bra.s   loop            ; next character
done:                   movem.L (sp)+,d0/a0     ; restore registers
                        rts                    

*************** number_to_hexstring *******************************************
** -> d0 = number
** -> a0 = string buffer start address

number_to_hexstring:    movem.l d0-d2/a0,-(sp)  ; save registers
                        moveq   #7,d1           ; Loop -> 8 Nibbles
label1:                 rol.L   #4,d0           ; rotate upper nibble down

                        move.b  d0,d2           ; move byte value to d2
                        and.b   #$f,d2          ; mask lower 4 bits
                        add.b   #"0",d2         ; add ascii code for '0'
                        cmp.b   #"9",d2         ; greater '9'?
                        ble     label2          ; no
                        add.b   #7,d2           ; convert to 'A' til 'F'

label2:                 move.b  d2,(a0)+        ; move to buffer
                        dbra    d1,label1       ; loop                 

                        move.b  #0,(a0)         ; terminate string with 0

                        movem.l (sp)+,d0-d2/a0
                        rts

*************** Data Area *****************************************************

                        data_f

dosname:                dc.b    "dos.library",0
                        even
dosbase:                ds.L    1
clihandle:              ds.L    1
hexstring:              ds.b    10
                        even
teststring1:            dc.b    "Ein Teststring!",10
teststring2:            even                        
str_length:             ds.L    1                        