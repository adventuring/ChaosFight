          rem ChaosFight - Source/Common/CharacterDefinitions.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem CHARACTER DEFINITIONS
          rem =================================================================
          rem Each character definition includes:
          rem   - Weight (affects jump height, movement speed, momentum, impact resistance/force)
          rem   - Animation graphics tables and frame counts
          rem   - Attack type (melee or ranged)
          rem   - Missile size (width × height)
          rem   - Missile emission height (on character sprite)

          rem =================================================================
          rem CHARACTER NAMES (Internal Documentation Only)
          rem =================================================================
          rem Character 0:  Bernie
          rem Character 1:  Curler
          rem Character 2:  Dragonet
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
          rem Character 13: Robo Tito
          rem Character 14: Ursulo
          rem Character 15: Veg Dog

          rem =================================================================
          rem CHARACTER WEIGHTS
          rem =================================================================
          rem Weight values affect:
          rem   - Jump height (higher weight = lower jump)
          rem   - Movement speed (higher weight = slower)
          rem   - Momentum (higher weight = more momentum when moving)
          rem   - Impact resistance (higher weight = less knocked back)
          rem   - Melee force (higher weight = more damage/knockback to opponents)
          rem Values: 1-255 (lower = lighter/faster, higher = heavier/slower/stronger)

          rem  Bernie, Curler, Dragonet, Zoe Ryen, Fat Tony, Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy, Pork Chop, Radish Goblin, Robo Tito, Ursulo, Veg Dog
          rem  heavy,  medium,     medium,   light,   heavy,  medium,     light,  heavier, light,   heavy,   very light, heavy,  very light, heavier, heavy,  medium
          data CharacterWeights
          35, 25, 20, 15, 30, 25, 15, 32, 15, 30, 10, 30, 10, 32, 30, 25
end

          rem  Bernie, Curler, Dragonet, Zoe Ryen, Fat Tony, Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy, Pork Chop, Radish Goblin, Robo Tito, Ursulo, Veg Dog
          data CharacterMissileWidths
             1, 4, 2, 2, 2, 2, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0
end

          rem  Bernie, Curler, Dragonet, Zoe Ryen, Fat Tony, Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy, Pork Chop, Radish Goblin, Robo Tito, Ursulo, Veg Dog
          data CharacterMissileHeights
             1, 2, 2, 2, 2, 2, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0
end

          rem  Bernie, Curler, Dragonet, Zoe Ryen, Fat Tony, Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy, Pork Chop, Radish Goblin, Robo Tito, Ursulo, Veg Dog
          data CharacterMissileMaxX
             4, 8, 6, 6, 6, 6, 0, 0, 6, 0, 0, 0, 0, 0, 6, 0
end

          rem  Bernie, Curler, Dragonet, Zoe Ryen, Fat Tony, Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy, Pork Chop, Radish Goblin, Robo Tito, Ursulo, Veg Dog
          data CharacterMissileMaxY
             4, 6, 6, 6, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 6, 0
