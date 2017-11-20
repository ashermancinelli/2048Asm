TITLE Add and Subtract              (AddSubAlt.asm)

; This program adds and subtracts 32-bit integers.
INCLUDE Irvine32.inc

.data

	; These coordinates are measured from 
	playerPosX	BYTE 	18
	playerPosY	BYTE 	11
	currentRoom BYTE	520 dup(?)
	deltax		SBYTE	0
	deltay		SBYTE	0

	startRoom	BYTE	"|----------------- --------------------|",0ah
				BYTE	"|                                      |",0ah
				BYTE	"\                                      |",0ah
				BYTE	" \                                     |",0ah
				BYTE	"  \                                    |",0ah
				BYTE	"  /                                    |",0ah
				BYTE	" /                                     |",0ah
				BYTE	"/                                      |",0ah
				BYTE	"|                                      |",0ah
				BYTE	"|                                      |",0ah
				BYTE	"|                                      |",0ah
				BYTE	"|                 O                    |",0ah
				BYTE	"|--------------------------------------|",0h


	room2		BYTE	"|--------------------------------------|",0ah
				BYTE	"\                                      |",0ah
				BYTE	" \                                     |",0ah
				BYTE	"  \                                    |",0ah
				BYTE	"   \                                   |",0ah
				BYTE	"    \                                  |",0ah
				BYTE	" ____\                                 |",0ah
				BYTE	"|                                      |",0ah
				BYTE	"|                                      |",0ah
				BYTE	"|                                      |",0ah
				BYTE	"|       O                              |",0ah
				BYTE	"|                                      |",0ah
				BYTE	"|--------------------------------------|",0h

	room3		BYTE	"                  |   | /   /           ",0ah
				BYTE	"                  |   |/   /            ",0ah
				BYTE	"                  |   |   /             ",0ah
				BYTE	"                  |      /              ",0ah
				BYTE	"                  |     /               ",0ah
				BYTE	"__________________|    /                ",0ah
				BYTE	"                      |                 ",0ah
				BYTE	"__________________    |                 ",0ah
				BYTE	"                  |   |                 ",0ah
				BYTE	"                  |   |                 ",0ah
				BYTE	"                  |   |                 ",0ah
				BYTE	"                  |   |                 ",0ah
				BYTE	"                  | O |                 ",0h


.code

changeToR3 PROC

	call Clrscr
	mov edx, offset room3

	mov esi, offset room3
	mov edi, offset currentRoom
	mov ecx, 520
	rep movsb

	call WriteString
	
	mov playerPosX, 20
	mov playerPosY, 12
	mov deltax, 0		
	mov deltay, 0		

	ret
changeToR3 ENDP

changeToR2 PROC

	call Clrscr
	mov edx, offset room2

	mov esi, offset room2
	mov edi, offset currentRoom
	mov ecx, 520
	rep movsb

	call WriteString
	
	mov playerPosX, 8
	mov playerPosY, 10
	mov deltax, 0		
	mov deltay, 0		

	ret
changeToR2 ENDP

changeToStart PROC

	call Clrscr
	mov edx, offset startRoom

	mov esi, offset startRoom
	mov edi, offset currentRoom
	mov ecx, 520
	rep movsb

	call WriteString
	
	mov playerPosX, 18
	mov playerPosY, 11
	mov deltax, 0		
	mov deltay, 0		

	ret
changeToStart ENDP

movePlayer PROC

	; eax = (deltay+posY) * 40
	;-------------------;
	mov al, playerPosY	;
	add al, playerPosY	;
	add al, playerPosY	;
	add al, playerPosY  ;
	add al, playerPosY	;
	add al, deltay		; 
	add al, deltay		;
	add al, deltay		;
	add al, deltay		;
	add al, deltay		;
						;
	movzx eax, al		;
	add eax, eax		;
	add eax, eax		;
	add eax, eax		;
	add eax, eax		;
	;-------------------;

	mov bh, deltax
	add bh, playerPosX	

	movzx ebx, bh
	add ebx, eax


	.if currentRoom[ebx] == 32

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

		mov dh, 0
		mov dl, 0
		call Gotoxy
	.endif
	
	ret
movePlayer ENDP

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
	.elseif AL == 49
		call changeToStart
	.elseif AL == 50
		call changeToR2
	.elseif AL == 51
		call changeToR3
	.endif

	call movePlayer

	ret
update ENDP


main PROC

	mov edx, offset startRoom

	mov esi, offset startRoom
	mov edi, offset currentRoom
	mov ecx, 520
	rep movsb

	call WriteString
	mov ecx, 3255
	
mainLoop:
	call update
	loop mainLoop

	exit
main ENDP
END main
