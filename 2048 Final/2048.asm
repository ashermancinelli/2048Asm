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
rowH = 4				; variable to hold the amount of squares per row
numCell = 15			; variable to represent the 16 cells in the grid labeled 0 through 15
ranCell DWORD ?			; variable to store the value of the cell randomly generated to hold a new '2'
score BYTE 0d			; variable to store the player's score for the game
result BYTE "Score: ",0	; variable to hold the string that preceds the player's score

; these are the EQU constants which define the colors we work with 
colors BYTE 8,LightCyan,Yellow,Blue,Magenta,LightMagenta,White,Black,Red

; these are the EQU constants which define the number values of the cells we work with
vals BYTE 0,2,4,8,16,32,64,128,129

; array of bytes to hold the colors of the cells
; values are not initialized to anything because they are based off of the cell values
cellColors BYTE	?,?,?,?,
				?,?,?,?,
				?,?,?,?,
				?,?,?,?		; initializes cell colors to default

; array of bytes to hold the cell values
; values initialized to start with the same two cells each game
cellVals BYTE	0,2,0,0,
				0,0,0,0,
				0,0,2,0,
				0,0,0,0		; initializes cell values to default
shiftDirection BYTE ?		; variable to store the direction of the board shift
key BYTE ?					; variable to store the value of key pressed by player
rowIdx DWORD ?				; variable to hold the row index
shiftArray DWORD vals[0],vals[0],vals[0],vals[0] ; variable to hold the values of the shifts
colIndex DWORD ?		; variable to hold the column index
; string that is sent to the screen when the player achieves the final cell value
winString BYTE "Congratulations! YOU WON!!!", 0h

; flag to signal when the game is over
gameOver BYTE 0
; flag to indicate when a new random cell needs to be generated
putCell BYTE 0

.code
main PROC
	call PrintBoard
	call Randomize

; this is the mainloop which defines what runs every time the user enters a key
;----------------------------------------------------------------------------;
mainLoop:

	call TakeInput
	; this is used as a flag, like a psuedo boolean type, to				 ;
	; determine if the game was over or not		
	.if gameOver == 1
		jmp done
	.endif
	; this inserts a cell at a random, not already taken cell
	call RandomCell
	; clears the screen before the next printBoard proc is called			 ;
	call Clrscr																 ;
	; this prints out the board with the updated values	
	call PrintBoard
	loop mainLoop

done:
    exit
main ENDP

;----------------------------------------------------------------------------;
; This procedure waits for input from the user, and upon input, calls the appropriate 
; procedures to reflect the move in our model of the game, and then the view part of the game 
; will be updated by the print board function in the mainloop.
; this will call three procedures when the user inputs a move direction.
; the board will shift the cells in the given direction, merge like cells in 
; the direction specified, and shift the cells again in the direction 
; specified.
;----------------------------------------------------------------------------;
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

;----------------------------------------------------------------------------;
; Although we named this as mergeLEFT, this works to merge any horizontal direction.
; becuase we shift, merge, then shift again, it does not matter whehter we call 
; a merge left or right, thus we only have one function.
;----------------------------------------------------------------------------;
MergeLeft PROC
	mov esi, 0
rowLoop:
	; this is called because a typical loop cannot be called when			 ;
	; the jump is this far.	
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

		; this detects the level the given merging cells are at,			 ;
		; and increases the color level by one.	
		mov bl, cellVals[eax+1]
		.if cellVals[eax] == bl	;cellVals[eax+1]
			add score,bl
			mov edi,ecx
			mov ecx,8
			LeftLoop:
				mov dl,vals[ecx]
				.if cellVals[eax] == dl
					mov dl,vals[ecx+1]
					mov cellVals[eax], dl
					mov cellVals[eax+1], vals[0]
				.endif
			loop LeftLoop
					
			; this is the win sequence. If the user gets to the point where	 ;
			; they are merging two cells of the highest value, they have 	 ;
			; won the game, so this clears the screen adn prints out 		 ;
			; a string which tells the user they have won.	
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

