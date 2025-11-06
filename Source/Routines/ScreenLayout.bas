SetAdminScreenLayout
          rem
          rem ChaosFight - Source/Routines/ScreenLayout.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Dynamic screen layout switching for admin vs game screens
          rem Screen Layout Switching System
          rem Admin screens (title, character select): 32×32 virtual
          rem   pixels (8 rows)
          rem Game screen: 32×8 virtual pixels (8 rows) with space for
          rem   health bars
          rem Set screen layout for title screen and character select (32×32)
          rem Input: None
          rem Output: pfrowheight set to 8, pfrows set to 32
          rem Mutates: pfrowheight (set to 8), pfrows (set to 32)
          rem Called Routines: None
          let pfrowheight = 8 : rem Constraints: Called from setup routines for admin screens
          let pfrows = 32
          return

SetGameScreenLayout
          rem Set screen layout for gameplay (32×8) with health bar space
          rem Input: None
          rem Output: pfrowheight set to 16, pfrows set to 8
          rem Mutates: pfrowheight (set to 16), pfrows (set to 8)
          rem Called Routines: None
          let pfrowheight = 16 : rem Constraints: Called from BeginGameLoop for gameplay screen
          let pfrows = 8
          return

GetScreenLayoutInfo
          rem Get current screen layout dimensions
          rem Input: pfrows (global) = number of playfield rows
          rem Output: temp1 = virtual width (32), temp2 = virtual height
          rem Mutates: temp1 (set to 32), temp2 (calculated from pfrows)
          rem Called Routines: None
          rem Constraints: None
          temp1 = 32              
          rem Always 32 virtual pixels wide
          temp2 = pfrows * 4      
          rem Height = rows × 4 pixels per row
          return
