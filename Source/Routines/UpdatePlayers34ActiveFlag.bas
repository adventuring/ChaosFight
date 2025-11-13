          rem ChaosFight - Source/Routines/UpdatePlayers34ActiveFlag.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

UpdatePlayers34ActiveFlag
          asm
UpdatePlayers34ActiveFlag
end
          rem Update Players34Active flag when players 3/4 are present.
          rem Input: playerCharacter[] (global array), playersEliminated_R,
          rem        PlayerEliminatedPlayer2/3 masks, controllerStatus
          rem Output: controllerStatus updated with Players34Active flag
          let controllerStatus = controllerStatus & ClearPlayers34Active
          rem Clear flag first

          rem Check if Player 3 is active (selected and not eliminated)

          if playerCharacter[2] = NoCharacter then CheckPlayer4ActiveFlag
          if PlayerEliminatedPlayer2 & playersEliminated_R then CheckPlayer4ActiveFlag
          let controllerStatus = controllerStatus | SetPlayers34Active
          rem Player 3 is active

CheckPlayer4ActiveFlag
          asm
CheckPlayer4ActiveFlag
end
          rem Check if Player 4 is active (selected and not eliminated)
          if playerCharacter[3] = NoCharacter then UpdatePlayers34ActiveDone
          if PlayerEliminatedPlayer3 & playersEliminated_R then UpdatePlayers34ActiveDone
          let controllerStatus = controllerStatus | SetPlayers34Active
          rem Player 4 is active
UpdatePlayers34ActiveDone
          asm
UpdatePlayers34ActiveDone
end
          return

