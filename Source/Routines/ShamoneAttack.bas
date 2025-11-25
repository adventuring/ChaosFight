          rem ChaosFight - Source/Routines/ShamoneAttack.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

ShamoneAttack
          asm
ShamoneAttack
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
          rem Output: Player jumps 11 pixels up, mêlée attack executed
          rem
          rem Mutates: temp1 (used for calculations), playerY[] (moved
          rem up 11 pixels), playerState[] (animation state set),
          rem missile state (via PerformMeleeAttack)
          rem
          rem Called Routines: PerformMeleeAttack (bank7) - executes mêlée
          rem attack, spawns missile
          rem
          rem Constraints: None
          rem Special attack: jumps while attacking simultaneously
          rem First, execute the jump
          let playerY[temp1] = playerY[temp1] - 11
          rem Light character, good jump
          let playerState[temp1] = playerState[temp1] | PlayerStateBitJumping
          rem Set jumping flag
          rem Then execute the attack (inline former PerformMeleeAttack)
          gosub SpawnMissile bank7
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted
          return otherbank

