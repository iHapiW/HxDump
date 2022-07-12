section .data
    HexStrFormat: db  " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 |                 ", 10 ; Format of Empty HexStr
    HEXLEN equ $-HexStrFormat                       ; Length of HexStrFormat
    Digits: db "0123456789abcdef"                   ; Hexadecimal Digits Table
    BUFFLEN equ 0x10                                ; Buffer Length (Based on HexStr)

section .bss
    Buff: resb BUFFLEN  ;Stdin Buffer
    HexStr: resb HEXLEN ; Buffer to get formatted with HexStrFormat
    offset: resb 1

section .text
    global _start   ; Linker Needs it
    
_start:
        nop         ; Keeping GDB Happy...

; Construct offset between start of Hex Representation and start of ASCII Representation
        mov al, BUFFLEN ; Load Buffer Length into al
        shl al, 1       ; Shift left once ( doubled )
        add al, BUFFLEN ; Add Buffer Length to it ( Tripled )
        add al, 3       ; Add 3 ( " | " characters )
        mov byte [ offset ], al ; Store in "offset" for future use

; Read from "stdin" into Buffer
Read:   mov eax, 3          ; sys_read
        mov ebx, 0          ; stdin
        mov ecx, Buff       ; bss buffer
        mov edx, BUFFLEN    ; Buffer Length
        int 0x80

; Redirect to "Done" if reached to EOF
        mov ebp, eax        ; Store Bytes count has been read in ebp
        cmp eax, 0          ; if eax == 0, we have reached EOF
        je Done             ; Jump done if reached EOF

; Copies HexStrFormat to HexStr
        xor ecx, ecx
mkStr:  mov al, byte [HexStrFormat+ecx]   ; Read from HexStrFormat
        mov byte [HexStr+ecx], al        ; Write into HexStr
        inc ecx                          ; Increment Counter
        cmp ecx, HEXLEN                  ; Compare with length
        jb  mkStr                        ; Jump if Below ( ecx < HEXLEN )

; Store Source and Destination in registers
        mov esi, Buff       ; Store address of Buff in esi
        mov edi, HexStr     ; Store address of HexStr in edi
        xor ecx, ecx        ; Clear Line String Pointer

; Scan the Buff into HexStr
Scan:   xor eax, eax        ; Clear eax ( for storing input )
        
        ; Calculate Hex Index from Counter
        mov edx, ecx        ; Copy Ecx
        shl edx, 1          ; shift 1 bit ( doubled )
        add edx, ecx        ; add with ecx ( tripled )

        ; Load Byte into registers
        mov al, byte [ esi + ecx ]  ; Put a byte from input buffer to AL
        mov ebx, eax                ; Duplicate input

        ; Make LSB Nybble of the Byte
        and al, 0xf                  ; Mask 0xF nybble into AL, to get only LSB nybble
        mov al, byte [Digits + eax]  ; Get Hexdigit of the LSB nybble from the table
        mov byte [edi + edx + 2], al ; Write back the LSB nybble into HexStr Format

        ; Make MSB Nybble of the Byte
        shr bl, 4                       ; Shift 4 nybble to right ( for getting MSB nybble in the LSB nybble )
        mov bl, byte [Digits + ebx]     ; Get hexdigit of the MSB nybble from the table
        mov byte [edi + edx + 1], bl    ; Write back the MSB nybble into HexStr Format

        ; Calculate Absolute Offset
        mov al, byte [ offset ]         ; Load offset into AL
        add al , cl                     ; Increase offset by cl ( counter )

        ; Get and Place ASCII Representation
        mov dl, byte [ esi + ecx ]      ; Get Byte from input Buffer

                ; Convert '\n' to ' ' for avoiding bad output
                cmp dl, 0x0A    ; compare dl with '\n'
                jne repr        ; if its not , go ahead and represent
                mov dl, 0x14    ; if it is, change it to 0x14 ( 20 ) ( " " ) ( Space character )

repr:   mov byte [ edi + eax ], dl ; Place the byte into the ASCII Representation

; Do Until there is nothing to scan
        inc ecx             ; Increase Line string pointer
        cmp ecx, ebp        ; Compare to number of characters has been read into buffer
        jb Scan             ; Jump if not Above ( ecx <= ebp )

; Write line into Stdout
        mov eax, 4      ; sys_write
        mov ebx, 1      ; stdout
        mov ecx, HexStr ; formatted HexStr
        mov edx, HEXLEN ; hex length
        int 0x80        ; sys_cal

        jmp Read        ; jump back to read

; Exit
Done:   mov eax, 1      ; sys_exit
        mov ebx, 0      ; return code 0
        int 0x80        ; sys_call
