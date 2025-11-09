SetAdminScreenLayout
SetGameScreenLayout
          rem Set screen layout for all screens (32×8) with health bar
          rem space
          rem
          rem Input: None
          rem
          rem Output: pfrowheight set to 16, pfrows set to 8
          rem
          rem Mutates: pfrowheight (set to 16), pfrows (set to 8)
          rem
          rem Called Routines: None
          rem Constraints: Called from BeginGameLoop for gameplay screen
          const pfrowheight = 16
          const pfrows = 8
          return
