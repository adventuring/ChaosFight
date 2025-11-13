          rem ChaosFight - Source/Routines/TriggerEliminationEffects.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

TriggerEliminationEffects
          asm
TriggerEliminationEffects
end
          rem
          rem Trigger elimination audio/visual effects for currentPlayer.
          rem Input: currentPlayer (0-3), SoundPlayerEliminated
          rem Output: Plays sound, configures effect timer, hides sprite, deactivates missiles
          rem Mutates: temp2, temp5, eliminationTimer[], playerState[], playerX/Y[]
          rem sound ID), player0x, player1x, player2x, player3x (TIA
          rem registers) = sprite positions moved off-screen,
          rem eliminationEffectTimer[] (global array) = effect timers,
          rem missileActive (global) = missile state (via
          rem DeactivatePlayerMissiles)
          rem
          rem Called Routines: PlaySoundEffect (bank15) - plays
          rem elimination sound, DeactivatePlayerMissiles (tail call) -
          rem removes player missiles
          rem Constraints: None
          let temp5 = SoundPlayerEliminated
          rem Play elimination sound effect
          let temp1 = temp5
          gosub PlaySoundEffect bank15
          rem PlaySoundEffect expects temp1 = sound ID

          rem Set elimination visual effect timer
          let temp2 = 30
          rem This could trigger screen flash, particle effects, etc.
          let eliminationEffectTimer_W[currentPlayer] = temp2
          rem 30 frames of elimination effect

          rem Hide player sprite immediately
          rem Inline HideEliminatedPlayerSprite
          if currentPlayer = 0 then player0x = 200
          rem Off-screen
          if currentPlayer = 1 then player1x = 200
          if currentPlayer = 2 then player2x = 200
          rem Player 3 uses player2 sprite (multisprite)
          if currentPlayer = 3 then player3x = 200
          rem Player 4 uses player3 sprite (multisprite)

          rem Stop any active missiles for this player
          goto DeactivatePlayerMissiles bank12
          rem tail call


          return

