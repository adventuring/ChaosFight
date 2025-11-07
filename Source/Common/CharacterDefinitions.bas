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
          rem Weight values affect:
          rem   - Jump height (higher weight = lower jump)
          rem   - Movement speed (higher weight = slower)
          rem   - Momentum (higher weight = more momentum when moving)
          rem   - Impact resistance (higher weight = less knocked back)
          rem - Melee force (higher weight = more damage/knockback to
          rem   opponents)
          rem Values: 5-100 (relative scale based on real-world weights
          rem   in kg)
          rem Weight scale: 5 = lightest (Bernie ~4.5 kg), 100 =
          rem   heaviest (Dragon/Megax ~1588 kg)
          rem Mapping uses logarithmic scale to preserve relative weight
          rem   differences

          rem Bernie, Curler, Dragon of Storms, Zoe Ryen, Fat Tony,
          rem   Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy,
          rem   Pork Chop, Radish Goblin, Robo Tito, Ursulo, Shamone
          rem Weight values based on real-world equivalents: Bernie (10
          rem   lbs), Curler (190 lbs), Dragon/Megax (3500 lbs rhino),
          rem Zoe (145 lbs female soldier), Fat Tony (240 lbs mobster),
          rem   Harpy (30 lbs 2x eagle), Knight Guy (250 lbs + armor),
          rem Frooty (120 lbs twink), Nefertem (440 lbs lion), Ninjish
          rem   Guy (130 lbs thin man), Pork Chop (250 lbs),
          rem Radish Goblin (50 lbs scaled daikon), Robo Tito (300 lbs
          rem   dumpster), Ursulo (220 lbs, 1.67m tall walking polar
          rem   bear), Shamone (65 lbs Labrador)
          rem Character weights: Bernie(5), Curler(53), Dragon(100),
          rem Zoe(48), Fat Tony(57), Megax(100), Harpy(23), Knight
          rem Guy(57), Frooty(45), Nefertem(66), Ninjish Guy(47), Pork
          rem Chop(57), Radish Goblin(31), Robo Tito(60), Ursulo(55),
          rem Shamone(35)
          data CharacterWeights
            5, 53, 100, 48, 57, 100, 23, 57, 45, 66, 47, 57, 31, 60, 55, 35
end

          rem
          rem SAFE FALL VELOCITY THRESHOLDS (120 / Weight)
          rem Lookup table for safe fall velocity threshold calculation
          rem Formula: safe_velocity = 120 / weight
          rem Pre-computed for all 16 characters to avoid variable
          rem   division
          rem Safe fall velocity thresholds: Bernie(24), Curler(2),
          rem Dragon(1), Zoe(2), Fat Tony(2), Megax(1), Harpy(5), Knight
          rem Guy(2), Frooty(2), Nefertem(1), Ninjish Guy(2), Pork
          rem Chop(2), Radish Goblin(3), Robo Tito(2), Ursulo(1),
          rem Shamone(3)
          rem Values: integer division of 120 by each character’s weight
          data SafeFallVelocityThresholds
            24, 2, 1, 2, 2, 1, 5, 2, 2, 1, 2, 2, 3, 2, 1, 3
end

          rem
          rem WEIGHT DIVIDED BY 20 (for Damage Multiplier)
          rem Lookup table for weight / 20 calculation
          rem Used for damage multiplier: damage = damage * (weight /
          rem   20)
          rem Weight divided by 20: Bernie(0), Curler(2), Dragon(5),
          rem Zoe(2), Fat Tony(2), Megax(5), Harpy(1), Knight Guy(2),
          rem Frooty(2), Nefertem(3), Ninjish Guy(2), Pork Chop(2),
          rem Radish Goblin(1), Robo Tito(3), Ursulo(4), Shamone(1)
          rem Pre-computed to avoid variable division
          data WeightDividedBy20
            0, 2, 5, 2, 2, 5, 1, 2, 2, 3, 2, 2, 1, 3, 4, 1
