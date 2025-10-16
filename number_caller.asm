; all functions for calling a random number here

section .data
	call_msg db "Calling number: %d", 10, 0 ;format string for printf

section .bss
	rand_num resd 1 ;reserve space for random number

section .text
	global call_number ;function name to be called from main
	extern rand, printf ;use rand() from C library

call_number:
	;generate random number using rand()
	call rand

	;rand() returns a large integer in EAX
	mov ebx, 75
	xor edx, edx
	div ebx ;EAX = quotient, EAX = remainder
	inc edx ;make range 1-75
	mov [rand_num], edx ;store the random number

	;print it using printf
	push dword [rand_num]
	push dword call_msg
	call printf
	add esp, 8

	ret

section .note.GNU-stack noalloc noexec nowrite progbits