;----------------------------------------------------------------------------;
; like the merge left procedure, it does not matter whether we call merge up or merge down, so there is
; only one function which we call for vertical movement.
;----------------------------------------------------------------------------;
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
			add score,bl
			mov edi,ecx
			mov ecx,8
			VertLoop:
				mov dl,vals[ecx]
				.if cellVals[eax] == dl
					mov dl,vals[ecx+1]
					mov cellVals[eax], dl
					mov cellVals[eax+rowH], vals[0]
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

;----------------------------------------------------------------------------;
; This set of procedures are all the same in how they function, they just go in different 
; directions. 
;----------------------------------------------------------------------------;
ShiftLeft PROC
	add score,0
	mov esi, 0
; the loop will run 4 times, iterating over the four rows of the board	  ;
rowLoop:
	cmp esi, rowH
	je done
	pushad
	; clears the array which holds the values of the board as they are shifted;
	mov shiftArray[0], vals[0]
	mov shiftArray[4], vals[0]
	mov shiftArray[8], vals[0]
	mov shiftArray[12], vals[0]
	mov rowIdx, esi
	mov esi, 0
	colLoop:
		cmp esi, rowH
		je innerDone
		mov eax, rowIdx
		add eax, eax
		add eax, eax
		add eax, esi
		; if the element of the board at the given point is not blank, then   ;
		; is appended to our shift arrray before being moved into the actual  ;
		; array. this functions to shift all the cells in the board in a 	  ;
		; given row to one direction.	
		.if cellVals[eax] != vals[0]
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

; this does the same thing as shift left, but instead of iteratng over the 	  ;
; rows of the board, it iterates over the columns to shift down.			  ;
; This also calls the append reversed function, as it is shifting opposite of ;
; the other shift function.	
ShiftDown PROC
	add score,0
	mov esi, 0
rowLoop:
	cmp esi, rowH
	je done
	pushad

	; this clears the array wihch will be filled so that the append method 	  ;
	; works as it is supposed to. 	
	mov shiftArray[0], vals[0]
	mov shiftArray[4], vals[0]
	mov shiftArray[8], vals[0]
	mov shiftArray[12], vals[0]
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
		.if cellVals[eax] != vals[0]
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

; same as the shift left procedure, but appends the cells and reprints 		  ;
; them to the right instead of to the left.	
ShiftRight PROC
	add score,0
	mov esi, 0
rowLoop:
	cmp esi, rowH
	je done
	pushad
	mov shiftArray[0], vals[0]
	mov shiftArray[4], vals[0]
	mov shiftArray[8], vals[0]
	mov shiftArray[12], vals[0]
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
		.if cellVals[eax] != vals[0]
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
	add score,0
rowLoop:
	cmp esi, rowH
	je done
	pushad
	mov shiftArray[0], vals[0]
	mov shiftArray[4], vals[0]
	mov shiftArray[8], vals[0]
	mov shiftArray[12], vals[0]
	mov rowIdx, esi
	mov esi, 0
	colLoop:
		cmp esi, rowH
		je innerDone
		mov eax, esi
		add eax, eax
		add eax, eax
		add eax, rowIdx
		.if cellVals[eax] != vals[0]
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

;----------------------------------------------------------------------------;;
; this iterates through all the elements of the board, assigning the  
; appropriate colors to correspond with the cell value
;----------------------------------------------------------------------------;;
SetColors PROC
	mov esi,ecx
	mov ecx,numCell
	NewColor:
		mov ebx,ecx
		.if cellVals[ebx] == vals[0]
			mov cellColors[ebx], colors[0]
		.endif
		mov ecx,8
		ColorCheck:
			mov al,vals[ecx]
			.if cellVals[ebx] == al
				mov dl,colors[ecx]
				mov cellColors[ebx],dl
			.endif
		Loop ColorCheck
		mov ecx,ebx
	Loop NewColor

	.if cellVals[0] == vals[0]
	mov cellColors[0], colors[0]
	.endif
	mov ecx,8
	ColorCheck0:
		mov al,vals[ecx]
		.if cellVals[0] == al
			mov dl,colors[ecx]
			mov cellColors[0],dl
		.endif
	Loop ColorCheck0

	mov ecx,esi
	ret
