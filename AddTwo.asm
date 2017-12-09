   TITLE 2048			(2048.asm)

INCLUDE Irvine32.inc
; procedure prototypes:
SetColor PROTO forecolor:BYTE, backcolor: BYTE
WriteColorChar PROTO char:BYTE, forecolor:BYTE, backcolor:BYTE
PrintLine PROTO idx:BYTE
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
cellColors BYTE	7,11,7,7,
				7,7,7,7,
				7,7,11,7,
				7,7,7,7		; initializes cell colors to default
cellVals DWORD	0,2,0,0,
				0,0,0,0,
				0,0,2,0,
				0,0,0,0		; initializes cell values to default
shiftDirection BYTE ?
key BYTE ?
rowIdx DWORD ?
shiftArray DWORD 7,7,7,7


putCell BYTE 0

.code
main PROC
	call Randomize
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
	ret
TakeInput ENDP

ShiftLeft PROC
	mov esi, 0
rowLoop:
	cmp esi, 4
	je done
	pushad
	mov shiftArray[0], 7
	mov shiftArray[4], 7
	mov shiftArray[8], 7
	mov shiftArray[12], 7
	mov rowIdx, esi
	mov esi, 0
	colLoop:
		cmp esi, 4
		je innerDone
		mov eax, rowIdx
		add eax, eax
		add eax, eax
		add eax, esi
		.if cellColors[eax] != 7
			call append
		.endif
		inc esi
		jmp colLoop
innerDone:
	call transferArray
	popad
	inc esi
	jmp rowLoop
done:
	ret
ShiftLeft ENDP

ShiftDown PROC
	mov esi, 0
rowLoop:
	cmp esi, 4
	je done
	pushad
	mov shiftArray[0], 7
	mov shiftArray[4], 7
	mov shiftArray[8], 7
	mov shiftArray[12], 7
	mov rowIdx, esi
	mov esi, 4
	colLoop:
		cmp esi, 0
		je innerDone
		dec esi
		; eax = (4 * rowIdx) + esi
		mov eax, esi
		add eax, eax
		add eax, eax
		add eax, rowIdx
		.if cellColors[eax] != 7
			call appendReversed
		.endif
		jmp colLoop
innerDone:
	call transferTransposedArray
	popad
	inc esi
	jmp rowLoop
done:
	ret
ShiftDown ENDP

ShiftRight PROC
	mov esi, 0
rowLoop:
	cmp esi, 4
	je done
	pushad
	mov shiftArray[0], 7
	mov shiftArray[4], 7
	mov shiftArray[8], 7
	mov shiftArray[12], 7
	mov rowIdx, esi
	mov esi, 4
	colLoop:
		cmp esi, 0
		je innerDone
		dec esi
		; eax = (4 * rowIdx) + esi
		mov eax, rowIdx
		add eax, eax
		add eax, eax
		add eax, esi
		.if cellColors[eax] != 7
			call appendReversed
		.endif
		jmp colLoop
innerDone:
	call transferArray
	popad
	inc esi
	jmp rowLoop
done:
	ret
ShiftRight ENDP

ShiftUp PROC
	mov esi, 0
rowLoop:
	cmp esi, 4
	je done
	pushad
	mov shiftArray[0], 7
	mov shiftArray[4], 7
	mov shiftArray[8], 7
	mov shiftArray[12], 7
	mov rowIdx, esi
	mov esi, 0
	colLoop:
		cmp esi, 4
		je innerDone
		mov eax, esi
		add eax, eax
		add eax, eax
		add eax, rowIdx
		.if cellColors[eax] != 7
			call append
		.endif
		inc esi
		jmp colLoop
innerDone:
	call transferTransposedArray
	popad
	inc esi
	jmp rowLoop
done:
	ret
ShiftUp ENDP

PrintBoard PROC
	mov ecx,rowH
	L1:		; loop for printing row 1
	INVOKE PrintLine, 0
    call Crlf
	loop L1

	mov ecx,rowH
	L2:		; loop for printing row 2
    INVOKE PrintLine, 4
    call Crlf
	loop L2
	
	mov ecx,rowH
	L3:		; loop for printing row 3
	INVOKE PrintLine, 8
    call Crlf
	loop L3

	mov ecx,rowH
	L4:		; loop for printing row 4
    INVOKE PrintLine, 12
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

		.if cellColors[eax] == 7 || cellColors[eax] == 8 
			inc putCell
			lea esi,cellColors			; adds tile color to random cell
			add esi,ranCell
			mov BYTE PTR [esi],11	
		.endif
		
	.until putCell == 1
	ret
RandomCell ENDP

PrintLine PROC idx:BYTE
	movzx ebx, idx
    INVOKE WriteColorChar, ' ', '0', cellColors[ebx+0]
    INVOKE WriteColorChar, ' ', '0', cellColors[ebx+0]
    INVOKE WriteColorChar, ' ', '0', cellColors[ebx+1]
    INVOKE WriteColorChar, ' ', '0', cellColors[ebx+1]
	INVOKE WriteColorChar, ' ', '0', cellColors[ebx+2]
    INVOKE WriteColorChar, ' ', '0', cellColors[ebx+2]
    INVOKE WriteColorChar, ' ', '0', cellColors[ebx+3]
    INVOKE WriteColorChar, ' ', '0', cellColors[ebx+3]
    ret
PrintLine ENDP

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
		mov ebx, rowIdx
		add ebx, ebx
		add ebx, ebx
		add ebx, esi
		mov cellColors[ebx], dl
		inc esi
	loop fill
	popad
	ret
transferArray ENDP

transferTransposedArray PROC
	pushad
	mov ecx, 4
	mov esi, 0
	fill:
		mov edx, shiftArray[esi*4]
		mov ebx, esi
		add ebx, ebx
		add ebx, ebx
		add ebx, rowIdx
		mov cellColors[ebx], dl
		inc esi
	loop fill
	popad
	ret
transferTransposedArray ENDP

append PROC
	pushad
	mov ecx, 4
	mov esi, 0
	appendValue:
		.if shiftArray[esi*4] == 7
			movzx ebx, cellColors[eax]
			mov shiftArray[esi*4], ebx
			jmp outOfLoop
		.endif
		inc esi
	loop appendValue
	outOfLoop:
	popad
	ret
append ENDP

appendReversed PROC
	pushad
	mov esi, 4
	appendValue:
		cmp esi, 0
		je outOfLoop
		dec esi
		.if shiftArray[esi*4] == 7
			movzx ebx, cellColors[eax]
			mov shiftArray[esi*4], ebx
			jmp outOfLoop
		.endif
	loop appendValue
	outOfLoop:
	popad
	ret
appendReversed ENDP

END MAIN
