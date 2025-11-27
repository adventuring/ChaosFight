          rem ChaosFight - Source/Routines/TriggerEliminationEffects.bas

          rem Copyright © 2025 Bruce-Robert Pocock.



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

          rem Play elimination sound effect

          let temp5 = SoundPlayerEliminated

          let temp1 = temp5

          rem PlaySoundEffect expects temp1 = sound ID

          gosub PlaySoundEffect bank15



          rem Set elimination visual effect timer

          rem This could trigger screen flash, particle effects, etc.

          let temp2 = 30

          rem 30 frames of elimination effect

          let eliminationEffectTimer_W[currentPlayer] = temp2



          rem Hide player sprite immediately

          rem Inline HideEliminatedPlayerSprite

          rem Off-screen

          if currentPlayer = 0 then player0x = 200

          if currentPlayer = 1 then player1x = 200

          rem Player 3 uses player2 sprite (multisprite)

          if currentPlayer = 2 then player2x = 200

          rem Player 4 uses player3 sprite (multisprite)

          if currentPlayer = 3 then player3x = 200



          rem Stop any active missiles for this player - inlined

          rem Clear missile active bit for this player (DeactivatePlayerMissiles)

          if currentPlayer = 0 then let missileActive = missileActive & $FE

          if currentPlayer = 1 then let missileActive = missileActive & $FD

          if currentPlayer = 2 then let missileActive = missileActive & $FB

          if currentPlayer = 3 then let missileActive = missileActive & $F7



          return otherbank


