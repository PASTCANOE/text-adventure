; adventure_main.asm - Tiny Adventure main engine (clean structure edition)
; Implements:
; - Room transitions
; - Commands: look, take, pet, answer, inventory, drop
; - Puzzle: answer 42 (uses atoi)
; - Locked door requiring the key
; - Victory when entering room 3

%define SYS_exit 60

section .bss
; conversions.asm requires this symbol
global result
result       resb 32
; Input line buffer
input_buffer resb 80

section .text
global _start

; -------------------------------------------------------
; External data (from adventure_data.asm)
; -------------------------------------------------------
extern current_room, has_key, puzzle_solved
extern room_desc_table
extern exits_north, exits_south, exits_east, exits_west
extern msg_welcome, msg_help, msg_unknown, msg_nogo
extern msg_locked, msg_goodbye, msg_victory
extern msg_take_key, msg_have_key, msg_take_key_locked
extern msg_inventory_empty, msg_inventory_key
extern msg_pet_cat, msg_take_cat_fail, msg_no_cat
extern msg_no_puzzle, msg_puzzle_wrong, msg_puzzle_solved
extern msg_answer_usage, msg_cant_take
extern prompt, newline
extern cmd_north, cmd_south, cmd_east, cmd_west
extern cmd_look, cmd_help, cmd_quit
extern cmd_take, cmd_inventory, cmd_pet, cmd_answer
extern cmd_key, cmd_cat

; New external strings for dropping feature
extern msg_drop_key, msg_drop_no_key, cmd_drop

; -------------------------------------------------------
; External helpers (adventure_io.asm)
; -------------------------------------------------------
extern print_string
extern read_line
extern compare_word
extern find_second_word
extern atoi   ; from conversions.asm

; -----------------------------------------------------------
; print_current_room
; -----------------------------------------------------------
print_current_room:
    lea rbx, [rel current_room]
    mov rax, [rbx]                ; rax = room index
    lea rcx, [rel room_desc_table]
    mov rbx, [rcx + rax*8]
    mov rsi, rbx
    call print_string
    ret

; -----------------------------------------------------------
; Movement helpers
; -----------------------------------------------------------
move_direction:
    lea rcx, [rel current_room]
    mov rax, [rcx]
    mov rbx, [rdi + rax*8]
    cmp rbx, -1
    je .no_exit
    mov [rcx], rbx
    ret

.no_exit:
    lea rsi, [rel msg_nogo]
    call print_string
    ret

check_victory:
    lea rbx, [rel current_room]
    mov rax, [rbx]
    cmp rax, 3
    jne .no_win
    lea rsi, [rel msg_victory]
    call print_string
    mov rax, SYS_exit
    xor rdi, rdi
    syscall

.no_win:
    ret

; -----------------------------------------------------------
; take key
; -----------------------------------------------------------
handle_take_key:
    lea rbx, [rel current_room]
    mov rax, [rbx]
    cmp rax, 1
    jne .wrong_place
    
    lea rcx, [rel has_key]
    mov rax, [rcx]
    cmp rax, 0
    jne .already_have
    
    lea rdx, [rel puzzle_solved]
    mov rax, [rdx]
    cmp rax, 0
    je .locked
    
    mov qword [rcx], 1
    lea rsi, [rel msg_take_key]
    call print_string
    ret

.locked:
    lea rsi, [rel msg_take_key_locked]
    call print_string
    ret

.already_have:
    lea rsi, [rel msg_have_key]
    call print_string
    ret

.wrong_place:
    lea rsi, [rel msg_cant_take]
    call print_string
    ret

; -----------------------------------------------------------
; drop key implementation
; -----------------------------------------------------------
handle_drop_key:
    lea rbx, [rel has_key]
    mov rax, [rbx]
    cmp rax, 0
    je .no_key_to_drop
    
    ; Clear inventory value back to 0
    mov qword [rbx], 0
    
    lea rsi, [rel msg_drop_key]
    call print_string
    ret

