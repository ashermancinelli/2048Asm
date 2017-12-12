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
SetColors PROTO
MergeUp PROTO
MergeDown PROTO
MergeRight PROTO
MergeLeft PROTO

.data
valueB DWORD '2'
rowH = 4
numCell = 16
ranCell DWORD ?
loops = 2

emptyCol = 8
emptyVal = 0
colors BYTE 8,LightCyan,Cyan,Blue,Magenta,LightMagenta,White,Black,Red
vals BYTE 0,2,4,8,16,32,64,128,129

cellColors BYTE	?,?,?,?,
				?,?,?,?,
				?,?,?,?,
				?,?,?,?		; initializes cell colors to default
cellVals BYTE	2,2,0,0,
				0,0,0,0,
				0,0,2,0,
				0,0,0,0		; initializes cell values to default
shiftDirection BYTE ?
key BYTE ?
rowIdx DWORD ?
shiftArray DWORD emptyVal,emptyVal,emptyVal,emptyVal
colIndex DWORD ?
winString BYTE "Congratulations! YOU WON!!!", 0h
gameOver BYTE 0

putCell BYTE 0

.code
main PROC
	call Randomize
	call PrintBoard

mainLoop:

	call TakeInput
	.if gameOver == 1
		jmp done
	.endif
	call RandomCell
	call PrintBoard
	loop mainLoop

done:
    exit
main ENDP

TakeInput PROC
	call ReadChar
	mov key,al
	.if key == 97				
		call ShiftLeft
		call MergeLeft
		call ShiftLeft
	.elseif key == 115			
		call ShiftDown
		call MergeVertical
		call ShiftDown
	.elseif key == 100			
		call ShiftRight
		call MergeLeft
		call ShiftRight
	.elseif key == 119			
		call ShiftUp
		call MergeVertical
		call ShiftUp
	.endif
	ret
TakeInput ENDP

MergeLeft PROC
	mov esi, 0
rowLoop:
	cmp esi, 4
	je done
	pushad

	mov rowIdx, esi
	mov esi, 0
	colLoop:
		cmp esi, 3
		je innerDone

		mov eax, rowIdx
		add eax, eax
		add eax, eax
		add eax, esi

		mov bl, cellVals[eax+1]
		.if cellVals[eax] == bl	;cellVals[eax+1]
			mov edi,ecx
			mov ecx,7
			LeftLoop:
				mov dl,vals[ecx]
				.if cellVals[eax] == dl
					mov dl,vals[ecx+1]
					mov cellVals[eax], dl
					mov cellVals[eax+1], emptyVal
				.endif
			loop LeftLoop
			mov ecx,edi
			mov dl,vals[8]
			.if cellVals[eax] == dl
				invoke SetColor, white, black
				call clrscr
				mov edx, offset winString
				call WriteString
				call crlf
				mov gameOver, 1
			.endif
		.endif

		inc esi
		jmp colLoop
innerDone:
	popad
	inc esi
	jmp rowLoop
done:
	ret
MergeLeft ENDP


MergeVertical PROC

	mov esi, 0
rowLoop:
	cmp esi, rowH
	je done
	pushad

	mov colIndex, esi
	mov esi, 0
	colLoop:
		cmp esi, 3
		je innerDone

		mov eax, esi
		add eax, eax
		add eax, eax
		add eax, colIndex

		
		mov bl, cellVals[eax+rowH]
		.if cellVals[eax] == bl	;cellVals[eax+rowH]
			mov edi,ecx
			mov ecx,7
			VertLoop:
				mov dl,vals[ecx]
				.if cellVals[eax] == dl
					mov dl,vals[ecx+1]
					mov cellVals[eax], dl
					mov cellVals[eax+rowH], emptyVal
				.endif
			loop VertLoop
			mov ecx,edi

			mov dl,vals[8]
			.if cellVals[eax] == dl
				invoke SetColor, white, black
				call clrscr
				mov edx, offset winString
				call WriteString
				call crlf
				mov gameOver, 1
			.endif
		.endif

		inc esi
		jmp colLoop
innerDone:
	popad
	inc esi
	jmp rowLoop
done:

	ret
MergeVertical ENDP


ShiftLeft PROC
	mov esi, 0
