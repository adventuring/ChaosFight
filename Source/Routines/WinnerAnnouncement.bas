          rem ChaosFight - Source/Routines/WinnerAnnouncement.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

WinnerAnnouncementLoop
          asm
WinnerAnnouncementLoop

end
          rem Winner announcement mode per-frame loop
          rem
          rem Input: joy0fire, joy1fire (hardware) = button states
          rem        switchselect (hardware) = select switch state
          rem Output: Dispatches to WinnerAdvanceToCharacterSelect or returns
          rem
          rem Called Routines: DisplayWinScreen (bank16) - accesses
          rem winner screen state
          rem
          rem Constraints: Must be colocated with WinnerAdvanceToCharacterSelect
          rem Check for button press to advance immediately
          if joy0fire then WinnerAdvanceToCharacterSelect
          if joy1fire then WinnerAdvanceToCharacterSelect
          if switchselect then WinnerAdvanceToCharacterSelect

          rem Display win screen and continue loop
          rem drawscreen called by MainLoop
          gosub DisplayWinScreen bank16
          return otherbank

WinnerAdvanceToCharacterSelect
          rem Transition to title screen (per issue #483 requirement)
          rem
          rem Input: None (called from WinnerAnnouncementLoop)
          rem
          rem Output: gameMode set to ModeTitle, ChangeGameMode called
          rem
          rem Mutates: gameMode (global)
          rem
          rem Called Routines: ChangeGameMode (bank14) - accesses game
          rem mode state
          rem Constraints: Must be colocated with WinnerAnnouncementLoop
          let gameMode = ModeTitle
          gosub ChangeGameMode bank14
          return otherbank

