          rem ChaosFight - Source/Routines/VisualEffects.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem VISUAL EFFECTS SYSTEM
          rem =================================================================
          rem Provides visual feedback for damage, hits, and other effects

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

          rem =================================================================
          rem FLASH EFFECT SYSTEM
          rem =================================================================
          rem Provides flashing effects during recovery/invulnerability

          rem Flash effect for recovery frames
          rem Input: currentPlayer = player index (0-3)
FlashRecoveryEffect
          rem Check if player is in recovery
          temp2 = playerRecoveryFrames[currentPlayer]
          if temp2 = 0 then return
          
          rem Flash every other frame
          temp3 = frame & 1
          rem tail call
          if temp3 = 0 then goto SetPlayerNormalColor
          gosub SetPlayerDimmedColor
          
          return

          rem Set player to normal color
SetPlayerNormalColor
          rem This will be called by PlayerRendering.bas
          rem Color is set based on player number and switchbw state
          return

          rem Set player to dimmed color
SetPlayerDimmedColor
          rem This will be called by PlayerRendering.bas
          rem Color is dimmed for hurt state
          return

          rem =================================================================
          rem HEALTH BAR VISUAL UPDATES
          rem =================================================================
          rem Updates health bar display based on current health

          rem Update health bar for a player
          rem Input: currentPlayer = player index (0-3)
UpdateHealthBar
          rem Health bar is handled by PlayerRendering.bas
          rem Visual effects are integrated into the damage system
          return

          rem =================================================================
          rem SPECIAL EFFECTS
          rem =================================================================
          rem Various special visual effects

          rem Screen flash effect
          rem Input: currentPlayer = intensity (0-15)
ScreenFlash
          rem Flash the background color
          temp2 = ColGrey(currentPlayer)
          COLUBK = ColGray(0)
          return

          rem Particle effect for hits
          rem Input: currentPlayer = player index (0-3)
HitParticleEffect
          rem This would show particle effects around the hit player
          rem For now, just a screen flash
          currentPlayer = 12
          gosub ScreenFlash
          return
