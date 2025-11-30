draw_bmp_48x2_X

	lda #0
	sta GRP0
	sta GRP1

	lda #7
	sta NUSIZ0	;7=Triplex (Player drawn three times)
	sta NUSIZ1	;7=Triplex (Player drawn three times)

	tsx
	stx aux6 ;save the stack pointer

	jsr position48

	lda #3		;2
	sta VDELP0	;3
	sta VDELP1	;3

	;enough cycles have passed for the HMOV, so we can clear HMCLR
	lda #0
	sta HMCLR
	sta WSYNC

	SLEEP 63

	jmp pf48x2_X_loop 	;3

 if >. != >[.+$52]
	align 256
 endif

pf48x2_X_loop

	lda (scorepointers+0),y 	;5
	sta GRP0			;3
	lda (scorepointers+2),y 	;5
	sta GRP1			;3
        lda (scorepointers+4),y         ;5
        sta GRP0                        ;3

        lax (scorepointers+10),y        ;5
        lda (scorepointers+8),y         ;5
        sta aux3                        ;3
        lda (scorepointers+6),y         ;5
        ldy aux3                        ;3

        sta GRP1                        ;3
        sty GRP0                        ;3
        stx GRP1                        ;3
        sty GRP0                        ;3

	ldy aux2			;3

	lda (aux5),y			;5
	sta missile0y			;3

	sleep 3

	dec aux2			;5


	lda (scorepointers+0),y 	;5
	sta GRP0			;3
	lda (scorepointers+2),y 	;5
	sta GRP1			;3
        lda (scorepointers+4),y         ;5
        sta GRP0                        ;3

        lax (scorepointers+10),y        ;5
        lda (scorepointers+8),y         ;5
        sta aux3                        ;3
        lda (scorepointers+6),y         ;5
        ldy aux3                        ;3

        sta GRP1                        ;3
        sty GRP0                        ;3
        stx GRP1                        ;3
        sty GRP0                        ;3

	sleep 4

	lda missile0y
	sta COLUP1
	sta COLUP0

	ldy aux2			;3
	bpl pf48x2_X_loop		;2/3


pf48x2_X_codeend
 ;echo "critical code in 48x2 is ",(pf48x2_X_codeend-pf48x2_X_loop), " bytes long."

	lda #0
	sta GRP0
	sta GRP1
	sta GRP0
	sta GRP1
	sta VDELP0
	sta VDELP1

	ldx aux6 ;restore the stack pointer
	txs
	rts
