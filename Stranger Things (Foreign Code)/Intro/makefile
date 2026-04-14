# This makefile does the following:
# 
# 1. Clean working directory
# 2. Assemble and link the project
# 3. Copy the TARGET file to an extern SDCARD
# 4. Copy the TARGET file to a local HARDDISK path
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

TARGET      = coppervect.exe
OBJECTS     = coppervect.o
#LIB         = amiga
#LIBDIR      = L:\Amiga\Lib
SDCARD      = A6000
HARDDISK    = D:\Emulation\Files\Computers\Amiga\Hard Disks\DATA

# Forces make to use the windows cmd
SHELL       = cmd.exe

all: clean $(TARGET) copy copylocal

$(TARGET) : $(OBJECTS)
	vlink -b amigahunk -o $(TARGET) $(OBJECTS)

coppervect.o : coppervect.s
	vasm -Fhunk -o coppervect.o coppervect.s

copy: $(TARGET)
	@echo Searching for drive "$(SDCARD)" ...
	@powershell -NoProfile -Command "\
		$$drive = Get-Volume -FileSystemLabel '$(SDCARD)' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DriveLetter; \
		if (-not $$drive) { \
			Write-Host '-----------------------------------------' -ForegroundColor Red; \
			Write-Host 'ERROR: Drive with label \"$(SDCARD)\" not found!'; \
			Write-Host 'Please insert the SD card and try again.'; \
			Write-Host '-----------------------------------------' -ForegroundColor Red; \
			exit 1; \
		} \
		Write-Host \"Found drive: $${drive}:\" -ForegroundColor Green; \
		Copy-Item -Path '$(TARGET)' -Destination \"$${drive}:\\\" -Force; \
		Write-Host 'Copy successful!' -ForegroundColor Green"

copylocal: $(TARGET)
	@echo Copying $(TARGET) to $(HARDDISK) ...
	@powershell -NoProfile -Command "\
		if (-not (Test-Path -Path '$(HARDDISK)')) { \
			Write-Host '-----------------------------------------' -ForegroundColor Red; \
			Write-Host 'ERROR: Path \"$(HARDDISK)\" not found!'; \
			Write-Host 'Please check the HARDDISK variable.'; \
			Write-Host '-----------------------------------------' -ForegroundColor Red; \
			exit 1; \
		} \
		Copy-Item -Path '$(TARGET)' -Destination '$(HARDDISK)\$(TARGET)' -Force; \
		Write-Host 'Copy to $(HARDDISK) successful!' -ForegroundColor Green"

clean:
	@if exist $(TARGET) del /q $(TARGET)
	@if exist $(OBJECTS) del /q $(OBJECTS)