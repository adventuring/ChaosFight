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
          rem Bernie (Character 0) - Ground Thump (Area-of-Effect) attack
          rem Input: temp1 = attacker player index (0-3)
          rem        playerState[] (global array) = player state flags
          rem        MaskPlayerStateFlags (constant) = bitmask to preserve state flags
          rem        ActionAttackExecuteShifted (constant) = attack execution animation state
          rem        PlayerStateBitFacing (constant) = facing direction bit
          rem Output: Two melee attacks executed (left and right), facing direction restored
          rem Mutates: temp1, temp3 (used for calculations), playerState[] (animation state set, facing toggled and restored),
          rem         missile state (via PerformMeleeAttack)
          rem Called Routines: PerformMeleeAttack - executes melee attack, spawns missile
          rem Constraints: None
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
          rem Curler (Character 1) - Ranged attack (ground-based)
          rem Input: temp1 = attacker player index (0-3)
          rem Output: Ranged attack executed
          rem Mutates: playerState[] (animation state set), missile state (via PerformRangedAttack)
          rem Called Routines: PerformRangedAttack - executes ranged attack, spawns projectile
          rem Constraints: Tail call to PerformRangedAttack
          rem Ranged attack (ground-based)
          goto PerformRangedAttack

DragonetAttack
          rem Dragonet (Character 2) - Ranged attack (fireballs that arc downwards)
          rem Input: temp1 = attacker player index (0-3)
          rem Output: Ranged attack executed
          rem Mutates: playerState[] (animation state set), missile state (via PerformRangedAttack)
          rem Called Routines: PerformRangedAttack - executes ranged attack, spawns projectile
          rem Constraints: Tail call to PerformRangedAttack
          rem Ranged attack (fireballs that arc downwards)
          goto PerformRangedAttack

ZoeRyenAttack
          rem ZoeRyen (Character 3) - Ranged attack
          rem Input: temp1 = attacker player index (0-3)
          rem Output: Ranged attack executed
          rem Mutates: playerState[] (animation state set), missile state (via PerformRangedAttack)
          rem Called Routines: PerformRangedAttack - executes ranged attack, spawns projectile
          rem Constraints: Tail call to PerformRangedAttack
          rem Ranged attack
          goto PerformRangedAttack

FatTonyAttack
          rem FatTony (Character 4) - Ranged attack (magic ring lasers)
          rem Input: temp1 = attacker player index (0-3)
          rem Output: Ranged attack executed
          rem Mutates: playerState[] (animation state set), missile state (via PerformRangedAttack)
          rem Called Routines: PerformRangedAttack - executes ranged attack, spawns projectile
          rem Constraints: Tail call to PerformRangedAttack
          rem Ranged attack (magic ring lasers)
          goto PerformRangedAttack

MegaxAttack
          rem Megax (Character 5) - Melee attack (fire breath visual - missile stays stationary)
          rem Input: temp1 = attacker player index (0-3)
          rem Output: Melee attack executed
          rem Mutates: playerState[] (animation state set), missile state (via PerformMeleeAttack)
          rem Called Routines: PerformMeleeAttack - executes melee attack, spawns missile
          rem Constraints: Tail call to PerformMeleeAttack
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
          rem Harpy (Character 6) - Diagonal Downward Swoop Attack
          rem Input: temp1 = attacker player index (0-3)
          rem        playerState[] (global array) = player state flags
          rem        characterStateFlags_R[] (global SCRAM array) = character state flags
          rem        MaskPlayerStateFlags (constant) = bitmask to preserve state flags
          rem        ActionAttackExecuteShifted (constant) = attack execution animation state
          rem        PlayerStateBitFacing (constant) = facing direction bit
          rem Output: Animation state set, player velocity set for diagonal swoop, jumping flag set,
          rem         swoop attack flag set
          rem Mutates: temp1-temp5 (used for calculations), playerState[] (animation state and jumping flag set),
          rem         playerVelocityX[], playerVelocityXL[], playerVelocityY[], playerVelocityYL[] (set for swoop),
          rem         characterStateFlags_W[] (swoop attack flag set)
          rem Called Routines: None
          rem Constraints: Must be colocated with HarpySetLeftVelocity, HarpySetVerticalVelocity (called via goto)
          dim HA_playerIndex = temp1
          dim HA_facing = temp2
          dim HA_velocityX = temp4
          dim HA_velocityY = temp3
          dim HA_stateFlags = temp5
          
          rem Set attack animation state
          rem Use temp1 directly for indexed addressing (batariBASIC does not resolve dim aliases)
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted 
          rem Set animation state 14 (attack execution)
          
          rem Get facing direction (bit 0: 0=left, 1=right)
          let HA_facing = playerState[temp1] & PlayerStateBitFacing
          
          rem Set diagonal velocity at 45° angle (4 pixels/frame
          rem   horizontal, 4 pixels/frame vertical)
          rem Horizontal: 4 pixels/frame in facing direction
          if HA_facing = 0 then HarpySetLeftVelocity
          rem Facing right: positive X velocity
          let HA_velocityX = 4
          goto HarpySetVerticalVelocity
HarpySetLeftVelocity
          rem Set left-facing velocity for Harpy swoop
          rem Input: None (called from HarpyAttack)
          rem Output: HA_velocityX set to 252 (-4 in signed 8-bit)
          rem Mutates: temp4 (HA_velocityX set to 252)
          rem Called Routines: None
          rem Constraints: Must be colocated with HarpyAttack, HarpySetVerticalVelocity
          rem Facing left: negative X velocity (252 = -4 in signed
          rem   8-bit)
          let HA_velocityX = 252
HarpySetVerticalVelocity
          rem Set vertical velocity for Harpy swoop
          rem Input: None (called from HarpyAttack)
          rem Output: HA_velocityY set to 4, player velocity arrays set
          rem Mutates: temp3 (HA_velocityY set to 4), playerVelocityX[], playerVelocityXL[],
          rem         playerVelocityY[], playerVelocityYL[], playerState[], characterStateFlags_W[]
          rem Called Routines: None
          rem Constraints: Must be colocated with HarpyAttack, HarpySetLeftVelocity
          rem Vertical: 4 pixels/frame downward (positive Y = down)
          let HA_velocityY = 4
          
          rem Set player velocity for diagonal swoop (45° angle:
          rem   4px/frame X, 4px/frame Y) - inlined for performance
          rem Use temp1 directly for indexed addressing (batariBASIC does not resolve dim aliases)
          let playerVelocityX[temp1] = HA_velocityX
          let playerVelocityXL[temp1] = 0
          let playerVelocityY[temp1] = HA_velocityY
          let playerVelocityYL[temp1] = 0
          
          rem Set jumping state so character can move vertically during
          rem   swoop
          rem This allows vertical movement without being on ground
          rem Use temp1 directly for indexed addressing (batariBASIC does not resolve dim aliases)
          let playerState[temp1] = playerState[temp1] | 4
          rem Set bit 2 (jumping flag)
          
          rem Set swoop attack flag for collision detection
          rem Bit 2 = swoop active (used to extend hitbox below
          rem   character during swoop)
          rem Collision system will check for hits below character
          rem   during swoop
          rem Fix RMW: Read from _R, modify, write to _W
          rem Use temp1 directly for indexed addressing (batariBASIC does not resolve dim aliases)
          let HA_stateFlags = characterStateFlags_R[temp1] | 4
          let characterStateFlags_W[temp1] = HA_stateFlags
          
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