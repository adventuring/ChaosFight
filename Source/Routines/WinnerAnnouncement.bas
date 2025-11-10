          rem ChaosFight - Source/Routines/WinnerAnnouncement.bas
          rem Winner announcement mode main loop wrapper

WinnerAnnouncement
          rem Winner announcement mode main loop entry point
          rem
          rem Input: None (called from MainLoop)
          rem
          rem Output: Dispatches to WinnerAnnouncementLoop
          rem
          rem Mutates: None
          rem
          rem Called Routines: WinnerAnnouncementLoop (bank9) - renders winner screen
          rem Constraints: Must be colocated with WinnerAnnouncementLoop (called via goto)
          rem Entry point for winner announcement mode
          goto WinnerAnnouncementLoop

WinnerAnnouncementLoop
          rem Winner announcement mode per-frame loop
          rem
          rem Input: joy0fire, joy1fire (hardware) = button states
          rem        switchselect (hardware) = select switch state
          rem        WinScreenTimer (global) = frame counter
          rem        WinScreenAutoAdvanceFrames (constant) =
          rem        auto-advance threshold
          rem
          rem Output: Dispatches to WinnerAdvanceToCharacterSelect or
          rem returns
          rem
          rem Mutates: WinScreenTimer (incremented)
          rem
          rem Called Routines: DisplayWinScreen (bank15) - accesses
          rem winner screen state
          rem
          rem Constraints: Must be colocated with WinnerAnnouncement,
          rem WinnerAdvanceToCharacterSelect
          rem Check for button press to advance immediately
          if joy0fire then WinnerAdvanceToCharacterSelect
          if joy1fire then WinnerAdvanceToCharacterSelect
          if switchselect then WinnerAdvanceToCharacterSelect
          
          rem Auto-advance after 10 seconds (600 frames at 60fps)
          let winScreenTimer_W = winScreenTimer_R + 1
          if winScreenTimer_R > WinScreenAutoAdvanceFrames then WinnerAdvanceToCharacterSelect
          
          rem Display win screen and continue loop
          gosub DisplayWinScreen bank15
          rem drawscreen called by MainLoop
          return
          goto WinnerAnnouncementLoop

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
          return


