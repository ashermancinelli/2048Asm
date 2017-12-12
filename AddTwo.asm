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
MergeUp PROTO
MergeDown PROTO
MergeRight PROTO
MergeLeft PROTO

.data
rows = 4
columns = 4
rowH = 4
ranCell DWORD ?
loops = 2

; these are the EQU constants which define the colors we work with 
;---------------------------------------------------------;
color1 = 11		; light blue = 2						  ;
color2 = 9		; dark blue = 4							  ;
color3 = 5		; purple = 8							  ;
color4 = 1		; dark purple = 16						  ;
color5 = 12		; red = 32								  ;
color6 = 2												  ;
color7 = 4												  ;
color8 = 8												  ;
empty = 7		; gray									  ;
empty2 = 8		; dark gray								  ;
;---------------------------------------------------------;

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
colIndex DWORD ?
winString BYTE "Congradulations! YOU WON!!!", 0h
gameOver BYTE 0

putCell BYTE 0

.code
main PROC
	call Randomize
	call PrintBoard

; this is teh mainloop which defines what runs every time the user enters a key
;----------------------------------------------------------------------------;
mainLoop:																	 ;
																			 ;
	call TakeInput															 ;
	; this is used as a flag, like a psuedo boolean type, to				 ;
	; determine if the gaem was over or not									 ;
	.if gameOver == 1														 ;
		jmp done															 ;
	.endif																	 ;
																			 ;
	; this inserts a cell at a random, not already taken cell				 ;
	call RandomCell															 ;
																			 ;
	; clears the screen before the next printBoard proc is called			 ;
	call Clrscr																 ;
																			 ;
	; this prints out the board with the updated values						 ;
	call PrintBoard															 ;
	loop mainLoop															 ;
																			 ;
done:																		 ;
																			 ;
    exit																	 ;
main ENDP																	 ;
;----------------------------------------------------------------------------;


; This procedure waits for input from the user, and upon input, calls the appropriate 
; procedures to reflect the move in our model of the game, and then the view part of the game 
; will be updated by the print board function in the mainloop.
; this will call three procedures when the user inputs a move direction.
; the board will shift the cells in the given direction, merge like cells in 
; the direction specified, and shift the cells again in the direction 
; specified.
;----------------------------------------------------------------------------;
TakeInput PROC																 ;
	call ReadChar															 ;
	mov key,al																 ;
	.if key == 97															 ;
		call ShiftLeft														 ;
		call MergeLeft														 ;
		call ShiftLeft														 ;
	.elseif key == 115														 ;
		call ShiftDown														 ;
		call MergeVertical													 ;
		call ShiftDown														 ;
	.elseif key == 100														 ;
		call ShiftRight														 ;
		call MergeLeft														 ;
		call ShiftRight														 ;
	.elseif key == 119														 ;
		call ShiftUp														 ;
		call MergeVertical													 ;
		call ShiftUp														 ;
	.endif																	 ;
	ret																		 ;
TakeInput ENDP																 ;
;----------------------------------------------------------------------------;


; Although we named this as mergeLEFT, this works to merge any horizontal direction.
; becuase we shift, merge, then shift again, it does not matter whehter we call 
; a merge left or right, thus we only have one function.
;----------------------------------------------------------------------------;
MergeLeft PROC																 ;
	mov esi, 0																 ;
