          rem
          rem ChaosFight - Source/Common/CharacterDefinitions.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Character Definitions
          rem Each character definition includes:
          rem - Weight (affects jump height, movement speed, momentum,
          rem   impact resistance/force)
          rem   - Animation graphics tables and frame counts
          rem
          rem   - Attack type (melee or ranged)
          rem   - Missile size (width × height)
          rem   - Missile emission height (on character sprite)

          rem CHARACTER NAMES (internal Documentation Only)
          rem Character 0:  Bernie
          rem Character 1:  Curler
          rem Character 2:  Dragon of Storms
          rem Character 3:  Zoe Ryen
          rem Character 4:  Fat Tony
          rem Character 5:  Megax
          rem Character 6:  Harpy
          rem Character 7:  Knight Guy
          rem Character 8:  Frooty
          rem Character 9:  Nefertem
          rem Character 10: Ninjish Guy
          rem Character 11: Pork Chop
          rem Character 12: Radish Goblin
          rem
          rem Character 13: Robo Tito
          rem Character 14: Ursulo
          rem Character 15: Shamone

          rem Character Weights
          rem Character data tables relocated to Source/Data/CharacterTables.bas

GetCharacterWeightSub
          rem
          rem Animation Sequence Definitions
          rem Animation sequences (16 total) - all use 8-frame padded
          rem   format:
          rem   0 = Standing still (facing right)
          rem   1 = Idle (resting)
          rem   2 = Standing still guarding
          rem   3 = Walking/running
          rem   4 = Coming to stop
          rem   5 = Taking a hit
          rem   6 = Falling backwards
          rem   7 = Falling down
          rem   8 = Fallen down
          rem   9 = Recovering to standing
          rem  10 = Jumping
          rem  11 = Falling after jump
          rem  12 = Landing
          rem  13 = Attack windup
          rem  14 = Attack execution
          rem  15 = Attack recovery
          rem
          rem Note: All animations use 8 bytes per sequence with padding
          rem Frame counts are implicit in the data structure (all 8
          rem   frames)
          rem Animation Frame References
          rem Each animation sequence consists of 1, 2, 4, or 8 frame
          rem   references
          rem Frame references are always written as 8 bytes (padded
          rem   with repeats)
          rem Frame references are relative to the 8px × 16px 16-byte
          rem   bitmap set
          rem Format examples:
          rem   1 frame:  (1, 1, 1, 1, 1, 1, 1, 1)
          rem   2 frames: (1, 2, 1, 2, 1, 2, 1, 2)
          rem   4 frames: (1, 2, 3, 4, 1, 2, 3, 4)
          rem   8 frames: (1, 2, 3, 4, 5, 6, 7, 8)
          rem Animation frame reference tables (NumCharacters characters
          rem   × 16 sequences × 8 bytes)
          rem Each character animation data is 128 bytes (16 sequences ×
          rem   8 bytes)
          rem Graphics Data Structure
          rem Each character has:
          rem   - 8px × 16px bitmap data (16 bytes per frame)
          rem   - Frame references point to these 16-byte blocks
          rem
          rem   - Graphics data will be loaded from ROM
          rem - Duplicate frames are compacted, gaps removed, empty
          rem   frames padded
          rem Character Definition Lookup Subroutines
          rem Return character weight based on CharacterWeights table
          rem
          rem Input: temp1 = character index (0-15)
          rem
          rem Output: temp4 = weight value
          rem
          rem Mutates: temp4
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must share bank with CharacterWeights data
          let temp4 = CharacterWeights(temp1)
          return

GetCharacterAttackTypeSub
          rem Decode bit-packed attack type for the requested character
          rem
          rem Input: temp1 = character index (0-15)
          rem
          rem Output: temp4 = attack type (0=melee, 1=ranged)
          rem
          rem Mutates: temp2-temp5
          rem
          rem Called Routines: None
          rem
          rem Constraints: CharacterAttackTypes table must share bank
          let temp3 = temp1 / 8
          let temp2 = temp1 & 7
          let temp4 = CharacterAttackTypes[temp3]
          let temp5 = temp2
