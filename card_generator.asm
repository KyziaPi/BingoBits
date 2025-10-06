; nasm -f elf32 card_generator.asm -o card_generator.o
; gcc -m32 -no-pie card_generator.o -o card_generator
; ./card_generator

section .data
    ; BINGO column ranges
    B_MIN equ 1
    B_MAX equ 15
    I_MIN equ 16
    I_MAX equ 30
    N_MIN equ 31
    N_MAX equ 45
    G_MIN equ 46
    G_MAX equ 60
    O_MIN equ 61
    O_MAX equ 75
    
    ; Card dimensions
    CARD_ROWS equ 5
    CARD_COLS equ 5
    NUMBERS_PER_COL equ 15
    
    ; Display formats for printf
    header_fmt db "    B    I    N    G    O", 10, 0
    row_fmt db " ", 0
    number_fmt db "%4d ", 0
    free_fmt db "FREE ", 0
    newline_fmt db 10, 0
    separator_fmt db "+----+----+----+----+----+", 10, 0
    card_title_fmt db "BINGO CARD", 10, 0
    
    ; Random seed for standalone testing
    seed dd 1

section .bss
    ; BINGO card storage (5x5 grid)
    bingo_card resd 25          ; 5x5 array of 32-bit integers
    
    ; Temporary arrays for column number generation
    b_numbers resb 15           ; Available B numbers (1-15)
    i_numbers resb 15           ; Available I numbers (16-30)  
    n_numbers resb 15           ; Available N numbers (31-45)
    g_numbers resb 15           ; Available G numbers (46-60)
    o_numbers resb 15           ; Available O numbers (61-75)
    
    ; Counters for available numbers in each column
    b_count resd 1
    i_count resd 1
    n_count resd 1
    g_count resd 1
    o_count resd 1

section .text
    extern printf
    extern time
    extern srand
    extern rand
    global generate_bingo_card
    global display_bingo_card
    global init_card_generator
    global get_card_number
    global is_valid_card
    global get_card_array
    global bingo_card
    global main

init_card_generator:
    ; Initialize card generator system
    ; Initialize random seed (will use external seed from main)
    ; Initialize available numbers for each column
    call init_column_arrays
    ret

init_column_arrays:
    ; Initialize B column (1-15)
    mov ecx, 15
    mov edi, b_numbers
    mov eax, B_MIN
init_b_loop:
    mov [edi], al
    inc edi
    inc eax
    loop init_b_loop
    mov dword [b_count], 15
    
    ; Initialize I column (16-30)  
    mov ecx, 15
    mov edi, i_numbers
    mov eax, I_MIN
init_i_loop:
    mov [edi], al
    inc edi
    inc eax
    loop init_i_loop
    mov dword [i_count], 15
    
    ; Initialize N column (31-45)
    mov ecx, 15
    mov edi, n_numbers
    mov eax, N_MIN
init_n_loop:
    mov [edi], al
    inc edi
    inc eax
    loop init_n_loop
    mov dword [n_count], 15
    
    ; Initialize G column (46-60)
    mov ecx, 15
    mov edi, g_numbers
    mov eax, G_MIN
init_g_loop:
    mov [edi], al
    inc edi
    inc eax
    loop init_g_loop
    mov dword [g_count], 15
    
    ; Initialize O column (61-75)
    mov ecx, 15
    mov edi, o_numbers
    mov eax, O_MIN
init_o_loop:
    mov [edi], al
    inc edi
    inc eax
    loop init_o_loop
    mov dword [o_count], 15
    
    ret

generate_bingo_card:
    ; Generate each column of the BINGO card
    
    ; Generate B column (column 0)
    mov esi, 0                  ; Column index
    call generate_column
    
    ; Generate I column (column 1) 
    mov esi, 1
    call generate_column
    
    ; Generate N column (column 2)
    mov esi, 2
    call generate_column
    
    ; Generate G column (column 3)
    mov esi, 3
    call generate_column
    
    ; Generate O column (column 4)
    mov esi, 4
    call generate_column
    
    ; Set center space (N column, row 2) to FREE (0)
    mov dword [bingo_card + 2*20 + 2*4], 0  ; Row 2, Col 2
    
    ret

generate_column:
    ; Generate 5 numbers for column esi
    ; esi = column index (0-4)
    
    push esi
    mov ecx, 5                  ; 5 numbers per column
    mov edi, 0                  ; Row index
    