rowLoop:																	 ;
	; this is called becaseu a typical loop cannot be called when			 ;
	; the jump is this far.													 ;
	cmp esi, 4																 ;
	je done																	 ;
	pushad																	 ;
																			 ;
	mov rowIdx, esi															 ;
	mov esi, 0																 ;
	colLoop:																 ;
		cmp esi, 3															 ;
		je innerDone														 ;
																			 ;
		mov eax, rowIdx														 ;
		add eax, eax														 ;
		add eax, eax														 ;
		add eax, esi														 ;
																			 ;
		; this detects the level the given merging cells are at,			 ;
		; and increases the color level by one.								 ;
		mov bl, cellColors[eax+1]											 ;
		.if cellColors[eax] == bl	;cellColors[eax+1]						 ;
			.if cellColors[eax] == color1									 ;
				mov cellColors[eax], color2									 ;
				mov cellColors[eax+1], 7									 ;
			.elseif cellColors[eax] == color2								 ;
				mov cellColors[eax], color3									 ;
				mov cellColors[eax+1], 7									 ;
			.elseif cellColors[eax] == color3								 ;
				mov cellColors[eax], color4									 ;
				mov cellColors[eax+1], 7									 ;
			.elseif cellColors[eax] == color4								 ;
				mov cellColors[eax], color5									 ;
				mov cellColors[eax+1], 7									 ;
			.elseif cellColors[eax] == color5								 ;
				mov cellColors[eax], color6									 ;
				mov cellColors[eax+1], 7									 ;
			.elseif cellColors[eax] == color6								 ;
				mov cellColors[eax], color7									 ;
				mov cellColors[eax+1], 7									 ;
			.elseif cellColors[eax] == color7								 ;
				mov cellColors[eax], color8									 ;
				mov cellColors[eax+1], 7									 ;
																			 ;
			; this is the win sequence. If the user gets to the point where	 ;
			; they are merging two cells of the highest value, they have 	 ;
			; won the game, so this clears the screen adn prints out 		 ;
			; a string which tells teh user they have won.					 ;
			.elseif cellColors[eax] == color8								 ;
				invoke SetColor, white, black								 ;
				call clrscr													 ;
				mov edx, offset winString									 ;
				call WriteString											 ;
				call crlf													 ;
				mov gameOver, 1												 ;
			.endif															 ;
		.endif																 ;
																			 ;
		inc esi																 ;
		jmp colLoop															 ;
innerDone:																	 ;
	popad																	 ;
	inc esi																	 ;
	jmp rowLoop																 ;
done:																		 ;
	ret																		 ;
MergeLeft ENDP																 ;
;----------------------------------------------------------------------------;


; like the merge left procedure, it does not matter whether we call merge up or merge down, so there is
; only one function which we call for vertical movement.
;----------------------------------------------------------------------------;
MergeVertical PROC															 ;
																			 ;
	mov esi, 0																 ;
rowLoop:																	 ;
	cmp esi, 4																 ;
	je done																	 ;
	pushad																	 ;
																			 ;
	mov colIndex, esi														 ;
	mov esi, 0																 ;
	colLoop:																 ;
		cmp esi, 3															 ;
		je innerDone														 ;
																			 ;
		mov eax, esi														 ;
		add eax, eax														 ;
		add eax, eax														 ;
		add eax, colIndex													 ;
																			 ;
		mov bl, cellColors[eax+4]											 ;
		.if cellColors[eax] == bl	;cellColors[eax+4]						 ;
			.if cellColors[eax] == color1									 ;
				mov cellColors[eax], color2									 ;
				mov cellColors[eax+4], 7									 ;
			.elseif cellColors[eax] == color2								 ;
				mov cellColors[eax], color3									 ;
				mov cellColors[eax+4], 7									 ;
			.elseif cellColors[eax] == color3								 ;
				mov cellColors[eax], color4									 ;
				mov cellColors[eax+4], 7									 ;
			.elseif cellColors[eax] == color4								 ;
				mov cellColors[eax], color5									 ;
				mov cellColors[eax+4], 7									 ;
			.elseif cellColors[eax] == color5								 ;
				mov cellColors[eax], color6									 ;
				mov cellColors[eax+4], 7									 ;
			.elseif cellColors[eax] == color6								 ;
				mov cellColors[eax], color7									 ;
				mov cellColors[eax+4], 7									 ;
			.elseif cellColors[eax] == color7								 ;
				mov cellColors[eax], color8									 ;
				mov cellColors[eax+4], 7									 ;
			.elseif cellColors[eax] == color8								 ;
				invoke SetColor, white, black								 ;
				call clrscr													 ;
				mov edx, offset winString									 ;
				call WriteString											 ;
				call crlf													 ;
				mov gameOver, 1												 ;
			.endif															 ;
		.endif																 ;
																			 ;
		inc esi																 ;
		jmp colLoop															 ;
innerDone:																	 ;
	popad																	 ;
	inc esi																	 ;
	jmp rowLoop																 ;
done:																		 ;
																			 ;
	ret																		 ;
MergeVertical ENDP															 ;
;----------------------------------------------------------------------------;


