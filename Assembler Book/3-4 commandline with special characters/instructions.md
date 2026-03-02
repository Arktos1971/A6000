Assemble Instructions:

Step 1 - Assemble to object code:

vasm -Fhunk -o echoclone2.o echoclone2.s

-F format -> amiga hunk
-o Object code output
and source file (.s)



Step 2 link against amiga.lib to executable:

vlink -b amigahunk -L path_to_lib_directory -l amiga -o echoclone2.exe echoclone2.o

-b output format
-L Lib directory
-l lib to link -> amiga (.lib)
-o Executable output
and object (.o) files
