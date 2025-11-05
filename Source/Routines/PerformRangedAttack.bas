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
          rem Spawn projectile missile for this attack
          gosub bank7 SpawnMissile
          
          rem Set animation state to attacking
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (ActionAttackExecute << 4)
          rem Set animation state 14 (attack execution)
          
          return