end

          rem
          rem SQUARE LOOKUP TABLE (for Velocity squared Calculations)
          rem Lookup table for squaring values 1-24
          rem Used for kinematic calculations: d = v squared / 4
          rem Pre-computed to avoid variable multiplication
          rem Square table values pre-divided by 4 (v² / 4) for velocities 1-24
          rem (0,1,2,4,6,9,12,16), (20,25,30,36,42,49,56,64),
          rem (72,81,90,100,110,121,132,144)
          rem Index is value (1-24), result is floor(v² / 4)
          data SquareTable
            0, 1, 2, 4, 6, 9, 12, 16, 20, 25, 30, 36, 42, 49, 56, 64, 72, 81, 90, 100, 110, 121, 132, 144
end

          rem
          rem Character Heights
          rem Character heights for hitbox collision detection (in
          rem   pixels)
          rem Bernie: 10 pixels, all others: 16 pixels
          rem Used for player:player and player:missile collision
          rem   detection
          rem Values: 10-16 pixels (character sprite heights)

          rem Bernie, Curler, Dragon of Storms, Zoe Ryen, Fat Tony,
          rem   Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy,
          rem   Pork Chop, Radish Goblin, Robo Tito, Ursulo, Shamone
          data CharacterHeights
            10, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16
end

          rem Character missile widths: Bernie(0, melee), Curler(4),
          rem Dragon(2), Zoe(4), Fat Tony(4), Megax(4), Harpy(0, melee),
          rem Knight Guy(0, melee), Frooty(1), Nefertem(0, melee),
          rem Ninjish Guy(0, melee), Pork Chop(0, melee), Radish
          rem Goblin(0, melee), Robo Tito(0, melee), Ursulo(0, melee),
          rem Shamone(0, melee)
          rem Bernie, Curler, Dragon of Storms, Zoe Ryen, Fat Tony,
          rem   Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy,
          rem   Pork Chop, Radish Goblin, Robo Tito, Ursulo, Shamone
          data CharacterMissileWidths
             0, 4, 2, 4, 4, 4, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
end

          rem Character missile heights: Bernie(0, melee), Curler(4),
          rem Dragon(2), Zoe(1), Fat Tony(1), Megax(4), Harpy(0, melee),
          rem Knight Guy(0, melee), Frooty(1), Nefertem(0, melee),
          rem Ninjish Guy(0, melee), Pork Chop(0, melee), Radish
          rem Goblin(0, melee), Robo Tito(0, melee), Ursulo(0, melee),
          rem Shamone(0, melee)
          rem Bernie, Curler, Dragon of Storms, Zoe Ryen, Fat Tony,
          rem   Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy,
          rem   Pork Chop, Radish Goblin, Robo Tito, Ursulo, Shamone
          data CharacterMissileHeights
             0, 4, 2, 1, 1, 4, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
end

          rem Character missile max X: Bernie(4), Curler(8), Dragon(6),
          rem Zoe(6), Fat Tony(6), Megax(6), Harpy(0, melee), Knight
          rem Guy(0, melee), Frooty(6), Nefertem(0, melee), Ninjish
          rem Guy(0, melee), Pork Chop(0, melee), Radish Goblin(0,
          rem melee), Robo Tito(0, melee), Ursulo(0, melee), Shamone(0,
          rem melee)
          rem Bernie, Curler, Dragon of Storms, Zoe Ryen, Fat Tony,
          rem   Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy,
          rem   Pork Chop, Radish Goblin, Robo Tito, Ursulo, Shamone
          data CharacterMissileMaxX
             4, 8, 6, 6, 6, 6, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0
end

          rem Character missile max Y: Bernie(4), Curler(6), Dragon(6),
          rem Zoe(6), Fat Tony(0), Megax(0), Harpy(0, melee), Knight
          rem Guy(0, melee), Frooty(6), Nefertem(0, melee), Ninjish
          rem Guy(0, melee), Pork Chop(0, melee), Radish Goblin(0,
          rem melee), Robo Tito(0, melee), Ursulo(0, melee), Shamone(0,
          rem melee)
          rem Bernie, Curler, Dragon of Storms, Zoe Ryen, Fat Tony,
          rem   Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy,
          rem   Pork Chop, Radish Goblin, Robo Tito, Ursulo, Shamone
          data CharacterMissileMaxY
             4, 6, 6, 6, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0
