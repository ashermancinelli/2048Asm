TITLE Add and Subtract              (AddSubAlt.asm)

; This program adds and subtracts 32-bit integers.
INCLUDE Irvine32.inc

.data

	_readkey  BYTE	"The read key function worked!", 0h

	startRoom BYTE	"|-------------------------------|",0ah
	row1	  BYTE	"|                               |",0ah
	row2	  BYTE	"\                               |",0ah
	row3	  BYTE	" \                              |",0ah
	row4	  BYTE	"  \                             |",0ah
	row5	  BYTE	"  /                             |",0ah
	row6	  BYTE	" /                              |",0ah
	row7	  BYTE	"/                               |",0ah
	row8	  BYTE	"|                               |",0ah
	row9	  BYTE	"|                               |",0ah
	row10	  BYTE	"|                               |",0ah
	row11	  BYTE	"|                               |",0ah
	row12	  BYTE	"|-------------------------------|",0h


	room2			BYTE	"|-------------------------------|",0ah
	secondRow1		BYTE	"\                               |",0ah
	secondRow2		BYTE	" \                              |",0ah
	secondRow3		BYTE	"  \                             |",0ah
	secondRow4		BYTE	"   \                            |",0ah
	secondRow5		BYTE	"    \                           |",0ah
	secondRow6		BYTE	" ____\                          |",0ah
	secondRow7		BYTE	"|                               |",0ah
	secondRow8		BYTE	"|                               |",0ah
	secondRow9		BYTE	"|                               |",0ah
	secondRow10		BYTE	"|                               |",0ah
	secondRow11		BYTE	"|                               |",0ah
	secondRow12		BYTE	"|-------------------------------|",0h

.code

update PROC

	mov eax, 50
	call WriteString

update ENDP


main PROC

	mov edx, offset startRoom
	mov ecx, 255
	
mainLoop:

	call ReadChar
	.if AL == 65
		mov edx, offset _readkey
		call WriteString
		call Clrscr
	.elseif AL != 65
		mov edx, offset startRoom
		;mov eax, 200
		;call Delay
		call Clrscr
		call update
	.endif

	loop mainLoop

	exit
main ENDP
END main
