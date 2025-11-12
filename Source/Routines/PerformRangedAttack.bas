PerformRangedAttack
          rem
          rem ChaosFight - Source/Routines/PerformRangedAttack.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Perform Ranged Attack
          rem Executes a ranged attack for the specified player.
          rem Spawns a projectile missile that travels across the
          rem screen.
          rem
          rem INPUT:
          rem   temp1 = attacker player index (0-3)
          rem Executes a ranged attack for the specified player
          rem
          rem Input: temp1 = attacker player index (0-3)
          rem        playerState[] (global array) = player state flags
          rem        MaskPlayerStateFlags (constant) = bitmask to
          rem        preserve state flags
          rem        ActionAttackExecuteShifted (constant) = attack
          rem        execution animation state
          rem
          rem Output: Projectile missile spawned, playerState[]
          rem animation state set to attacking
          rem
          rem Mutates: playerState[] (animation state set to
          rem ActionAttackExecuteShifted),
          rem         missile state (via SpawnMissile)
          rem
          rem Called Routines: SpawnMissile (bank12) - spawns projectile
          rem missile
          rem
          rem Constraints: None
          gosub SpawnMissile bank12
          rem Spawn projectile missile for this attack
          
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted
          rem Set animation state to attacking
          rem Set animation state 14 (attack execution)
          
          return
          asm
PerformRangedAttack = .PerformRangedAttack
end