.no_key_to_drop:
    lea rsi, [rel msg_drop_no_key]
    call print_string
    ret

; -----------------------------------------------------------
; pet cat
; -----------------------------------------------------------
handle_pet:
    lea rbx, [rel current_room]
    mov rax, [rbx]
    cmp rax, 1
    jne .no_cat_here
    
    lea rsi, [rel input_buffer]
    call find_second_word
    mov rsi, rax
    lea rdi, [rel cmd_cat]
    call compare_word
    cmp rax, 1
    jne .no_cat_here
    lea rsi, [rel msg_pet_cat]
    call print_string
    ret

.no_cat_here:
    lea rsi, [rel msg_no_cat]
    call print_string
    ret

; -----------------------------------------------------------
; take cat
; -----------------------------------------------------------
handle_take_cat:
    lea rsi, [rel msg_take_cat_fail]
    call print_string
    ret

; -----------------------------------------------------------
; inventory
; -----------------------------------------------------------
do_inventory:
    lea rbx, [rel has_key]
    mov rax, [rbx]
    cmp rax, 0
    je .empty
    lea rsi, [rel msg_inventory_key]
    call print_string
    ret

.empty:
    lea rsi, [rel msg_inventory_empty]
    call print_string
    ret

; -----------------------------------------------------------
; answer <number> (puzzle)
; -----------------------------------------------------------
handle_answer:
    lea rbx, [rel current_room]
    mov rax, [rbx]
    cmp rax, 1
    jne .no_puzzle_here
    
    lea rsi, [rel input_buffer]
    call find_second_word
    mov rsi, rax
    mov dl, [rsi]
    cmp dl, 0
    je .usage
    cmp dl, 10
    je .usage
    
    call atoi                     ; rax = integer
    cmp rax, 42
    jne .wrong
    
    lea rcx, [rel puzzle_solved]
    mov qword [rcx], 1
    lea rsi, [rel msg_puzzle_solved]
    call print_string
    ret

.wrong:
    lea rsi, [rel msg_puzzle_wrong]
    call print_string
    ret

.usage:
    lea rsi, [rel msg_answer_usage]
    call print_string
    ret

.no_puzzle_here:
    lea rsi, [rel msg_no_puzzle]
    call print_string
    ret

; -----------------------------------------------------------
; main entry point
; -----------------------------------------------------------
_start:
    lea rsi, [rel msg_welcome]
    call print_string
    call print_current_room

read_command:
    lea rsi, [rel prompt]
    call print_string
    
    lea rsi, [rel input_buffer]
    mov rdx, 80
    call read_line

        ; ------------------------------------------------------
    ; COMMAND DISPATCH (Fixed Routing Order)
    ; ------------------------------------------------------
    ; quit
    lea rdi, [rel cmd_quit]
    lea rsi, [rel input_buffer]
    call compare_word
    cmp rax, 1
    je .do_quit

    ; help
    lea rdi, [rel cmd_help]
    lea rsi, [rel input_buffer]
    call compare_word
    cmp rax, 1
    je .do_help

    ; inventory
    lea rdi, [rel cmd_inventory]
    lea rsi, [rel input_buffer]
    call compare_word
    cmp rax, 1
    je .do_inventory_cmd

    ; look → print room
    lea rdi, [rel cmd_look]
    lea rsi, [rel input_buffer]
    call compare_word
    cmp rax, 1
    je .do_look

    ; answer
    lea rdi, [rel cmd_answer]
    lea rsi, [rel input_buffer]
    call compare_word
    cmp rax, 1
    je .do_answer_cmd

    ; pet
    lea rdi, [rel cmd_pet]
    lea rsi, [rel input_buffer]
    call compare_word
    cmp rax, 1
    je .do_pet_cmd

    ; north
    lea rdi, [rel cmd_north]
    lea rsi, [rel input_buffer]
    call compare_word
    cmp rax, 1
    je .mv_north

    ; south
    lea rdi, [rel cmd_south]
    lea rsi, [rel input_buffer]
    call compare_word
    cmp rax, 1
    je .mv_south

    ; east
    lea rdi, [rel cmd_east]
    lea rsi, [rel input_buffer]
    call compare_word
    cmp rax, 1
    je .mv_east

    ; west
    lea rdi, [rel cmd_west]
    lea rsi, [rel input_buffer]
    call compare_word
    cmp rax, 1
    je .mv_west

    ; drop
    lea rdi, [rel cmd_drop]
    lea rsi, [rel input_buffer]
    call compare_word
    cmp rax, 1
    je .handle_drop_routing

    ; take
    lea rdi, [rel cmd_take]
    lea rsi, [rel input_buffer]
    call compare_word
    cmp rax, 1
    je .do_take_cmd

    ; unknown instruction (if it matches nothing else)
    lea rsi, [rel msg_unknown]
    call print_string
    jmp after_action

