	.file	"source.s"
	.text			@ legt eine Textsection fuer PrgrammCode + Konstanten an
	.align	2		@ sorgt dafuer, dass nachfolgende Anweisungen auf einer durch 4 teilbaren Adresse liegen
				@ unteren 2 Bit sind 0
	.global	main		@ nimmt das Symbol main in die globale Sysmboltabelle auf
	.type	main,function


main:
	push	{lr}

	bl	sub1
	bl	sub2
	bl	sub3

	pop	{pc}

sub1leaf:
@ this is getting called by sub1 and is a leaf methode
@ this checks if r1 + r2 = r3
	add 	r1, r1, r2
	cmp 	r1, r3
	movne 	r0, #0
	moveq 	r0, #1


	bx 	lr

sub1:
@ this uses only scratchregister and is not a leaf methode
@ this saves some values in the scratchregister
	mov 	r1, #1
	mov 	r2, #2
	mov 	r3, #3

	push	{lr}
	bl 		sub1leaf
	pop 	{lr}

	bx 	lr



sub2:
@ this uses only scratchregister and is a leaf methode
@ this loads the value of IP in r1, adds r0, saves the result in r2 and checks if r2 is bigger than IP
	mov 	r1, ip
	add 	r2, r1, r0
	cmp 	ip, r2
	movne 	r0, #0
	moveq 	r0, #1


	bx 	lr


sub3:
@ this uses non-scratchregister and is not a leaf methode
@ this overwrites values in r4 - r6, makes a cpm, saves result in r0, restores original values
	push 	{r4, r5, r6}

	mov 	r4, r0
	add 	r6, r4, r5, LSL #2

	cmp 	r6, #100
	movle 	r0, #0
	movgt 	r0, #1

	pop 	{r4, r5, r6}


	push 	{lr}
	bl 	sub2
	pop	{lr}

	bx 	lr


.Lfe1:
	.size	main,.Lfe1-main

@ End of File