end

          rem Character missile force: Bernie(3), Curler(5), Dragon(4),
          rem Zoe(4), Fat Tony(4, ranged magic ring lasers), Megax(0),
          rem Harpy(0), Knight Guy(0), Frooty(4), Nefertem(0), Ninjish
          rem Guy(0), Pork Chop(0), Radish Goblin(0), Robo Tito(0),
          rem Ursulo(4), Shamone(0)
          rem Bernie, Curler, Dragon of Storms, Zoe Ryen, Fat Tony,
          rem   Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy,
          rem   Pork Chop, Radish Goblin, Robo Tito, Ursulo, Shamone
          data CharacterMissileForce
             3, 5, 4, 4, 4, 0, 0, 0, 4, 0, 0, 0, 0, 0, 4, 0
end

          rem Character missile lifetime: Bernie(4, melee), Curler(255,
          rem ranged), Dragon(255, ranged), Zoe(255, ranged), Fat
          rem Tony(255, ranged magic ring lasers), Megax(4, melee),
          rem Harpy(5, melee), Knight Guy(6, melee), Frooty(255,
          rem ranged), Nefertem(5, melee), Ninjish Guy(4, melee), Pork
          rem Chop(4, melee), Radish Goblin(3, melee), Robo Tito(5,
          rem melee), Ursulo(5, melee claw swipe), Shamone(4, melee)
          rem Bernie, Curler, Dragon of Storms, Zoe Ryen, Fat Tony,
          rem   Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy,
          rem   Pork Chop, Radish Goblin, Robo Tito, Ursulo, Shamone
          rem melee ranged ranged ranged ranged melee melee melee ranged
          rem   melee melee melee melee melee ranged melee
          rem Note: Melee attacks show brief visual (sword, fist, etc.),
          rem   ranged persist until hit
          data CharacterMissileLifetime
             4, 255, 255, 255, 255, 4, 5, 6, 255, 5, 4, 4, 3, 5, 5, 4
end

          rem
          rem Bit Mask Table For Player Index
          rem Bit mask values for player indices (0-3)
          rem Used for bit-flag operations on playersEliminated and
          rem   missileActive
          rem Values: 1, 2, 4, 8 for players 0, 1, 2, 3 respectively
          data BitMask
             1, 2, 4, 8
end

          rem
          rem Character Attack Types
          rem 0 = melee, 1 = ranged
          rem Stored as bit-per-character in packed bytes (4 bytes for
          rem   up to 32 characters)

          rem Bernie Curler Dragon of Storms Zoe Ryen Fat Tony Grizzard
          rem   Harpy Knight Guy
          rem melee ranged melee ranged ranged melee ranged ranged
          rem Frooty Nefertem Ninjish Pork Chop Radish Robo Tito Ursulo
          rem   Shamone
          rem ranged melee melee melee melee melee melee melee
          rem Bernie: melee (no ranged attack)
          rem Harpy changed from melee to ranged (diagonal downward
          rem   attack)
          rem Ursulo changed from ranged to melee (claw swipe)
          rem Harpy changed from ranged to melee (diagonal swoop,
          rem special case)
          rem Megax changed from ranged to melee (decorative missile)
          rem NinjishGuy changed from melee to ranged (shuriken)
          data CharacterAttackTypes
              %00011110, %00000101, %00000000, %00000000
