; bingobits.asm
;
; FINAL (fully connected version)
; nasm -f elf32 bingobits.asm -o bingobits.o
; nasm -f elf32 card_generator.asm -o card_generator.o
; nasm -f elf32 number_caller.asm -o number_caller.o
; nasm -f elf32 card_marker.asm -o card_marker.o
;
; gcc -m32 -no-pie bingobits.o card_generator.o number_caller.o card_marker.o -o bingobits
; ./bingobits
;

section .data
    newline             db 10, 0
    intro               db "Welcome to BingoBits!", 10, "Type 'help' to learn how to play", 10, 0
    commands            db "Commands:", 10, "'help' - shows commands to play the game", 10, \
    "'new' - generate a new board", 10, "'card' - display current card without marks", 10, \
    "'marked' - display the card with marks", 10, "'call' - call a number", 10, "'called' - display all called numbers", 10, \
    "'mark' - mark the board", 10, "'BINGO' - check if you won", 10, "'exit' - quit the game (progress won't be saved)", 10, 10, 0
    new_card_msg        db "A new BINGO card has been generated!", 10, 0
    cmd_start           db "> ", 0
    invalid_msg         db "Invalid command! Type 'help' to see all the commands available.", 10, 0
    not_win_msg         db 10, "You haven't hit BINGO yet, keep playing.", 10, 0
    win_msg             db 10, "BINGO!!! You win!", 10, 10, "Type 'new' to play again or type 'exit' to quit.", 10, 0
    exit_msg            db "Thank you for playing! ^-^", 10, 0
    marking_msg         db "Format: [col] [row]", 10, "Mark: ", 0
    mark_error_msg      db 10, "INVALID INPUT: Row and column values should be integers within 0-4", 10, 0
    generate_card_msg   db "Command not usable yet. Please generate a bingo card first by typing 'new'", 10, 10, 0

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
    fmt_int         db "%4d %4d", 0
    fmt_card_num    db "%1d ", 10, 0

section .bss
    input               resb 20
    mark_coordinates    resb 8

section .text
    global main
    extern printf, scanf, call_number, display_called_numbers, reset_called_numbers
    extern init_card_generator, generate_bingo_card, display_bingo_card, is_valid_card, get_card_number
    extern time, srand
    extern init_marker, mark_position, display_marked_card, check_bingo

main:
    push ebp
    mov ebp, esp

    ; Initialize random seed
    push 0
    call time
    add esp, 4

    push eax
    call srand
    add esp, 4

    call init_card_generator

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

    ; compare input
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
    push dword new_card_msg
    call printf
    add esp, 4

    call generate_bingo_card
    call display_bingo_card

    ; initialize marker and reset called numbers
    call init_marker
    call reset_called_numbers
    jmp input_loop

cmd_card:
    call card_validation
    call display_bingo_card
    jmp input_loop

cmd_call:
    call card_validation
    call call_number
    jmp input_loop

cmd_called:
    call card_validation
    call display_called_numbers
    jmp input_loop

mark_invalid:
    ; print invalid mark win_msg
    push dword mark_error_msg
    call printf
    add esp, 4
    jmp input_loop

cmd_mark:
    call card_validation

    push dword marking_msg
    call printf
    add esp, 4

    ; Scan coordinates input
    lea eax, [mark_coordinates]
    push dword eax
    lea eax, [mark_coordinates + 4]
    push dword eax
    push dword fmt_int
    call scanf
    add esp, 12

    ; [mark_coordinates] = row value (4 bytes)
    ; [mark_coordinates + 4] = col value (4 bytes)

    ; Validate row (0-4)
    mov eax, [mark_coordinates]
    cmp eax, 4
    ja mark_invalid

    ; Validate col (0-4)
    mov eax, [mark_coordinates + 4]
    cmp eax, 4
    ja mark_invalid

    ; Mark the card at [row][col]
    ; Parameters are pushed in reverse order: row then col
    push dword [mark_coordinates ]   ; row (will be at ebp+8)
    push dword [mark_coordinates + 4]       ; col (will be at ebp+12)
    call mark_position
    add esp, 8

    ; Display the marked card
    call display_marked_card

    jmp input_loop

cmd_marked:
    call card_validation
    call display_marked_card
    jmp input_loop

cmd_bingo:
    call card_validation
    call check_bingo
    cmp eax, 1
    je player_wins

    push dword not_win_msg
    call printf
    add esp, 4
    jmp input_loop

player_wins:
    push dword win_msg
    call printf
    add esp, 4
    jmp input_loop

exit:
    push dword exit_msg
    call printf
    add esp, 4


    mov eax, 0
    mov esp, ebp
    pop ebp

    ret

;-------------------------
; BINGO CARD VALIDATOR
;-------------------------

card_validation:
    call is_valid_card
    cmp eax, 1
    je .valid

.not_valid:
    push generate_card_msg
    call printf
    add esp, 4
    
    jmp input_loop

.valid:
    ret

;----------------------------------------------------
; str_cmp: compares strings at [esi] and [edi]
; return: EAX = 0 if equal, EAX = 1 if not equal
;----------------------------------------------------

str_cmp:
    xor eax, eax
.next_char:
    mov al, [esi]
    mov bl, [edi]
    cmp al, bl
    jne .not_equal
    cmp al, 0
    je .equal
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