**
** Date: 22.02.2026
**
** Book: Amiga Assembler von Null auf Hundert (German)
** Page: 68
**
** Description: Outputs text to a CLI window
**
**
                opt d+                          ; export with symbols
                
                machine 68080					; treat this source as 68080 code.

                
                incdir	"L:\Amiga\Include"
    			include	"exec\exec_lib.i"
                include "dos\dos.i"
                include "dos\dos_lib.i"

                output	textoutput.exe




ExecBase        equ 4
OpenLib         equ -552
CloseLib        equ -414
Write           equ -48
Output          equ -60

                code_f

*************** Open DOS-Lib **************************************************

                move.L  ExecBase,a6             ; Exec-Lib Base
                lea     dosname,a1              ; DOS-Lib Name
                clr.L   d0                      ; Version doesn't matter
                jsr     OpenLib(a6)             ; Open Lib
                tst.L   d0                      ; Error opening?
                beq     ende                    ; yes then quit
                move.L  d0,dosbase              ; Save dosbase address

*************** Get Output-Handle for the CLI Window **************************

                move.L  dosbase,a6              ; Set dosbase
                jsr     Output(a6)              ; Get Output-Handle
                move.L  d0,clihandle            ; Save Handle

*************** Output Text ***************************************************

                move.L  clihandle,d1            ; Load Handle in d1
                move.L  #text,d2                ; Address of text in memory
                move.L  #33,d3                  ; Text length in d3
                jsr     Write(a6)               ; Call DOS Write

*************** Close Lib *****************************************************

                move.L  dosbase,a1              ; DOS Lib Base Address
                move.L  4,a6                    ; Set Exec Base
                jsr     CloseLib(a6)            ; Close DOS Lib

ende:           rts                

*************** Data Area *****************************************************

                data_f

dosname:        dc.b    "dos.library",0
                even
dosbase:        ds.L    1
clihandle       ds.L    1
text:           dc.b    "My first Text in a CLI Window! Yeaah!!!",10
                even