GetCharacterAttackTypeSubShiftLoop
          if temp5 = 0 then goto GetCharacterAttackTypeSubShiftDone
          let temp4 = temp4 / 2
          let temp5 = temp5 - 1
          goto GetCharacterAttackTypeSubShiftLoop
GetCharacterAttackTypeSubShiftDone
          let temp4 = temp4 & 1
          return

GetMissileDimsSub
          rem Retrieve missile width and height for the character
          rem
          rem Input: temp1 = character index (0-15)
          rem
          rem Output: temp3 = missile width, temp4 = missile height
          rem
          rem Mutates: temp3-temp4
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must share bank with missile dimension tables
          let temp3 = CharacterMissileWidths(temp1)
          let temp4 = CharacterMissileHeights(temp1)
          return

GetMissileEmissionHeightSub
          rem Get missile emission height from character data
          rem
          rem Input: temp1 = character index (0-15)
          rem
          rem Output: temp4 = emission height in pixels
          rem
          rem Mutates: temp4
          rem
          rem Called Routines: None
          rem
          rem Constraints: Table access requires same bank residency
          let temp4 = CharacterMissileEmissionHeights(temp1)
          return

GetMissileMomentumXSub
          rem Fetch missile horizontal momentum for the character
          rem
          rem Input: temp1 = character index (0-15)
          rem
          rem Output: temp4 = horizontal momentum (signed)
          rem
          rem Mutates: temp4
          rem
          rem Called Routines: None
          rem
          rem Constraints: Shares bank with CharacterMissileMomentumX
          let temp4 = CharacterMissileMomentumX(temp1)
          return

GetMissileMomentumYSub
          rem Fetch missile vertical momentum for the character
          rem
          rem Input: temp1 = character index (0-15)
          rem
          rem Output: temp4 = vertical momentum (signed)
          rem
          rem Mutates: temp4
          rem
          rem Called Routines: None
          rem
          rem Constraints: Shares bank with CharacterMissileMomentumY
          let temp4 = CharacterMissileMomentumY(temp1)
          return

GetMissileFlagsSub
          rem Retrieve missile flag bitfield for the character
          rem
          rem Input: temp1 = character index (0-15)
          rem
          rem Output: temp4 = missile flags
          rem
          rem Mutates: temp4
          rem
          rem Called Routines: None
          rem
          rem Constraints: Shares bank with CharacterMissileFlags table
          let temp4 = CharacterMissileFlags(temp1)
          return

          rem
          rem Data Format Notes For Skylinetool Output

          rem SkylineTool should emit batariBasic-compatible data in
          rem   this format:

          rem 1. Animation frame references (8 bytes per sequence):
          rem    data Character0Animations
          rem     1, 1, 1, 1, 1, 1, 1, 1     ; 1 frame
          rem     1, 2, 1, 2, 1, 2, 1, 2     ; 2 frames
          rem     4, 5, 6, 7, 4, 5, 6, 7     ; 4 frames
          rem     1, 2, 3, 4, 5, 6, 7, 8     ; 8 frames
          rem    end             ; terminate animation table

          rem 2. Graphics data (16 bytes bitmap):
          rem    data Character0Graphics
          rem     %01110010, %11010011, ...  ; 16 bytes bitmap data
          rem    end             ; terminate bitmap table

          rem 3. Frame compaction:
          rem    - Duplicate frames: compact into single frame reference
          rem    - Gaps: removed during compaction
          rem    - Padding: fill with repeats (1->1,1,1,1,1,1,1,1)

          rem 4. Each character needs:
          rem - 16 animation sequences × 8 bytes = 128 bytes frame
          rem   references
          rem - Variable number of unique graphics frames × 32 bytes =
          rem   graphics data
          rem - Total per character: ~128 + (unique_frames × 32) bytes

          rem 5. Output file format: Source/Generated/CharacterData.bas
          rem    This file will be included in the build process
