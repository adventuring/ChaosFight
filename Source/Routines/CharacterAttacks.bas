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
          rem Area-of-effect attack: hits both left AND right simultaneously
          rem Save original facing direction
          let BA_originalFacing = playerState[BA_attackerIndex] & PlayerStateBitFacing
          rem Set animation state (PerformMeleeAttack also sets it, but we need it set first)
          let playerState[BA_attackerIndex] = (playerState[BA_attackerIndex] & MaskPlayerStateFlags) | ActionAttackExecuteShifted 
          rem Attack in facing direction
          gosub PerformMeleeAttack
          rem Flip facing (XOR with bit 0)
          let playerState[BA_attackerIndex] = playerState[BA_attackerIndex] ^ PlayerStateBitFacing
          rem Attack in opposite direction
          gosub PerformMeleeAttack
          rem Restore original facing (XOR again to flip back)
          let playerState[BA_attackerIndex] = playerState[BA_attackerIndex] ^ PlayerStateBitFacing
          return

          rem ==========================================================
          rem SIMPLE CHARACTER ATTACKS (Consolidated)
          rem ==========================================================
          rem Simple attacks that just set animation state and call
          rem   PerformMeleeAttack or PerformRangedAttack
          rem NOTE: PerformMeleeAttack and PerformRangedAttack already set
          rem   animation state, so we can skip it here to save bytes
          rem Character-specific attack type is determined by dispatcher
          rem   which uses CharacterAttackTypes lookup table
CurlerAttack
          rem Ranged attack (ground-based)
          goto PerformRangedAttack

DragonetAttack
          rem Ranged attack (fireballs that arc downwards)
          goto PerformRangedAttack

ZoeRyenAttack
          rem Ranged attack
          goto PerformRangedAttack

FatTonyAttack
          rem Ranged attack (magic ring lasers)
          goto PerformRangedAttack

MegaxAttack
          rem Melee attack (fire breath visual - missile stays stationary)
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

KnightGuyAttack
          rem Melee attack (sword visual - missile moves away then returns)
          goto PerformMeleeAttack

FrootyAttack
          rem Ranged attack (magical sparkles from lollipop)
          goto PerformRangedAttack

NefertemAttack
          rem Melee attack
          goto PerformMeleeAttack

NinjishGuyAttack
          rem Ranged attack (small bullet)
          goto PerformRangedAttack

PorkChopAttack
          rem Melee attack
          goto PerformMeleeAttack

RadishGoblinAttack
          rem Melee attack
          goto PerformMeleeAttack

RoboTitoAttack
          rem Melee attack
          goto PerformMeleeAttack

UrsuloAttack
          rem Melee attack (claw swipe)
          goto PerformMeleeAttack

ShamoneAttack
          rem Special attack: jumps while attacking simultaneously
          rem First, execute the jump
          let playerY[temp1] = playerY[temp1] - 11 
          rem Light character, good jump
          let playerState[temp1] = playerState[temp1] | PlayerStateBitJumping
          rem Set jumping flag
          rem Then execute the attack (PerformMeleeAttack sets animation state)
          goto PerformMeleeAttack

          rem ==========================================================
          rem CHARACTER ATTACK DISPATCHER
          rem ==========================================================
          rem NOTE: DispatchCharacterAttack is defined in PlayerInput.bas
          rem   to avoid duplication. This file contains only the
          rem   character-specific attack implementations.