**
** Date: 07.03.2026
**
** Important: needs 68020 or higher!!!
**
** Description: converts the decimal number 269488144 to decimal string
**              and writes this decimal string to cli window
**
                        machine 68020			        ; treat this source as 68080 code.

                
ExecBase        equ 4
OpenLib         equ -552
CloseLib        equ -414
Write           equ -48
Output          equ -60

                        code_f

                        move.L  #269488144,d0
                        move.L  #decstring_end,a0
                        bsr     number_to_decstring
                        move.L  d2,str_length
                        move.L  a0,a5

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
                        move.L  a5,d2           ; Address of text in memory
                        move.L  str_length,d3           ; Text length in d3
                        jsr     Write(a6)               ; Call DOS Write

*************** Close Lib *****************************************************

                        move.L  dosbase,a1              ; DOS Lib Base Address
                        move.L  4,a6                    ; Set Exec Base
                        jsr     CloseLib(a6)            ; Close DOS Lib

exit:                   rts                        

*************** number_to_decstring *******************************************
** destroys d0-d2
**
** -> a0 = String Buffer end address
** -> d0 = number to convert
** <- a0 = Result string start address
** <- d2 = string length

number_to_decstring:    moveq.l #0,d2               ; counter for string length
                        clr.b   (a0)                ; string is null terminated

loop1:                  divul.L #10,d1:d0           ; d1 = remainder / d0 = quotient
                                                    ; works only on 68020+

                        add.L   #'0',d1             ; remainder to character
                        move.b  d1,-(a0)            ; save digit in string
                        addq.L  #1,d2               ; increment string length

                        tst.L   d0                  ; quotient = 0?
                        bne.s   loop1               ; no - go on

                        rts

*************** Data Area *****************************************************

                        data_f

dosname:                dc.b    "dos.library",0
                        even
dosbase:                ds.L    1
clihandle:              ds.L    1

decstring:              ds.b    11
decstring_end:          ds.b    1
str_length:             ds.l    1        
