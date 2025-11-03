          rem ChaosFight - Source/Routines/WinnerAnnouncement.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem WINNER ANNOUNCEMENT LOOP - Called from MainLoop each frame
          rem =================================================================
          rem This is the main loop that runs each frame during Winner Announcement mode.
          rem Called repeatedly from MainLoop dispatcher.
          rem Setup is handled by BeginWinnerAnnouncement (called from ChangeGameMode).

WinnerAnnouncement
          rem Display winner screen
          gosub bank7 DisplayWinScreen
          
          rem Check for button press to return to title screen
          rem Check standard controllers (Player 1 & 2)
          if joy0fire then goto WinnerReturnToTitle
          if joy1fire then goto WinnerReturnToTitle
          
          rem Check Quadtari controllers (Players 3 & 4 if active)
          if ControllerStatus & SetQuadtariDetected then goto WinnerCheckQuadtari
          goto WinnerSkipQuadtari
WinnerCheckQuadtari
          if !INPT0{7} then goto WinnerReturnToTitle
          if !INPT2{7} then goto WinnerReturnToTitle
WinnerSkipQuadtari
          
          rem Return to MainLoop for next frame
          rem MainLoop will call drawscreen after this returns
          return

WinnerReturnToTitle
          rem Transition to title screen
          GameMode = ModeTitle : gosub bank13 ChangeGameMode
          return


