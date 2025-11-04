          rem ChaosFight - Source/Routines/WinnerAnnouncement.bas
          rem Winner announcement mode main loop wrapper

WinnerAnnouncement
WinnerAnnouncementLoop
          rem Check for button press to advance immediately
          if joy0fire then WinnerAdvanceToCharacterSelect
          if joy1fire then WinnerAdvanceToCharacterSelect
          if switchselect then WinnerAdvanceToCharacterSelect
          
          rem Auto-advance after 10 seconds (600 frames at 60fps)
          let WinScreenTimer = WinScreenTimer + 1
          if WinScreenTimer > WinScreenAutoAdvanceFrames then WinnerAdvanceToCharacterSelect
          
          rem Display win screen and continue loop
          rem gosub bank7 DisplayWinScreen
          rem TODO: Implement DisplayWinScreen function when ready
          drawscreen
          goto WinnerAnnouncementLoop

WinnerAdvanceToCharacterSelect
          rem Transition to title screen (per issue #483 requirement)
          let gameMode = ModeTitle
          gosub bank13 ChangeGameMode
          return


