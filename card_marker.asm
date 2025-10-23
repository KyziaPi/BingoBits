; card_maker.asm
; all functions for marking the bingo card 
; checking for BINGO wins

section .data
    ; Display formats
    marked_header_fmt db "    B    I    N    G    O", 10, 0
    marked_row_fmt db " ", 0
    marked_number_fmt db "%4d ", 0
    marked_x_fmt db "  X  ", 0
    marked_free_fmt db "FREE ", 0
    marked_newline_fmt db 10, 0
    marked_separator_fmt db "+----+----+----+----+----+", 10, 0
    
    ; Messages
    already_marked_msg db "This position has already been marked!", 10, 0
    not_called_msg db "Number %d hasn't been called yet!", 10, 0
    mark_success_msg db "Successfully marked number %d at position [%d][%d]", 10, 0

section .bss
    ; 5x5 array to track marked positions (0 = unmarked, 1 = marked)
    marked_card resb 25

section .text
    global init_marker
    global mark_position
    global is_position_marked
    global display_marked_card
    global check_bingo
    global marked_card
    extern printf
    extern get_card_number
    extern bingo_card
    extern called_flags

; Initialize the marker system
init_marker:
    push ecx
    push edi
    
    ; Clear all marked positions
    mov ecx, 25
    mov edi, marked_card
    xor eax, eax
    rep stosb
    
    ; Mark the center FREE space as already marked
    mov byte [marked_card + 12], 1  ; Position 12 (row 2, col 2)
    
    pop edi
    pop ecx
    ret

; Mark a position on the card
; Parameters: row (0-4), col (0-4) pushed on stack
; Returns: 0 if successful, 1 if already marked, 2 if not called yet
mark_position:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push esi
    
    mov eax, [ebp + 12]     ; row
    mov ebx, [ebp + 8]      ; col
    
    ; Validate bounds
    cmp eax, 4
    ja .invalid_position
    cmp ebx, 4
    ja .invalid_position
    
    ; Calculate position: row * 5 + col
    mov ecx, eax
    imul ecx, 5
    add ecx, ebx
    
    ; Check if already marked
    cmp byte [marked_card + ecx], 1
    je .already_marked
    
    ; Get the number at this position
    push eax
    push ebx
    call get_card_number
    add esp, 8
    mov esi, eax            ; esi = card number
    
    ; Check if it's the FREE space (center position)
    cmp ecx, 12
    je .mark_it             ; FREE space is always valid
    
    ; Check if this number has been called
    cmp esi, 0
    jl .invalid_position
    cmp esi, 75
    ja .invalid_position
    
    cmp byte [called_flags + esi], 1
    jne .not_called
    
.mark_it:
    ; Mark the position
    mov byte [marked_card + ecx], 1
    
    ; Print success message
    push ebx                ; col
    push dword [ebp + 12]   ; row
    push esi                ; number
    push mark_success_msg
    call printf
    add esp, 16
    
    ; Display the marked card
    call display_marked_card
    
    xor eax, eax            ; Return 0 for success
    jmp .done
    
.already_marked:
    push already_marked_msg
    call printf
    add esp, 4
    mov eax, 1              ; Return 1 for already marked
    jmp .done
    
.not_called:
    push esi                ; number
    push not_called_msg
    call printf
    add esp, 8
    mov eax, 2              ; Return 2 for not called
    jmp .done
    
.invalid_position:
    mov eax, 3              ; Return 3 for invalid position
    
.done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop ebp
    ret

; Check if a position is marked
; Parameters: row (0-4), col (0-4) pushed on stack
; Returns: 1 if marked, 0 if not marked
is_position_marked:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 12]     ; row
    mov ebx, [ebp + 8]      ; col
    
    ; Validate bounds
    cmp eax, 4
    ja .not_marked
    cmp ebx, 4
    ja .not_marked
    
    ; Calculate position: row * 5 + col
    imul eax, 5
    add eax, ebx
    
    ; Check if marked
    movzx eax, byte [marked_card + eax]
    jmp .done
    
.not_marked:
    xor eax, eax
    
.done:
    pop ebp
    ret

; Display the BINGO card with marks
display_marked_card:
    push ebx
    push esi
    push edi
    
    ; Print separator
    push marked_separator_fmt
    call printf
    add esp, 4
    
    ; Print header
    push marked_header_fmt
    call printf
    add esp, 4
    
    ; Print separator
    push marked_separator_fmt
    call printf
    add esp, 4
    
    ; Print each row
    mov esi, 0              ; Row counter
    
