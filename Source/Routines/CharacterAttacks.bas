          rem ChaosFight - Source/Routines/CharacterAttacks.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Character-specific Attack Subroutines

BernieAttack
          rem Executes Bernie’s ground-thump area attack
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
          rem Bernie (character 0) - Ground Thump area-of-effect attack
          rem
          rem Input: temp1 = attacker player index (0-3)
          rem        playerState[] (global array) = player state flags
          rem        MaskPlayerStateFlags (constant) = bitmask to
          rem        preserve state flags
          rem        ActionAttackExecuteShifted (constant) = attack
          rem        execution animation state
          rem        PlayerStateBitFacing (constant) = facing direction
          rem        bit
          rem
          rem Output: Two melee attacks executed (left and right),
          rem facing direction restored
          rem
          rem Mutates: temp1, temp3 (used for calculations),
          rem playerState[] (animation state set, facing toggled and
          rem restored),
          rem         missile state (via PerformMeleeAttack)
          rem
          rem Called Routines: PerformMeleeAttack - executes melee
          rem attack
          rem Constraints: None
          rem Area-of-effect attack: hits both left AND right
          rem simultaneously
          rem Save original facing direction
let temp3 = playerState[temp1] & PlayerStateBitFacing
          rem Set animation state (PerformMeleeAttack also sets it, but
          rem we need it set first)
let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted
          rem Attack in facing direction
gosub PerformMeleeAttack bank7
          rem Flip facing (XOR with bit 0)
let playerState[temp1] = playerState[temp1] ^ PlayerStateBitFacing
          rem Attack in opposite direction
gosub PerformMeleeAttack bank7
          rem Restore original facing (XOR again to flip back)
let playerState[temp1] = playerState[temp1] ^ PlayerStateBitFacing
return

          rem NOTE: Characters with simple melee or ranged attacks now dispatch
          rem directly to PerformMeleeAttack or PerformRangedAttack from
          rem CharacterAttacksDispatch.bas. No dedicated wrapper routines are
          rem required for those cases.

HarpyAttack
          rem
          rem Harpy (character 6) - Diagonal downward swoop attack
          rem Attack moves the character along a 45° downward path; the sprite acts
          rem   as the hitbox for the 5-frame swoop animation.
          rem Input: temp1 = attacker player index (0-3)
          rem        playerState[] (global array) = player state flags
          rem        characterStateFlags_R[] (global SCRAM array) =
          rem        character state flags
          rem        MaskPlayerStateFlags (constant) = bitmask to
          rem        preserve state flags
          rem        ActionAttackExecuteShifted (constant) = attack
          rem        execution animation state
          rem        PlayerStateBitFacing (constant) = facing direction
          rem        bit
          rem
          rem Output: Animation state set, player velocity set for
          rem diagonal swoop, jumping flag set,
          rem         swoop attack flag set
          rem
          rem Mutates: temp1-temp5 (used for calculations),
          rem playerState[] (animation state and jumping flag set),
          rem         playerVelocityX[], playerVelocityXL[],
          rem         playerVelocityY[], playerVelocityYL[] (set for
          rem         swoop),
          rem         characterStateFlags_W[] (swoop attack flag set)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with HarpySetLeftVelocity,
          rem HarpySetVerticalVelocity (called via goto)
          
          rem Set attack animation state
          rem Use temp1 directly for indexed addressing (batariBASIC
          rem does not resolve dim aliases)
let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted 
          rem Set animation state 14 (attack execution)

          rem Get facing direction (bit 0: 0=left, 1=right)
let temp2 = playerState[temp1] & PlayerStateBitFacing
          
          rem Set diagonal velocity at 45° angle (4 pixels/frame
          rem   horizontal, 4 pixels/frame vertical)
          rem Horizontal: 4 pixels/frame in facing direction
          rem Use explicit assignment to dodge unsupported multiply op
          rem When temp2=0 (left): want 252 (-4), when temp2≠0 (right): want 4
