**
** Date: 23.02.2026
**
** Book: Amiga Assembler von Null auf Hundert (German)
** Page: 71
**
** Description: Read input from keyboard on a CLI window
**
**
                opt d+                          ; export with symbols
                
                machine 68080					; treat this source as 68080 code.

                
                incdir	"L:\Amiga\Include"
    			include	"exec\exec_lib.i"
                include "dos\dos.i"
                include "dos\dos_lib.i"

                output	textinput.exe




ExecBase        equ 4
OpenLib         equ -552
CloseLib        equ -414
Write           equ -48
Read            equ -42
Output          equ -60
input           equ -54

                code_f

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
                move.L  d0,d5                   ; Save Handle in d5

*************** Display prompt text *******************************************

                move.L  d5,d1                   ; Output handle to d1
                move.L  #text1,d2               ; text adress to d2
                move.L  #(text1end-text1),d3    ; text length to d3
                jsr     Write(a6)               ; call dos write routine

*************** Get text from keyboard ****************************************

                jsr     input(a6)               ; get input handle
                move.L  d0,d1                   ; save handle in d1
                move.l  #buffer,d2              ; input buffer start address
                move.L  #40,d3                  ; input buffer length
                jsr     Read(a6)                ; get input
                move.L  d0,d4                   ; store number of characters

*************** Output Text ***************************************************

                move.L  d5,d1                   ; Load Handle in d1
                move.L  #text2,d2               ; Address of text in memory
                move.L  #(text2end-text2),d3    ; Text length in d3
                jsr     Write(a6)               ; Call DOS Write

*************** Output text input buffer **************************************

                move.L  d5,d1                   ; Load Handle in d1
                move.L  #buffer,d2              ; buffer startaddress
                move.l  d4,d3                   ; text length to d3
                jsr     Write(a6)               ; call DOS Write

*************** Close Lib *****************************************************

                move.L  a6,a1                   ; DOS Lib Base Address
                move.L  ExecBase,a6             ; Set Exec Base
                jsr     CloseLib(a6)            ; Close DOS Lib

ende:           rts                

*************** Data Area *****************************************************

                data_f

dosname:        dc.b    "dos.library",0
                even
text1:          dc.b    "Please enter your text: "
text1end:       
                even
text2:          dc.b    "You wrote: "
text2end:       
                even
buffer:         ds.b    40                
