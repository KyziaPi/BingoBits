; number_caller.asm
; generates random bingo numbers (1-75)
; displays called number list
; all functions for calling a random number here

section .data
	; format strings
	call_msg db "Calling number: %c-%02d", 10, 0
	called_list_msg db "Numbers called so far:", 10, 0
	no_called_msg db "No numbers have been called yet.", 10, 0
	num_format db "%c-%02d ", 0
	newline db 10, 0

	; column letters for Bingo
	column_letters db "BINGO", 0

	; initialized variables
	rand_num dd 0
	called_flags times 76 db 0
	called_count dd 0

section .text
	global call_number, display_called_numbers, reset_called_numbers
	extern rand, printf

; call number - generate and print one random number (1-75)
call_number:
	mov eax, [called_count]
	cmp eax, 75
	je .all_called

.generate_new:
	call rand
	xor edx, edx
	mov ebx, 75
	div ebx ; EDX = remainder (0-74)
	inc edx ; make range 1-75
	mov [rand_num], edx

	mov ebx, [rand_num] 
	cmp byte [called_flags + ebx], 1
	je .generate_new ; skip if number already called

	mov byte [called_flags + ebx], + 1 ; mark as called
	inc dword [called_count]

	; compute column letter using (num - 1) / 15
	mov eax, [rand_num]
	dec eax
	mov edi, 15
	xor edx, edx
	div edi ; eax = column index 0-4
	mov bl, [column_letters + eax]

	; print "Calling number: B-12"
	mov eax, [rand_num]
	push eax
	movzx eax, bl
	push eax
	push dword call_msg
	call printf
	add esp, 12
	ret

.all_called:
	push dword no_called_msg
	call printf
	add esp, 4
	ret

; display_called_numbers - print all called numbers (1-75)
display_called_numbers:
	mov eax, [called_count]
	cmp eax, 0
	je .none_called

	push dword called_list_msg
	call printf
	add esp, 4

	mov ecx, 1 ; start from 1
	mov edi, 0 ; counter for formatting (new line 10 numbers)

.loop:
	cmp ecx, 76
	jge .done
	cmp byte [called_flags + ecx], 1
	jne .next

	; compute letter for ecx
	mov eax, ecx
	dec eax
	push edx ; save edx
	xor edx, edx
	mov ebx, 15
	div ebx
	mov bl, [column_letters + eax]
	pop edx ; restore edx

	; printf"(%c-%02d", letter, ecx)
	push ecx ; save ecx
	push edi ; save edi

	
	mov eax, ecx
	push eax ; %d argument
	movzx eax, bl ; %c argument
	push eax
	push dword num_format
	call printf
	add esp, 12

	pop edi ; restore edi
	pop ecx ; restore ecx

	inc edi ; increment counter
	cmp edi, 10 ; check if we have printed 10 numbers
	jl .next

	; print newline after every 10 numbers
	push ecx
	push dword newline
	call printf
	add esp, 4
	pop ecx
	xor edi, edi ; reset counter

.next:
	inc ecx
	jmp .loop

.done:
	; print final newline if needed
	cmp edi, 0
	je .skip_final_newline
	push dword newline
	call printf
	add esp, 4

.skip_final_newline:
	ret

.none_called:
	push dword no_called_msg
	call printf
	add esp, 4
	ret

; reset_called_numbers - reset all called numbers
reset_called_numbers:
	push ebp
	mov ebp, esp

	; reset called_count to 0
	mov dword [called_count], 0

	; reset all flags to 0
	mov ecx, 0 ; counter

.reset_loop:
	cmp ecx, 76
	jge .done
	mov byte [called_flags + ecx], 0
	inc ecx
	jmp .reset_loop

.done:
	mov esp, ebp
	pop ebp
	ret



section .note.GNU-stack noalloc noexec nowrite progbits