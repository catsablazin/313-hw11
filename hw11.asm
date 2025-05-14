section .data
inputBuf:    db 0x5A, 0x6C, 0x0A, 0x1B, 0x2C, 0x3D, 0x4E, 0x5F
inputLen     equ $ - inputBuf   ; calculates num of bytes in input

section .bss
outputBuf:   resb 80            ; reserves space for ascii hex output

section .text
global _start

_start:
        mov esi, inputBuf       ; esi iterates through each input byte
        mov edi, outputBuf      ; edi writes ascii characters
        mov ecx, inputLen       ; number of bytes to process

convert_loop:
        cmp ecx, 0
        je add_newline          ; finalizes output

        lodsb                   ; loads byte from esi to al

        ; high nibble
        mov ah, al              ; saves byte
        shr ah, 4               ; moves high nibble to lower bits
        mov al, ah              ; high nibble placed in al for translation
        call nibble_to_ascii    ; converts ascii to hex
        stosb                   ; stores in output buffer

        ; low nibble
        mov al, byte [esi - 1]  ; reload original byte
        and al, 0x0F
        call nibble_to_ascii    ; converts low nibble ascii to hex
        stosb                   ; stores in output buffer

        ; adds space
        mov al, ' '
        stosb

        dec ecx                 ; moves to next byte in input
        jmp convert_loop

add_newline:
        ; adds new line at the end
        mov al, 0x0A
        stosb

        mov eax, 4              ; syscall
        mov ebx, 1              ; file descriptor
        mov ecx, outputBuf      ; pointer to buffer
        mov edx, edi            ; gets curr buffer
        sub edx, ecx            ; calculates lenght
        int 0x80

        ; exit
        mov eax, 1
        xor ebx, ebx
        int 0x80

        ;; translates ascii hex
nibble_to_ascii:
        cmp al, 9
        jbe .digit
        add al, 'A' - 10
        ret

.digit:
        add al, '0'
        ret
