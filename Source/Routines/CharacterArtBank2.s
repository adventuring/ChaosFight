;;;; ChaosFight - Source/Routines/CharacterArtBank2.s
;;;; Copyright © 2025 Bruce-Robert Pocock.
;;;; Character artwork location system for Bank 2 (Characters 0-7 and 16-23)

;;; =================================================================
;;; CHARACTER ARTWORK LOCATION SYSTEM - BANK 2
;;; =================================================================
;;; Operates on characters 0-7 (and 16-23 as replicas)
;;; All sprite data referenced must be in Bank 2
;;; Character 16 = Character 0 (Bernie), Character 17 = Character 1 (Curler), etc.

;;; Character sprite organization: 
;;; - 16 actions (0-15), each with 8 frames (0-7)
;;; - Total: 128 sprites per character (16 actions × 8 frames)
;;; - Each sprite is 16 bytes (8x16 pixels = 16 bytes)
;;; - Sprite index = (action << 3) | frame = action * 8 + frame (0-127)
 ;;; - .byte offset = sprite_index << 4 = sprite_index * 16 (0-2032 bytes, needs 16-bit)
;;; - Address = character_base_address + byte_offset

;;; Character sprite pointer tables (Bank 2 only)
 ;;; Low .byte pointers for each character base sprite data
CharacterSpriteLBank2:
.byte < BernieFrames, < CurlerFrames, < DragonOfStormsFrames, < ZoeRyenFrames
.byte < FatTonyFrames, < MegaxFrames, < HarpyFrames, < KnightGuyFrames

 ;;; High .byte pointers for each character base sprite data
CharacterSpriteHBank2:
.byte > BernieFrames, > CurlerFrames, > DragonOfStormsFrames, > ZoeRyenFrames
.byte > FatTonyFrames, > MegaxFrames, > HarpyFrames, > KnightGuyFrames

;;; Character FrameMap pointer tables (Bank 2 only)
;;; Low .byte pointers for each character FrameMap
CharacterFrameMapLBank2:
.byte < BernieFrameMap, < CurlerFrameMap, < DragonOfStormsFrameMap, < ZoeRyenFrameMap
.byte < FatTonyFrameMap, < MegaxFrameMap, < HarpyFrameMap, < KnightGuyFrameMap

;;; High .byte pointers for each character FrameMap
CharacterFrameMapHBank2:
.byte > BernieFrameMap, > CurlerFrameMap, > DragonOfStormsFrameMap, > ZoeRyenFrameMap
.byte > FatTonyFrameMap, > MegaxFrameMap, > HarpyFrameMap, > KnightGuyFrameMap

;;; =================================================================
;;; CHARACTER ARTWORK LOCATION FUNCTION - BANK 2
;;; =================================================================
;;; Locates character sprite data for specific action and frame
;;; Input: A = character index (0-7 or 16-23, mapped to 0-7)
;;;        X = animation frame (0-7) from sprite 10fps counter, NOT global frame
;;;        Y = action (0-15)
;;; Note: Frame is relative to sprite own 10fps counter, NOT global frame counter
 ;;; Output: temp4 = sprite data pointer low .byte
 ;;;         temp5 = sprite data pointer high .byte
;;; Modifies: A,x,y, temp1, temp2, temp4, temp5

