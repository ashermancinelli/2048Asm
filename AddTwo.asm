TITLE Add and Subtract              (AddSubAlt.asm)

; This program adds and subtracts 32-bit integers.
INCLUDE Irvine32.inc

.data

	; These coordinates are measured from 
	playerPosX	BYTE 18
	playerPosY	BYTE 11
	deltax		SBYTE 0
	deltay		SBYTE 0

	startRoom	BYTE	"|-------------------------------|",0ah
				BYTE	"|                               |",0ah
				BYTE	"\                               |",0ah
				BYTE	" \                              |",0ah
				BYTE	"  \                             |",0ah
				BYTE	"  /                             |",0ah
				BYTE	" /                              |",0ah
				BYTE	"/                               |",0ah
				BYTE	"|                               |",0ah
				BYTE	"|                               |",0ah
				BYTE	"|                               |",0ah
				BYTE	"|                 O             |",0ah
				BYTE	"|-------------------------------|",0h


	room2		BYTE	"|-------------------------------|",0ah
				BYTE	"\                               |",0ah
				BYTE	" \                              |",0ah
				BYTE	"  \                             |",0ah
				BYTE	"   \                            |",0ah
				BYTE	"    \                           |",0ah
				BYTE	" ____\                          |",0ah
				BYTE	"|                               |",0ah
				BYTE	"|                               |",0ah
				BYTE	"|                               |",0ah
				BYTE	"|                               |",0ah
				BYTE	"|                               |",0ah
				BYTE	"|-------------------------------|",0h

.code

update PROC
	
	call ReadChar
	.if AL == 97
		mov deltax, -1
	.elseif AL == 100
		mov deltax, 1
	.elseif AL == 115
		mov deltay, -1
	.elseif AL == 119
		mov deltay, 1
	.endif

	mov dh, playerPosY
	mov dl, playerPosX
	call Gotoxy
	mov al, " "
	call WriteChar

	mov bh, deltax
	mov bl, deltay

	add playerPosX, bh
	sub playerPosY, bl
	mov dh, playerPosY
	mov dl, playerPosX
	call Gotoxy
	mov al, "O"
	call WriteChar

	mov deltax, 0
	mov deltay, 0
	ret
update ENDP


main PROC

	mov edx, offset startRoom
	call WriteString
	mov ecx, 255
	
mainLoop:
	call update
	loop mainLoop

	exit
main ENDP
END main
