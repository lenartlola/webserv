BITS 64

SECTION .data

struc s_sockaddr
	.sin_family resw 1
	.sin_port resw 1
	.sin_addr resd 1
	.sin_z_pad resb 8
endstruc

pop_sa istruc s_sockaddr
	at s_sockaddr.sin_family, dw 2
	at s_sockaddr.sin_port, dw 0x539
	at s_sockaddr.sin_addr, dd 0, 0
	at s_sockaddr.sin_z_pad, dd 0, 0
iend

SECTION .text


global _start

_exit:
	mov rax, 60
	syscall

exit_error:
	mov rdi, 1
	call _exit

bind_socket:
	mov [pop_sa + s_sockaddr.sin_addr], rax		; the created fd	
	mov rdi, eax					; yes, mov is really a copy
	mov rsi, s_sockaddr
	mov rax, 0x31

	ret

create_socket:
	mov rax, 0x29
	mov rdi, 2		; set type to AF_INET
	mov rsi, 1		; sock stream
	xor rdx, rdx
	syscall
	; check if success or fail
	cmp rax, 0
	jl exit_error
	ret

_start:
	call create_socket
	call bind_socket
	mov rdi, 0
	call _exit
