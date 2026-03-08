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