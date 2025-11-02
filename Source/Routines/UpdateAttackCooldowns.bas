          rem ChaosFight - Source/Routines/UpdateAttackCooldowns.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem UPDATE ATTACK COOLDOWNS
          rem =================================================================
          rem Updates attack cooldown timers for all players each frame.
          rem Decrements cooldown timers and clears them when they reach zero.
          
          rem AVAILABLE VARIABLES (from Variables.bas):
          rem   PlayerAttackCooldown[0-3] - Attack cooldown frame counters (var44-var47)
          rem =================================================================
          
          rem Update attack cooldowns for all players
UpdateAttackCooldowns
          rem Player 1 (index 0)
          if PlayerAttackCooldown[0] > 0 then PlayerAttackCooldown[0] = PlayerAttackCooldown[0] - 1
          
          rem Player 2 (index 1)
          if PlayerAttackCooldown[1] > 0 then PlayerAttackCooldown[1] = PlayerAttackCooldown[1] - 1
          
          rem Player 3 (index 2) - only if active
          if !QuadtariDetected then goto SkipPlayer3Cooldown
          if PlayerAttackCooldown[2] > 0 then PlayerAttackCooldown[2] = PlayerAttackCooldown[2] - 1
SkipPlayer3Cooldown
          
          rem Player 4 (index 3) - only if active
          if !QuadtariDetected then goto SkipPlayer4Cooldown
          if PlayerAttackCooldown[3] > 0 then PlayerAttackCooldown[3] = PlayerAttackCooldown[3] - 1
SkipPlayer4Cooldown
          
          return

