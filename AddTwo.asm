   TITLE 2048			(2048.asm)

INCLUDE Irvine32.inc
; procedure prototypes:
SetColor PROTO forecolor:BYTE, backcolor: BYTE
WriteColorChar PROTO char:BYTE, forecolor:BYTE, backcolor:BYTE
PrintRowOdd PROTO c1:BYTE, c2:BYTE, c3:BYTE, c4:BYTE
PrintRowEven PROTO c1:BYTE, c2:BYTE, c3:BYTE, c4:BYTE
PrintBoard PROTO
RandomCell PROTO
TakeInput PROTO
ShiftLeft PROTO
ShiftRight PROTO
ShiftDown PROTO
ShiftUp PROTO

.data
rows = 4
columns = 4
rowH = 4
ranCell DWORD ?
loops = 2
color1 = 11		; light blue = 2
color2 = 9		; dark blue = 4
color3 = 5		; purple = 8
color4 = 1		; dark purple = 16
color5 = 12		; red = 32
empty = 7		; gray
empty2 = 8		; dark gray
cells BYTE	7,7,7,7,
			7,7,7,7,
			7,7,7,7,
			7,7,7,7		; initializes cell colors to an empty board
shiftDirection BYTE ?
key BYTE ?
CurrentRow DWORD ?
shiftArray DWORD 7,7,7,7


putCell BYTE 0

.code
main PROC
	call Randomize

	call RandomCell
	call RandomCell
	call PrintBoard

mainLoop:

	call TakeInput
	;call RandomCell
	call PrintBoard

	loop mainLoop


    exit
main ENDP

TakeInput PROC
	call ReadChar
	mov key,al
	.if key == 97				
		call ShiftLeft
	.elseif key == 115			
		call ShiftDown
	.elseif key == 100			
		call ShiftRight
	.elseif key == 119			
		call ShiftUp
	.endif
TakeInput ENDP

ShiftLeft PROC
	mov ecx, 4
	mov esi, 0

shiftLoop:
	pushad
	mov shiftArray[0], 7
	mov shiftArray[4], 7
	mov shiftArray[8], 7
	mov shiftArray[12], 7
	mov CurrentRow, esi
	mov ecx, 4
	mov esi, 0
	innerL:
		mov eax, CurrentRow
		add eax, eax
		add eax, eax
		add eax, esi
		.if cells[eax] != 7
			call append
		.endif
		inc esi
	loop innerL
	call transferArray
	popad
	inc esi
	loop shiftLoop
	ret
ShiftLeft ENDP

ShiftDown PROC

ShiftDown ENDP

ShiftRight PROC

ShiftRight ENDP

ShiftUp PROC

ShiftUp ENDP

PrintBoard PROC
	mov ecx,rowH
	L1:		; loop for printing row 1
	INVOKE PrintRowOdd, cells, (cells+1), (cells+2), (cells+3)
    call Crlf
	loop L1

	mov ecx,rowH
	L2:		; loop for printing row 2
    INVOKE PrintRowEven, (cells+4), (cells+5), (cells+6), (cells+7)
    call Crlf
	loop L2
	
	mov ecx,rowH
	L3:		; loop for printing row 3
	INVOKE PrintRowOdd, (cells+8), (cells+9), (cells+10), (cells+11)
    call Crlf
	loop L3

	mov ecx,rowH
	L4:		; loop for printing row 4
    INVOKE PrintRowEven, (cells+12), (cells+13), (cells+14), (cells+15)
    call Crlf
	loop L4

    INVOKE SetColor, black, black ; return to normal color
    call Crlf
	ret
PrintBoard ENDP

RandomCell PROC
	mov putCell, 0
	.repeat
		mov eax,16
		call RandomRange
		mov ranCell,eax

		mov eax, ranCell

		.if cells[eax] == 7 || cells[eax] == 8 
			inc putCell
			lea esi,cells			; adds tile color to random cell
			add esi,ranCell
			mov BYTE PTR [esi],11	
		.endif
		
	.until putCell == 1
	ret
RandomCell ENDP

PrintRowOdd PROC c1:BYTE, c2:BYTE, c3:BYTE, c4:BYTE
    INVOKE WriteColorChar, ' ', c1, c1
    INVOKE WriteColorChar, ' ', c1, c1
    INVOKE WriteColorChar, ' ', c2, c2
    INVOKE WriteColorChar, ' ', c2, c2
	INVOKE WriteColorChar, ' ', c3, c3
    INVOKE WriteColorChar, ' ', c3, c3
    INVOKE WriteColorChar, ' ', c4, c4
    INVOKE WriteColorChar, ' ', c4, c4
    ret
PrintRowOdd ENDP

PrintRowEven PROC c1:BYTE, c2:BYTE, c3:BYTE, c4:BYTE
    INVOKE WriteColorChar, ' ', c1, c1
    INVOKE WriteColorChar, ' ', c1, c1
    INVOKE WriteColorChar, ' ', c2, c2
    INVOKE WriteColorChar, ' ', c2, c2
	INVOKE WriteColorChar, ' ', c3, c3
    INVOKE WriteColorChar, ' ', c3, c3
    INVOKE WriteColorChar, ' ', c4, c4
    INVOKE WriteColorChar, ' ', c4, c4
    ret
PrintRowEven ENDP

WriteColorChar PROC USES eax, char:BYTE, forecolor:BYTE, backcolor:BYTE 
    INVOKE SetColor, forecolor, backcolor
    mov al, char
    call WriteChar
	INVOKE SetColor, forecolor, backcolor
    mov al, char
    call WriteChar
	INVOKE SetColor, forecolor, backcolor
    mov al, char
    call WriteChar
	INVOKE SetColor, forecolor, backcolor
    mov al, char
    call WriteChar
    ret
WriteColorChar ENDP

SetColor PROC, forecolor:BYTE, backcolor:BYTE
    movzx eax, backcolor
    shl eax, 4
    or al, forecolor
    call SetTextColor       ; from Irvine32.lib
    ret
SetColor ENDP

transferArray PROC
	pushad
	mov ecx, 4
	mov esi, 0
	fill:
		mov edx, shiftArray[esi*4]
		mov ebx, CurrentRow
		add ebx, ebx
		add ebx, ebx
		add ebx, esi
		mov cells[ebx], dl
		inc esi
	loop fill
	popad
	ret
transferArray ENDP

append PROC
	pushad
	mov ecx, 4
	mov esi, 0
	appendValue:
		.if shiftArray[esi*4] == 7
			movzx ebx, cells[eax]
			mov shiftArray[esi*4], ebx
			inc esi
			jmp outOfLoop
		.endif
		inc esi
	loop appendValue
	outOfLoop:
	popad
	ret
append ENDP

END MAIN
