**
** Date: 23.02.2026
**
** Book: Amiga Assembler von Null auf Hundert (German)
** Page: 74
**
** Description: prints the command line parameter
**
**
                opt d+                          ; export with symbols
                
                machine 68080					; treat this source as 68080 code.

                output	echoclone.exe

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
                beq     ende                    ; yes then quit
                move.L  d0,a6                   ; Save dosbase in a6

*************** Get Output-Handle for the CLI Window **************************

                jsr     Output(a6)              ; Get Output-Handle
                move.L  d0,d1                   ; Save Handle in d1

*************** Get Registers back ********************************************

                movem.L (sp)+,a0/d0             ; Restore Commandline

*************** Write text to CLI *********************************************

                                                ; Handle is allready in d1
                move.L  a0,d2                   ; text address into d2
                move.l  d0,d3                   ; text length into d3
                jsr     Write(a6)

*************** Close Library *************************************************

                move.L  a6,a1
                move.l  ExecBase,a6
                jsr     CloseLib(a6)

ende:           rts

*************** Data Area *****************************************************

                data_f

dosname:        dc.b    "dos.library",0
                even
                