gen_col_loop:
    push ecx
    push edi
    
    ; Get random number for this column
    call get_random_for_column
    
    ; Store in card array: card[row][col] = card[row*5 + col]
    pop edi
    mov ebx, edi               ; row
    imul ebx, 5                ; row * 5
    add ebx, esi               ; + column
    mov [bingo_card + ebx*4], eax
    
    inc edi                    ; Next row
    pop ecx
    loop gen_col_loop
    
    pop esi
    ret

get_random_for_column:
    ; Get random number for column esi, remove it from available pool
    ; Returns number in eax
    
    cmp esi, 0
    je get_b_number
    cmp esi, 1  
    je get_i_number
    cmp esi, 2
    je get_n_number
    cmp esi, 3
    je get_g_number
    jmp get_o_number

get_b_number:
    mov eax, [b_count]
    call simple_random
    xor edx, edx
    div eax                    ; Random index in available B numbers
    mov edx, edx
    
    movzx eax, byte [b_numbers + edx]  ; Get the number
    
    ; Remove this number from available pool
    call remove_from_b_pool
    ret

get_i_number:
    mov eax, [i_count]
    call simple_random
    xor edx, edx
    div eax
    mov edx, edx
    
    movzx eax, byte [i_numbers + edx]
    call remove_from_i_pool
    ret

get_n_number:
    mov eax, [n_count]
    call simple_random
    xor edx, edx
    div eax
    mov edx, edx
    
    movzx eax, byte [n_numbers + edx]
    call remove_from_n_pool
    ret

get_g_number:
    mov eax, [g_count]
    call simple_random
    xor edx, edx
    div eax
    mov edx, edx
    
    movzx eax, byte [g_numbers + edx]
    call remove_from_g_pool
    ret

get_o_number:
    mov eax, [o_count]
    call simple_random
    xor edx, edx
    div eax
    mov edx, edx
    
    movzx eax, byte [o_numbers + edx]
    call remove_from_o_pool
    ret

simple_random:
    ; Use C library rand() function instead of custom LCG
    call rand
    ret

remove_from_b_pool:
    ; Remove number at index edx from B pool
    mov ecx, [b_count]
    dec ecx
    mov [b_count], ecx
    
    ; Shift remaining numbers down
    cmp edx, ecx
    jge b_remove_done
    
    mov esi, edx
    inc esi
    add esi, b_numbers
    mov edi, edx
    add edi, b_numbers
    
    sub ecx, edx
    rep movsb
    
b_remove_done:
    ret

remove_from_i_pool:
    mov ecx, [i_count]
    dec ecx
    mov [i_count], ecx
    
    cmp edx, ecx
    jge i_remove_done
    
    mov esi, edx
    inc esi
    add esi, i_numbers
    mov edi, edx
    add edi, i_numbers
    
    sub ecx, edx
    rep movsb
    
i_remove_done:
    ret

remove_from_n_pool:
    mov ecx, [n_count]
    dec ecx
    mov [n_count], ecx
    
    cmp edx, ecx
    jge n_remove_done
    
    mov esi, edx
    inc esi
    add esi, n_numbers
    mov edi, edx
    add edi, n_numbers
    
    sub ecx, edx
    rep movsb
    
n_remove_done:
    ret

remove_from_g_pool:
    mov ecx, [g_count]
    dec ecx
    mov [g_count], ecx
    
    cmp edx, ecx
    jge g_remove_done
    
    mov esi, edx
    inc esi
    add esi, g_numbers
    mov edi, edx
    add edi, g_numbers
    
    sub ecx, edx
    rep movsb
    
g_remove_done:
    ret

remove_from_o_pool:
    mov ecx, [o_count]
    dec ecx
    mov [o_count], ecx
    
    cmp edx, ecx
    jge o_remove_done
    
    mov esi, edx
    inc esi
    add esi, o_numbers
    mov edi, edx
    add edi, o_numbers
    
    sub ecx, edx
    rep movsb
    
o_remove_done:
    ret

get_card_number:
    ; Get number at specific position (row, col)
    ; Parameters: row (0-4), col (0-4) pushed on stack
    ; Returns: number at that position in eax
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 12]     ; row
    mov ebx, [ebp + 8]      ; col
    
    ; Validate bounds
    cmp eax, 4
    ja invalid_position
    cmp ebx, 4  
    ja invalid_position
    
    ; Calculate position: row * 5 + col
    imul eax, 5
    add eax, ebx
    
    ; Get number from card
    mov eax, [bingo_card + eax*4]
    jmp get_card_done
    
