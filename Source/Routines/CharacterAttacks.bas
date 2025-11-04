          rem ChaosFight - Source/Routines/CharacterAttacks.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem CHARACTER-SPECIFIC ATTACK SUBROUTINES
          rem =================================================================
          rem Each character has a unique attack subroutine that:
          rem   1. Calls either PerformMeleeAttack or PerformRangedAttack
          rem   2. Sets the appropriate animation state
          rem   3. Handles any character-specific attack logic

          rem Input for all attack routines:
          rem   temp1 = attacker player index (0-3)

          rem All other needed data (X, Y, facing direction, etc.) is looked up
          rem from the player arrays using temp1 as the index

          rem =================================================================
          rem BERNIE (Character 0) - Melee Attack (Both Directions)
          rem =================================================================
BernieAttack
          rem Bernie special attack hits both left AND right simultaneously
          rem This is unique - all other melee attacks only hit in facing direction
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (ActionAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          
          rem Attack in facing direction
          gosub PerformMeleeAttack
          
          rem Also attack in opposite direction
          rem Temporarily flip facing
          let temp5 = playerState[temp1] & 1 
          rem Store original facing
          if temp5 then FaceLeft1
          let playerState[temp1] = playerState[temp1] | 1 
          rem Face right
          goto FacingDone1
FaceLeft1
          let playerState[temp1] = playerState[temp1] & 254 
          rem Face left
FacingDone1
          
          rem Attack in opposite direction
          gosub PerformMeleeAttack
          
          rem Restore original facing
          if temp5 then RestoreFaceRight1
          let playerState[temp1] = playerState[temp1] & 254
          goto RestoreFacingDone1
RestoreFaceRight1
          let playerState[temp1] = playerState[temp1] | 1
RestoreFacingDone1
          
          return

          rem =================================================================
          rem CURLER (Character 1) - Ranged Attack (ground-based)
          rem =================================================================
CurlerAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (ActionAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformRangedAttack

          rem =================================================================
          rem DRAGON OF STORMS (Character 2) - Melee Attack
          rem =================================================================
DragonetAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (ActionAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformMeleeAttack

          rem =================================================================
          rem ZOE RYEN (Character 3) - Ranged Attack
          rem =================================================================
ZoeRyenAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (ActionAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformRangedAttack

          rem =================================================================
          rem FAT TONY (Character 4) - Melee Attack
          rem =================================================================
FatTonyAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (ActionAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformRangedAttack

          rem =================================================================
          rem MEGAX (Character 5) - Ranged Attack
          rem =================================================================
MegaxAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (ActionAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformRangedAttack

          rem =================================================================
          rem HARPY (Character 6) - Diagonal Downward Swoop Attack
          rem =================================================================
          rem Harpy attack moves the character itself in a 45° rapid downward swoop
          rem Attack hitbox is below the character during the swoop
          rem 5-frame duration for the swoop attack visual
          rem No missile is spawned - character movement IS the attack
HarpyAttack
          dim HA_playerIndex = temp1
          dim HA_facing = temp2
          dim HA_velocityX = temp2
          dim HA_velocityY = temp3
          
          rem Set attack animation state
          let playerState[HA_playerIndex] = (playerState[HA_playerIndex] & MaskPlayerStateFlags) | (ActionAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          
          rem Get facing direction (bit 0: 0=left, 1=right)
          let HA_facing = playerState[HA_playerIndex] & 1
          
          rem Set diagonal velocity at 45° angle (4 pixels/frame horizontal, 4 pixels/frame vertical)
          rem Horizontal: 4 pixels/frame in facing direction
          if HA_facing = 0 then HarpySetLeftVelocity
          rem Facing right: positive X velocity
          let HA_velocityX = 4
          goto HarpySetVerticalVelocity
HarpySetLeftVelocity
          rem Facing left: negative X velocity (252 = -4 in signed 8-bit)
          let HA_velocityX = 252
HarpySetVerticalVelocity
          rem Vertical: 4 pixels/frame downward (positive Y = down)
          let HA_velocityY = 4
          
          rem Set player velocity for diagonal swoop (45° angle: 4px/frame X, 4px/frame Y)
          rem Use SetPlayerVelocity to set both X and Y velocities
          let temp1 = HA_playerIndex
          let temp2 = HA_velocityX
          let temp3 = HA_velocityY
          gosub SetPlayerVelocity
          
          rem Set jumping state so character can move vertically during swoop
          rem This allows vertical movement without being "on ground"
          let playerState[HA_playerIndex] = playerState[HA_playerIndex] | 4
          rem Set bit 2 (jumping flag)
          
          rem Set swoop attack flag for collision detection
          rem Bit 2 = swoop active (used to extend hitbox below character during swoop)
          rem Collision system will check for hits below character during swoop
          let characterStateFlags[HA_playerIndex] = characterStateFlags[HA_playerIndex] | 4
          
          rem Attack behavior:
          rem - Character moves diagonally down at 45° (4px/frame X, 4px/frame Y)
          rem - Attack hitbox is below character during movement
          rem - 5-frame attack animation duration (handled by animation system)
          rem - Movement continues until collision or attack animation completes
          rem - No missile spawned - character movement IS the attack
          rem - Hit players are damaged and pushed (knockback handled by collision system)
          
          return

          rem =================================================================
          rem KNIGHT GUY (Character 7) - Ranged Attack
          rem =================================================================
KnightGuyAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (ActionAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformRangedAttack

          rem =================================================================
          rem FROOTY (Character 8) - Ranged Attack with Magical Sparkles
          rem =================================================================
          rem Frooty fires magical sparkles from her lollipop weapon
          rem Sparkles are implemented via missile sprite graphics
          rem Multi-hit or spread patterns can use multiple sparkle sprites
          rem Sprite data should show sparkle particle effects
FrootyAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (ActionAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformRangedAttack
          rem Magical sparkles: Visual effect handled by missile sprite graphics
          rem The missile sprite for Frooty (character 8) should display sparkle particles
          rem Sprite generation via SkylineTool should create sparkle graphics

          rem =================================================================
          rem NEFERTEM (Character 9) - Melee Attack
          rem =================================================================
NefertemAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (ActionAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformMeleeAttack

          rem =================================================================
          rem NINJISH GUY (Character 10) - Ranged Attack (small bullet)
          rem =================================================================
NinjishGuyAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (ActionAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformRangedAttack

          rem =================================================================
          rem PORK CHOP (Character 11) - Melee Attack
          rem =================================================================
PorkChopAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (ActionAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformMeleeAttack

          rem =================================================================
          rem RADISH GOBLIN (Character 12) - Melee Attack
          rem =================================================================
RadishGoblinAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (ActionAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformMeleeAttack

          rem =================================================================
          rem ROBO TITO (Character 13) - Melee Attack
          rem =================================================================
RoboTitoAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (ActionAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformMeleeAttack

          rem =================================================================
          rem URSULO (Character 14) - Melee Attack (Claw Swipe)
          rem =================================================================
UrsuloAttack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (ActionAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformMeleeAttack

          rem =================================================================
          rem SHAMONE (Character 15) - Jump + Attack (Special)
          rem =================================================================
          rem Shamone special attack: jumps while attacking simultaneously
ShamoneAttack
          rem First, execute the jump
          let playerY[temp1] = playerY[temp1] - 11 
          rem Light character, good jump
          let playerState[temp1] = playerState[temp1] | (1 << PlayerStateJumping)
          rem Set jumping flag
          
          rem Then execute the attack
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (ActionAttackExecute << ShiftAnimationState) 
          rem Set animation state 14 (attack execution)
          rem tail call
          goto PerformMeleeAttack

          rem =================================================================
          rem CHARACTER ATTACK DISPATCHER
          rem =================================================================
          rem Routes to the appropriate character attack subroutine based on character type

          rem INPUT:
          rem   temp1 = attacker player index (0-3)

          rem All character attack routines will look up playerX[temp1], playerY[temp1],
          rem playerState[temp1], etc. as needed.

DispatchCharacterAttack
          rem Get character type for this player using direct array access
          rem temp1 contains player index (0-3)
          let temp2 = playerChar[temp1]
          rem Map MethHound (31) to ShamoneAttack handler
          if temp2 = 31 then temp2 = ActionAttackRecovery
          rem Use Shamone attack for MethHound
          on temp2 goto BernieAttack, CurlerAttack, DragonetAttack, ZoeRyenAttack, FatTonyAttack, MegaxAttack, HarpyAttack, KnightGuyAttack, FrootyAttack, NefertemAttack, NinjishGuyAttack, PorkChopAttack, RadishGoblinAttack, RoboTitoAttack, UrsuloAttack, ShamoneAttack
          rem Default to Bernie attack if invalid character
          goto BernieAttack