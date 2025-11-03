rem ChaosFight - Source/Routines/Combat.bas
rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
rem COMBAT SYSTEM - Generic subroutines using player arrays
          rem =================================================================

rem =================================================================
rem DAMAGE INDICATOR SYSTEM
rem =================================================================
rem Shows visual feedback when players take damage

rem Show damage indicator for a player
rem Input: currentPlayer = player index (0-3), temp2 = damage amount
VisualShowDamageIndicator
          rem Set player to hurt state for visual feedback
          temp3 = playerState[currentPlayer] & %00011111 
          rem Keep lower 5 bits
          temp3 = temp3 | %10010000 
          rem Set animation to 9 (hurt state)
          let playerState[currentPlayer] = temp3
          
          rem Set recovery frames for hurt visual duration
          let playerRecoveryFrames[currentPlayer] = 15 
          rem 15 frames of hurt visual
          
          return

rem Damage indicator system (wrapper for compatibility)
CombatShowDamageIndicator
          gosub VisualShowDamageIndicator
          return

rem Damage sound system
PlayDamageSound
          let temp1 = SoundHit
          gosub bank15 PlaySoundEffect
          return

rem =================================================================
rem PERFORM MELEE ATTACK
rem =================================================================
rem Executes a melee attack for the specified player.
rem Spawns a brief missile visual (sword, fist, etc.) and checks for hits.

rem INPUT:
rem currentPlayer = attacker participant array index (0-3 maps to participants 1-4)
PerformMeleeAttack
          rem Spawn missile visual for this attack
          gosub bank7 SpawnMissile
          
          rem Set animation state to attacking
          let playerState[currentPlayer] = (playerState[currentPlayer] & %00001111) | (14 << 4)
          rem Set animation state 14 (attack execution)
          
          rem Check immediate collision with other players in melee range
          rem This is handled by the main collision detection system
          rem For now, collision will be handled in UpdateAllMissiles
          
          return

rem =================================================================
rem PERFORM RANGED ATTACK
rem =================================================================
rem Executes a ranged attack for the specified player.
rem Spawns a projectile missile that travels across the screen.

rem INPUT:
rem currentPlayer = attacker participant array index (0-3 maps to participants 1-4)
PerformRangedAttack
          rem Spawn projectile missile for this attack
          gosub bank7 SpawnMissile
          
          rem Set animation state to attacking
          let playerState[currentPlayer] = (playerState[currentPlayer] & %00001111) | (14 << 4)
          rem Set animation state 14 (attack execution)
          
          return
