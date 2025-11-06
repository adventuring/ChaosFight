BernieAttack
          rem
          rem ChaosFight - Source/Routines/CharacterAttacks.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Character-specific Attack Subroutines
          rem Each character has a unique attack subroutine that:
          rem 1. Calls either PerformMeleeAttack or PerformRangedAttack
          rem   2. Sets the appropriate animation state
          rem   3. Handles any character-specific attack logic
          rem Input for all attack routines:
          rem   temp1 = attacker player index (0-3)
          rem
          rem All other needed data (X, Y, facing direction, etc.) is
          rem   looked up
          rem from the player arrays using temp1 as the index
          rem Bernie (character 0) - Ground Thump (area-of-effect)
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
          dim BA_attackerIndex = temp1 : rem Constraints: None
          dim BA_originalFacing = temp3
          rem Area-of-effect attack: hits both left AND right simultaneously
          let BA_originalFacing = playerState[BA_attackerIndex] & PlayerStateBitFacing : rem Save original facing direction
          rem Set animation state (PerformMeleeAttack also sets it, but we need it set first)
          let playerState[BA_attackerIndex] = (playerState[BA_attackerIndex] & MaskPlayerStateFlags) | ActionAttackExecuteShifted 
          gosub PerformMeleeAttack : rem Attack in facing direction
          let playerState[BA_attackerIndex] = playerState[BA_attackerIndex] ^ PlayerStateBitFacing : rem Flip facing (XOR with bit 0)
          gosub PerformMeleeAttack : rem Attack in opposite direction
          let playerState[BA_attackerIndex] = playerState[BA_attackerIndex] ^ PlayerStateBitFacing : rem Restore original facing (XOR again to flip back)
          return

          rem
          rem Simple Character Attacks (consolidated)
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
          goto PerformRangedAttack : rem Ranged attack (ground-based)

DragonetAttack
          rem Dragonet (Character 2) - Ranged attack (fireballs that arc downwards)
          rem Input: temp1 = attacker player index (0-3)
          rem Output: Ranged attack executed
          rem Mutates: playerState[] (animation state set), missile state (via PerformRangedAttack)
          rem Called Routines: PerformRangedAttack - executes ranged attack, spawns projectile
          rem Constraints: Tail call to PerformRangedAttack
          goto PerformRangedAttack : rem Ranged attack (fireballs that arc downwards)

ZoeRyenAttack
          rem ZoeRyen (Character 3) - Ranged attack
          rem Input: temp1 = attacker player index (0-3)
          rem Output: Ranged attack executed
          rem Mutates: playerState[] (animation state set), missile state (via PerformRangedAttack)
          rem Called Routines: PerformRangedAttack - executes ranged attack, spawns projectile
          rem Constraints: Tail call to PerformRangedAttack
          goto PerformRangedAttack : rem Ranged attack

FatTonyAttack
          rem FatTony (Character 4) - Ranged attack (magic ring lasers)
          rem Input: temp1 = attacker player index (0-3)
          rem Output: Ranged attack executed
          rem Mutates: playerState[] (animation state set), missile state (via PerformRangedAttack)
          rem Called Routines: PerformRangedAttack - executes ranged attack, spawns projectile
          rem Constraints: Tail call to PerformRangedAttack
          goto PerformRangedAttack : rem Ranged attack (magic ring lasers)

MegaxAttack
          rem Megax (Character 5) - Melee attack (fire breath visual - missile stays stationary)
          rem Input: temp1 = attacker player index (0-3)
          rem Output: Melee attack executed
          rem Mutates: playerState[] (animation state set), missile state (via PerformMeleeAttack)
          rem Called Routines: PerformMeleeAttack - executes melee attack, spawns missile
          rem Constraints: Tail call to PerformMeleeAttack
          goto PerformMeleeAttack : rem Melee attack (fire breath visual - missile stays stationary)

          rem
          rem Harpy (character 6) - Diagonal Downward Swoop Attack
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
          
          let HA_facing = playerState[temp1] & PlayerStateBitFacing : rem Get facing direction (bit 0: 0=left, 1=right)
          
          rem Set diagonal velocity at 45° angle (4 pixels/frame
          rem   horizontal, 4 pixels/frame vertical)
          if HA_facing = 0 then HarpySetLeftVelocity : rem Horizontal: 4 pixels/frame in facing direction
          let HA_velocityX = 4 : rem Facing right: positive X velocity
          goto HarpySetVerticalVelocity
HarpySetLeftVelocity
          rem Set left-facing velocity for Harpy swoop
          rem Input: None (called from HarpyAttack)
          rem Output: HA_velocityX set to 252 (-4 in signed 8-bit)
          rem Mutates: temp4 (HA_velocityX set to 252)
          rem Called Routines: None
          rem Constraints: Must be colocated with HarpyAttack, HarpySetVerticalVelocity
          rem Facing left: negative X velocity (252 = -4 in signed
          let HA_velocityX = 252 : rem   8-bit)
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
          rem KnightGuy (Character 7) - Melee attack (sword visual - missile moves away then returns)
          rem Input: temp1 = attacker player index (0-3)
          rem Output: Melee attack executed
          rem Mutates: playerState[] (animation state set), missile state (via PerformMeleeAttack)
          rem Called Routines: PerformMeleeAttack (tail call via goto) - executes melee attack, spawns missile
          rem Constraints: Tail call to PerformMeleeAttack
          goto PerformMeleeAttack : rem Melee attack (sword visual - missile moves away then returns)

