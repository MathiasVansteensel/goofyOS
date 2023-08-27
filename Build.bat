@echo off

set NASM_PATH=C:\Users\Mathias\AppData\Local\bin\NASM\nasm.exe
set BOOT_ASSEMBLY_FILE=Bootloader\Boot.asm
set KERNEL_ASSEMBLY_FILE=Kernel\Kernel.asm
set BIN_ASSEMBLED_FOLDER=Bin\Assembled
set OUT_FOLDER=Bin
set BOOT_BIN=%BIN_ASSEMBLED_FOLDER%\Boot.img
set KERNEL_FOLDER=Kernel
set KERNEL_BIN=%BIN_ASSEMBLED_FOLDER%\kernel.bin
set ISO_FILE=%OUT_FOLDER%\Boot.iso
set TOOLS_FOLDER=Tools
set MKISOFS_PATH=%TOOLS_FOLDER%\mkisofs.exe
set TMP_FOLDER=%OUT_FOLDER%\tmp
set TMP_BOOT_ASM=%TMP_FOLDER%\temp_boot.asm

rem Create the output folders if they don't exist
if not exist "%OUT_FOLDER%" mkdir "%OUT_FOLDER%"
if not exist "%BIN_ASSEMBLED_FOLDER%" mkdir "%BIN_ASSEMBLED_FOLDER%"
if not exist "%TMP_FOLDER%" mkdir "%TMP_FOLDER%"

rem Assemble boot image
CALL :AssembleBootImg

rem Assemble kernel
CALL :AssembleKernel

rem Convert the binary image and the kernel to a bootable ISO using mkisofs
"%MKISOFS_PATH%" -o "%ISO_FILE%" -b "Boot.img" -no-emul-boot -boot-load-size 4 -boot-info-table "%BIN_ASSEMBLED_FOLDER%" "%BOOT_BIN%" "%KERNEL_BIN%"

echo ISO file created: %ISO_FILE%

echo DONE!
EXIT /B 0

:AssembleBootImg

del "%TMP_BOOT_ASM%"

rem Make tmp kernel file and add kernel offset footer
copy /b "%BOOT_ASSEMBLY_FILE%" "%TMP_BOOT_ASM%" > nul
echo KERNEL_OFFSET equ 0x6969 >> "%TMP_BOOT_ASM%"

rem Assemble the boot image
"%NASM_PATH%" -f bin "%TMP_BOOT_ASM%" -o "%BOOT_BIN%"

del "%TMP_BOOT_ASM%"

rem Get the size of the output file
for %%F in ("%BOOT_BIN%") do set FILE_SIZE=%%~zF

rem Calculate the padding size to align to the next 2048 bytes (ISO standard)
set /a PADDING_SIZE=(2048 - (%FILE_SIZE% %% 2048)) %% 2048

rem Create a padding file with zeros
(for /L %%N in (1,1,%PADDING_SIZE%) do @echo() > "%BIN_ASSEMBLED_FOLDER%\padding.tmp"

rem Concatenate the padding file to the output file
copy /b "%BOOT_BIN%" + "%BIN_ASSEMBLED_FOLDER%\padding.tmp" "%BOOT_BIN%" > nul

rem Delete the padding file
del "%BIN_ASSEMBLED_FOLDER%\padding.tmp"

for %%F in ("%BOOT_BIN%") do set FILE_SIZE=%%~zF
for /f %%a in ('echo %FILE_SIZE% ^| powershell -command "[System.Convert]::ToString(%FILE_SIZE%, 16)"') do set ADDRESS=0x%%a

set /A KERNEL_OFFSET=0x7c00 + %FILE_SIZE%

for /f %%a in ('echo %KERNEL_OFFSET% ^| powershell -command "[System.Convert]::ToString(%KERNEL_OFFSET%, 16)"') do set KERNEL_OFFSET=0x%%a

rem Make tmp kernel file and add kernel offset footer
copy /b "%BOOT_ASSEMBLY_FILE%" "%TMP_BOOT_ASM%" > nul
echo KERNEL_OFFSET equ %FILE_SIZE% >> "%TMP_BOOT_ASM%"

rem Make tmp kernel file and add kernel offset footer
copy /b "%BOOT_ASSEMBLY_FILE%" "%TMP_BOOT_ASM%" > nul



echo KERNEL_OFFSET equ %ADDRESS% >> "%TMP_BOOT_ASM%"

rem Assemble the boot image
"%NASM_PATH%" -f bin "%TMP_BOOT_ASM%" -o "%BOOT_BIN%"

copy /b "%BOOT_ASSEMBLY_FILE%" "%TMP_BOOT_ASM%" > nul
echo KERNEL_OFFSET equ %FILE_SIZE% >> "%TMP_BOOT_ASM%"

echo Boot image padded. (size=%FILE_SIZE%bytes)

EXIT /B 0

:AssembleKernel
rem Assemble the kernel
"%NASM_PATH%" -f bin "%KERNEL_ASSEMBLY_FILE%" -o "%KERNEL_BIN%"
for %%F in ("%KERNEL_BIN%") do set FILE_SIZE=%%~zF

echo "Assembled kernel (size=%FILE_SIZE% | offset in RAM=%KERNEL_OFFSET%)"

EXIT /B 0