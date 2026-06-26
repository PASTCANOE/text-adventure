; adventure_io.asm - Input/output helper routines
; Provides:
; print_string - print a null-terminated string
; read_line    - read a line from stdin, null-terminated
; compare_word - compare first word of input to a command
; find_second_word - locate the second word in a line

%define SYS_read 0
%define SYS_write 1

%define STDIN 0
%define STDOUT 1

section .text

global print_string
global read_line
global compare_word
global find_second_word

; -----------------------------------------------------------
; print_string
; Input:
;   rsi - pointer to null-terminated string
; Output:
;   prints the string to STDOUT
; Clobbers:
;   rax, rdi, rdx
; -----------------------------------------------------------
print_string:
    mov rdx, 0
.ps_len_loop:
    cmp byte [rsi + rdx], 0
    je .ps_len_done
    inc rdx
    jmp .ps_len_loop
.ps_len_done:
    mov rax, SYS_write
    mov rdi, STDOUT
    syscall
    ret

; -----------------------------------------------------------
; read_line
; Input:
;   rsi - pointer to buffer
;   rdx - maximum number of bytes to read
; Output:
;   buffer filled with input, followed by a null terminator.
; Notes:
;   - sys_read returns number of bytes in rax.
;   - We automatically strip the trailing newline character
; -----------------------------------------------------------
read_line:
    mov rax, SYS_read
    mov rdi, STDIN
    syscall
    
    ; rax = number of bytes read
    cmp rax, 0
    jle .rl_empty
    
    ; Strip newline if present at the end of input
    cmp byte [rsi + rax - 1], 10
    jne .rl_null_term
    dec rax

.rl_null_term:
    mov byte [rsi + rax], 0
    ret

.rl_empty:
    mov byte [rsi], 0
    ret

; -----------------------------------------------------------
; compare_word
; Compare the first word in an input buffer with a command word.
;
; Input:
;   rsi - pointer to input buffer (null-terminated line)
;   rdi - pointer to command string (null-terminated)
;
; Output:
;   rax = 1 if input's first word matches command exactly
;   rax = 0 otherwise
; -----------------------------------------------------------
compare_word:
    xor rax, rax

.cw_loop:
    mov bl, [rdi]
    mov dl, [rsi]
    cmp bl, 0
    je .cw_end_of_cmd
    
    ; command not finished yet; input must still have characters
    cmp dl, 0
    je .cw_no
    cmp dl, 10
    je .cw_no
    cmp dl, ' '
    je .cw_no
    
    ; characters must match
    cmp dl, bl
    jne .cw_no
    inc rdi
    inc rsi
    jmp .cw_loop

.cw_end_of_cmd:
    ; End of command string.
    ; Input must now be end, space, or newline.
    cmp dl, 0
    je .cw_yes
    cmp dl, 10
    je .cw_yes
    cmp dl, ' '
    je .cw_yes
    jmp .cw_no

.cw_yes:
    mov rax, 1
    ret

.cw_no:
    xor rax, rax
    ret

; -----------------------------------------------------------
; find_second_word
;
; Locate the second word in an input line.
;
; Input:
;   rsi - pointer to input buffer (null-terminated line)
;
; Output:
;   rax - pointer to start of second word, or
;         pointer to null/newline if no second word exists.
; -----------------------------------------------------------
find_second_word:
    ; Skip leading spaces
.fw_skip_spaces_start:
    mov dl, [rsi]
    cmp dl, ' '
    jne .fw_first_word
    inc rsi
    jmp .fw_skip_spaces_start

.fw_first_word:
    ; Skip first word characters until space/newline/0
    mov dl, [rsi]
    cmp dl, 0
    je .fw_no_second
    cmp dl, 10
    je .fw_no_second
    cmp dl, ' '
    je .fw_after_first
    inc rsi
    jmp .fw_first_word

.fw_after_first:
    ; Skip spaces after first word
    mov dl, [rsi]
    cmp dl, ' '
    jne .fw_second_start
    inc rsi
    jmp .fw_after_first

.fw_second_start:
    ; rsi now points at second word start, or at newline/0
    mov rax, rsi
    ret

.fw_no_second:
    ; No second word, return pointer to end
    mov rax, rsi
    ret
