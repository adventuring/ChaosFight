          ;;
;;; ChaosFight - Source/Common/CharacterDefinitions.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

;;; Character Definitions
          ;; Each character definition includes:
          ;; - Weight (affects jump height, movement speed, momentum,
          ;; impact resistance/force)
          ;; - Animation graphics tables and frame counts
          ;;
          ;; - Attack type (mêlée or ranged)
          ;; - Missile size (width × height)
          ;; - Missile emission height (on character sprite)

          ;; CHARACTER NAMES (internal Documentation Only)
          ;; Character 0:  Bernie
          ;; Character 1:  Curler
          ;; Character 2:  Dragon of Storms
          ;; Character 3:  Zoe Ryen
          ;; Character 4:  Fat Tony
          ;; Character 5:  Megax
          ;; Character 6:  Harpy
          ;; Character 7:  Knight Guy
          ;; Character 8:  Frooty
          ;; Character 9:  Nefertem
          ;; Character 10: Ninjish Guy
          ;; Character 11: Pork Chop
          ;; Character 12: Radish Goblin
          ;;
          ;; Character 13: Robo Tito
          ;; Character 14: Ursulo
          ;; Character 15: Shamone

          ;; Character Weights
          ;; Character data tables relocated to Source/Data/CharacterTables.bas

GetCharacterWeightSub
          ;;
          ;; Animation Sequence Definitions
          ;; Animation sequences (16 total) - all use 8-frame padded
          format:
          ;; 0 = Standing still (facing right)
          ;; 1 = Idle (resting)
          ;; 2 = Standing still guarding
          ;; 3 = Walking/running
          ;; 4 = Coming to stop
          ;; 5 = Taking a hit
          ;; 6 = Falling backwards
          ;; 7 = Falling down
          ;; 8 = Fallen down
          ;; 9 = Recovering to sta

          ;; 10 = Jumping
          ;; 11 = Falling after jump
          ;; 12 = Landing
          ;; 13 = Attack windup
          ;; 14 = Attack execution
          ;; 15 = Attack recovery
          ;;
          ;; Note: All animations use 8 bytes per sequence with padding
          ;; Frame counts are implicit in the data structure (all 8
          ;; frames)
          ;; Animation Frame References
          ;; Each animation sequence consists of 1, 2, 4, or 8 frame
          ;; references
          ;; Frame references are always written as 8 bytes (padded
          ;; with repeats)
          ;; Frame references are relative to the 8px × 16px 16-byte
          ;; bitmap set
          ;; Format examples:
          ;; 1 frame:  (1, 1, 1, 1, 1, 1, 1, 1)
          ;; 2 frames: (1, 2, 1, 2, 1, 2, 1, 2)
          ;; 4 frames: (1, 2, 3, 4, 1, 2, 3, 4)
          ;; 8 frames: (1, 2, 3, 4, 5, 6, 7, 8)
          ;; Animation frame reference tables (NumCharacters characters
          ;; × 16 sequences × 8 bytes)
          ;; Each character animation data is 128 bytes (16 sequences x
          ;; 8 bytes)
          ;; Graphics Data Structure
          ;; Each character has:
          ;; - 8px × 16px bitmap data (16 bytes per frame)
          ;; - Frame references point to these 16-byte blocks
          ;;
          ;; - Graphics data will be loaded from ROM
          ;; - Duplicate frames are compacted, gaps removed, empty
          ;; frames padded
          ;; Character Definition Lookup Subroutines
          Return character weight based on CharacterWeights table
          ;;
          ;; Input: temp1 = character index (0-15)
          ;;
          ;; Output: temp4 = weight value
          ;;
          ;; Mutates: temp4
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must share bank with CharacterWeights data
          let temp4 = CharacterWeights[temp1]
          return thisbank
GetCharacterAttackTypeSub
          ;; Decode bit-packed attack type for the requested character
          ;;
          ;; Input: temp1 = character index (0-15)
          ;;
          ;; Output: temp4 = attack type (0=mêlée, 1=ranged)
          ;;
          ;; Mutates: temp2-temp5
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: CharacterAttackTypes table must share bank
          let temp3 = temp1 / 8
          let temp2 = temp1 & 7
          let temp4 = CharacterAttackTypes[temp3]
          let temp5 = temp2
