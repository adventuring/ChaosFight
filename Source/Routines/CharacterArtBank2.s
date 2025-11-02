; ChaosFight - Source/Routines/CharacterArtBank2.s
; Copyright © 2025 Interworldly Adventuring, LLC.
; Character artwork location system for Bank 2 (Characters 0-7 and 16-23)

; =================================================================
; CHARACTER ARTWORK LOCATION SYSTEM - BANK 2
; =================================================================
; Operates on characters 0-7 (and 16-23 as replicas)
; All sprite data referenced must be in Bank 2
; Character 16 = Character 0 (Bernie), Character 17 = Character 1 (Curler), etc.

; Character sprite organization: 
; - 16 actions (0-15), each with 8 frames (0-7)
; - Total: 128 sprites per character (16 actions × 8 frames)
; - Each sprite is 16 bytes (8x16 pixels = 16 bytes)
; - Sprite index = (action << 3) | frame = action * 8 + frame (0-127)
; - Byte offset = sprite_index << 4 = sprite_index * 16 (0-2032 bytes, needs 16-bit)
; - Address = character_base_address + byte_offset

; Character sprite pointer tables (Bank 2 only)
; Low byte pointers for each character base sprite data
CharacterSpritePtrLoBank2:
    .byte <BernieSprite, <CurlerSprite, <DragonetSprite, <ZoeRyenSprite
    .byte <FatTonySprite, <MegaxSprite, <HarpySprite, <KnightGuySprite

; High byte pointers for each character base sprite data  
CharacterSpritePtrHiBank2:
    .byte >BernieSprite, >CurlerSprite, >DragonetSprite, >ZoeRyenSprite
    .byte >FatTonySprite, >MegaxSprite, >HarpySprite, >KnightGuySprite

; =================================================================
; CHARACTER ARTWORK LOCATION FUNCTION - BANK 2
; =================================================================
; Locates character sprite data for specific action and frame
; Input: A = character index (0-7 or 16-23, mapped to 0-7)
;        X = animation frame (0-7) from sprite 10fps counter, NOT global frame
;        Y = action (0-15)
; Note: Frame is relative to sprite own 10fps counter, NOT global frame counter
; Output: temp4 = sprite data pointer low byte
;         temp5 = sprite data pointer high byte
;         temp6 = bank number (always 2)
; Modifies: A, X, Y, temp1, temp2, temp3

LocateCharacterArtBank2:
    ; Input: temp9 = bank-relative character index (0-7)
    ;        temp2 = animation frame (0-7)
    ;        temp3 = action (0-15)
    ; Note: temp9 is passed from dispatcher, already 0-7 for Bank 2
    
    ; Set bank to 2
    lda #2
    sta temp6
    
    ; Get base sprite pointer for character (using bank-relative index in temp9)
    ldy temp9           ; Bank-relative character index (0-7) as Y
    lda CharacterSpritePtrLoBank2,y
    sta temp4           ; Store low byte
    lda CharacterSpritePtrHiBank2,y  
    sta temp5           ; Store high byte
    
    ; Calculate sprite index: index = (action << 3) | frame
    ; action is in temp3 (0-15), frame is in temp2 (0-7)
    lda temp3           ; Load action
    asl                 ; action << 1
    asl                 ; action << 2
    asl                 ; action << 3 (action * 8)
    ora temp2           ; OR with frame: (action << 3) | frame
    sta temp1           ; Store sprite index (0-127) in temp1
    
    ; Calculate byte offset: offset = index << 4 (needs 16-bit arithmetic)
    ; temp1 = sprite_index (0-127)
    ; We need: offset = sprite_index * 16
    ; Since sprite_index can be up to 127, offset can be up to 2032 (needs 16-bit)
    
    ; Clear high byte of offset (will be calculated)
    lda #0
    sta temp2           ; temp2 = high byte of offset (initially 0)
    
    ; Multiply sprite_index by 16 (shift left 4 times)
    lda temp1           ; Load sprite_index
    asl                 ; << 1 (multiply by 2)
    rol temp2           ; Rotate carry into high byte
    asl                 ; << 1 (multiply by 4)
    rol temp2           ; Rotate carry into high byte
    asl                 ; << 1 (multiply by 8)
    rol temp2           ; Rotate carry into high byte
    asl                 ; << 1 (multiply by 16)
    rol temp2           ; Rotate carry into high byte
    ; Now A = low byte of offset, temp2 = high byte of offset
    
    ; Add offset to base address (16-bit addition)
    clc
    adc temp4           ; Add low byte of offset to low byte of base
    sta temp4           ; Store result low byte
    lda temp2           ; Load high byte of offset
    adc temp5           ; Add high byte of offset to high byte of base (with carry)
    sta temp5           ; Store result high byte
    
    rts

; =================================================================
; SET PLAYER CHARACTER ART - BANK 2
; =================================================================
; Set player sprite to character artwork
; Input: temp1 = character index, temp2 = animation frame (0-7), temp3 = action (0-15)
;        temp7 = player number (0-3)
SetPlayerCharacterArtBank2:
    ; Input: temp9 = bank-relative character index (0-7) - already set by dispatcher
    ;        temp2 = animation frame (0-7) - already set by caller
    ;        temp3 = action (0-15) - already set by caller
    ;        temp8 = player number (0-3) - already set by caller
    jsr LocateCharacterArtBank2
    
    ; Set appropriate sprite pointer based on game player number (0-3)
    ; Game player assignments to multisprite kernel sprites:
    ;   Game Player 0 -> P0 (hardware sprite)
    ;   Game Player 1 -> P1 (_P1 virtual sprite)
    ;   Game Player 2 -> P2 (virtual sprite)
    ;   Game Player 3 -> P3 (virtual sprite)
    ; Note: temp8 = player number (set by dispatcher from temp7)
    lda temp8
    cmp #0
    bne .check_player1
    ; Game Player 0 -> P0 sprite
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
    ; Game Player 1 -> P1 (_P1 virtual sprite)
    lda temp4
    sta player1pointerlo
    lda temp5
    sta player1pointerhi
    lda #16
    sta player1height
    rts
    
.check_player2:
    cmp #2
    bne .player3
    ; Game Player 2 -> P2 virtual sprite
    lda temp4
    sta player2pointerlo
    lda temp5
    sta player2pointerhi
    lda #16
    sta player2height
    rts
    
.player3:
    ; Game Player 3 -> P3 virtual sprite
    lda temp4
    sta player3pointerlo
    lda temp5
    sta player3pointerhi
    lda #16
    sta player3height
    rts
