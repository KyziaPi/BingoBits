; bingobits.asm
;
; FINAL
; nasm -f elf32 bingobits.asm -o bingobits.o
; nasm -f elf32 card_generator.asm -o card_generator.o
; nasm -f elf32 number_caller.asm -o number_caller.o
; nasm -f elf32 card_marker.asm -o card_marker.o
;
; gcc -m32 -no-pie bingobits.o bingo_card.o number_caller.o card_marker.asm -o bingobits
; ./bingobits
;
; TEMPORARY
; nasm -f elf32 bingobits.asm -o bingobits.o;
; assemble:
; nasm -f elf32 bingobits.asm -o bingobits.o
; link:
; gcc -m32 -no-pie bingobits.o -o bingobits
; run:
; ./bingobits
;

section .data
    newline         db 10, 0
    intro           db "Welcome to BingoBits!", 10, "Type 'help' to learn how to play", 10, 0
    commands        db "Commands:", 10, "'help' - shows commands to play the game", 10, "'new' - generate a new board", 10, "'card' - display current card without marks", 10, "'marked' - display the card with marks", 10, "'call' - call a number", 10, "'called' - display all called numbers", 10, "'mark' - mark the board", 10, "'BINGO' - check if you won", 10, "'exit' - quit the game (progress won't be saved)", 10, 0
    new_card_msg    db "A new BINGO card has been generated!", 10, 0
    cmd_start       db "> ", 0
    invalid_msg     db "Invalid command! Type 'help' to see all the commands available.", 10, 0
    exit_msg        db "Thank you for playing! ^-^", 10, 0

    str_help        db "help", 0
    str_new         db "new", 0
    str_card        db "card", 0
    str_call        db "call", 0
    str_called      db "called", 0
    str_mark        db "mark", 0
    str_marked      db "marked", 0
    str_bingo       db "BINGO", 0
    str_exit        db "exit", 0

    fmt_str         db "%19s", 0
    fmt_int         db "%1d %1d", 0

    in_progress     db "This feature hasn't been implemented yet ^-^", 10, 0

section .bss
    input               resb 20
    confirm             resb 2
    mark_coordinates    resb 4

section .text
    global main
    extern printf, scanf

main:
    ; Print intro
    push dword intro
    call printf
    add esp, 4

;---------------
; MAIN LOOP
;---------------
input_loop:
    ; Print command mark
    push dword cmd_start
    call printf
    add esp, 4

    ; Scan user input
    push dword input
    push dword fmt_str
    call scanf
    add esp, 8

    ; compare input to 'help'
    mov esi, input
    mov edi, str_help
    call str_cmp
    cmp eax, 0
    je cmd_help

    ; compare input to 'new'
    mov esi, input
    mov edi, str_new
    call str_cmp
    cmp eax, 0
    je cmd_new

    ; compare input to 'card'
    mov esi, input
    mov edi, str_card
    call str_cmp
    cmp eax, 0
    je cmd_card

    ; compare input to 'call'
    mov esi, input
    mov edi, str_call
    call str_cmp
    cmp eax, 0
    je cmd_call

    ; compare input to 'called'
    mov esi, input
    mov edi, str_called
    call str_cmp
    cmp eax, 0
    je cmd_called

    ; compare input to 'mark'
    mov esi, input
    mov edi, str_mark
    call str_cmp
    cmp eax, 0
    je cmd_mark

    ; compare input to 'marked'
    mov esi, input
    mov edi, str_marked
    call str_cmp
    cmp eax, 0
    je cmd_marked

    ; compare input to 'BINGO'
    mov esi, input
    mov edi, str_bingo
    call str_cmp
    cmp eax, 0
    je cmd_bingo

    ; compare input to 'exit'
    mov esi, input
    mov edi, str_exit
    call str_cmp
    cmp eax, 0
    je exit

    ; invalid command
    push dword invalid_msg
    call printf
    add esp, 4
    jmp input_loop

;----------------------
; COMMAND HANDLERS
;---------------------- 
cmd_help:
    ; print commands
    push dword commands
    call printf
    add esp, 4
    jmp input_loop

cmd_new:
    ; TODO
    push dword in_progress
    call printf
    add esp, 4
    jmp input_loop

cmd_card:
    ; TODO
    push dword in_progress
    call printf
    add esp, 4
    jmp input_loop

cmd_call:
    ; TODO
    push dword in_progress
    call printf
    add esp, 4
    jmp input_loop

cmd_called:
    ; TODO
    push dword in_progress
    call printf
    add esp, 4
    jmp input_loop

cmd_mark:
    ; TODO
    push dword in_progress
    call printf
    add esp, 4
    jmp input_loop

cmd_marked:
    ; TODO
    push dword in_progress
    call printf
    add esp, 4
    jmp input_loop

cmd_bingo:
    ; TODO
    push dword in_progress
    call printf
    add esp, 4
    jmp input_loop

exit:
    push dword exit_msg
    call printf
    add esp, 4

    mov eax, 0
    ret

;----------------------------------------------------
; str_cmp: compares strings at [esi] and [edi]
; return: EAX = 0 if equal, EAX = 1 if not equal
;----------------------------------------------------

str_cmp:
    xor eax, eax            ; clear EAX

.next_char:
    mov al, [esi]           ; load byte from input
    mov bl, [edi]           ; load byte from target
    cmp al, bl
    jne .not_equal
    cmp al, 0
    je .equal               ; both equal to 0 (null-terminator)
    inc esi
    inc edi
    jmp .next_char

.not_equal:
    mov eax, 1
    ret 

.equal:
    xor eax, eax
    ret

section .note.GNU-stack noalloc noexec nowrite progbits