; This set of procedures are all the same in how they function, they just go in different 
; directions. 
;----------------------------------------------------------------------------;;
ShiftLeft PROC																  ;
	mov esi, 0																  ;
																			  ;
	; the loop will run 4 times, iterating over the four rows of the board	  ;
rowLoop:																	  ;
	cmp esi, 4																  ;
	je done																	  ;
	pushad																	  ;
	; clears the array which holds the values of the board as they are shifted;
	mov shiftArray[0], 7													  ;
	mov shiftArray[4], 7													  ;
	mov shiftArray[8], 7													  ;
	mov shiftArray[12], 7													  ;
	mov rowIdx, esi															  ;
	mov esi, 0																  ;
	colLoop:																  ;
		cmp esi, 4															  ;
		je innerDone														  ;
		mov eax, rowIdx														  ;
		add eax, eax														  ;
		add eax, eax														  ;
		add eax, esi														  ;
		; if the element of the board at the given point is not blank, then   ;
		; is appended to our shift arrray before being moved into the actual  ;
		; array. this functions to shift all the cells in the board in a 	  ;
		; given row to one direction.										  ;
		.if cellColors[eax] != 7											  ;
			call append														  ;
		.endif																  ;
		inc esi																  ;
		jmp colLoop															  ;
innerDone:																	  ;
	call transferArray														  ;
	popad																	  ;
	inc esi																	  ;
	jmp rowLoop																  ;
done:																		  ;
	ret																		  ;
ShiftLeft ENDP																  ;
																			  ;
; this does the same thing as shift left, but instead of iteratng over teh 	  ;
; rows of the board, it iterates over the columns to shift down.			  ;
; This also calls teh append reversed function, as it is shifting opposite of ;
; the other shift function.													  ;
ShiftDown PROC																  ;
	mov esi, 0																  ;
rowLoop:																	  ;
	cmp esi, 4																  ;
	je done																	  ;
	pushad																	  ;
																			  ;
	; this clears the array wihch will be filled so that the append method 	  ;
	; works as it is supposed to. 											  ;
	mov shiftArray[0], 7													  ;
	mov shiftArray[4], 7													  ;
	mov shiftArray[8], 7													  ;
	mov shiftArray[12], 7													  ;
	mov rowIdx, esi															  ;
	mov esi, 4																  ;
	colLoop:																  ;
		cmp esi, 0															  ;
		je innerDone														  ;
		dec esi																  ;
		; eax = (4 * rowIdx) + esi											  ;
		mov eax, esi														  ;
		add eax, eax														  ;
		add eax, eax														  ;
		add eax, rowIdx														  ;
		.if cellColors[eax] != 7											  ;
			call appendReversed												  ;
		.endif																  ;
		jmp colLoop															  ;
innerDone:																	  ;
	call transferTransposedArray											  ;
	popad																	  ;
	inc esi																	  ;
	jmp rowLoop																  ;
done:																		  ;
	ret																		  ;
ShiftDown ENDP																  ;
																			  ;
; same as the shift left procedure, but appends the cells and reprints 		  ;
; them to the right instead of to the left.									  ;
ShiftRight PROC																  ;
	mov esi, 0																  ;
rowLoop:																	  ;
	cmp esi, 4																  ;
	je done																	  ;
	pushad																	  ;
	mov shiftArray[0], 7													  ;
	mov shiftArray[4], 7													  ;
	mov shiftArray[8], 7													  ;
	mov shiftArray[12], 7													  ;
	mov rowIdx, esi															  ;
	mov esi, 4																  ;
	colLoop:																  ;
		cmp esi, 0															  ;
		je innerDone														  ;
		dec esi																  ;
		; eax = (4 * rowIdx) + esi											  ;
		mov eax, rowIdx														  ;
		add eax, eax														  ;
		add eax, eax														  ;
		add eax, esi														  ;
		.if cellColors[eax] != 7											  ;
			call appendReversed												  ;
		.endif																  ;
		jmp colLoop															  ;
innerDone:																	  ;
	call transferArray														  ;
	popad																	  ;
	inc esi																	  ;
	jmp rowLoop																  ;
done:																		  ;
	ret																		  ;
ShiftRight ENDP																  ;
																			  ;
ShiftUp PROC																  ;
	mov esi, 0																  ;
