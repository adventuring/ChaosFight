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
CharacterSpriteLBank2
    BYTE < BernieFrames, < CurlerFrames, < DragonOfStormsFrames, < ZoeRyenFrames
    BYTE < FatTonyFrames, < MegaxFrames, < HarpyFrames, < KnightGuyFrames

; High byte pointers for each character base sprite data  
CharacterSpriteHBank2
    BYTE > BernieFrames, > CurlerFrames, > DragonOfStormsFrames, > ZoeRyenFrames
    BYTE > FatTonyFrames, > MegaxFrames, > HarpyFrames, > KnightGuyFrames

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
; Modifies: A, X, Y, temp1, temp2, temp4, temp5

LocateCharacterArtBank2
    ; Input: temp6 = bank-relative character index (0-7)
    ;        temp2 = animation frame (0-7)
    ;        temp3 = action (0-15)
    ; Note: temp6 is passed from dispatcher, already 0-7 for Bank 2
    
    ; Get base sprite pointer for character (using bank-relative index in temp6)
    ldy temp6           ; Bank-relative character index (0-7) as Y
    lda CharacterSpriteLBank2,y
    sta temp4           ; Store low byte
    lda CharacterSpriteHBank2,y  
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
; Copy character sprite data from ROM to RAM and set sprite height
; Input: temp1 = character index, temp2 = animation frame (0-7), temp3 = action (0-15)
;        temp4 = player number (0-3)
; Note: Sprite pointers are already initialized to RAM addresses by InitializeSpritePointers
;       This routine copies sprite data from ROM to the appropriate RAM buffer
SetPlayerCharacterArtBank2
    SUBROUTINE
    ; Input: temp6 = bank-relative character index (0-7) - already set by dispatcher
    ;        temp2 = animation frame (0-7) - already set by caller
    ;        temp3 = action (0-15) - already set by caller
    ;        temp5 = player number (0-3) - already set by caller
    ; Save player number before LocateCharacterArtBank2 overwrites temp4/temp5
    lda temp5           ; Load player number
    pha                 ; Save on stack
    
    jsr LocateCharacterArtBank2
    ; After LocateCharacterArtBank2:
    ;   temp4 = sprite data pointer low byte (ROM address)
    ;   temp5 = sprite data pointer high byte (ROM address)
    ;   temp6 is available for use
    
    ; Restore player number from stack
    pla
    sta temp6           ; Store player number in temp6 (safe to use)
    
    ; Copy sprite data from ROM to RAM buffer
    ; Source: ROM address in temp4/temp5
    ; Destination depends on player number (now in temp6):
    ;   Player 0 -> w000-w015 (r000-r015)
    ;   Player 1 -> w016-w031 (r016-r031)
    ;   Player 2 -> w032-w047 (r032-r047)
    ;   Player 3 -> w048-w063 (r048-r063)
    
    ; Set up destination pointer based on player number (in temp6)
    ; Save player number to stack before using it
    lda temp6           ; Load player number (0-3)
    pha                 ; Save player number to stack
    ; Determine destination base address based on player
    cmp #0
    bne .CheckPlayer1Copy
    ; Player 0: Copy to w000-w015 (absolute address $F000)
    jmp .CopyPlayer0
.CheckPlayer1Copy
    cmp #1
    bne .CheckPlayer2Copy
    ; Player 1: Copy to w016-w031 (absolute address $F010)
    jmp .CopyPlayer1
.CheckPlayer2Copy
    cmp #2
    bne .CopyPlayer3
    ; Player 2: Copy to w032-w047 (absolute address $F020)
    jmp .CopyPlayer2
.CopyPlayer3
    ; Player 3: Copy to w048-w063 (absolute address $F030)
    jmp .CopyPlayer3Data
    
.CopyPlayer0
    ; Copy 16 bytes from ROM (temp4/temp5) to w000-w015
    ldy #0
.CopyLoop0
    lda (temp4),y       ; Read from ROM (indirect addressing via temp4/temp5)
    sta w000,y          ; Write to SCRAM (absolute indexed addressing)
    iny
    cpy #16
    bne .CopyLoop0
    jmp .SetHeight
    
.CopyPlayer1
    ; Copy 16 bytes from ROM (temp4/temp5) to w016-w031
    ldy #0
.CopyLoop1
    lda (temp4),y       ; Read from ROM
    sta w016,y          ; Write to SCRAM
    iny
    cpy #16
    bne .CopyLoop1
    jmp .SetHeight
    
.CopyPlayer2
    ; Copy 16 bytes from ROM (temp4/temp5) to w032-w047
    ldy #0
.CopyLoop2
    lda (temp4),y       ; Read from ROM
    sta w032,y          ; Write to SCRAM
    iny
    cpy #16
    bne .CopyLoop2
    jmp .SetHeight
    
.CopyPlayer3Data
    ; Copy 16 bytes from ROM (temp4/temp5) to w048-w063
    ldy #0
.CopyLoop3
    lda (temp4),y       ; Read from ROM
    sta w048,y          ; Write to SCRAM
    iny
    cpy #16
    bne .CopyLoop3
    
.SetHeight
    
    ; Set sprite height (all sprites are 16 bytes = 16 scanlines)
    ; Restore player number from stack
    pla                 ; Restore player number from stack
    sta temp6           ; Store in temp6 for height setting
    cmp #0
    bne .CheckPlayer1Height
    lda #16
    sta player0height
    rts
.CheckPlayer1Height
    cmp #1
    bne .CheckPlayer2Height
    lda #16
    sta player1height
    rts
.CheckPlayer2Height
    cmp #2
    bne .SetPlayer3Height
    lda #16
    sta player2height
    rts
.SetPlayer3Height
    lda #16
    sta player3height
    rts