GetCharacterAttackTypeSubShiftLoop
          ;; If temp5 = 0, then jmp GetCharacterAttackTypeSubShiftDone
          lda temp5
          beq GetCharacterAttackTypeSubShiftDone
          ;; Use bit shift instead of division (optimized for Atari 2600)
asm:

            lsr temp4
end:
          let temp5 = temp5 - 1
          jmp GetCharacterAttackTypeSubShiftLoop
GetCharacterAttackTypeSubShiftDone
          let temp4 = temp4 & 1
          return thisbank
GetMissileDimsSub
          ;; Retrieve missile width and height for the character
          ;;
          ;; Input: temp1 = character index (0-15)
          ;;
          ;; Output: temp3 = missile width, temp4 = missile height
          ;;
          ;; Mutates: temp3-temp4
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must share bank with missile dimension tables
          let temp3 = CharacterMissileWidths[temp1]
          let temp4 = CharacterMissileHeights[temp1]
          return thisbank
GetMissileEmissionHeightSub
          ;; Get missile emission height from character data
          ;;
          ;; Input: temp1 = character index (0-15)
          ;;
          ;; Output: temp4 = emission height in pixels
          ;;
          ;; Mutates: temp4
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Table access requires same bank residency
          let temp4 = CharacterMissileEmissionHeights[temp1]
          return thisbank
GetMissileMomentumXSub
          ;; Fetch missile horizontal momentum for the character
          ;;
          ;; Input: temp1 = character index (0-15)
          ;;
          ;; Output: temp4 = horizontal momentum (signed)
          ;;
          ;; Mutates: temp4
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Shares bank with CharacterMissileMomentumX
          let temp4 = CharacterMissileMomentumX[temp1]
          return thisbank
GetMissileMomentumYSub
          ;; Fetch missile vertical momentum for the character
          ;;
          ;; Input: temp1 = character index (0-15)
          ;;
          ;; Output: temp4 = vertical momentum (signed)
          ;;
          ;; Mutates: temp4
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Shares bank with CharacterMissileMomentumY
          let temp4 = CharacterMissileMomentumY[temp1]
          return thisbank
GetMissileFlagsSub
          ;; Retrieve missile flag bitfield for the character
          ;;
          ;; Input: temp1 = character index (0-15)
          ;;
          ;; Output: temp4 = missile flags
          ;;
          ;; Mutates: temp4
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Shares bank with CharacterMissileFlags table
          let temp4 = CharacterMissileFlags[temp1]
          return thisbank
          ;;
          Data Format Notes For Skylinetool Output

          ;; SkylineTool should emit batariBasic-compatible data in
          ;; this format:

          ;; 1. Animation frame references (8 bytes per sequence):
          data Character0Animations
          ;; 1, 1, 1, 1, 1, 1, 1, 1     ; 1 frame
          ;; 1, 2, 1, 2, 1, 2, 1, 2     ; 2 frames
          ;; 4, 5, 6, 7, 4, 5, 6, 7     ; 4 frames
          ;; 1, 2, 3, 4, 5, 6, 7, 8     ; 8 frames
          end             ; terminate animation table

          ;; 2. Graphics data (16 bytes bitmap):
          data Character0Graphics
          ;; %01110010, %11010011, ...  ; 16 bytes bitmap data
          end             ; terminate bitmap table

          ;; 3. Frame compaction:
          ;; - Duplicate frames: compact into single frame reference
          ;; - Gaps: removed during compaction
          ;; - Padding: fill with repeats (1->1,1,1,1,1,1,1,1)

          ;; 4. Each character needs:
          ;; - 16 animation sequences × 8 bytes = 128 bytes frame
          ;; references
          ;; - Variable number of unique graphics frames × 32 bytes =
          ;; graphics data
          ;; - Total per character: ~128 + (unique_frames × 32) bytes

          ;; 5. Output file format: Source/Generated/CharacterData.bas
          ;; This file will be included in the build process