.handle_drop_routing:
    ; Identify what they want to drop
    lea rsi, [rel input_buffer]
    call find_second_word
    mov rsi, rax
    lea rdi, [rel cmd_key]
    call compare_word
    cmp rax, 1
    je .do_drop_key
    
    lea rsi, [rel msg_unknown]
    call print_string
    jmp after_action

.do_drop_key:
    call handle_drop_key
    jmp after_action

; -----------------------------------------------------------
; COMMAND HANDLERS
; -----------------------------------------------------------
.do_help:
    lea rsi, [rel msg_help]
    call print_string
    jmp after_action

.do_inventory_cmd:
    call do_inventory
    jmp after_action

.do_answer_cmd:
    call handle_answer
    jmp after_action

.do_pet_cmd:
    call handle_pet
    jmp after_action

.do_take_cmd:
    lea rsi, [rel input_buffer]
    call find_second_word
    mov rbx, rax                 ; save second word pointer
    
    ; take key?
    lea rdi, [rel cmd_key]
    mov rsi, rbx
    call compare_word
    cmp rax, 1
    je .take_key
    
    ; take cat?
    lea rdi, [rel cmd_cat]
    mov rsi, rbx
    call compare_word
    cmp rax, 1
    je .take_cat
    
    ; fallback
    lea rsi, [rel msg_cant_take]
    call print_string
    jmp after_action

.take_key:
    call handle_take_key
    jmp after_action

.take_cat:
    call handle_take_cat
    jmp after_action

.do_look:
    call print_current_room
    jmp after_action

; -----------------------------------------------------------
; MOVEMENT
; -----------------------------------------------------------
.mv_north:
    lea rdi, [rel exits_north]
    call move_direction
    call check_victory
    call print_current_room
    jmp after_action

.mv_south:
    lea rdi, [rel exits_south]
    call move_direction
    call check_victory
    call print_current_room
    jmp after_action

.mv_east:
    ; special lock on east from room 1
    lea rbx, [rel current_room]
    mov rax, [rbx]
    cmp rax, 1
    jne .mv_east_normal
    
    ; must have key
    lea rcx, [rel has_key]
    mov rdx, [rcx]
    cmp rdx, 0
    je .door_locked

.mv_east_normal:
    lea rdi, [rel exits_east]
    call move_direction
    call check_victory
    call print_current_room
    jmp after_action
.door_locked:
    lea rsi, [rel msg_locked]
    call print_string
    jmp after_action

.mv_west:
    lea rdi, [rel exits_west]
    call move_direction
    call check_victory
    call print_current_room
    jmp after_action

; -----------------------------------------------------------
; QUIT
; -----------------------------------------------------------
.do_quit:
    lea rsi, [rel msg_goodbye]
    call print_string
    mov rax, SYS_exit
    xor rdi, rdi
    syscall

; -----------------------------------------------------------
; AFTER ACTION
; -----------------------------------------------------------
after_action:
    jmp read_command