rowLoop:																	  ;
	cmp esi, 4																  ;
	je done																	  ;
	pushad																	  ;
	mov shiftArray[0], 7													  ;
	mov shiftArray[4], 7													  ;
	mov shiftArray[8], 7													  ;
	mov shiftArray[12], 7													  ;
	mov rowIdx, esi															  ;
	mov esi, 0																  ;
	colLoop:																  ;
		cmp esi, 4															  ;
		je innerDone														  ;
		mov eax, esi														  ;
		add eax, eax														  ;
		add eax, eax														  ;
		add eax, rowIdx														  ;
		.if cellColors[eax] != 7											  ;
			call append														  ;
		.endif																  ;
		inc esi																  ;
		jmp colLoop															  ;
innerDone:																	  ;
	call transferTransposedArray											  ;
	popad																	  ;
	inc esi																	  ;
	jmp rowLoop																  ;
done:																		  ;
	ret																		  ;
ShiftUp ENDP																  ;
;----------------------------------------------------------------------------;;

; this iterates through all the elements of the board, printing them out with 
; our custom print line procedure, which calls our custom set color and 
; write colored char procedures
;----------------------------------------------------------------------------;;
PrintBoard PROC																  ;
	mov ecx,rowH															  ;
	L1:		; loop for printing row 1										  ;
	INVOKE PrintLine, 0														  ;
    call Crlf																  ;
	loop L1																	  ;
																			  ;
	mov ecx,rowH															  ;
	L2:		; loop for printing row 2										  ;
    INVOKE PrintLine, 4														  ;
    call Crlf																  ;
	loop L2																	  ;
																			  ;
	mov ecx,rowH															  ;
	L3:		; loop for printing row 3										  ;
	INVOKE PrintLine, 8														  ;
    call Crlf																  ;
	loop L3																	  ;
																			  ;
	mov ecx,rowH															  ;
	L4:		; loop for printing row 4										  ;
    INVOKE PrintLine, 12													  ;
    call Crlf																  ;
	loop L4																	  ;
																			  ;
    INVOKE SetColor, black, black ; return to normal color					  ;
    call Crlf																  ;
	ret																		  ;
PrintBoard ENDP																  ;
;----------------------------------------------------------------------------;;

; this repeates a loop which continually generates random cells until it 
; finds an empty cell, and places it there in our model. 
;----------------------------------------------------------------------------;
RandomCell PROC																 ;
	mov putCell, 0															 ;
	.repeat																	 ;
		mov eax,16															 ;
		call RandomRange													 ;
		mov ranCell,eax														 ;
																			 ;
		mov eax, ranCell													 ;
																			 ;
		; tests to see if the cell it's looking at is already taken 		 ;
		; by another cell, if not, it will loop again. If so, 				 ;
		; the loop will terminate.											 ;
		.if cellColors[eax] == 7 || cellColors[eax] == 8 					 ;
			inc putCell														 ;
			lea esi,cellColors			; adds tile color to random cell	 ;
			add esi,ranCell													 ;
																			 ;
			; move the cell to the random cell the loop found				 ;
			mov BYTE PTR [esi],11											 ;
		.endif																 ;
																			 ;
	.until putCell == 1														 ;
	ret																		 ;
RandomCell ENDP																 ;
;----------------------------------------------------------------------------;

; custom print line function which prints a single row at a time, as well
; as sets the color according to the cell's element in our model of the 
; board.
;----------------------------------------------------------------------------;
PrintLine PROC idx:BYTE														 ;
	movzx ebx, idx															 ;
    INVOKE WriteColorChar, ' ', ' ', cellColors[ebx+0]						 ;
    INVOKE WriteColorChar, ' ', ' ', cellColors[ebx+0]						 ;
    INVOKE WriteColorChar, ' ', ' ', cellColors[ebx+1]						 ;
    INVOKE WriteColorChar, ' ', ' ', cellColors[ebx+1]						 ;
	INVOKE WriteColorChar, ' ', ' ', cellColors[ebx+2]						 ;
    INVOKE WriteColorChar, ' ', ' ', cellColors[ebx+2]						 ;
    INVOKE WriteColorChar, ' ', ' ', cellColors[ebx+3]						 ;
    INVOKE WriteColorChar, ' ', ' ', cellColors[ebx+3]						 ;
    ret																		 ;
PrintLine ENDP																 ;
;----------------------------------------------------------------------------;

