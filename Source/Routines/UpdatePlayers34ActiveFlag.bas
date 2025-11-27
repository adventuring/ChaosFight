          rem ChaosFight - Source/Routines/UpdatePlayers34ActiveFlag.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

UpdatePlayers34ActiveFlag
          rem Returns: Far (return otherbank)
          asm
UpdatePlayers34ActiveFlag
end
          rem Update Players34Active flag when players 3/4 are present.
          rem Returns: Far (return otherbank)
          rem Input: playerCharacter[] (global array), playerHealth[], controllerStatus
          rem Output: controllerStatus updated with Players34Active flag
          rem Clear flag first
          let controllerStatus = controllerStatus & ClearPlayers34Active

          rem Check if Player 3 is active (selected and not eliminated)

          if playerCharacter[2] = NoCharacter then CheckPlayer4ActiveFlag
          if playerHealth[2] = 0 then CheckPlayer4ActiveFlag
          rem Player 3 is active
          let controllerStatus = controllerStatus | SetPlayers34Active

CheckPlayer4ActiveFlag
          rem Returns: Far (return otherbank)
          asm
CheckPlayer4ActiveFlag
end
          rem Check if Player 4 is active (selected and not eliminated)
          rem Returns: Far (return otherbank)
          if playerCharacter[3] = NoCharacter then UpdatePlayers34ActiveDone
          if playerHealth[3] = 0 then UpdatePlayers34ActiveDone
          rem Player 4 is active
          let controllerStatus = controllerStatus | SetPlayers34Active
UpdatePlayers34ActiveDone
          rem Returns: Far (return otherbank)
          asm
UpdatePlayers34ActiveDone
end
          return otherbank

