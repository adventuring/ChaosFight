PerformMeleeAttack
          asm
PerformMeleeAttack
end
          rem
          rem ChaosFight - Source/Routines/PerformMeleeAttack.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Perform Mêlée Attack
          rem Executes a mêlée attack for the specified player.
          rem Spawns a brief missile visual (sword, fist, etc.) and
          rem   checks for hits.
          rem
          rem INPUT:
          rem   temp1 = attacker player index (0-3)
          rem Executes a mêlée attack for the specified player
          rem
          rem Input: temp1 = attacker player index (0-3)
          rem        playerState[] (global array) = player state flags
          rem        MaskPlayerStateFlags (constant) = bitmask to
          rem        preserve state flags
          rem        ActionAttackExecuteShifted (constant) = attack
          rem        execution animation state
          rem
          rem Output: Missile spawned, playerState[] animation state set
          rem to attacking
          rem
          rem Mutates: playerState[] (animation state set to
          rem ActionAttackExecuteShifted),
          rem         missile state (via SpawnMissile)
          rem
          rem Called Routines: SpawnMissile - spawns missile
          rem visual for attack
          rem
          rem Constraints: None
          rem Spawn missile visual for this attack
          gosub SpawnMissile bank7

          rem Set animation state to attacking
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted
          rem Set animation state 14 (attack execution)

          rem Check immediate collision with other players in mêlée
          rem   range
          rem This is handled by the main collision detection system
          rem For now, collision will be handled in UpdateAllMissiles

          return otherbank
