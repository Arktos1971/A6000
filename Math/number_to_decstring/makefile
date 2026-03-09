# This makefile does the following:
# 
# 1. Clean working directory
# 2. Assemble and link the project
# 3. Copy the TARGET file to an extern SDCARD
#
# I am working in a Windows environment therefore
# the need of the SHELL variable
#
# The copying process is a bit of a convoluted affair
# because I determine the destination drive not by a
# drive letter – which can change on removable media –
# but by the volume label. See variable SDCARD.
# This is more difficult under Windows than you might
# think, and the only working option seems to be PowerShell,
# which is what I'm using here!
#

TARGET      = number_to_decstring.exe
OBJECTS     = number_to_decstring.o
LIBS        = amiga
LIBDIR      = L:\Amiga\Lib
SDCARD 		= A6000

# Forces make to use the windows cmd
SHELL       = cmd.exe

all: clean $(TARGET) copy

$(TARGET) : $(OBJECTS)
	vlink -b amigahunk -L $(LIBDIR) -l $(LIBS) -o $(TARGET) $(OBJECTS)

number_to_decstring.o : number_to_decstring.s
	vasm -Fhunk -o number_to_decstring.o number_to_decstring.s

# The robust solution for CMD + PowerShell
copy: $(TARGET)
	@echo Searching for drive $(SDCARD) ...
	@for /f "usebackq delims=" %%d in (`powershell -NoProfile -Command "Get-Volume -FileSystemLabel '$(SDCARD)' | Select-Object -ExpandProperty DriveLetter"`) do @( \
		if not "%%d" == "" ( \
			echo Found drive: %%d: && \
			copy /y "$(TARGET)" "%%d:\" \
		) \
	)

clean:
	@if exist $(TARGET) del /q $(TARGET)
	@if exist $(OBJECTS) del /q $(OBJECTS)