end
          rem CharacterAttackTypes bits:
          rem   Bit 0  (Bernie)                        = 0 (melee)
          rem   Bits 1-4 (Curler, Dragon, Zoe, FatTony) = 1 (ranged)
          rem   Bits 5-7 (Megax, Harpy, KnightGuy)      = 0 (melee)
          rem   Bit 8  (Frooty)                        = 1 (ranged)
          rem   Bit 9  (Nefertem)                      = 0 (melee)
          rem   Bit 10 (NinjishGuy)                    = 1 (ranged)
          rem   Bits 11-15 (Pork Chop, Radish, RoboTito, Ursulo, Shamone) = 0 (melee)

          rem
          rem Missile Size Definitions
          rem Missile dimensions (width × height) for each character
          rem
          rem Format: width, height
          rem Melee attacks can use 0x0 if no visible missile


          rem Missile Emission Heights
          rem Vertical offset on character sprite where missile is
          rem   emitted
          rem Values: 0-7 (top to bottom of 8-pixel tall sprite)

          rem Bernie, Curler, Dragon of Storms, Zoe Ryen, Fat Tony,
          rem   Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy,
          rem   Pork Chop, Radish Goblin, Robo Tito, Ursulo, Shamone
          rem Note: Curler uses 14 for emission from feet (14 pixels
          rem   from top of 16px sprite = near ground)
          rem Note: Megax uses 4 for mouth height (fire breath emission
          rem   point)
          data CharacterMissileEmissionHeights
             3, 14, 4, 4, 3, 4, 4, 4, 3, 3, 3, 3, 3, 3, 4, 3
end

          rem
          rem MISSILE INITIAL MOMENTUM X (horizontal Velocity)
          rem Initial horizontal velocity of missile in pixels per frame
          rem Positive = right, Negative = left, 0 = straight up/down
          rem Values: -127 to 127

          rem Bernie, Curler, Dragon of Storms, Zoe Ryen, Fat Tony,
          rem   Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy,
          rem Character missile momentum X: Bernie(5), Curler(6),
          rem Dragon(4), Zoe(6), Fat Tony(0), Megax(0), Harpy(5), Knight
          rem Guy(8), Frooty(6), Nefertem(0), Ninjish Guy(0), Pork
          rem Chop(0), Radish Goblin(0), Robo Tito(0), Ursulo(0, melee,
          rem changed from 7), Shamone(0)
          rem   Pork Chop, Radish Goblin, Robo Tito, Ursulo, Shamone
          data CharacterMissileMomentumX
             5, 6, 4, 6, 0, 0, 5, 8, 6, 0, 0, 0, 0, 0, 0, 0
end

          rem
          rem MISSILE INITIAL MOMENTUM Y (vertical Velocity)
          rem Initial vertical velocity of missile in pixels per frame
          rem Positive = down, Negative = up, 0 = horizontal only
          rem   (arrowshot)
          rem Negative = ballistic/parabolic arc
          rem Values: -127 to 127 (typically -8 to 0 for parabolic arcs)

          rem Character missile momentum Y: Bernie(0), Curler(0),
          rem Dragon(-4, ballistic), Zoe(0, arrowshot), Fat Tony(0),
          rem Megax(0), Harpy(4, diagonal downward), Knight Guy(0),
          rem Frooty(-5, ballistic), Nefertem(0), Ninjish Guy(0), Pork
          rem Chop(0), Radish Goblin(0), Robo Tito(0), Ursulo(0, melee),
          rem Shamone(0)
          rem Bernie, Curler, Dragon of Storms, Zoe Ryen, Fat Tony,
          rem   Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy,
          rem   Pork Chop, Radish Goblin, Robo Tito, Ursulo, Shamone
          rem N/A arrowshot ballistic arrowshot N/A N/A N/A diagonal
          rem   ballistic N/A arrowshot N/A N/A N/A melee N/A
          rem  Harpy: diagonal downward attack (positive = down)
          rem  Ursulo: melee claw swipe (no missile momentum)
          data CharacterMissileMomentumY
             0, 0, -4, 0, 0, 0, 4, 0, -5, 0, 0, 0, 0, 0, 0, 0
