TITLE Add and Subtract              (AddSubAlt.asm)

; This program adds and subtracts 32-bit integers.
INCLUDE Irvine32.inc

.data

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
	secondRow4		BYTE	"  /                             |",0ah
	secondRow5		BYTE	" /                              |",0ah
	secondRow6		BYTE	"/                               |",0ah
	secondRow7		BYTE	"|                               |",0ah
	secondRow8		BYTE	"|                               |",0ah
	secondRow9		BYTE	"|                               |",0ah
	secondRow10		BYTE	"|                               |",0ah
	secondRow11		BYTE	"|                               |",0ah
	secondRow12		BYTE	"|-------------------------------|",0h

.code

mainLoop PROC

	mov eax, 50
	call Delay
	call Clrscr
	call Crlf
	call WriteString

mainLoop ENDP


main PROC

	mov edx, offset startRoom
	mov ecx, 255
	
mainL:
	call mainLoop
	mov eax, 50
	call Delay
	loop mainL

	exit
main ENDP
END main
