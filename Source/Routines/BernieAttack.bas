          rem ChaosFight - Source/Routines/BernieAttack.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

BernieAttack
          asm
BernieAttack

end
          rem Executes Bernies ground-thump area attack
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
          rem Output: Two mêlée attacks executed (left and right),
          rem facing direction restored
          rem
          rem Mutates: temp1, temp3 (used for calculations),
          rem playerState[] (animation state set, facing toggled and
          rem restored),
          rem         missile state (via PerformMeleeAttack)
          rem
          rem Called Routines: PerformMeleeAttack (bank7) - executes mêlée
          rem attack via shared tables
          rem Constraints: None
          rem Area-of-effect attack: hits both left AND right
          rem simultaneously
          rem Save original facing direction
          let temp3 = playerState[temp1] & PlayerStateBitFacing
          rem Set animation state (PerformMeleeAttack also sets it, but
          rem we need it set first)
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted
          rem Attack in facing direction (inline former PerformMeleeAttack)
          gosub SpawnMissile bank7
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted
          rem Flip facing (XOR with bit 0)
          let playerState[temp1] = playerState[temp1] ^ PlayerStateBitFacing
          rem Attack in opposite direction (inline former PerformMeleeAttack)
          gosub SpawnMissile bank7
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted
          rem Restore original facing (XOR again to flip back)
          let playerState[temp1] = playerState[temp1] ^ PlayerStateBitFacing
          return otherbank