; this writes out four characters, along with the forecolor and background color,
; which makes up one square of our board. One swuare from our board is four characters
; and this proc converts one cell from our board model to our view.
;----------------------------------------------------------------------------;
WriteColorChar PROC USES eax, char:BYTE, forecolor:BYTE, backcolor:BYTE 	 ;
    INVOKE SetColor, forecolor, backcolor									 ;
    mov al, char															 ;
    call WriteChar															 ;
	INVOKE SetColor, forecolor, backcolor									 ;
    mov al, char															 ;
    call WriteChar															 ;
	INVOKE SetColor, forecolor, backcolor									 ;
    mov al, char															 ;
    call WriteChar															 ;
	INVOKE SetColor, forecolor, backcolor									 ;
    mov al, char															 ;
    call WriteChar															 ;
    ret																		 ;
WriteColorChar ENDP															 ;
;----------------------------------------------------------------------------;


SetColor PROC, forecolor:BYTE, backcolor:BYTE
	pushad
    ;movzx eax, backcolor
    ;shl eax, 4
    ;or al, forecolor
	movzx eax, backcolor
	mov ebx, 16
	mul ebx
	movzx ebx, forecolor
	add eax, ebx
	call SetTextColor       ; from Irvine32.lib
	popad
    ret
SetColor ENDP

; These are the procedures used to transfer teh array that has been appended to
; in the shifting and merging functions to the actual model of our board.
;----------------------------------------------------------------------------;
transferArray PROC															 ;
	pushad																	 ;
	mov ecx, 4																 ;
	mov esi, 0																 ;
	fill:																	 ;
		mov edx, shiftArray[esi*4]											 ;
		mov ebx, rowIdx														 ;
		add ebx, ebx														 ;
		add ebx, ebx														 ;
		add ebx, esi														 ;
		mov cellColors[ebx], dl												 ;
		inc esi																 ;
	loop fill																 ;
	popad																	 ;
	ret																		 ;
transferArray ENDP															 ;
																			 ;
;----------------------------------------------------------------------------;
																			 ;
; this is the same as the last procedure, but iterates over columns 		 ;
; instead of rows.															 ;
transferTransposedArray PROC												 ;
	pushad																	 ;
	mov ecx, 4																 ;
	mov esi, 0																 ;
	fill:																	 ;
		mov edx, shiftArray[esi*4]											 ;
		mov ebx, esi														 ;
		add ebx, ebx														 ;
		add ebx, ebx														 ;
		add ebx, rowIdx														 ;
		mov cellColors[ebx], dl												 ;
		inc esi																 ;
	loop fill																 ;
	popad																	 ;
	ret																		 ;
transferTransposedArray ENDP												 ;
;----------------------------------------------------------------------------;


; This is our makeshift array appending method. It iterates through the array 
; until it found an emtpy element of the array, and inserts the given value
; when that value is found.
;----------------------------------------------------------------------------;
append PROC																	 ;
	pushad																	 ;
	mov ecx, 4																 ;
	mov esi, 0																 ;
	appendValue:															 ;
		.if shiftArray[esi*4] == 7											 ;
			movzx ebx, cellColors[eax]										 ;
			mov shiftArray[esi*4], ebx										 ;
			jmp outOfLoop													 ;
		.endif																 ;
		inc esi																 ;
	loop appendValue														 ;
	outOfLoop:																 ;
	popad																	 ;
	ret																		 ;
append ENDP																	 ;
																			 ;
;----------------------------------------------------------------------------;
																			 ;
; this does teh same thing as the previous procedurem, but in reverse for	 ;
; the left vs right and up vs down merging procedures.						 ;
appendReversed PROC															 ;
	pushad																	 ;
	mov esi, 4																 ;
	appendValue:															 ;
		cmp esi, 0															 ;
		je outOfLoop														 ;
		dec esi																 ;
		.if shiftArray[esi*4] == 7											 ;
			movzx ebx, cellColors[eax]										 ;
			mov shiftArray[esi*4], ebx										 ;
			jmp outOfLoop													 ;
		.endif																 ;
	loop appendValue														 ;
	outOfLoop:																 ;
	popad																	 ;
	ret																		 ;
appendReversed ENDP															 ;
;----------------------------------------------------------------------------;

END MAIN
