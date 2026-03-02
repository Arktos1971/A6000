Assemble Instructions:

Step 1 - Assemble to object code:

vasm -Fhunk -o textinput.o textinput.s

-F format -> amiga hunk
-o Object code output
and source file (.s)



Step 2 link against amiga.lib to executable:

vlink -b amigahunk -L path_to_lib_directory -l amiga -o textinput.exe textinput.o

-b output format
-L Lib directory
-l lib to link -> amiga (.lib)
-o Executable output
and object (.o) files
