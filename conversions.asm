; conversions.asm – Helper file for data type conversions
; exposes itoa and atoi
;
; Works under Linux / WSL (64-bit)

section .text

global itoa
global atoi
extern result        ; result buffer declared in main file

; ============================================================
; Integer to ASCII Conversion (itoa)
; ------------------------------------------------------------
; input : integer in RAX
; output: pointer to ASCII string in RAX
; ============================================================
itoa:
    mov rsi, result
    mov rcx, 10
    add rsi, 20              ; Allow space for up to 19 digits + sign + LF + NULL
    mov byte [rsi], 0        ; Null terminator
    dec rsi
    mov byte [rsi], 10       ; Newline
    dec rsi
    
    xor rdx, rdx             ; Clear remainder
    mov rbx, 0               ; Sign flag = 0
    cmp rax, 0
    jge .convert
    neg rax
    mov rbx, 1               ; Set sign flag if negative

.convert:
    mov rcx, 10
.itoa_loop:
    xor rdx, rdx
    div rcx                  ; RAX ÷ 10 → quotient in RAX, remainder in RDX
    add dl, '0'              ; Convert remainder to ASCII
    mov [rsi], dl
    dec rsi
    test rax, rax
    jnz .itoa_loop
    inc rsi
    cmp rbx, 1
    jne .done
    dec rsi
    mov byte [rsi], '-'

.done:
    mov rax, rsi             ; Return pointer to start of string
    ret

; ============================================================
; ASCII to Integer Conversion (atoi)
; ------------------------------------------------------------
; input : pointer to ASCII string in RSI
; output: integer in RAX
; ============================================================
atoi:
    xor rax, rax             ; Clear accumulator
    xor rcx, rcx             ; Sign flag (0=+, 1=-)
    xor rdx, rdx

; Skip leading whitespace
.skip_ws:
    mov dl, [rsi]
    cmp dl, ' '
    je .next_ws
    cmp dl, 9                ; tab
    jne .check_sign

.next_ws:
    inc rsi
    jmp .skip_ws

.check_sign:
    mov dl, [rsi]
    cmp dl, '-'
    jne .maybe_plus
    mov rcx, 1               ; negative flag set
    inc rsi
    jmp .parse

.maybe_plus:
    cmp dl, '+'
    jne .parse
    inc rsi

.parse:
    mov dl, [rsi]
    cmp dl, 10               ; newline?
    je .done
    test dl, dl              ; null?
    je .done
    cmp dl, '0'              ; not a digit
    jb .done
    cmp dl, '9'              ; not a digit
    ja .done
    
    sub dl, '0'              ; convert ASCII -> digit
    imul rax, rax, 10
    add rax, rdx
    inc rsi
    jmp .parse

.done:
    test rcx, rcx
    jz .return
    neg rax                  ; Apply negative sign if flag was set

.return:
    ret