FrootyAttack
          rem Frooty (Character 8) - Ranged attack (magical sparkles from lollipop)
          rem Input: temp1 = attacker player index (0-3)
          rem Output: Ranged attack executed
          rem Mutates: playerState[] (animation state set), missile state (via PerformRangedAttack)
          rem Called Routines: PerformRangedAttack (tail call via goto) - executes ranged attack, spawns projectile
          rem Constraints: Tail call to PerformRangedAttack
          goto PerformRangedAttack : rem Ranged attack (magical sparkles from lollipop)

NefertemAttack
          rem Nefertem (Character 9) - Melee attack
          rem Input: temp1 = attacker player index (0-3)
          rem Output: Melee attack executed
          rem Mutates: playerState[] (animation state set), missile state (via PerformMeleeAttack)
          rem Called Routines: PerformMeleeAttack (tail call via goto) - executes melee attack, spawns missile
          rem Constraints: Tail call to PerformMeleeAttack
          goto PerformMeleeAttack : rem Melee attack

NinjishGuyAttack
          rem NinjishGuy (Character 10) - Ranged attack (small bullet)
          rem Input: temp1 = attacker player index (0-3)
          rem Output: Ranged attack executed
          rem Mutates: playerState[] (animation state set), missile state (via PerformRangedAttack)
          rem Called Routines: PerformRangedAttack (tail call via goto) - executes ranged attack, spawns projectile
          rem Constraints: Tail call to PerformRangedAttack
          goto PerformRangedAttack : rem Ranged attack (small bullet)

PorkChopAttack
          rem PorkChop (Character 11) - Melee attack
          rem Input: temp1 = attacker player index (0-3)
          rem Output: Melee attack executed
          rem Mutates: playerState[] (animation state set), missile state (via PerformMeleeAttack)
          rem Called Routines: PerformMeleeAttack (tail call via goto) - executes melee attack, spawns missile
          rem Constraints: Tail call to PerformMeleeAttack
          goto PerformMeleeAttack : rem Melee attack

RadishGoblinAttack
          rem RadishGoblin (Character 12) - Melee attack
          rem Input: temp1 = attacker player index (0-3)
          rem Output: Melee attack executed
          rem Mutates: playerState[] (animation state set), missile state (via PerformMeleeAttack)
          rem Called Routines: PerformMeleeAttack (tail call via goto) - executes melee attack, spawns missile
          rem Constraints: Tail call to PerformMeleeAttack
          goto PerformMeleeAttack : rem Melee attack

RoboTitoAttack
          rem RoboTito (Character 13) - Melee attack
          rem Input: temp1 = attacker player index (0-3)
          rem Output: Melee attack executed
          rem Mutates: playerState[] (animation state set), missile state (via PerformMeleeAttack)
          rem Called Routines: PerformMeleeAttack (tail call via goto) - executes melee attack, spawns missile
          rem Constraints: Tail call to PerformMeleeAttack
          goto PerformMeleeAttack : rem Melee attack

UrsuloAttack
          rem Ursulo (Character 14) - Melee attack (claw swipe)
          rem Input: temp1 = attacker player index (0-3)
          rem Output: Melee attack executed
          rem Mutates: playerState[] (animation state set), missile state (via PerformMeleeAttack)
          rem Called Routines: PerformMeleeAttack (tail call via goto) - executes melee attack, spawns missile
          rem Constraints: Tail call to PerformMeleeAttack
          goto PerformMeleeAttack : rem Melee attack (claw swipe)

ShamoneAttack
          rem Shamone (Character 15) - Special attack: jumps while attacking simultaneously
          rem Input: temp1 = attacker player index (0-3)
          rem        playerY[] (global array) = player Y positions
          rem        playerState[] (global array) = player state flags
          rem        MaskPlayerStateFlags (constant) = bitmask to preserve state flags
          rem        ActionAttackExecuteShifted (constant) = attack execution animation state
          rem Output: Player jumps 11 pixels up, melee attack executed
          rem Mutates: temp1 (used for calculations), playerY[] (moved up 11 pixels), playerState[] (animation state set), missile state (via PerformMeleeAttack)
          rem Called Routines: PerformMeleeAttack - executes melee attack, spawns missile
          rem Constraints: None
          rem Special attack: jumps while attacking simultaneously
          let playerY[temp1] = playerY[temp1] - 11 : rem First, execute the jump
          let playerState[temp1] = playerState[temp1] | PlayerStateBitJumping : rem Light character, good jump
          rem Set jumping flag
          goto PerformMeleeAttack : rem Then execute the attack (PerformMeleeAttack sets animation state)

          rem
          rem Character Attack Dispatcher
          rem NOTE: DispatchCharacterAttack is defined in PlayerInput.bas
          rem   to avoid duplication. This file contains only the
          rem   character-specific attack implementations.