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
          
          rem TODO: Add button press detection for return to title (#402)
          
          rem Return to MainLoop for next frame
          rem MainLoop will call drawscreen after this returns
          return


