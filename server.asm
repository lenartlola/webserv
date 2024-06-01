BITS 64

SECTION .data
sa_family dw 2
sa_port dw 0x3713
sa_addr db 0x0
pad db 0,0
read_buffer: times 1024 db 0
msg_buffer: db `HTTP/1.0 200 OK\r\n\r\n`, 0
file_path: times 1024 db 0
file_content: times 1024 db 0

SECTION .text


global _start

_exit:
	mov rax, 60
	syscall

exit_error:
	mov rdi, 1
	call _exit

listen_socket:
	mov rax, 50
	mov rsi, 0
	syscall
	cmp rax, 0
	jl exit_error

	ret

bind_socket:
	; bind a port to the created socket
	mov rdi, rax					; set the created fd to rdi
	mov rsi, sa_family
	mov rdx, 16
	mov rax, 0x31
	syscall
	cmp rax, 0
	jl exit_error

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

get_file_path:
	; search for the first space
start_loop:
	mov al, byte [read_buffer + r9]
	cmp al, " "
	je start_copy
	inc r9
	jmp start_loop
start_copy:
	inc r9
	xor r10, r10
copy_loop:
	; TODO check for NULLByte termination
	cmp byte [read_buffer + r9], " "
	je end_copy
	mov dl, byte [read_buffer + r9]
	mov byte [file_path + r10], dl
	inc r9
	inc r10
	jmp copy_loop
end_copy:
	ret

child_process:
	; read from the accepted fd
	mov rax, 0
	lea rsi, [read_buffer]
	mov rdx, 1024
	syscall

	mov r12, rdi			; store the connection fd
	xor r9, r9
	call get_file_path
	
	; open the file
	mov rax, 2
	lea rdi, [file_path]
	mov rsi, 0
	syscall

	; read from the file
	mov rdi, rax
	xor rax, rax
	lea rsi, [file_content]
	mov rdx, 1024
	syscall
	
	; store the nuber of read bytes to r11
	push rax

	; close file fd
	mov rax, 3
	syscall

	; write OK to connection
	mov rdi, r12
	lea rsi, [msg_buffer]
	xor rdx, rdx
	mov rdx, 19
	mov rax, 1
	syscall

	; write file content to connection
	mov rdi, r12
	lea rsi, [file_content]
	xor rdx, rdx
	pop rdx
	mov rax, 1
	syscall

	; close the connection
	mov rax, 3
	syscall
	mov rdi, rbx			; reset the socket fd to rdi

	ret

;fork_process:
;	mov rax, 57
;	syscall
;
;	ret

socket_accept:
	mov rax, 43
	mov rsi, 0
	mov rdx, 0
	syscall
	cmp rax, 0
	jl exit_error
	mov rbx, rdi			; store the socket fd as we need rdi
	mov rdi, rax 
	ret

server_loop:
	call socket_accept
;	call fork_process
;	cmp rax, 0
	call child_process

	; wait to child
;	mov rdi, 0
;	mov rsi, 0
;	mov rdx, 0
;	mov r10, 0
;	mov rax, 61
;	syscall
	jmp server_loop
	ret

_start:
	call create_socket
	call bind_socket
	call listen_socket
	call server_loop
	mov rdi, 0
	call _exit