LocateCharacterArtBank2 .proc
          ;;; Input: temp6 = bank-relative character index (0-7)
          ;;;        temp2 = animation frame (0-7)
          ;;;        temp3 = action (0-15)
          ;;; Note: temp6 is passed from dispatcher, already 0-7 for Bank 2

          ;;; Save bank-relative character index (we'll need it for both FrameMap and Frames)
          lda temp6
          pha
          ;; Save on sta


          ;;; Get FrameMap pointer for character
          ldy temp6
          ;; Bank-relative character index (0-7) as Y
          ;; lda CharacterFrameMapLBank2,y (duplicate)
          sta temp1
          ;; Store FrameMap low .byte in temp1
          ;; lda CharacterFrameMapHBank2,y (duplicate)
          ;; pha (duplicate)
          ;; Save FrameMap high .byte on sta


          ;;; Calculate FrameMap index: FrameMap_index = action * 8 + frame
          ;;; action is in temp3 (0-15), frame is in temp2 (0-7)
          ;; lda temp3 (duplicate)
          ;; Load action
          asl
          ;; action << 1
          ;; asl (duplicate)
          ;; action << 2
          ;; asl (duplicate)
          ;; action << 3 (action * 8)
          clc
frame:


action:


          tay
          ;; Use as index into FrameMap (0-127)

          ;;; Set up indirect pointer for FrameMap lookup
          pla
          ;; Restore FrameMap high .byte
          ;; sta temp5 (duplicate)
          ;; Store in temp5 for indirect addressing
          ;;; temp1/temp5 now point to FrameMap

          ;;; Look up actual frame index from FrameMap
          ;; lda (temp1),y       ;; Load FrameMap[FrameMap_index] - this is the actual frame index (8-bit) (duplicate)
          ;; sta temp1 (duplicate)
          ;; Store actual frame index low .byte in temp1

          ;;; Zero-extend frame index to 16-bit (clear high .byte)
          ;; lda # 0 (duplicate)
          ;; sta temp2 (duplicate)
          ;; temp2 = frame_index high .byte (zero-extended)
          ;;; Now temp1/temp2 = 16-bit frame_index (0-255, zero-extended)

          ;;; Get base Frames pointer for character
          ;; pla (duplicate)
          ;; Restore bank-relative character index
          ;; tay (duplicate)
          ;; Use as index
          ;; lda CharacterSpriteLBank2,y (duplicate)
          ;; sta temp4 (duplicate)
          ;; Store Frames low .byte in temp4
          ;; lda CharacterSpriteHBank2,y (duplicate)
          ;; sta temp5 (duplicate)
          ;; Store Frames high .byte in temp5

          ;;; Calculate .byte offset: offset = frame_index * 16 (frame_index << 4)
          ;;; temp1/temp2 = 16-bit frame_index (0-255, zero-extended)
          ;;; We need: offset = frame_index * 16
          ;;; Since frame_index can be up to 255, offset can be up to 4080 (needs 16-bit)

          ;;; Multiply 16-bit frame_index by 16 (shift left 4 times)
          ;; lda temp1 (duplicate)
          ;; Load frame_index low .byte
          ;; asl (duplicate)
          ;; << 1 (multiply by 2)
          rol temp2
          ;; Rotate carry into high .byte
          ;; asl (duplicate)
          ;; << 1 (multiply by 4)
          ;; rol temp2 (duplicate)
          ;; Rotate carry into high .byte
          ;; asl (duplicate)
          ;; << 1 (multiply by 8)
          ;; rol temp2 (duplicate)
          ;; Rotate carry into high .byte
          ;; asl (duplicate)
          ;; << 1 (multiply by 16)
          ;; rol temp2 (duplicate)
          ;; Rotate carry into high .byte
          ;;; Now A = low .byte of offset, temp2 = high .byte of offset

          ;;; Add offset to base Frames address (16-bit addition)
          ;; clc (duplicate)
          adc temp4
          ;; Add low .byte of offset to low .byte of base
          ;; sta temp4 (duplicate)
          ;; Store result low .byte
          ;; lda temp2 (duplicate)
          ;; Load high .byte of offset
          ;; adc temp5 (duplicate)
          ;; Add high .byte of offset to high .byte of base (with carry)
          ;; sta temp5 (duplicate)
          ;; Store result high .byte

          ;;; CRITICAL: This routine may be called cross-bank, so must use BS_return
          ;;; instead of rts to properly decode encoded return address
          jmp BS_return
.pend

;;; =================================================================
 ;;; = PLAYER CHARACTER ART - BANK 2
;;; =================================================================
;;; Copy character sprite data from ROM to RAM and set sprite height
;;; Input: temp1 = character index, temp2 = animation frame (0-7), temp3 = action (0-15)
;;;        temp4 = player number (0-3)
;;; Note: Sprite pointers are already initialized to RAM addresses by InitializeSpritePointers
;;;       This routine copies sprite data from ROM to the appropriate RAM buffer
SetPlayerCharacterArtBank2 .proc
          ;;; Input: temp6 = bank-relative character index (0-7) - already set by dispatcher
          ;;;        temp2 = animation frame (0-7) - already set by caller
          ;;;        temp3 = action (0-15) - already set by caller
          ;;;        temp5 = player number (0-3) - already set by caller
          ;;; CRITICAL: Optimized to avoid pha/pla to keep peak stack usage <= 16 bytes
          ;;; Save player number in X register instead of stack (saves 1 .byte peak stack usage)
          ldx temp5
          ;; Save player number in X register

          ;;; INLINED LocateCharacterArtBank2 (saves 2 bytes on stack by avoiding jsr

          ;;; Save bank-relative character index in Y register temporarily (saves 1 .byte peak stack usage)
          ;; ldy temp6 (duplicate)
          ;; Save bank-relative character index in Y register

          ;;; Get FrameMap pointer for character
          ;;; Y already has bank-relative character index (0-7)
          ;; lda CharacterFrameMapLBank2,y (duplicate)
          ;; sta temp1 (duplicate)
          ;; Store FrameMap low .byte in temp1
          ;; lda CharacterFrameMapHBank2,y (duplicate)
          ;; sta temp4 (duplicate)
          ;; Save FrameMap high .byte in temp4 temporarily (saves 1 .byte peak stack usage)

          ;;; Calculate FrameMap index: FrameMap_index = action * 8 + frame
          ;;; action is in temp3 (0-15), frame is in temp2 (0-7)
          ;; lda temp3 (duplicate)
          ;; Load action
          ;; asl (duplicate)
          ;; action << 1
          ;; asl (duplicate)
          ;; action << 2
          ;; asl (duplicate)
          ;; action << 3 (action * 8)
          ;; clc (duplicate)
;; frame: (duplicate)


;; action: (duplicate)


          ;; tay (duplicate)
          ;; Use as index into FrameMap (0-127)

          ;;; Set up indirect pointer for FrameMap lookup
          ;; lda temp4 (duplicate)
          ;; Restore FrameMap high .byte from temp4
          ;; sta temp5 (duplicate)
          ;; Store in temp5 for indirect addressing
          ;;; temp1/temp5 now point to FrameMap

          ;;; Look up actual frame index from FrameMap
          ;; lda (temp1),y       ;; Load FrameMap[FrameMap_index] - this is the actual frame index (8-bit) (duplicate)
          ;; sta temp1 (duplicate)
          ;; Store actual frame index low .byte in temp1

          ;;; Zero-extend frame index to 16-bit (clear high .byte)
          ;; lda # 0 (duplicate)
          ;; sta temp2 (duplicate)
          ;; temp2 = frame_index high .byte (zero-extended)
          ;;; Now temp1/temp2 = 16-bit frame_index (0-255, zero-extended)

          ;;; Get base Frames pointer for character
          ;; lda temp6 (duplicate)
          ;; Reload bank-relative character index from temp6 (instead of sta

          ;; tay (duplicate)
          ;; Use as index
          ;; lda CharacterSpriteLBank2,y (duplicate)
          ;; sta temp4 (duplicate)
          ;; Store Frames low .byte in temp4
          ;; lda CharacterSpriteHBank2,y (duplicate)
          ;; sta temp5 (duplicate)
          ;; Store Frames high .byte in temp5

          ;;; Calculate .byte offset: offset = frame_index * 16 (frame_index << 4)
          ;;; temp1/temp2 = 16-bit frame_index (0-255, zero-extended)
          ;;; We need: offset = frame_index * 16
          ;;; Since frame_index can be up to 255, offset can be up to 4080 (needs 16-bit)

          ;;; Multiply 16-bit frame_index by 16 (shift left 4 times)
          ;; lda temp1 (duplicate)
          ;; Load frame_index low .byte
          ;; asl (duplicate)
          ;; << 1 (multiply by 2)
          ;; rol temp2 (duplicate)
          ;; Rotate carry into high .byte
          ;; asl (duplicate)
          ;; << 1 (multiply by 4)
          ;; rol temp2 (duplicate)
          ;; Rotate carry into high .byte
          ;; asl (duplicate)
          ;; << 1 (multiply by 8)
          ;; rol temp2 (duplicate)
          ;; Rotate carry into high .byte
          ;; asl (duplicate)
          ;; << 1 (multiply by 16)
          ;; rol temp2 (duplicate)
          ;; Rotate carry into high .byte
          ;;; Now A = low .byte of offset, temp2 = high .byte of offset

          ;;; Add offset to base Frames address (16-bit addition)
          ;; clc (duplicate)
          ;; adc temp4 (duplicate)
          ;; Add low .byte of offset to low .byte of base
          ;; sta temp4 (duplicate)
          ;; Store result low .byte
          ;; lda temp2 (duplicate)
          ;; Load high .byte of offset
          ;; adc temp5 (duplicate)
          ;; Add high .byte of offset to high .byte of base (with carry)
          ;; sta temp5 (duplicate)
          ;; Store result high .byte
          ;;; END INLINED LocateCharacterArtBank2
          ;;; After inlined LocateCharacterArtBank2:
          ;;;   temp4 = sprite data pointer low .byte (ROM address)
          ;;;   temp5 = sprite data pointer high .byte (ROM address)
          ;;;   X register = player number (saved at sta

          ;;;   temp6 is available for use

          ;;; Restore player number from X register (saved at sta

          stx temp6
          ;; Store player number in temp6 (safe to use)

          ;;; Copy sprite data from ROM to RAM buffer
          ;;; Source: ROM address in temp4/temp5
          ;;; Destination depends on player number (now in temp6):
          ;;;   Player 0 -> playerFrameBuffer_W[0-15] (r000-r015)
          ;;;   Player 1 -> playerFrameBuffer_W[16-31] (r016-r031)
          ;;;   Player 2 -> playerFrameBuffer_W[32-47] (r032-r047)
          ;;;   Player 3 -> playerFrameBuffer_W[48-63] (r048-r063)

          ;;; Set up destination pointer based on player number (in temp6)
          ;;; Save player number to stack before using it


          ;;; Optimized: Use computed offset instead of separate copy routines
          ;;; Calculate destination offset: player * 16
          ;; lda temp6 (duplicate)
          ;; Load player number (0-3)
          ;; asl (duplicate)
          ;; player * 2
          ;; asl (duplicate)
          ;; player * 4
          ;; asl (duplicate)
          ;; player * 8
          ;; asl (duplicate)
          ;; player * 16
          tax
          ;; Store offset in X for later use

          ;;; Copy 16 bytes from ROM (temp4/temp5) to playerFrameBuffer_W[offset to offset+15]
          ;;; Use X as base offset,y as loop counter (countdown from 16 to 1)
          ;; TODO: ldy #$0f            ;; Start at 16 ($10)
CopyLoopBank2:
          ;; lda (temp4),y       ;; Read from ROM (indirect addressing via temp4/temp5) (duplicate)
          ;; sta w000,x (duplicate)
          ;; Write to SCRAM (absolute indexed addressing with X base)
          inx
          ;; Increment destination offset
          dey
          ;; TODO: bpl CopyLoopBank2

SetHeightBank2:
          ;;; Set sprite height (all sprites are 16 bytes = 16 scanlines)
          ;;; Optimized: Use indexed addressing since player heights are consecutive ($B0-$B3)
          ;;; CRITICAL: Use player number from temp6 (already set at line 155), NOT from sta

          ;;; This saves 1 .byte on stack (no pha/pla needed)
          ;; ldx temp6 (duplicate)
          ;; Load player number from temp6 (0-3) - already set at line 155
          ;; lda # 16 (duplicate)
          ;; All sprites are 16 scanlines
          ;; sta player0height,x ;; Store using indexed addressing (player0height=$B0, so $B0+x = correct address) (duplicate)
          ;;; CRITICAL: This routine is called cross-bank via gosub ... bank2
          ;;; Must use jmp BS_return instead of rts to properly decode encoded return address
          ;; jmp BS_return (duplicate)
.pend


