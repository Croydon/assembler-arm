	.file "source.s"
	.text 		@ legt eine Textsection fuer PrgrammCode + Konstanten an
	.align 2 	@ sorgt dafuer, dass nachfolgende Anweisungen auf einer durch 4 teilbaren Adresse liegen
			@ unteren 2 Bit sind 0
	.global main 	@ nimmt das Symbol main in die globale Sysmboltabelle auf
	.type main,function

main:
	stmfd sp!, {r4, r5, lr} @ Ruecksprungadresse und Register sichern

copy:
@ copy each number from a byte table to a word (32bit) table
	LDR r1, =Liste1 @ pointer to beginning of Liste1
	LDR r2, =Liste2 @ pointer to beginning of Liste2

	LDRB r3, [r1] @ load fist element of Liste1 into r2, the first elements represents the amount of numbers
	STR r3, [r2] @ save first element of Liste1 into Liste2

	@r4 holds temporary the current number, not neccessary here, r4 would be equal r3

	MOV r5, #1 @ foreach counter

foreach:
	LDRB r4, [r1, #1]! @ load next number from Liste1, increase pointer with write back

	BL signed

	STR r4, [r2, #9]! @ word size = 4xbyte, increase pointer with write back

	@ check if there are futher elements left
	CMP r5, r3
	ADDNE r5, #1
	BNE foreach

	B sort


signed:
@ convert each signed 8bit number to a signed 32bit number
	MOV r4, r4, LSL #24 @ fill up the remaining digits with zeros to the right
	MOV r4, r4, ASR #24 @ keep the MSB, but shift the rest of the original 8bit number back

	bx lr

sort:
@ sorts the numbers in Liste2 ascending
@ this uses a very basic bubblesort
	LDR r2, =Liste2 @ reset pointer of Liste2

	@ r3 holds amount of numbers

	@ ADD r1, r2, #4 @ r1 = pointer for the loop; skip the first number @ // not needed?

	MOV r5, r3 @ counter for outer loop

sortOuterLoop:
	CMP r5, #0 @ //#1 ??
	SUBNE r5, #1

	MOV r6, #0 @ counter for inner loop
	ADD r1, r2, #4 @ r1 = pointer for the loop; skip the first number

	BNE sortInnerLoop

	BL finish

sortInnerLoop:
	@ SUB r7, r5, #1 // not needed?

	CMP r5, r6 @ check if we are  the end of the unsorted part of the list
	BEQ sortOuterLoop

	LDR r8, [r1] @ first number for cmp
	LDR r9, [r1, #4] @ second number

	CMP r8, r9
	@ swap numbers if r8 greater than r9
	STRGE r8, [r1, #4]
	STRGE r9, [r1]

	ADD r1, r1, #4 @ increase list pointer for next loop interation
	ADD r6, r6, #1 @ increase inner loop counter

	@ CMP r7, r6 @ // not needed?
	@ BNE sortInnerLoop

	B sortInnerLoop




finish:
	ldmfd sp!, {r4, r5, pc} @ Ruecksprungadresse und Register

@ // not needed? TAB2: .word Liste2 @ Beispiel um an Adressen aus anderen Segmenten zu kommen

.Lfe1:
	.size main,.Lfe1-main

@ .data-Section fuer initialisierte Daten
	.data
@ Erster Wert der Tabelle steht fuer die Anzahl (max. 64) der Werte der Tabelle
Liste1: .byte (Liste1Ende-Liste1), -9, 8, -7, 6, -5, 4, -3, 2, -1, 0, 127, 128
Liste1Ende:

@ .comm-Section fuer nicht initialisierte Daten
	.comm Liste2, ((Liste1Ende-Liste1)*4) 	@ Speicherbereich mit der Groesse*4 von Liste1 reservieren

@ End of File
