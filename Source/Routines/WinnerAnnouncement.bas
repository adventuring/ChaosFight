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
          goto WinnerAnnouncementLoop : rem              Entry point for winner announcement mode

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
          rem Called Routines: DisplayWinScreen (bank12) - accesses
          rem winner screen state
          rem
          rem Constraints: Must be colocated with WinnerAnnouncement,
          rem WinnerAdvanceToCharacterSelect
          if joy0fire then WinnerAdvanceToCharacterSelect : rem Check for button press to advance immediately
          if joy1fire then WinnerAdvanceToCharacterSelect
          if switchselect then WinnerAdvanceToCharacterSelect
          
          let winScreenTimer_W = winScreenTimer_R + 1 : rem Auto-advance after 10 seconds (600 frames at 60fps)
          if winScreenTimer_R > WinScreenAutoAdvanceFrames then WinnerAdvanceToCharacterSelect
          
          gosub DisplayWinScreen bank12 : rem Display win screen and continue loop
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
          let gameMode = ModeTitle : rem Constraints: Must be colocated with WinnerAnnouncementLoop
          gosub ChangeGameMode bank14
          return


