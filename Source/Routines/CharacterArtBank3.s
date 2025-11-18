; ChaosFight - Source/Routines/CharacterArtBank3.s
; Copyright © 2025 Interworldly Adventuring, LLC.
; Character artwork location system for Bank 3 (Characters 8-15 and 24-31)

; =================================================================
; CHARACTER ARTWORK LOCATION SYSTEM - BANK 3
; =================================================================
; Operates on characters 8-15 (and 24-31 as replicas)
; All sprite data referenced must be in Bank 3
; Character 24 = Character 8 (Frooty), Character 25 = Character 9 (Nefertem), etc.

; Character sprite organization: 
; - 16 actions (0-15), each with 8 frames (0-7)
; - Total: 128 sprites per character (16 actions × 8 frames)
; - Each sprite is 16 bytes (8x16 pixels = 16 bytes)
; - Sprite index = (action << 3) | frame = action * 8 + frame (0-127)
; - Byte offset = sprite_index << 4 = sprite_index * 16 (0-2032 bytes, needs 16-bit)
; - Address = character_base_address + byte_offset

; Character sprite pointer tables (Bank 3 only)
; Low byte pointers for each character base sprite data
CharacterSpriteLBank3
          BYTE < FrootyFrames, < NefertemFrames, < NinjishGuyFrames, < PorkChopFrames
          BYTE < RadishGoblinFrames, < RoboTitoFrames, < UrsuloFrames, < ShamoneFrames

; High byte pointers for each character base sprite data  
CharacterSpriteHBank3
          BYTE > FrootyFrames, > NefertemFrames, > NinjishGuyFrames, > PorkChopFrames
          BYTE > RadishGoblinFrames, > RoboTitoFrames, > UrsuloFrames, > ShamoneFrames

; Character FrameMap pointer tables (Bank 3 only)
; Low byte pointers for each character FrameMap
CharacterFrameMapLBank3
          BYTE < FrootyFrameMap, < NefertemFrameMap, < NinjishGuyFrameMap, < PorkChopFrameMap
          BYTE < RadishGoblinFrameMap, < RoboTitoFrameMap, < UrsuloFrameMap, < ShamoneFrameMap

; High byte pointers for each character FrameMap
CharacterFrameMapHBank3
          BYTE > FrootyFrameMap, > NefertemFrameMap, > NinjishGuyFrameMap, > PorkChopFrameMap
          BYTE > RadishGoblinFrameMap, > RoboTitoFrameMap, > UrsuloFrameMap, > ShamoneFrameMap

; =================================================================
; CHARACTER ARTWORK LOCATION FUNCTION - BANK 3
; =================================================================
; Locates character sprite data for specific action and frame
; Input: temp6 = bank-relative character index (0-7)
;        temp2 = animation frame (0-7) from sprite 10fps counter, NOT global frame
;        temp3 = action (0-15)
; Note: Frame is relative to sprite own 10fps counter, NOT global frame counter
; Output: temp4 = sprite data pointer low byte
;         temp5 = sprite data pointer high byte
; Modifies: A, X, Y, temp1, temp2, temp4, temp5

LocateCharacterArtBank3
          ; Input: temp6 = bank-relative character index (0-7) - already set by dispatcher
          ;        temp2 = animation frame (0-7) - already set by caller
          ;        temp3 = action (0-15) - already set by caller
          ; Note: temp6 is passed from dispatcher, already 0-7 for Bank 3
          
          ; Save bank-relative character index (we’ll need it for both FrameMap and Frames)
          lda temp6
          pha                 ; Save on stack
          
          ; Get FrameMap pointer for character
          ldy temp6           ; Bank-relative character index (0-7) as Y
          lda CharacterFrameMapLBank3,y
          sta temp1           ; Store FrameMap low byte in temp1
          lda CharacterFrameMapHBank3,y
          pha                 ; Save FrameMap high byte on stack
          
          ; Calculate FrameMap index: FrameMap_index = action * 8 + frame
          ; action is in temp3 (0-15), frame is in temp2 (0-7)
          lda temp3           ; Load action
          asl                 ; action << 1
          asl                 ; action << 2
          asl                 ; action << 3 (action * 8)
          clc
          adc temp2           ; Add frame: action * 8 + frame
          tay                 ; Use as index into FrameMap (0-127)
          
          ; Set up indirect pointer for FrameMap lookup
          pla                 ; Restore FrameMap high byte
          sta temp5           ; Store in temp5 for indirect addressing
          ; temp1/temp5 now point to FrameMap
          
          ; Look up actual frame index from FrameMap
          lda (temp1),y       ; Load FrameMap[FrameMap_index] - this is the actual frame index (8-bit)
          sta temp1           ; Store actual frame index low byte in temp1
          
          ; Zero-extend frame index to 16-bit (clear high byte)
          lda #0
          sta temp2           ; temp2 = frame_index high byte (zero-extended)
          ; Now temp1/temp2 = 16-bit frame_index (0-255, zero-extended)
          
          ; Get base Frames pointer for character
          pla                 ; Restore bank-relative character index
          tay                 ; Use as index
          lda CharacterSpriteLBank3,y
          sta temp4           ; Store Frames low byte in temp4
          lda CharacterSpriteHBank3,y
          sta temp5           ; Store Frames high byte in temp5
          
          ; Calculate byte offset: offset = frame_index * 16 (frame_index << 4)
          ; temp1/temp2 = 16-bit frame_index (0-255, zero-extended)
          ; We need: offset = frame_index * 16
          ; Since frame_index can be up to 255, offset can be up to 4080 (needs 16-bit)
          
          ; Multiply 16-bit frame_index by 16 (shift left 4 times)
          lda temp1           ; Load frame_index low byte
          asl                 ; << 1 (multiply by 2)
          rol temp2           ; Rotate carry into high byte
          asl                 ; << 1 (multiply by 4)
          rol temp2           ; Rotate carry into high byte
          asl                 ; << 1 (multiply by 8)
          rol temp2           ; Rotate carry into high byte
          asl                 ; << 1 (multiply by 16)
          rol temp2           ; Rotate carry into high byte
          ; Now A = low byte of offset, temp2 = high byte of offset
          
          ; Add offset to base Frames address (16-bit addition)
          clc
          adc temp4           ; Add low byte of offset to low byte of base
          sta temp4           ; Store result low byte
          lda temp2           ; Load high byte of offset
          adc temp5           ; Add high byte of offset to high byte of base (with carry)
          sta temp5           ; Store result high byte
          
          rts

