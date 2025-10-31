; ChaosFight - Source/Routines/CharacterArt.s
; Copyright © 2025 Interworldly Adventuring, LLC.
; Character artwork location system for multi-bank sprite data

; =================================================================
; CHARACTER ARTWORK LOCATION SYSTEM
; =================================================================
; Locates character sprite data across multiple ROM banks
; Supports animation frames (0-7) and sequences (0-15)
; Each character can have sprites distributed across banks

; Character sprite organization: 8 frames × 16 sequences per character
; Character bank mapping - which bank contains each character's base data
CharacterBankTable:
    .byte 2, 2, 2, 2    ; Characters 0-3: Bernie, Curler, Dragonet, EXOPilot
    .byte 2, 2, 2, 2    ; Characters 4-7: FatTony, Megax, Harpy, KnightGuy  
    .byte 3, 3, 3, 3    ; Characters 8-11: Frooty, Nefertem, NinjishGuy, PorkChop
    .byte 3, 3, 3, 3    ; Characters 12-15: RadishGoblin, RoboTito, Ursulo, VegDog

; Animation frame bank offsets (0 = same bank as character)
AnimationFrameBankOffsets:
    .byte 0, 0, 0, 0, 0, 0, 0, 0    ; Frames 0-7: all in base bank for now

; Character sprite pointer tables
; Low byte pointers for each character base sprite data
CharacterSpritePtrLo:
    .byte <BernieSprite, <CurlerSprite, <DragonetSprite, <EXOPilotSprite
    .byte <FatTonySprite, <MegaxSprite, <HarpySprite, <KnightGuySprite
    .byte <FrootySprite, <NefertemSprite, <NinjishGuySprite, <PorkChopSprite
    .byte <RadishGoblinSprite, <RoboTitoSprite, <UrsuloSprite, <VegDogSprite

; High byte pointers for each character base sprite data  
CharacterSpritePtrHi:
    .byte >BernieSprite, >CurlerSprite, >DragonetSprite, >EXOPilotSprite
    .byte >FatTonySprite, >MegaxSprite, >HarpySprite, >KnightGuySprite
    .byte >FrootySprite, >NefertemSprite, >NinjishGuySprite, >PorkChopSprite
    .byte >RadishGoblinSprite, >RoboTitoSprite, >UrsuloSprite, >VegDogSprite

; =================================================================
; ANIMATION FRAME OFFSET TABLES
; =================================================================
; Byte offsets for each animation frame within character sprite data
; Each frame is 16 bytes (16 rows × 1 byte per row)
AnimationFrameOffsets:
    .byte 0, 16, 32, 48, 64, 80, 96, 112    ; Frames 0-7

; Sequence offsets - each sequence contains 8 frames
; Each sequence is 128 bytes (8 frames × 16 bytes per frame)
AnimationSequenceOffsets:
    .byte 0, 128, 0, 128, 0, 128, 0, 128        ; Sequences 0-7
    .byte 0, 128, 0, 128, 0, 128, 0, 128        ; Sequences 8-15

; =================================================================
; CHARACTER ARTWORK LOCATION FUNCTION
; =================================================================
; Locates character sprite data for specific animation frame/sequence
; Input: A = character index (0-15)
;        X = animation frame (0-7) 
;        Y = animation sequence (0-15)
; Output: temp4 = sprite data pointer low byte
;         temp5 = sprite data pointer high byte
;         temp6 = bank number
; Modifies: A, X, Y, temp1, temp2, temp3

LocateCharacterArt:
    ; Save input parameters
    sta temp1           ; Character index
    stx temp2           ; Animation frame  
    sty temp3           ; Animation sequence
    
    ; Get base bank for this character
    ldy temp1           ; Character index as Y
    lda CharacterBankTable,y
    sta temp6           ; Store base bank
    
    ; Check if animation frame requires different bank
    ldy temp2           ; Animation frame as Y
    lda AnimationFrameBankOffsets,y
    clc
    adc temp6           ; Add frame bank offset to base bank
    sta temp6           ; Store final bank number
    
    ; Get base sprite pointer for character
    ldy temp1           ; Character index as Y
    lda CharacterSpritePtrLo,y
    sta temp4           ; Store low byte
    lda CharacterSpritePtrHi,y  
    sta temp5           ; Store high byte
    
    ; Add sequence offset
    ldy temp3           ; Animation sequence as Y
    lda AnimationSequenceOffsets,y
    clc
    adc temp4           ; Add to low byte
    sta temp4
    bcc .no_carry1      ; Check for carry
    inc temp5           ; Increment high byte if carry
.no_carry1:
    
    ; Add frame offset
    ldy temp2           ; Animation frame as Y
    lda AnimationFrameOffsets,y
    clc
    adc temp4           ; Add to low byte
    sta temp4
    bcc .no_carry2      ; Check for carry
    inc temp5           ; Increment high byte if carry
.no_carry2:
    
    rts

; =================================================================
; BATARIBASIC INTERFACE FUNCTIONS
; =================================================================
; These functions provide batariBasic-compatible interface

; Set player sprite to character artwork
; Input: temp1 = character index, temp2 = animation frame, temp3 = animation sequence
;        temp7 = player number (0-3)
SetPlayerCharacterArt:
    lda temp1
    ldx temp2
    ldy temp3
    jsr LocateCharacterArt
    
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
    cmp #2
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

; =================================================================
; BANK SWITCHING SUPPORT
; =================================================================
; Switch to the bank containing the desired character art
; Input: temp6 = bank number
; Output: Bank switched, previous bank saved in temp8
SwitchToArtBank:
    ; Save current bank (implementation depends on bankswitching method)
    ; This is a placeholder - actual implementation depends on banking hardware
    lda temp6           ; Target bank
    ; TODO: Implement actual bank switching based on cartridge type
    rts

; Restore previous bank
; Input: temp8 = previous bank number
RestorePreviousBank:
    ; Restore bank (implementation depends on bankswitching method)
    lda temp8           ; Previous bank
    ; TODO: Implement actual bank restoration
    rts

; Validation routines
; Validate character index is within bounds
; Input: A = character index
; Output: Carry set if invalid, clear if valid
ValidateCharacterIndex:
    cmp #16             ; Check if >= 16
    rts                 ; Carry set if invalid

; Validate animation frame is within bounds  
; Input: A = animation frame
; Output: Carry set if invalid, clear if valid
ValidateAnimationFrame:
    cmp #8              ; Check if >= 8
    rts                 ; Carry set if invalid

; Validate animation sequence is within bounds
; Input: A = animation sequence  
; Output: Carry set if invalid, clear if valid
ValidateAnimationSequence:
    cmp #16             ; Check if >= 16
    rts                 ; Carry set if invalid
