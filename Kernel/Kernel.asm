org 0x7c00
bits 16             ; Set the code generation mode to 16-bit

section .text
    global _start   ; Entry point for the kernel

_start:
    ; Set up video mode
    mov ah, 0x0       ; BIOS function to set video mode
    mov al, 0x03      ; Video mode: 80x25 text mode
    int 0x10          ; Call BIOS interrupt

    ; Print "Hello Kernel" to the screen
    mov ah, 0x0E      ; BIOS function to print a character
    mov al, 'H'       ; Character to print
    int 0x10          ; Call BIOS interrupt
    mov al, 'e'
    int 0x10
    mov al, 'l'
    int 0x10
    int 0x10
    mov al, 'o'
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 'K'
    int 0x10
    mov al, 'e'
    int 0x10
    mov al, 'r'
    int 0x10
    mov al, 'n'
    int 0x10
    mov al, 'e'
    int 0x10
    mov al, 'l'
    int 0x10

    hlt
    ; Infinite loop
    jmp $