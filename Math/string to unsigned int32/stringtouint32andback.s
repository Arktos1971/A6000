**
** Date: 27.02.2026
**
** Description: converts entered decimal integer to uint32
**              adds 111 and output the result        
**
                opt d+                          ; export with symbols
                
                machine ac68080					; treat this source as 68080 code.

                output	math-example-1.exe

                
ExecBase        equ 4
OpenLib         equ -552
CloseLib        equ -414
Write           equ -48
Read            equ -42
Output          equ -60
Input           equ -54

                code_f

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

*************** Display prompt text *******************************************

                move.L  d5,d1                   ; Output handle to d1
                move.L  #text1,d2               ; text adress to d2
                move.L  #(text1end-text1),d3    ; text length to d3
                jsr     Write(a6)               ; call dos write routine

*************** Get text from keyboard ****************************************

                jsr     Input(a6)               ; get input handle
                move.L  d0,d1                   ; save handle in d1
                move.l  #buffer,d2              ; input buffer start address
                move.L  #40,d3                  ; input buffer length
                jsr     Read(a6)                ; get input
                move.L  d0,d4                   ; store number of characters

*************** convert input to uint32 ***************************************

                move.L  d2,a0                   ; buffer start adress
                bsr     stringToUint32          ; convert input to uint32
                move.L  d0,number               ; store result

*************** add 111 to number *********************************************

                ;addi.w  #111,d0                 ; add 111
                addi.w  #111,number

*************** convert back to string ****************************************

                move.L  number,d0               ; load number
                lea     result,a0               ; result address
                bsr     uint32ToString          ; convert

*************** Output Text ***************************************************

                move.L  d5,d1                   ; Load Handle in d1
                move.L  #text2,d2               ; Address of text in memory
                move.L  #(text2end-text2),d3    ; Text length in d3
                jsr     Write(a6)               ; Call DOS Write

*************** Output text input buffer **************************************

                move.L  d5,d1                   ; Load Handle in d1
                move.L  a0,d2              ; buffer startaddress
                move.l  d4,d3                   ; text length to d3
                jsr     Write(a6)               ; call DOS Write

*************** Close Lib *****************************************************

                move.L  a6,a1                   ; DOS Lib Base Address
                move.L  ExecBase,a6             ; Set Exec Base
                jsr     CloseLib(a6)            ; Close DOS Lib

exit:           rts


*************** convert string to uint32 **************************************
**
** -> a0 = string address
** <- d0 = uint32 result

stringToUint32: movem.l d1-d2,-(sp)        ; save D1 and D2 to stack
                moveq   #0,d0              ; clear result

.loop           moveq   #0,d1
                move.b  (a0)+,d1            ; get next digit
                tst.b   d1                  ; end of string?
                beq.s   .exit               ; if \0, then finished

                sub.b   #"0",d1             ; subtract ASCII '0'
                blt.s   .exit               ; abort due to invalid character (< '0')
                cmp.b   #"9",d1
                bgt.s   .exit               ; abort due to invalid character (> '9')

                ; efficient multiplication with 10 without MULU (faster than MULU -> 68000)

                move.l  d0,d2               ; coyp d0 to d2
                lsl.l   #3,d0               ; D0 = D0 * 8
                lsl.l   #1,d2               ; D2 = D2 * 2
                add.l   d2,d0               ; D0 = (D0*8) + (D2*2) = D0 * 10
                
                add.l   d1,d0               ; add new digit
                bra.s   .loop               ; next character

.exit           movem.l (sp)+,d1-d2         ; restore D1 and D2 from stack
                rts

*************** convert uint32 to string **************************************
**
** -> d0 = number to convert
** -> a0 = result buffer address

uint32ToString: movem.l d0-d5,-(sp)         ; save registers
    
                ; we need 5 bytes for 10 BCD-Digits (2 Digits per byte)
                ; we use D1,D2,D3 as temporary BCD memory

                moveq   #0,d1               ; BCD Ziffern 9, 8
                moveq   #0,d2               ; BCD Ziffern 7, 6, 5, 4
                moveq   #0,d3               ; BCD Ziffern 3, 2, 1, 0
                moveq   #31,d4              ; Loop-Counter für 32 Bits

.shift_loop
                ; BCD correction (before shift)
                ; This part simulates the "Add 3 if > 4" rule for each nibble.
                ; In 68k, it is often more efficient to use ABCD for correction
                
                ; We shift the most significant bit of D0 into the "Extend" flag (X)

                lsl.l   #1,d0
    
                ; And insert it into our BCD register chain via ABCD.

                abcd    d3,d3               ; add D3 zu D3 + X-Flag (decimal!)
                abcd    d2,d2               ; Cascading through the registers
                abcd    d1,d1
    
                dbra    d4,.shift_loop

                ; The BCD values ​​are now in registers D1-D3. Example: $42 $94 $96 $72 $95
                ; Now we unpack the nibbles into the ASCII buffer.
                
                lea     temp_bcd,a1
                move.l  d1,(a1)             ; BCD in Speicher legen zum einfacheren Zugriff
                move.l  d2,4(a1)
                move.l  d3,8(a1)
    
                moveq   #4,d4               ; Processing 5 bytes
.unpack         move.b  (a1)+,d1            ; Get one byte (e.g. $42)
                move.b  d1,d2
                lsr.b   #4,d1               ; upper nibble (4)
                addi.b  #$30,d1             ; to ASCII '4'
                move.b  d1,(a0)+
                
                andi.b  #$0F,d2             ; lower nibble (2)
                addi.b  #$30,d2             ; to ASCII '2'
                move.b  d2,(a0)+
                
                dbra    d4,.unpack

                clr.b   (a0)                ; string-terminator
                movem.l (a7)+,d0-d5
                rts

*************** Data Area *****************************************************

                data_f

dosname:        dc.b    "dos.library",0
                even
text1:          dc.b    "Enter unsigned int32 number: "
text1end:       even
text2:          dc.b    "Your number and 111 added: "
text2end:       even

dosbase:        ds.L    1
clihandle:      ds.L    1

number:         ds.L    1

temp_bcd:       ds.b 12                     ; temporary bcd memory

buffer:         ds.b 20                     ; input string memory

result:         ds.b 20                     ; result string memory