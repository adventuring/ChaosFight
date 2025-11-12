SetGameScreenLayout
          rem Set screen layout for all screens (32×8) with health bar
          rem space
          rem
          rem Input: None
          rem
          rem Output: pfrowheight set to ScreenPfRowHeight, pfrows set to ScreenPfRows
          rem
          rem Mutates: pfrowheight (set to ScreenPfRowHeight), pfrows (set to ScreenPfRows)
          rem
          rem Called Routines: None
          rem Constraints: Called for all screen layouts
          pfrowheight = ScreenPfRowHeight
          pfrows = ScreenPfRows
          return
asm
SetGameScreenLayout = .SetGameScreenLayout
end
