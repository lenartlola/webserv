BITS 64

SECTION .data
sa_family dw 2
sa_port dw 0x3713
sa_addr db 0x0
pad db 0,0
read_buffer: times 1024 db 0
msg_buffer: db "POST /tmp/tmp800mw4_4 HTTP/1.1\r\nHost: localhost\r\nUser-Agent: python-requests/2.32.3\r\nAccept-Encoding: gzip, deflate, zstd\r\nAccept: */*\r\nConnection: keep-alive\r\nContent-Length: 244\r\n\r\ndync75U9v3AgD4F4lGFEkOVSlPTyWmdPp6CBIa1J7Cl2J7eeZ9NXBOEgOdKC79oRkqNvAi5OGRQAPHpMd8ybzb8ScZcYCQS2mF94j5PPUMu9MktPl2V7tLPgQ6TAZqPMZgQ2dY5F8KjmfwG9ZdA0LOjd31ceFYHPU7o68fDfKEXfIqHRev7gmIx8y762SSRcsRiT5o9riuukIFZK2Cy5SBnEsYhkeAeuoAApEplQIJjG53bLnIDq", 0
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
		
		