invalid_position:
    mov eax, -1             ; Return -1 for invalid position
    
get_card_done:
    pop ebp
    ret

is_valid_card:
    ; Check if the generated card is valid (no duplicates, proper ranges)
    ; Returns: 1 if valid, 0 if invalid
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    ; Check each number is in proper column range and no duplicates
    mov esi, 0              ; Position counter
    
validate_loop:
    cmp esi, 25
    jge card_valid
    
    ; Skip center position (FREE)
    cmp esi, 12
    je skip_center_validate
    
    ; Get number at this position
    mov eax, [bingo_card + esi*4]
    
    ; Check range based on column
    mov ebx, esi
    mov ecx, 5
    xor edx, edx
    div ecx                 ; eax = row, edx = col
    mov eax, [bingo_card + esi*4]  ; Restore number
    
    ; Check column range
    cmp edx, 0              ; B column
    jne check_i_col
    cmp eax, B_MIN
    jb card_invalid
    cmp eax, B_MAX
    ja card_invalid
    jmp check_duplicates
    
check_i_col:
    cmp edx, 1              ; I column
    jne check_n_col
    cmp eax, I_MIN
    jb card_invalid
    cmp eax, I_MAX
    ja card_invalid
    jmp check_duplicates
    
check_n_col:
    cmp edx, 2              ; N column
    jne check_g_col
    cmp eax, N_MIN
    jb card_invalid
    cmp eax, N_MAX
    ja card_invalid
    jmp check_duplicates
    
check_g_col:
    cmp edx, 3              ; G column
    jne check_o_col
    cmp eax, G_MIN
    jb card_invalid
    cmp eax, G_MAX
    ja card_invalid
    jmp check_duplicates
    
check_o_col:
    ; O column
    cmp eax, O_MIN
    jb card_invalid
    cmp eax, O_MAX
    ja card_invalid
    
check_duplicates:
    ; Check for duplicates in rest of card
    mov edi, esi
    inc edi
    
dup_loop:
    cmp edi, 25
    jge no_duplicates
    
    ; Skip center position
    cmp edi, 12
    je skip_center_dup
    
    cmp eax, [bingo_card + edi*4]
    je card_invalid
    
skip_center_dup:
    inc edi
    jmp dup_loop
    
no_duplicates:
skip_center_validate:
    inc esi
    jmp validate_loop
    
card_valid:
    mov eax, 1
    jmp validate_done
    
card_invalid:
    mov eax, 0
    
validate_done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

get_card_array:
    ; Return pointer to the card array in eax
    mov eax, bingo_card
    ret

display_bingo_card:
    ; Display the BINGO card using printf
    
    ; Print card title
    push card_title_fmt
    call printf
    add esp, 4
    
    ; Print separator
    push separator_fmt  
    call printf
    add esp, 4
    
    ; Print header
    push header_fmt
    call printf
    add esp, 4
    
    ; Print separator
    push separator_fmt
    call printf  
    add esp, 4
    
    ; Print each row
    mov esi, 0                  ; Row counter
    
display_row_loop:
    cmp esi, 5
    jge display_done
    
    ; Print row start
    push row_fmt
    call printf
    add esp, 4
    
    ; Print each column in this row
    mov edi, 0                  ; Column counter
    
display_col_loop:
    cmp edi, 5
    jge end_row
    
    ; Calculate array index: row * 5 + col
    mov eax, esi
    imul eax, 5
    add eax, edi
    
    ; Get the number at this position
    mov ebx, [bingo_card + eax*4]
    
    ; Check if it's the FREE space (center: row 2, col 2)
    cmp esi, 2
    jne not_free_space
    cmp edi, 2
    jne not_free_space
    
    ; Print FREE
    push free_fmt
    call printf
    add esp, 4
    jmp next_column
    
not_free_space:
    ; Print the number
    push ebx
    push number_fmt
    call printf
    add esp, 8
    
next_column:
    inc edi
    jmp display_col_loop
    
end_row:
    ; Print newline after row
    push newline_fmt
    call printf
    add esp, 4
    
    inc esi
    jmp display_row_loop
    
display_done:
    ; Print final separator
    push separator_fmt
    call printf
    add esp, 4
    
    ; Print extra newline
    push newline_fmt
    call printf
    add esp, 4
    
    ret

section .note.GNU-stack noalloc noexec nowrite progbits