; =================================================================
; SET PLAYER CHARACTER ART - BANK 3
; =================================================================
; Copy character sprite data from ROM to RAM and set sprite height
; Input: temp1 = character index, temp2 = animation frame (0-7), temp3 = action (0-15)
;        temp4 = player number (0-3)
; Note: Sprite pointers are already initialized to RAM addresses by InitializeSpritePointers
;       This routine copies sprite data from ROM to the appropriate RAM buffer
SetPlayerCharacterArtBank3
          SUBROUTINE
          ; Input: temp6 = bank-relative character index (0-7) - already set by dispatcher
          ;        temp2 = animation frame (0-7) - already set by caller
          ;        temp3 = action (0-15) - already set by caller
          ;        temp5 = player number (0-3) - already set by caller
          ; Save player number before LocateCharacterArtBank3 overwrites temp4/temp5
          lda temp5           ; Load player number
          pha                 ; Save on stack
          
          jsr LocateCharacterArtBank3
          ; After LocateCharacterArtBank3:
          ;   temp4 = sprite data pointer low byte (ROM address)
          ;   temp5 = sprite data pointer high byte (ROM address)
          ;   temp6 is available for use
          
          ; Restore player number from stack
          pla
          sta temp6           ; Store player number in temp6 (safe to use)
          pha                 ; Save player number to stack    

          ; Copy sprite data from ROM to RAM buffer
          ; Source: ROM address in temp4/temp5
          ; Destination depends on player number (now in temp6):
          ;   Player 0 -> playerFrameBuffer_W[0-15] (r000-r015)
          ;   Player 1 -> playerFrameBuffer_W[16-31] (r016-r031)
          ;   Player 2 -> playerFrameBuffer_W[32-47] (r032-r047)
          ;   Player 3 -> playerFrameBuffer_W[48-63] (r048-r063)
          
          ; Optimized: Use computed offset instead of separate copy routines
          ; Calculate destination offset: player * 16
          lda temp6           ; Load player number (0-3)
          asl                 ; player * 2
          asl                 ; player * 4
          asl                 ; player * 8
          asl                 ; player * 16
          tax                 ; Store offset in X for later use
          
          ; Copy 16 bytes from ROM (temp4/temp5) to playerFrameBuffer_W[offset to offset+15]
          ; Use X as base offset, Y as loop counter (countdown from 15 to 0)
          ldy #$0f            ; Start at 15 ($0F)
.CopyLoop
          lda (temp4),y       ; Read from ROM (indirect addressing via temp4/temp5)
          sta playerFrameBuffer_W,x          ; Write to SCRAM (absolute indexed addressing with X base)
          inx                 ; Increment destination offset
          dey
          bpl .CopyLoop

.SetHeight
          ; Set sprite height (all sprites are 16 bytes = 16 scanlines)
          ; Optimized: Use indexed addressing since player heights are consecutive ($B0-$B3)
          ; Restore player number from stack
          pla                 ; Restore player number from stack
          tax                 ; Use X as index (0-3)
          lda #16             ; All sprites are 16 scanlines
          sta player0height,x ; Store using indexed addressing (player0height=$B0, so $B0+x = correct address)
          rts
