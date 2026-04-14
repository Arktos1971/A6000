**
** Date: 07.03.2026 /14.04.2026
**
** Important: There are two subroutines:
**
**            One ist for all 68000er CPU's and the other is
**            optimized for 68020+ CPU's
**
** Description: converts a decimal number (here: 269488144) to string
**              and writes this string to cli window
**
                        machine 68020			        ; treat this source as 68020 code.

                
ExecBase        equ 4
OpenLib         equ -552
CloseLib        equ -414
Write           equ -48
Output          equ -60

                        code_f

                        move.L  #269488144,d0
                        move.L  #resultstring,a0
                        bsr     uint32_to_string_68000
                        move.L  d1,str_length

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
                        move.l  #resultstring,d2        ; Address of text in memory
                        move.L  str_length,d3           ; Text length in d3
                        jsr     Write(a6)               ; Call DOS Write

*************** Close Lib *****************************************************

                        movea.L dosbase,a1              ; DOS Lib Base Address
                        movea.L 4,a6                    ; Set Exec Base
                        jsr     CloseLib(a6)            ; Close DOS Lib

exit:                   rts                        

*************** uint32_to_string 68000 *************************************
**
** Converts a 32 Bit unsigned int to zero-terminated string
**
** -> a0 = string buffer start address
** -> d0 = number to convert
** <- a0 = string start address
** <- d1 = string length
**

uint32_to_string_68000:
                        movem.l d2-d5/a0-a1,-(sp)   ; save registers
                        lea     PowerTable(pc),a1   ; Address of the powers of 10

                        clr.l   d1                  ; reset length counter to 0
                        moveq   #0,d4               ; Flag for leading zeros (0 = suppress)

.NextPower
                        move.l  (a1)+,d2            ; get first/next power of 10 from table
                        beq.s   .Terminate          ; 0 marks end -> Terminate
                        moveq   #'0',d3             ; ASCII Character '0'

.SubtractLoop
                        sub.l   d2,d0               ; subtract table value
                        bcs.s   .Restore            ; if carry set = negative -> finished this digit
                        addq.b  #1,d3               ; increment ASCII-Character
                        bra.s   .SubtractLoop       ; loop

.Restore
                        add.l   d2,d0               ; undo last subtraction
    
                        * test for leading zeros
                        cmp.b   #'0',d3             ; test if character = '0'?
                        bne.s   .StoreDigit         ; No -> save always
                        tst.l   d4                  ; have we already saved a digit?
                        bne.s   .StoreDigit         ; Yes -> not first digit -> save
                        cmp.l   #1,d2               ; Is this the very last position?
                        beq.s   .StoreDigit         ; Yes -> save "0" if digit = 0
                        bra.s   .NextPower           ; No? -> ignore and go on

.StoreDigit
                        move.b  d3,(a0)+            ; Write character to buffer
                        addq.l  #1,d1               ; increment length by 1
                        moveq   #1,d4               ; set flag for first digit
                        bra.s   .NextPower

.Terminate
                        clr.b   (a0)                ; set last byte = 0 (terminated string)
                        movem.l (sp)+,d2-d5/a0-a1   ; restore registers
                        rts

    align 2
PowerTable:
    dc.l    1000000000
    dc.l    100000000
    dc.l    10000000
    dc.l    1000000
    dc.l    100000
    dc.l    10000
    dc.l    1000
    dc.l    100
    dc.l    10
    dc.l    1
    dc.l    0

*************** uint32_to_string 68020 *************************************
**
** Converts a 32 Bit unsigned int to zero-terminated string
**
** destroys d0-d2
**
** -> a0 = String Buffer end address
** -> d0 = number to convert
** <- a0 = Result string start address
** <- d2 = string length
**

uint32_to_string_68020:
                        moveq.l #0,d2               ; counter for string l1ength
                        clr.b   (a0)                ; string is null terminated

.loop1                  divul.L #10,d1:d0           ; d1 = remainder / d0 = quotient
                                                    ; works only on 68020+

                        add.L   #'0',d1             ; remainder to character
                        move.b  d1,-(a0)            ; save digit in string
                        addq.L  #1,d2               ; increment string length

                        tst.L   d0                  ; quotient = 0?
                        bne.s   .loop1              ; no - go on

                        rts

*************** Data Area *****************************************************

                        data_f

dosname:                dc.b    "dos.library",0
                        even
dosbase:                ds.L    1
clihandle:              ds.L    1

resultstring:           ds.b    11
resultstring_end:       ds.b    1
str_length:             ds.l    1        
