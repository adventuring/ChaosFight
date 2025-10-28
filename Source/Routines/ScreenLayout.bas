          rem ChaosFight - Source/Routines/ScreenLayout.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Dynamic screen layout switching for admin vs game screens

          rem =================================================================
          rem SCREEN LAYOUT SWITCHING SYSTEM
          rem =================================================================
          rem Admin screens (title, character select): 32×32 virtual pixels (8 rows)
          rem Game screen: 32×8 virtual pixels (8 rows) with space for health bars

SetAdminScreenLayout
          rem Set screen layout for title screen and character select (32×32)
          pfrowheight = 8
          pfrows = 32
          return

SetGameScreenLayout
          rem Set screen layout for gameplay (32×8) with health bar space
          pfrowheight = 16
          pfrows = 8
          return

GetScreenLayoutInfo
          rem Get current screen layout dimensions
          rem Output: temp1 = virtual width (32), temp2 = virtual height
          temp1 = 32              
          rem Always 32 virtual pixels wide
          temp2 = pfrows * 4      
          rem Height = rows × 4 pixels per row
          return
