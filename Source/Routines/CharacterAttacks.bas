          rem ChaosFight - Source/Routines/CharacterAttacks.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem ==========================================================
          rem CHARACTER-SPECIFIC ATTACK SUBROUTINES
          rem ==========================================================
          rem Each character has a unique attack subroutine that:
          rem 1. Calls either PerformMeleeAttack or PerformRangedAttack
          rem   2. Sets the appropriate animation state
          rem   3. Handles any character-specific attack logic

          rem Input for all attack routines:
          rem   temp1 = attacker player index (0-3)

          rem All other needed data (X, Y, facing direction, etc.) is
          rem   looked up
          rem from the player arrays using temp1 as the index

          rem ==========================================================
          rem BERNIE (Character 0) - Ground Thump (Area-of-Effect)
          rem ==========================================================
BernieAttack
          dim BA_attackerIndex = temp1
          dim BA_originalFacing = temp3
          rem Bernies Ground Thump attack is an area-of-effect that
          rem   hits nearby characters both to his left AND right
          rem   simultaneously, and shoves them rapidly away from him
          rem This is unique - all other melee attacks only hit in
          rem   facing direction
          let playerState[BA_attackerIndex] = (playerState[BA_attackerIndex] & MaskPlayerStateFlags) | ActionAttackExecuteShifted 
          rem Set animation state 14 (attack execution)
          
          rem   SpawnMissile)
          rem Save original facing direction (temp5 conflicts with
          let BA_originalFacing = playerState[BA_attackerIndex] & PlayerStateBitFacing
          
          rem Attack in facing direction
          gosub PerformMeleeAttack
          
          rem Also attack in opposite direction
          rem Temporarily flip facing
          if BA_originalFacing then FaceLeft1
          let playerState[BA_attackerIndex] = playerState[BA_attackerIndex] | PlayerStateBitFacing
          goto FacingDone1
FaceLeft1
          let playerState[BA_attackerIndex] = playerState[BA_attackerIndex] & (255 - PlayerStateBitFacing)
FacingDone1
          
          rem Attack in opposite direction
          gosub PerformMeleeAttack
          

          if BA_originalFacing then RestoreFaceRight1
          let playerState[BA_attackerIndex] = playerState[BA_attackerIndex] & (255 - PlayerStateBitFacing)
          goto RestoreFacingDone1
RestoreFaceRight1
          let playerState[BA_attackerIndex] = playerState[BA_attackerIndex] | PlayerStateBitFacing
RestoreFacingDone1
          
          return

          rem ==========================================================
          rem CURLER (Character 1) - Ranged Attack (ground-based)
          rem ==========================================================
CurlerAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformRangedAttack

          rem ==========================================================
          rem DRAGON OF STORMS (Character 2) - Ranged Attack
          rem ==========================================================
          rem Fires ranged fireballs that slowly arc downwards
          rem 2×2 missile with ballistic arc trajectory
DragonetAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformRangedAttack

          rem ==========================================================
          rem ZOE RYEN (Character 3) - Ranged Attack
          rem ==========================================================
ZoeRyenAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformRangedAttack

          rem ==========================================================
          rem FAT TONY (Character 4) - Ranged Attack
          rem ==========================================================
          rem Magic ring lasers shoot across screen very quickly
          rem Pass through walls, thin, wide missile
FatTonyAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformRangedAttack

          rem ==========================================================
          rem MEGAX (Character 5) - Melée Attack (fire breath visual)
          rem ==========================================================
          rem Megax uses a melée attack with a missile sprite for fire
          rem   breath visual effect.
          rem The missile appears adjacent to Megax, stays stationary
          rem   during attack, and vanishes when attack completes.
MegaxAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformMeleeAttack

          rem ==========================================================
          rem HARPY (Character 6) - Diagonal Downward Swoop Attack
          rem ==========================================================
          rem Harpy attack moves the character itself in a 45° rapid
          rem   downward swoop
          rem Attack hitbox is below the character during the swoop
          rem 5-frame duration for the swoop attack visual
          rem No missile is spawned - character movement IS the attack
HarpyAttack
          dim HA_playerIndex = temp1
          dim HA_facing = temp2
          dim HA_velocityX = temp2
          dim HA_velocityY = temp3
          
          rem Set attack animation state
          let playerState[HA_playerIndex] = (playerState[HA_playerIndex] & MaskPlayerStateFlags) | ActionAttackExecuteShifted 
          rem Set animation state 14 (attack execution)
          
          rem Get facing direction (bit 0: 0=left, 1=right)
          let HA_facing = playerState[HA_playerIndex] & PlayerStateBitFacing
          
          rem Set diagonal velocity at 45° angle (4 pixels/frame
          rem   horizontal, 4 pixels/frame vertical)
          rem Horizontal: 4 pixels/frame in facing direction
          if HA_facing = 0 then HarpySetLeftVelocity
          rem Facing right: positive X velocity
          let HA_velocityX = 4
          goto HarpySetVerticalVelocity
HarpySetLeftVelocity
          rem Facing left: negative X velocity (252 = -4 in signed
          rem   8-bit)
          let HA_velocityX = 252
HarpySetVerticalVelocity
          rem Vertical: 4 pixels/frame downward (positive Y = down)
          let HA_velocityY = 4
          
          rem Set player velocity for diagonal swoop (45° angle:
          rem   4px/frame X, 4px/frame Y) - inlined for performance
          let playerVelocityX[HA_playerIndex] = HA_velocityX
          let playerVelocityXL[HA_playerIndex] = 0
          let playerVelocityY[HA_playerIndex] = HA_velocityY
          let playerVelocityYL[HA_playerIndex] = 0
          
          rem Set jumping state so character can move vertically during
          rem   swoop
          rem This allows vertical movement without being on ground
          let playerState[HA_playerIndex] = playerState[HA_playerIndex] | 4
          rem Set bit 2 (jumping flag)
          
          rem Set swoop attack flag for collision detection
          rem Bit 2 = swoop active (used to extend hitbox below
          rem   character during swoop)
          rem Collision system will check for hits below character
          rem   during swoop
          rem Fix RMW: Read from _R, modify, write to _W
          let HA_stateFlags = characterStateFlags_R[HA_playerIndex] | 4
          let characterStateFlags_W[HA_playerIndex] = HA_stateFlags
          
          rem Attack behavior:
          rem - Character moves diagonally down at 45° (4px/frame X,
          rem   4px/frame Y)
          rem - Attack hitbox is below character during movement
          rem - 5-frame attack animation duration (handled by animation
          rem   system)
          rem - Movement continues until collision or attack animation
          rem   completes
          rem - No missile spawned - character movement IS the attack
          rem - Hit players are damaged and pushed (knockback handled by
          rem   collision system)
          
          return

          rem ==========================================================
          rem KNIGHT GUY (Character 7) - Melée Attack (sword visual)
          rem ==========================================================
          rem Knight Guy uses a melée attack with a missile sprite for
          rem   sword visual effect.
          rem The missile appears partially overlapping the player, moves
          rem   slightly away during attack phase (sword swing), returns
          rem   to start, and vanishes when attack completes.
KnightGuyAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformMeleeAttack

          rem ==========================================================
          rem FROOTY (Character 8) - Ranged Attack with Magical Sparkles
          rem ==========================================================
          rem Frooty fires magical sparkles from her lollipop weapon
          rem Sparkles are implemented via missile sprite graphics
          rem Multi-hit or spread patterns can use multiple sparkle
          rem   sprites
          rem Sprite data should show sparkle particle effects
FrootyAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformRangedAttack
          rem Magical sparkles: Visual effect handled by missile sprite
          rem   graphics
          rem The missile sprite for Frooty (character 8) should display
          rem   sparkle particles
          rem Sprite generation via SkylineTool should create sparkle
          rem   graphics

          rem ==========================================================
          rem NEFERTEM (Character 9) - Melee Attack
          rem ==========================================================
NefertemAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformMeleeAttack

          rem ==========================================================
          rem NINJISH GUY (Character 10) - Ranged Attack (small bullet)
          rem ==========================================================
NinjishGuyAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformRangedAttack

          rem ==========================================================
          rem PORK CHOP (Character 11) - Melee Attack
          rem ==========================================================
PorkChopAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformMeleeAttack

          rem ==========================================================
          rem RADISH GOBLIN (Character 12) - Melee Attack
          rem ==========================================================
RadishGoblinAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformMeleeAttack

          rem ==========================================================
          rem ROBO TITO (Character 13) - Melee Attack
          rem ==========================================================
RoboTitoAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformMeleeAttack

          rem ==========================================================
          rem URSULO (Character 14) - Melee Attack (Claw Swipe)
          rem ==========================================================
UrsuloAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformMeleeAttack

          rem ==========================================================
          rem SHAMONE (Character 15) - Jump + Attack (Special)
          rem ==========================================================
          rem Shamone special attack: jumps while attacking
          rem   simultaneously
ShamoneAttack
          rem First, execute the jump
          let playerY[temp1] = playerY[temp1] - 11 
          rem Light character, good jump
          let playerState[temp1] = playerState[temp1] | PlayerStateBitJumping
          rem Set jumping flag
          
          rem Then execute the attack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformMeleeAttack

          rem ==========================================================
          rem CHARACTER ATTACK DISPATCHER
          rem ==========================================================
          rem Routes to the appropriate character attack subroutine
          rem   based on character type

          rem INPUT:
          rem   temp1 = attacker player index (0-3)

          rem All character attack routines will look up playerX[temp1],
          rem   playerY[temp1],
          rem playerState[temp1], etc. as needed.

DispatchCharacterAttack
          rem Get character type for this player using direct array
          rem   access
          rem temp1 contains player index (0-3)
          let temp2 = playerChar[temp1]
          rem Dispatch to character-specific attack handler (0-31)
          rem MethHound (31) uses ShamoneAttack handler
          if temp2 < 8 then on temp2 goto BernieAttack, CurlerAttack, DragonetAttack, ZoeRyenAttack, FatTonyAttack, MegaxAttack, HarpyAttack, KnightGuyAttack
          if temp2 < 8 then goto DoneCharacterAttackDispatch
          temp2 = temp2 - 8
          if temp2 < 8 then on temp2 goto FrootyAttack, NefertemAttack, NinjishGuyAttack, PorkChopAttack, RadishGoblinAttack, RoboTitoAttack, UrsuloAttack, ShamoneAttack
          if temp2 < 8 then goto DoneCharacterAttackDispatch
          temp2 = temp2 - 8
          if temp2 < 8 then on temp2 goto Char16Attack, Char17Attack, Char18Attack, Char19Attack, Char20Attack, Char21Attack, Char22Attack, Char23Attack
          if temp2 < 8 then goto DoneCharacterAttackDispatch
          temp2 = temp2 - 8
          on temp2 goto Char24Attack, Char25Attack, Char26Attack, Char27Attack, Char28Attack, Char29Attack, Char30Attack, ShamoneAttack
DoneCharacterAttackDispatch
          rem Default to Bernie attack if invalid character
          goto BernieAttack