end

          rem
          rem Missile Interaction Flags
          rem Bit flags for missile behavior:
          rem Bit 0: Hit background (0=pass through, 1=hit and
          rem   disappear)
          rem   Bit 1: Hit player (0=pass through, 1=hit and disappear)
          rem Bit 2: Apply gravity (0=no gravity, 1=affected by gravity)
          rem   Bit 3: Bounce off walls (0=stop/hit, 1=bounce)
          rem Bit 4: Apply friction (0=constant velocity, 1=decelerates)
          rem   Bit 5-7: Reserved
          rem Values stored as packed bytes per character

          rem Bernie, Curler, Dragon of Storms, Zoe Ryen, Fat Tony,
          rem   Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy,
          rem   Pork Chop, Radish Goblin, Robo Tito, Ursulo, Shamone
          rem Note: Bit 0=hit bg (MissileFlagHitBackground=1), Bit 1=hit
          rem   player (MissileFlagHitPlayer=2),
          rem Bit 2=gravity (MissileFlagGravity=4), Bit 3=bounce
          rem   (MissileFlagBounce=8), Bit 4=friction
          rem   (MissileFlagFriction=16)
          rem Values use enum constants for bitfield encoding (see
          rem   Enums.bas for constant definitions)
          rem  0 = no flags
          rem Curler = MissileFlagCurlerFull = 31
          rem   (HitBackground|HitPlayer|Gravity|Bounce|Friction)
          rem Dragon of Storms = MissileFlagHitBackgroundAndGravity = 5
          rem   (HitBackground|Gravity) for ballistic arc
          rem Zoe Ryen = MissileFlagHitBackground = 1 (hits backgrounds
          rem   and players)
          rem Frooty = MissileFlagHitBackgroundAndGravity = 5
          data CharacterMissileFlags
            0, MissileFlagCurlerFull, MissileFlagHitBackgroundAndGravity, MissileFlagHitBackground, 0, 0, 0, 0, MissileFlagHitBackgroundAndGravity, 0, 0, 0, 0, 0, 0, 0
end
          rem CharacterMissileFlags entries:
          rem   0 = Bernie (melee)
          rem   MissileFlagCurlerFull = Curler (all flags set)
          rem   MissileFlagHitBackgroundAndGravity = Dragon of Storms, Frooty
          rem   MissileFlagHitBackground = Zoe Ryen
          rem   Remaining entries (Fat Tony through Shamone) have no missile flags (0)
          rem   Ursulo changed from MissileFlagHitBackground to 0 (melee)

          rem
          rem MISSILE LIFETIME (duration)
          rem How long the missile/attack visual stays active (in
          rem   frames)
          rem For melee attacks: 3-8 frames (brief sword/punch visual)
          rem For ranged attacks: 255 = until collision or off-screen
          rem Values: 1-255 frames
          rem Note: CharacterMissileLifetime is defined above at line 76

          rem Bernie, Curler, Dragon of Storms, Zoe Ryen, Fat Tony,
          rem   Megax, Harpy, Knight Guy, Frooty, Nefertem, Ninjish Guy,
          rem   Pork Chop, Radish Goblin, Robo Tito, Ursulo, Shamone
          rem AOE offset in pixels (0 = no AOE, positive = area of
          rem   effect)
          data CharacterAOEOffsets
             0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
end

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
          rem
          rem Attack windup (2 frames)
          rem Attack execution (1 frame)
          rem Attack recovery (1 frame)
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
          temp4 = CharacterWeights(temp1)
          return

GetCharAttackTypeSub
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
          temp3 = temp1 / 8
          temp2 = temp1 & 7
          temp4 = CharacterAttackTypes[temp3]
          temp5 = temp2
GetCharAttackTypeSubShiftLoop
          if temp5 = 0 then goto GetCharAttackTypeSubShiftDone
          temp4 = temp4 / 2
          temp5 = temp5 - 1
          goto GetCharAttackTypeSubShiftLoop
GetCharAttackTypeSubShiftDone
          temp4 = temp4 & 1
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
          temp3 = CharacterMissileWidths(temp1)
          temp4 = CharacterMissileHeights(temp1)
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
          temp4 = CharacterMissileEmissionHeights(temp1)
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
          temp4 = CharacterMissileMomentumX(temp1)
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
          temp4 = CharacterMissileMomentumY(temp1)
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
          temp4 = CharacterMissileFlags(temp1)
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
          rem - 16 animation sequences × 8 bytes = 128 bytes frame
          rem   references
          rem - Variable number of unique graphics frames × 32 bytes =
          rem   graphics data
          rem - Total per character: ~128 + (unique_frames × 32) bytes

          rem 5. Output file format: Source/Generated/CharacterData.bas
          rem    This file will be included in the build process
