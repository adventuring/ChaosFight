          rem ChaosFight - Source/Routines/WinnerAnnouncement.bas
          rem Winner announcement mode main loop wrapper

WinnerAnnouncement
          rem Winner announcement mode main loop entry point
          rem Input: None (called from MainLoop)
          rem Output: Dispatches to WinnerAnnouncementLoop
          rem Mutates: None (dispatcher only)
          rem Called Routines: None (dispatcher only)
          rem Constraints: Must be colocated with WinnerAnnouncementLoop
          rem              Entry point for winner announcement mode
          goto WinnerAnnouncementLoop

WinnerAnnouncementLoop
          rem Winner announcement mode per-frame loop
          rem Input: joy0fire, joy1fire (hardware) = button states
          rem        switchselect (hardware) = select switch state
          rem        WinScreenTimer (global) = frame counter
          rem        WinScreenAutoAdvanceFrames (constant) = auto-advance threshold
          rem Output: Dispatches to WinnerAdvanceToCharacterSelect or returns
          rem Mutates: WinScreenTimer (incremented)
          rem Called Routines: DisplayWinScreen (bank12) - accesses winner screen state
          rem Constraints: Must be colocated with WinnerAnnouncement, WinnerAdvanceToCharacterSelect
          rem Check for button press to advance immediately
          if joy0fire then WinnerAdvanceToCharacterSelect
          if joy1fire then WinnerAdvanceToCharacterSelect
          if switchselect then WinnerAdvanceToCharacterSelect
          
          rem Auto-advance after 10 seconds (600 frames at 60fps)
          let WinScreenTimer = WinScreenTimer + 1
          if WinScreenTimer > WinScreenAutoAdvanceFrames then WinnerAdvanceToCharacterSelect
          
          rem Display win screen and continue loop
          gosub DisplayWinScreen bank12
          rem drawscreen called by MainLoop
          return
          goto WinnerAnnouncementLoop

WinnerAdvanceToCharacterSelect
          rem Transition to title screen (per issue #483 requirement)
          rem Input: None (called from WinnerAnnouncementLoop)
          rem Output: gameMode set to ModeTitle, ChangeGameMode called
          rem Mutates: gameMode (global)
          rem Called Routines: ChangeGameMode (bank14) - accesses game mode state
          rem Constraints: Must be colocated with WinnerAnnouncementLoop
          let gameMode = ModeTitle
          gosub ChangeGameMode bank14
          return