SetColors ENDP

;----------------------------------------------------------------------------;;
; this iterates through all the elements of the board, printing them out with 
; our custom print line procedure, which calls our custom set color and 
; write colored char procedures
;----------------------------------------------------------------------------;;
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

	INVOKE SetColor,colors[0],black

	mov edx,OFFSET result
	call WriteString

	mov eax,0
	mov ebx,0
	mov al,score
	call WriteInt


    INVOKE SetColor, black, black ; return to normal color
    call Crlf
	ret
PrintBoard ENDP
;----------------------------------------------------------------------------;;

; this repeates a loop which continually generates random cells until it 
; finds an empty cell, and places it there in our model. 
;----------------------------------------------------------------------------;
RandomCell PROC
	mov putCell, 0
	.repeat
		mov eax,numCell
		call RandomRange
		mov ranCell,eax

		mov eax, ranCell
		; tests to see if the cell it's looking at is already taken 		 ;
		; by another cell, if not, it will loop again. If so, 				 ;
		; the loop will terminate.			
		.if cellVals[eax] == emptyVal
			inc putCell
			lea esi,cellVals			; adds tile color to random cell
			add esi,ranCell
			mov BYTE PTR [esi],2
		.endif
		
	.until putCell == 1
	ret
RandomCell ENDP

;----------------------------------------------------------------------------;
; custom print line function which prints a single row at a time, as well
; as sets the color according to the cell's element in our model of the 
; board.
;----------------------------------------------------------------------------;
PrintLine PROC idx:BYTE
	movzx edx, idx
	mov esi,ecx

	mov edi,0
	mov ecx,rowH
	PrintLoop:
		INVOKE WriteColorChar, ' ', colors[0], cellColors[edx+edi]

		.if cellVals[edx+edi] != vals[0] && esi==1
			mov eax,0
			mov ebx,0
			mov al,cellVals[edx+edi]
			mov bl,TYPE cellVals[edx+edi]
			call WriteHexB

			INVOKE SetColor, colors[0], cellColors[edx+edi]
			mov al, ' '
			call WriteChar
			INVOKE SetColor, colors[0], cellColors[edx+edi]
			mov al, ' '
			call WriteChar

		.else
			INVOKE WriteColorChar, ' ', colors[0], cellColors[edx+edi]
		.endif

		inc edi
	loop PrintLoop

	mov ecx,esi
    ret
PrintLine ENDP

;----------------------------------------------------------------------------;
; this writes out four characters, along with the forecolor and background color,
; which makes up one square of our board. One swuare from our board is four characters
; and this proc converts one cell from our board model to our view.
;----------------------------------------------------------------------------;
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
	mov ebx, 16
	mul ebx
	movzx ebx, forecolor
	add eax, ebx
	call SetTextColor       ; from Irvine32.lib
	popad
    ret
SetColor ENDP

; These are the procedures used to transfer the array that has been appended to
; in the shifting and merging functions to the actual model of our board.
;----------------------------------------------------------------------------;
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

; this is the same as the last procedure, but iterates over columns 		 ;
; instead of rows.	
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

;----------------------------------------------------------------------------;
; This is our makeshift array appending method. It iterates through the array 
; until it found an emtpy element of the array, and inserts the given value
; when that value is found.
;----------------------------------------------------------------------------;
append PROC
	pushad
	mov ecx, rowH
	mov esi, 0
	appendValue:
		.if shiftArray[esi*rowH] == vals[0]
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

;----------------------------------------------------------------------------;
; this does the same thing as the previous procedurem, but in reverse for	 ;
; the left vs right and up vs down merging procedures.
appendReversed PROC
	pushad
	mov esi, rowH
	appendValue:
		cmp esi, 0
		je outOfLoop
		dec esi
		.if shiftArray[esi*rowH] == vals[0]
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