end

          rem  Bernie, Curler, Dragonet, Zoe Ryen, Fat Tony, Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy, Pork Chop, Radish Goblin, Robo Tito, Ursulo, Veg Dog
          data CharacterMissileForce
             3, 5, 4, 4, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 4, 0
          end

          rem  Bernie, Curler, Dragonet, Zoe Ryen, Fat Tony, Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy, Pork Chop, Radish Goblin, Robo Tito, Ursulo, Veg Dog
          rem  melee  ranged         ranged    ranged    melee   melee           melee   melee      ranged          melee       melee      melee      melee         melee      ranged    melee
          rem  Note: Melee attacks show brief visual (sword, fist, etc.), ranged persist until hit
          data CharacterMissileLifetime
             4, 255, 255, 255, 4, 4, 5, 6, 255, 5, 4, 4, 3, 5, 255, 4
          end

          rem =================================================================
          rem BIT MASK TABLE FOR PLAYER INDEX
          rem =================================================================
          rem Bit mask values for player indices (0-3)
          rem Used for bit-flag operations on playersEliminated and missileActive
          rem Values: 1, 2, 4, 8 for players 0, 1, 2, 3 respectively
          data BitMask
             1, 2, 4, 8
          end

          rem =================================================================
          rem CHARACTER ATTACK TYPES
          rem =================================================================
          rem 0 = melee, 1 = ranged
          rem Stored as bit-per-character in packed bytes (4 bytes for up to 32 characters)

          rem  Bernie    Curler     Dragonet  Zoe Ryen Fat Tony  Grizzard   Harpy     Knight Guy
          rem  melee     ranged     melee     ranged    ranged    melee      ranged    ranged
          rem  Frooty    Nefertem   Ninjish   Pork Chop Radish    Robo Tito  Ursulo    Veg Dog
          rem  ranged    melee      melee     melee     melee     melee      ranged    melee
          rem  Harpy changed from melee to ranged (diagonal downward attack)
          data CharacterAttackTypes
              %01111111, %01000001, %00000000, %00000000
          end

          rem =================================================================
          rem MISSILE SIZE DEFINITIONS
          rem =================================================================
          rem Missile dimensions (width × height) for each character
          rem Format: width, height
          rem Melee attacks can use 0x0 if no visible missile


          rem =================================================================
          rem MISSILE EMISSION HEIGHTS
          rem =================================================================
          rem Vertical offset on character sprite where missile is emitted
          rem Values: 0-7 (top to bottom of 8-pixel tall sprite)

          rem  Bernie, Curler, Dragonet, Zoe Ryen, Fat Tony, Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy, Pork Chop, Radish Goblin, Robo Tito, Ursulo, Veg Dog
          data CharacterMissileEmissionHeights
             3, 7, 4, 4, 3, 3, 4, 4, 3, 3, 3, 3, 3, 3, 4, 3
          end

          rem =================================================================
          rem MISSILE INITIAL MOMENTUM X (Horizontal Velocity)
          rem =================================================================
          rem Initial horizontal velocity of missile in pixels per frame
          rem Positive = right, Negative = left, 0 = straight up/down
          rem Values: -127 to 127

          rem  Bernie, Curler, Dragonet, Zoe Ryen, Fat Tony, Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy, Pork Chop, Radish Goblin, Robo Tito, Ursulo, Veg Dog
          data CharacterMissileMomentumX
             5, 6, 4, 6, 0, 0, 5, 8, 6, 0, 0, 0, 0, 0, 7, 0
          end

          rem =================================================================
          rem MISSILE INITIAL MOMENTUM Y (Vertical Velocity)
          rem =================================================================
          rem Initial vertical velocity of missile in pixels per frame
          rem Positive = down, Negative = up, 0 = horizontal only (arrowshot)
          rem Negative = ballistic/parabolic arc
          rem Values: -127 to 127 (typically -8 to 0 for parabolic arcs)

          rem  Bernie, Curler, Dragonet, Zoe Ryen, Fat Tony, Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy, Pork Chop, Radish Goblin, Robo Tito, Ursulo, Veg Dog
          rem  N/A    arrowshot    ballistic arrowshot N/A       N/A              N/A      diagonal   ballistic       N/A         arrowshot  N/A        N/A           N/A       ballistic  N/A
          rem  Harpy: diagonal downward attack (positive = down)
          data CharacterMissileMomentumY
             0, 0, -4, 0, 0, 0, 4, 0, -5, 0, 0, 0, 0, 0, -6, 0
          end

          rem =================================================================
          rem MISSILE INTERACTION FLAGS
          rem =================================================================
          rem Bit flags for missile behavior:
          rem   Bit 0: Hit background (0=pass through, 1=hit and disappear)
          rem   Bit 1: Hit player (0=pass through, 1=hit and disappear)
          rem   Bit 2: Apply gravity (0=no gravity, 1=affected by gravity)
          rem   Bit 3: Bounce off walls (0=stop/hit, 1=bounce)
          rem   Bit 4-7: Reserved
          rem Values stored as packed bytes per character

          rem  Bernie, Curler, Dragonet, Zoe Ryen, Fat Tony, Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy, Pork Chop, Radish Goblin, Robo Tito, Ursulo, Veg Dog
          rem  Note: Bit 0=hit bg (MissileFlagHitBackground), Bit 1=hit player (MissileFlagHitPlayer), 
          rem       Bit 2=gravity (MissileFlagGravity), Bit 3=bounce (MissileFlagBounce)
          rem  Values use enum constants for bitfield encoding (see Enums.bas)
          data CharacterMissileFlags
              %00000000, %00000011, %00000001, %00000000, %00000000, %00000000, %00000000, %00000000, %00000001, %00000000, %00000000, %00000000, %00000000, %00000000, %00000001, %00000000
          rem  0,      MissileFlagHitBoth, MissileFlagHitBackground, 0, 0, 0, 0, 0, MissileFlagHitBackground, 0, 0, 0, 0, 0, MissileFlagHitBackground, 0
          end

          rem =================================================================
          rem MISSILE LIFETIME (DURATION)
          rem =================================================================
          rem How long the missile/attack visual stays active (in frames)
          rem For melee attacks: 3-8 frames (brief sword/punch visual)
          rem For ranged attacks: 255 = until collision or off-screen
          rem Values: 1-255 frames
          rem Note: CharacterMissileLifetime is defined above at line 76

          rem  Bernie, Curler, Dragonet, Zoe Ryen, Fat Tony, Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy, Pork Chop, Radish Goblin, Robo Tito, Ursulo, Veg Dog
          rem  AOE offset in pixels (0 = no AOE, positive = area of effect)
          data CharacterAOEOffsets
             0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
          end

          rem =================================================================
          rem ANIMATION SEQUENCE DEFINITIONS
          rem =================================================================
          rem Animation sequences (16 total) - all use 8-frame padded format:
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

          rem Note: All animations use 8 bytes per sequence with padding
          rem Frame counts are implicit in the data structure (all 8 frames)

          rem =================================================================
          rem ANIMATION FRAME REFERENCES
          rem =================================================================
          rem Each animation sequence consists of 1, 2, 4, or 8 frame references
          rem Frame references are always written as 8 bytes (padded with repeats)
          rem Frame references are relative to the 8px × 16px 16-byte bitmap set
          rem Format examples:
          rem   1 frame:  (1, 1, 1, 1, 1, 1, 1, 1)
          rem   2 frames: (1, 2, 1, 2, 1, 2, 1, 2)  
          rem   4 frames: (1, 2, 3, 4, 1, 2, 3, 4)
          rem   8 frames: (1, 2, 3, 4, 5, 6, 7, 8)

          rem Animation frame reference tables (16 characters × 16 sequences × 8 bytes)
          rem Each character animation data is 128 bytes (16 sequences × 8 bytes)
          rem Total: 2048 bytes for all character animations

          rem Standing still (1 frame)
          rem Idle (2 frames)
          rem Guarding (1 frame)
          rem Walking (4 frames)
          rem Coming to stop (2 frames)
          rem Taking hit (2 frames)
          rem Falling backwards (2 frames)
          rem Falling down (3 frames)
          rem Fallen down (1 frame)
          rem Recovering (2 frames)
          rem Jumping (2 frames)
          rem Falling after jump (2 frames)
          rem Landing (2 frames)
          rem Attack windup (2 frames)
          rem Attack execution (1 frame)
          rem Attack recovery (1 frame)

          rem =================================================================
          rem GRAPHICS DATA STRUCTURE
          rem =================================================================
          rem Each character has:
          rem   - 8px × 16px bitmap data (16 bytes per frame)
          rem   - Frame references point to these 16-byte blocks
          rem   - Graphics data will be loaded from ROM
          rem   - Duplicate frames are compacted, gaps removed, empty frames padded

          rem =================================================================
          rem CHARACTER DEFINITION LOOKUP SUBROUTINES
          rem =================================================================

          rem Get character weight
          rem Input: character index (in temp1)
          rem Output: weight (in temp4)
          rem Note: Uses array access since data is immutable
          GetCharWeightSub
              temp4 = CharacterWeights(temp1)
              return

          rem Get character attack type
          rem Input: character index (in temp1)
          rem Output: attack type 0=melee, 1=ranged (in temp4)
          rem Note: Attack types are bit-packed, so we need to extract the bit
          GetCharAttackTypeSub
              rem Division by 8 should compile to LSR x3 (bit shift right 3 times)
              rem batariBASIC optimizes division by powers of 2 to bit shifts
              temp3 = temp1 / 8
              temp2 = temp1 & 7
              temp4 = (CharacterAttackTypes(temp3) & (1 << temp2)) >> temp2
              return

          rem Get missile dimensions
          rem Input: character index (in temp1)
          rem Output: width (in temp3), height (in temp4)
          rem Note: Uses array access since data is immutable
          GetMissileDimsSub
              temp3 = CharacterMissileWidths(temp1)
              temp4 = CharacterMissileHeights(temp1)
              return

          rem Get missile emission height
          rem Input: character index (in temp1)
          rem Output: emission height (in temp4)
          rem Note: Uses array access since data is immutable
          GetMissileEmissionHeightSub
              temp4 = CharacterMissileEmissionHeights(temp1)
              return

          rem Get missile momentum X
          rem Input: character index (in temp1)
          rem Output: momentum X (in temp4)
          rem Note: Uses array access since data is immutable
          rem Values range from -127 to 127 (signed)
          GetMissileMomentumXSub
              temp4 = CharacterMissileMomentumX(temp1)
              return

          rem Get missile momentum Y
          rem Input: character index (in temp1)
          rem Output: momentum Y (in temp4)
          rem Note: Uses array access since data is immutable
          rem Values range from -127 to 127 (signed)
          GetMissileMomentumYSub
              temp4 = CharacterMissileMomentumY(temp1)
              return

          rem Get missile flags
          rem Input: character index (in temp1)
          rem Output: flags (in temp4)
          rem Note: Bit flags: MissileFlagHitBackground (bit 0), MissileFlagHitPlayer (bit 1),
          rem       MissileFlagGravity (bit 2), MissileFlagBounce (bit 3)
          rem Note: Uses array access since data is immutable
          rem Use constants from Enums.bas for bitfield checking: temp5 & MissileFlagGravity
          GetMissileFlagsSub
              temp4 = CharacterMissileFlags(temp1)
              return

          rem =================================================================
          rem DATA FORMAT NOTES FOR SKYLINETOOL OUTPUT
          rem =================================================================

          rem SkylineTool should emit batariBasic-compatible data in this format:

          rem 1. Animation frame references (8 bytes per sequence):
          rem    data Character0Animations
          rem     1, 1, 1, 1, 1, 1, 1, 1     ; 1 frame
          rem     1, 2, 1, 2, 1, 2, 1, 2     ; 2 frames
          rem     4, 5, 6, 7, 4, 5, 6, 7     ; 4 frames
          rem     1, 2, 3, 4, 5, 6, 7, 8     ; 8 frames
          rem    end

          rem 2. Graphics data (16 bytes bitmap):
          rem    data Character0Graphics
          rem     %01110010, %11010011, ...  ; 16 bytes bitmap data
          rem    end

          rem 3. Frame compaction:
          rem    - Duplicate frames: compact into single frame reference
          rem    - Gaps: removed during compaction
          rem    - Padding: fill with repeats (1->1,1,1,1,1,1,1,1)

          rem 4. Each character needs:
          rem    - 16 animation sequences × 8 bytes = 128 bytes frame references
          rem    - Variable number of unique graphics frames × 32 bytes = graphics data
          rem    - Total per character: ~128 + (unique_frames × 32) bytes

          rem 5. Output file format: Source/Generated/CharacterData.bas
          rem    This file will be included in the build process