org 0x7c00
bits 16

section .text
    global _start

_start:
    ; Print message
    mov ah, 0x0E
    mov al, 'H'
    mov bh, 0x00
    mov bl, 0x07
    int 0x10

    ; Display VGA bitmap (placeholder code)
    ; You would normally set up VGA mode and display pixel data here
    
    ; Load another bin file from the boot device
    mov ah, 0x02        ; BIOS function: Read Sectors From Drive
    mov al, 1           ; Number of sectors to read
    mov ch, 0           ; Cylinder number
    mov cl, 2           ; Sector number (adjust as needed)
    mov dh, 0           ; Head number
    mov dl, 0x80        ; Boot device (0x80 for the first hard disk)
    mov bx, 0x8000      ; Load address (adjust as needed)
    int 0x13

    jmp $               ; Endless loop

times 510 - ($ - $$) db 0
dw 0xAA55
