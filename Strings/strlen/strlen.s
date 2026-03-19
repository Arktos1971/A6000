*************** strlen - get string length ************************************
** -> a0 = string buffer start address
** <- d0 = string length

strlen:                 movem.L a0,-(sp)        ; save registers
                        moveq.L #0,d0           ; string length counter
loop:                   tst.b   (a0)+           ; test if character = 0
                        beq.s   done            ; yes -> string end
                        addq.l  #1,d0           ; add 1 to string lenhth counter
                        bra.s   loop            ; next character
done:                   movem.L (sp)+,a0        ; restore registers
                        rts                    
