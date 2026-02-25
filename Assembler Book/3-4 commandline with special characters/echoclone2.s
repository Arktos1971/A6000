**
** Date: 25.02.2026
**
** Book: Amiga Assembler von Null auf Hundert (German)
** Page: 79
**
** Description: prints the command line parameter and replaces
**              special characters
**
**
                opt d+                          ; export with symbols
                
                machine 68080					; treat this source as 68080 code.

                output	echoclone2.exe

ExecBase        equ 4
OpenLib         equ -552
CloseLib        equ -414
Output          equ -60
Write           equ -48

                code_f

*************** Save registers to stack **************************************************

                movem.L a0/d0,-(sp)             ; Save commandline

*************** Open DOS-Lib **************************************************

                move.L  ExecBase,a6             ; Exec-Lib Base
                lea     dosname,a1              ; DOS-Lib Name
                clr.L   d0                      ; Version doesn't matter
                jsr     OpenLib(a6)             ; Open Lib
                tst.L   d0                      ; Error opening?
                beq     exit                    ; yes then quit
                move.L  d0,a6                   ; Save dosbase in a6

*************** Get Output-Handle for the CLI Window **************************

                jsr     Output(a6)              ; Get Output-Handle
                move.L  d0,d5                   ; Save Handle in d5

*************** Get Registers back ********************************************

                movem.L (sp)+,a4/d4             ; Restore Commandline

*************** Prepare Loop Registers ****************************************

                move.L  a4,a2                   ; Commandline address
                move.L  d4,d1                   ; and length to a2/d1
                subq    #1,d1                   ; cause loop runs until -1

*************** Main Loop / Search '*' ****************************************

loop1:          cmp.b   #"*",(a2)+              ; found '*'?
                beq     loop2                   ; then jump to next loop
                dbra    d1,loop1                ; check next character
                bra     output

*************** Remove found character ****************************************

loop2:          move.L  d1,d0                   ; set inner loop counter d1
                subq    #1,d0                   ; to d0 minus 1
                move.L  a2,a0                   ; source text pointer
                lea     -1(a0),a1               ; target text pointer
loop3:          move.b  (a0)+,(a1)+             ; move character data
                dbra    d0,loop3

*************** Check if character after '*'= 'e' or 'n' **********************

                lea     -1(a2),a0               ; minus 1 -> cause (a2)+ while
                                                ; searching for '*'
                cmp.b   #"e",(a0)               ; found 'e'?
                beq     label1                  ; Yes - continue at label1
                cmp.b   #"n",(a0)               ; or 'n'?
                beq     label2                  ; Yes - continue at label2
                bra     label3                  ; nothing found? -> label3

*************** replace 'e' or 'n' with ESC or RETURN *************************

label1:         move.b  #27,(a0)                ; replace 'e' with Esc
                bra     label3
label2:         move.b  #10,(a0)                ; replace 'n' with Return

*************** adjust loop counter and text length ***************************

label3:         subq    #2,d1                   ; loop counter -2
                subq    #1,d4                   ; text length -1
                bra     loop1                   ; main loop

*************** output edited text ********************************************

output:         move.L  d5,d1                   ; Handle
                move.L  a4,d2                   ; Address
                move.L  d4,d3                   ; Length
                jsr     Write(a6)

*************** close Lib and end *********************************************

                move.L  a6,a1                   ; Close Lib
                move.L  ExecBase,a6
                jsr     CloseLib(a6)

exit:           rts

*************** Data Area *****************************************************

                data_f

dosname:        dc.b    "dos.library",0
                even







