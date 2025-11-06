          rem ChaosFight - Source/Routines/PerformRangedAttack.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem ==========================================================
          rem PERFORM RANGED ATTACK
          rem ==========================================================
          rem Executes a ranged attack for the specified player.
          rem Spawns a projectile missile that travels across the screen.

          rem INPUT:
          rem   temp1 = attacker player index (0-3)
PerformRangedAttack
          rem Executes a ranged attack for the specified player
          rem Input: temp1 = attacker player index (0-3)
          rem        playerState[] (global array) = player state flags
          rem        MaskPlayerStateFlags (constant) = bitmask to preserve state flags
          rem        ActionAttackExecuteShifted (constant) = attack execution animation state
          rem Output: Projectile missile spawned, playerState[] animation state set to attacking
          rem Mutates: playerState[] (animation state set to ActionAttackExecuteShifted),
          rem         missile state (via SpawnMissile)
          rem Called Routines: SpawnMissile (bank7) - spawns projectile missile
          rem Constraints: None
          rem Spawn projectile missile for this attack
          gosub SpawnMissile bank7
          
          rem Set animation state to attacking
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted
          rem Set animation state 14 (attack execution)
          
          return