let temp4 = 252
if temp2 then temp4 = 4
HarpySetLeftVelocity
          rem Label for documentation - velocity already set above
          rem Constraints: Must be colocated with HarpyAttack,
          rem HarpySetVerticalVelocity
HarpySetVerticalVelocity
          rem Set vertical velocity for Harpy swoop
          rem
          rem Input: None (called from HarpyAttack)
          rem
          rem Output: temp3 set to 4, player velocity arrays set
          rem
          rem Mutates: temp3 (temp3 set to 4), playerVelocityX[],
          rem playerVelocityXL[],
          rem         playerVelocityY[], playerVelocityYL[],
          rem         playerState[], characterStateFlags_W[]
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with HarpyAttack,
          rem HarpySetLeftVelocity
          rem Vertical: 4 pixels/frame downward (positive Y = down)
let temp3 = 4
          
          rem Set player velocity for diagonal swoop (45° angle:
          rem   4px/frame X, 4px/frame Y) - inlined for performance
          rem Use temp1 directly for indexed addressing (batariBASIC
          rem does not resolve dim aliases)
let playerVelocityX[temp1] = temp4
let playerVelocityXL[temp1] = 0
let playerVelocityY[temp1] = temp3
let playerVelocityYL[temp1] = 0
          
          rem Set jumping state so character can move vertically during
          rem   swoop
          rem This allows vertical movement without being on ground
          rem Use temp1 directly for indexed addressing (batariBASIC
          rem does not resolve dim aliases)
let playerState[temp1] = playerState[temp1] | 4
          rem Set bit 2 (jumping flag)
          
          rem Set swoop attack flag for collision detection
          rem Bit 2 = swoop active (used to extend hitbox below
          rem   character during swoop)
          rem Collision system will check for hits below character
          rem   during swoop
          rem Fix RMW: Read from _R, modify, write to _W
          rem Use temp1 directly for indexed addressing (batariBASIC
          rem does not resolve dim aliases)
let temp5 = characterStateFlags_R[temp1] | 4
let characterStateFlags_W[temp1] = temp5
          
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

UrsuloAttack
          asm
          UrsuloAttack = .UrsuloAttack
end
          rem Ursulo (Character 14) - Melee attack (claw swipe)
          rem
          rem Input: temp1 = attacker player index (0-3)
          rem
          rem Output: Melee attack executed
          rem
          rem Mutates: playerState[] (animation state set), missile
          rem state (via PerformMeleeAttack)
          rem
          rem Called Routines: PerformMeleeAttack (tail call via goto) -
          rem executes melee attack, spawns missile
          rem
          rem Constraints: Tail call to PerformMeleeAttack
          rem Melee attack (claw swipe)
gosub PerformMeleeAttack bank7
return

ShamoneAttack
          asm
          ShamoneAttack = .ShamoneAttack
end
          rem Shamone (Character 15) - Special attack: jumps while
          rem attacking simultaneously
          rem
          rem Input: temp1 = attacker player index (0-3)
          rem        playerY[] (global array) = player Y positions
          rem        playerState[] (global array) = player state flags
          rem        MaskPlayerStateFlags (constant) = bitmask to
          rem        preserve state flags
          rem        ActionAttackExecuteShifted (constant) = attack
          rem        execution animation state
          rem
          rem Output: Player jumps 11 pixels up, melee attack executed
          rem
          rem Mutates: temp1 (used for calculations), playerY[] (moved
          rem up 11 pixels), playerState[] (animation state set),
          rem missile state (via PerformMeleeAttack)
          rem
          rem Called Routines: PerformMeleeAttack - executes melee
          rem attack, spawns missile
          rem
          rem Constraints: None
          rem Special attack: jumps while attacking simultaneously
let playerY[temp1] = playerY[temp1] - 11
          rem First, execute the jump
let playerState[temp1] = playerState[temp1] | PlayerStateBitJumping
          rem Light character, good jump
          rem Set jumping flag
          rem Then execute the attack (PerformMeleeAttack sets animation state)
gosub PerformMeleeAttack bank7
return

