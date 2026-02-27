Sections:
00: "CODE_F" (0-38)
01: "DATA_F" (0-C)


Source: "echoclone.s"
                            	     1: **
                            	     2: ** Date: 23.02.2026
                            	     3: **
                            	     4: ** Book: Amiga Assembler von Null auf Hundert (German)
                            	     5: ** Page: 74
                            	     6: **
                            	     7: ** Description: prints the command line parameter
                            	     8: **
                            	     9: **
                            	    10:                 opt d+                          ; export with symbols
                            	    11:                 
                            	    12:                 machine 68080					; treat this source as 68080 code.
                            	    13: 
                            	    14:                 output	echoclone.exe
                            	    15: 
                            	    16: ExecBase        equ 4
                            	    17: OpenLib         equ -552
                            	    18: CloseLib        equ -414
                            	    19: Output          equ -60
                            	    20: Write           equ -48
                            	    21: 
                            	    22:                 code_f
                            	    23: 
                            	    24: *************** Save registers to stack **************************************************
                            	    25: 
00:00000000 48E78080        	    26:                 movem.L a0/d0,-(sp)             ; Save commandline
                            	    27: 
                            	    28: *************** Open DOS-Lib **************************************************
                            	    29: 
00:00000004 2C780004        	    30:                 move.L  ExecBase,a6             ; Exec-Lib Base
00:00000008 43F900000000    	    31:                 lea     dosname,a1              ; DOS-Lib Name
00:0000000E 7000            	    32:                 clr.L   d0                      ; Version doesn't matter
00:00000010 4EAEFDD8        	    33:                 jsr     OpenLib(a6)             ; Open Lib
00:00000014 4A80            	    34:                 tst.L   d0                      ; Error opening?
00:00000016 671E            	    35:                 beq     ende                    ; yes then quit
00:00000018 2C40            	    36:                 move.L  d0,a6                   ; Save dosbase in a6
                            	    37: 
                            	    38: *************** Get Output-Handle for the CLI Window **************************
                            	    39: 
00:0000001A 4EAEFFC4        	    40:                 jsr     Output(a6)              ; Get Output-Handle
00:0000001E 2200            	    41:                 move.L  d0,d1                   ; Save Handle in d1
                            	    42: 
                            	    43: *************** Get Registers back ********************************************
                            	    44: 
00:00000020 4CDF0101        	    45:                 movem.L (sp)+,a0/d0             ; Restore Commandline
                            	    46: 
                            	    47: *************** Write text to CLI *********************************************
                            	    48: 
                            	    49:                                                 ; Handle is allready in d1
00:00000024 2408            	    50:                 move.L  a0,d2                   ; text address into d2
00:00000026 2600            	    51:                 move.l  d0,d3                   ; text length into d3
00:00000028 4EAEFFD0        	    52:                 jsr     Write(a6)
                            	    53: 
                            	    54: *************** Close Library *************************************************
                            	    55: 
00:0000002C 224E            	    56:                 move.L  a6,a1
00:0000002E 2C780004        	    57:                 move.l  ExecBase,a6
00:00000032 4EAEFE62        	    58:                 jsr     CloseLib(a6)
                            	    59: 
00:00000036 4E75            	    60: ende:           rts
                            	    61: 
                            	    62: *************** Data Area *****************************************************
                            	    63: 
                            	    64:                 data_f
                            	    65: 
01:00000000 646F732E6C696272	    66: dosname:        dc.b    "dos.library",0
01:00000008 617279
01:0000000B 00
                            	    67:                 even
                            	    68: 


Symbols by name:
CloseLib                         E:FFFFFE62
ExecBase                         E:00000004
OpenLib                          E:FFFFFDD8
Output                           E:FFFFFFC4
Write                            E:FFFFFFD0
dosname                         01:00000000
ende                            00:00000036

Symbols by value:
00000000 dosname
00000004 ExecBase
00000036 ende
FFFFFDD8 OpenLib
FFFFFE62 CloseLib
FFFFFFC4 Output
FFFFFFD0 Write