rowLoop:
	cmp esi, rowH
	je done
	pushad
	mov shiftArray[0], emptyVal
	mov shiftArray[4], emptyVal
	mov shiftArray[8], emptyVal
	mov shiftArray[12], emptyVal
	mov rowIdx, esi
	mov esi, 0
	colLoop:
		cmp esi, rowH
		je innerDone
		mov eax, rowIdx
		add eax, eax
		add eax, eax
		add eax, esi
		.if cellVals[eax] != emptyVal
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
	cmp esi, rowH
	je done
	pushad
	mov shiftArray[0], emptyVal
	mov shiftArray[4], emptyVal
	mov shiftArray[8], emptyVal
	mov shiftArray[12], emptyVal
	mov rowIdx, esi
	mov esi, rowH
	colLoop:
		cmp esi, 0
		je innerDone
		dec esi
		mov eax, esi
		add eax, eax
		add eax, eax
		add eax, rowIdx
		.if cellVals[eax] != emptyVal
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
	cmp esi, rowH
	je done
	pushad
	mov shiftArray[0], emptyVal
	mov shiftArray[4], emptyVal
	mov shiftArray[8], emptyVal
	mov shiftArray[12], emptyVal
	mov rowIdx, esi
	mov esi, rowH
	colLoop:
		cmp esi, 0
		je innerDone
		dec esi
		mov eax, rowIdx
		add eax, eax
		add eax, eax
		add eax, esi
		.if cellVals[eax] != emptyVal
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
	cmp esi, rowH
	je done
	pushad
	mov shiftArray[0], emptyVal
	mov shiftArray[4], emptyVal
	mov shiftArray[8], emptyVal
	mov shiftArray[12], emptyVal
	mov rowIdx, esi
	mov esi, 0
	colLoop:
		cmp esi, rowH
		je innerDone
		mov eax, esi
		add eax, eax
		add eax, eax
		add eax, rowIdx
		.if cellVals[eax] != emptyVal
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

SetColors PROC
	mov esi,ecx
	mov ecx,numCell
	NewColor:
		mov ebx,ecx
		mov ecx,8
		.if cellVals[ebx] == emptyVal
			mov cellColors[ebx], emptyCol
		.endif
		ColorCheck:
			mov al,vals[ecx]
			.if cellVals[ebx] == al
				mov dl,colors[ecx]
				mov cellColors[ebx],dl
			.endif
		Loop ColorCheck
		mov ecx,ebx
	Loop NewColor

	.if cellVals[numCell] == emptyVal
		mov cellColors[0],emptyCol
	.elseif cellVals[0] == 2
		mov dl,colors[1]
		mov cellColors[0],dl
	.endif

	mov ecx,esi
	ret
SetColors ENDP

PrintBoard PROC
	INVOKE SetColors

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
		mov eax,numCell
		call RandomRange
		mov ranCell,eax

		mov eax, ranCell

		.if cellVals[eax] == emptyVal
			inc putCell
			lea esi,cellVals			; adds tile color to random cell
			add esi,ranCell
			mov BYTE PTR [esi],2
		.endif
		
	.until putCell == 1
	ret
RandomCell ENDP

PrintLine PROC idx:BYTE
	movzx edx, idx
	mov esi,ecx

	mov edi,0
	mov ecx,rowH
	PrintLoop:
		INVOKE WriteColorChar, ' ', emptyCol, cellColors[edx+edi]

		.if cellVals[edx+edi] != emptyVal && esi==1
			mov eax,0
			mov ebx,0
			mov al,cellVals[edx+edi]
			mov bl,TYPE cellVals[edx+edi]
			call WriteHexB

			INVOKE SetColor, emptyCol, cellColors[edx+edi]
			mov al, ' '
			call WriteChar
			INVOKE SetColor, emptyCol, cellColors[edx+edi]
			mov al, ' '
			call WriteChar

		.else
			INVOKE WriteColorChar, ' ', emptyCol, cellColors[edx+edi]
		.endif

		inc edi
	loop PrintLoop

	mov ecx,esi
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
	pushad
	movzx eax, backcolor
	mov ebx, numCell
	mul ebx
	movzx ebx, forecolor
	add eax, ebx
	call SetTextColor       ; from Irvine32.lib
	popad
    ret
SetColor ENDP

transferArray PROC
	pushad
	mov ecx, rowH
	mov esi, 0
	fill:
		mov edx, shiftArray[esi*rowH]
		mov ebx, rowIdx
		add ebx, ebx
		add ebx, ebx
		add ebx, esi
		mov cellVals[ebx], dl
		inc esi
	loop fill
	popad
	ret
transferArray ENDP

transferTransposedArray PROC
	pushad
	mov ecx, rowH
	mov esi, 0
	fill:
		mov edx, shiftArray[esi*rowH]
		mov ebx, esi
		add ebx, ebx
		add ebx, ebx
		add ebx, rowIdx
		mov cellVals[ebx], dl
		inc esi
	loop fill
	popad
	ret
transferTransposedArray ENDP

append PROC
	pushad
	mov ecx, rowH
	mov esi, 0
	appendValue:
		.if shiftArray[esi*rowH] == emptyVal
			movzx ebx, cellVals[eax]
			mov shiftArray[esi*rowH], ebx
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
	mov esi, rowH
	appendValue:
		cmp esi, 0
		je outOfLoop
		dec esi
		.if shiftArray[esi*rowH] == emptyVal
			movzx ebx, cellVals[eax]
			mov shiftArray[esi*rowH], ebx
			jmp outOfLoop
		.endif
	loop appendValue
	outOfLoop:
	popad
	ret
appendReversed ENDP

END MAIN
