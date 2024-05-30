#!/bin/bash

nasm -felf64 server.asm -o server.o
ld -o server server.o
rm -rf server.o