.display_row_loop:
    cmp esi, 5
    jge .display_done
    
    ; Print row start
    push marked_row_fmt
    call printf
    add esp, 4
    
    ; Print each column in this row
    mov edi, 0              ; Column counter
    
.display_col_loop:
    cmp edi, 5
    jge .end_row
    
    ; Calculate array index: row * 5 + col
    mov eax, esi
    imul eax, 5
    add eax, edi
    
    ; Check if position is marked
    cmp byte [marked_card + eax], 1
    je .print_mark
    
    ; Not marked - print the number
    mov ebx, [bingo_card + eax*4]
    
    ; Check if it's the FREE space
    cmp esi, 2
    jne .not_free
    cmp edi, 2
    jne .not_free
    
    push marked_free_fmt
    call printf
    add esp, 4
    jmp .next_column
    
.not_free:
    push ebx
    push marked_number_fmt
    call printf
    add esp, 8
    jmp .next_column
    
.print_mark:
    ; Position is marked - print X
    push marked_x_fmt
    call printf
    add esp, 4
    
.next_column:
    inc edi
    jmp .display_col_loop
    
.end_row:
    ; Print newline after row
    push marked_newline_fmt
    call printf
    add esp, 4
    
    inc esi
    jmp .display_row_loop
    
.display_done:
    ; Print final separator
    push marked_separator_fmt
    call printf
    add esp, 4
    
    ; Print extra newline
    push marked_newline_fmt
    call printf
    add esp, 4
    
    pop edi
    pop esi
    pop ebx
    ret

; Check if player has BINGO
; Returns: 1 if BINGO, 0 if not
check_bingo:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    ; Check all 5 rows
    mov esi, 0              ; Row counter
.check_rows:
    cmp esi, 5
    jge .check_cols
    
    mov ecx, 0              ; Marked count
    mov edi, 0              ; Column counter
    
.row_loop:
    cmp edi, 5
    jge .row_done
    
    ; Calculate position: row * 5 + col
    mov eax, esi
    imul eax, 5
    add eax, edi
    
    ; Check if marked
    cmp byte [marked_card + eax], 1
    jne .row_next
    inc ecx
    
.row_next:
    inc edi
    jmp .row_loop
    
.row_done:
    cmp ecx, 5
    je .found_bingo
    inc esi
    jmp .check_rows
    
    ; Check all 5 columns
.check_cols:
    mov esi, 0              ; Column counter
    
.check_cols_loop:
    cmp esi, 5
    jge .check_diag1
    
    mov ecx, 0              ; Marked count
    mov edi, 0              ; Row counter
.col_loop:
    cmp edi, 5
    jge .col_done
    
    ; Calculate position: row * 5 + col
    mov eax, edi
    imul eax, 5
    add eax, esi
    
    ; Check if marked
    cmp byte [marked_card + eax], 1
    jne .col_next
    inc ecx
    
.col_next:
    inc edi
    jmp .col_loop
    
.col_done:
    cmp ecx, 5
    je .found_bingo
    inc esi
    jmp .check_cols_loop
    
    ; Check diagonal (top-left to bottom-right)
.check_diag1:
    mov ecx, 0              ; Marked count
    mov esi, 0              ; Position counter (0, 6, 12, 18, 24)
    
.diag1_loop:
    cmp esi, 25
    jge .check_diag2
    
    cmp byte [marked_card + esi], 1
    jne .diag1_next
    inc ecx
    
.diag1_next:
    add esi, 6              ; Move to next diagonal position
    jmp .diag1_loop
    
.check_diag2:
    cmp ecx, 5
    je .found_bingo
    
    ; Check diagonal (top-right to bottom-left)
    mov ecx, 0              ; Marked count
    mov esi, 4              ; Position counter (4, 8, 12, 16, 20)
    
.diag2_loop:
    cmp esi, 21
    jge .no_bingo
    
    cmp byte [marked_card + esi], 1
    jne .diag2_next
    inc ecx
    
.diag2_next:
    add esi, 4              ; Move to next diagonal position
    jmp .diag2_loop
    
.no_bingo:
    cmp ecx, 5
    je .found_bingo
    xor eax, eax            ; Return 0
    jmp .check_done
    
.found_bingo:
    mov eax, 1              ; Return 1
    
.check_done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

section .note.GNU-stack noalloc noexec nowrite progbits
