          rem ChaosFight - Source/Routines/PerformMeleeAttack.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem ==========================================================
          rem PERFORM MELEE ATTACK
          rem ==========================================================
          rem Executes a melee attack for the specified player.
          rem Spawns a brief missile visual (sword, fist, etc.) and
          rem   checks for hits.

          rem INPUT:
          rem   temp1 = attacker player index (0-3)
PerformMeleeAttack
          rem Spawn missile visual for this attack
          gosub bank7 SpawnMissile
          
          rem Set animation state to attacking
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted
          rem Set animation state 14 (attack execution)
          
          rem Check immediate collision with other players in melee
          rem   range
          rem This is handled by the main collision detection system
          rem For now, collision will be handled in UpdateAllMissiles
          
          return
