; ChaosFight - Source/Routines/CharacterArt_Bank4.s
; Copyright © 2025 Interworldly Adventuring, LLC.
; Character artwork location system for Bank 2 (Characters 16-23 (copies of 0-7))

; =================================================================
; CHARACTER ARTWORK LOCATION SYSTEM - BANK 2
; =================================================================
; Operates on characters 0-7 (and 16-23 as copies)
; All sprite data referenced must be in Bank 2

; Character sprite organization: 8 frames × 16 sequences per character
; Bank 2 character mapping (local index 0-7, global 0-7 and 16-23)
; Characters 16-23: Copies (same as 0-7), Curler, Dragonet, EXOPilot, FatTony, Megax, Harpy, KnightGuy
; Characters 16-23: Copies of 0-7 (mapped to local indices 0-7)

; Character sprite pointer tables (Bank 4 - replicas from Bank 2)
; Low byte pointers for each character base sprite data
CharacterSpritePtrLo_Bank4:
    .byte <BernieSprite, <CurlerSprite, <DragonetSprite, <EXOPilotSprite
    .byte <FatTonySprite, <MegaxSprite, <HarpySprite, <KnightGuySprite

; High byte pointers for each character base sprite data  
CharacterSpritePtrHi_Bank4:
    .byte >BernieSprite, >CurlerSprite, >DragonetSprite, >EXOPilotSprite
    .byte >FatTonySprite, >MegaxSprite, >HarpySprite, >KnightGuySprite

; =================================================================
; ANIMATION FRAME OFFSET TABLES
; =================================================================
; Byte offsets for each animation frame within character sprite data
; Each frame is 16 bytes (16 rows × 1 byte per row)
AnimationFrameOffsets_Bank4:
    .byte 0, 16, 32, 48, 64, 80, 96, 112    ; Frames 0-7

; Sequence offsets - each sequence contains 8 frames
; Each sequence is 128 bytes (8 frames × 16 bytes per frame)
AnimationSequenceOffsets_Bank4:
    .byte 0, 128, 0, 128, 0, 128, 0, 128        ; Sequences 0-7
    .byte 0, 128, 0, 128, 0, 128, 0, 128        ; Sequences 8-15

; =================================================================
; CHARACTER ARTWORK LOCATION FUNCTION - BANK 2
; =================================================================
; Locates character sprite data for specific animation frame/sequence
; Input: A = character index (16-23, mapped to 0-7)
;        X = animation frame (0-7) 
;        Y = animation sequence (0-15)
; Output: temp4 = sprite data pointer low byte
;         temp5 = sprite data pointer high byte
;         temp6 = bank number (always 2)
; Modifies: A, X, Y, temp1, temp2, temp3

LocateCharacterArt_Bank4:
    ; Save input parameters
    sta temp1           ; Character index
    stx temp2           ; Animation frame  
    sty temp3           ; Animation sequence
    
    ; Map character index to local 0-7 range
    ; Characters 16-23 map to 0-7 (replicas of characters 0-7)
    ; Character 16 = Character 0 (Bernie), Character 17 = Character 1 (Curler), etc.
    lda temp1
    sec
    sbc #16             ; Subtract 16 to map 16-23 to 0-7
    and #$07            ; Mask to 0-7 range
    sta temp1           ; Store local index
    
    ; Set bank to 4
    lda #4
    sta temp6
    
    ; Get base sprite pointer for character (using local index)
    ldy temp1           ; Local character index as Y
    lda CharacterSpritePtrLo_Bank4,y
    sta temp4           ; Store low byte
    lda CharacterSpritePtrHi_Bank4,y  
    sta temp5           ; Store high byte
    
    ; Add sequence offset
    ldy temp3           ; Animation sequence as Y
    lda AnimationSequenceOffsets_Bank4,y
    clc
    adc temp4           ; Add to low byte
    sta temp4
    bcc .no_carry1      ; Check for carry
    inc temp5           ; Increment high byte if carry
.no_carry1:
    
    ; Add frame offset
    ldy temp2           ; Animation frame as Y
    lda AnimationFrameOffsets_Bank4,y
    clc
    adc temp4           ; Add to low byte
    sta temp4
    bcc .no_carry2      ; Check for carry
    inc temp5           ; Increment high byte if carry
.no_carry2:
    
    rts

; =================================================================
; SET PLAYER CHARACTER ART - BANK 2
; =================================================================
; Set player sprite to character artwork
; Input: temp1 = character index, temp2 = animation frame, temp3 = animation sequence
;        temp7 = player number (0-3)
SetPlayerCharacterArt_Bank4:
    lda temp1
    ldx temp2
    ldy temp3
    jsr LocateCharacterArt_Bank4
    
    ; Set appropriate player pointer based on player number
    lda temp7
    cmp #0
    bne .check_player1
    ; Player 0
    lda temp4
    sta player0pointerlo
    lda temp5  
    sta player0pointerhi
    lda #16
    sta player0height
    rts
    
.check_player1:
    cmp #1
    bne .check_player2
    ; Player 1
    lda temp4
    sta player1pointerlo
    lda temp5
    sta player1pointerhi
    lda #16
    sta player1height
    rts
    
.check_player2:
    cmp #4
    bne .check_player3
    ; Player 2 (multisprite)
    lda temp4
    sta player2pointerlo
    lda temp5
    sta player2pointerhi
    lda #16
    sta player2height
    rts
    
.check_player3:
    ; Player 3 (multisprite)
    lda temp4
    sta player3pointerlo
    lda temp5
    sta player3pointerhi
    lda #16
    sta player3height
    rts

