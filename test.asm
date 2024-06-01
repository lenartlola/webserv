BITS 64

SECTION .data
sa_family dw 2
sa_port dw 0x3713
sa_addr db 0x0
pad db 0,0
read_buffer: times 1024 db 0
msg_buffer: db "GET /tmp/kjsahfkj we", 0
file_path: times 1024 db 0

SECTION .text

global _start

_start:
	start_loop:
		;lea rsi, [msg_buffer]
		xor r9, r9
find_space:
		mov al, byte[msg_buffer + r9]
		cmp al, " "
		je found_space
		inc r9
		jmp find_space
	found_space:
		inc r9
		inc r9
		xor r10, r10
		jmp second_loop
	second_loop:
		cmp byte [msg_buffer + r9], " "
		je found_second_space
		mov dl, byte [msg_buffer + r9]
		mov byte[file_path + r10], dl
		inc r9
		inc r10
		jmp second_loop
	found_second_space:
		ret
		
		


