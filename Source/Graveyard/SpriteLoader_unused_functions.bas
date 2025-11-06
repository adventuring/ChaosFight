LoadPlayer0Sprite
          rem ChaosFight -
          rem   Source/Graveyard/SpriteLoader_unused_functions.bas
          rem MOVED FROM: Source/Routines/SpriteLoader.bas
          rem
          rem DATE: 2025-01-XX
          rem REASON: Unused legacy functions, replaced by
          rem   LoadPlayerSprite dispatcher
          rem Load Player Sprites (legacy Player-specific Functions)
          rem Load sprite data into specific player registers
          rem These functions contain the actual player graphics
          rem   commands
          rem NOTE: Superseded by LoadPlayerSprite dispatcher with
          rem   LoadPlayerSpriteDispatch
          
          rem Use art location system for Participant 1 sprite loading
          rem   (array [0] → P0 sprite)
          rem temp1 = character index, temp2 = animation frame already
          let temp4 = 0 : rem   set
          rem Participant 1 (array [0]) → P0 sprite (player0x/player0y)
          
          rem TODO: Replace with actual assembly when LocateCharacterArt
          rem   and SetPlayer0CharacterArt are implemented
          rem For now, use placeholder sprite data
          return
          
LoadPlayer1Sprite
          rem Use art location system for Participant 2 sprite loading
          rem   (array [1] → P1 sprite)
          rem temp1 = character index, temp2 = animation frame already
          let temp4 = 1 : rem   set
          rem Participant 2 (array [1]) → P1 sprite (player1x/player1y,
          rem   virtual _P1)
          
          rem TODO: Replace with actual assembly when LocateCharacterArt
          rem   and SetPlayer1CharacterArt are implemented
          rem For now, use placeholder sprite data
          return
          
LoadPlayer2Sprite
          rem Use art location system for Participant 3 sprite loading
          rem   (array [2] → P2 sprite)
          rem temp1 = character index, temp2 = animation frame already
          let temp4 = 2 : rem   set
          rem Participant 3 (array [2]) → P2 sprite (player2x/player2y)
          
          rem TODO: Replace with actual assembly when LocateCharacterArt
          rem   and SetPlayer2CharacterArt are implemented
          rem For now, use placeholder sprite data
          return
          
LoadPlayer3Sprite
          rem Use art location system for Participant 4 sprite loading
          rem   (array [3] → P3 sprite)
          rem temp1 = character index, temp2 = animation frame already
          let temp4 = 3 : rem   set
          rem Participant 4 (array [3]) → P3 sprite (player3x/player3y)
          
          rem TODO: Replace with actual assembly when LocateCharacterArt
          rem   and SetPlayer3CharacterArt are implemented
          rem For now, use placeholder sprite data
          return

DrawPlayfieldHealthBar
          rem
          rem Healthbar System Unused Function
          rem MOVED FROM: Source/Routines/HealthBarSystem.bas
          rem DATE: 2025-01-XX
          rem REASON: P3/P4 health uses score digits, not playfield
          rem   pixels

          rem Displays a health bar using playfield pixels
          rem INPUT: temp1 = health (0-100), temp2 = player index (2-3)
          rem temp3 = Y row (23 for bottom), temp4 = starting X position
          rem NOTE: Replaced by UpdatePlayer34HealthBars which uses
          rem   score digits
          
          rem Calculate bar length (0-15 pixels)
          temp5 = temp1 * 15
          temp5 = temp5 / 100
          if temp5 > 15 then temp5 = 15
          
          if temp2 = 2 then COLUPF = ColYellow(12) : rem Set health bar color based on player
          if temp2 = 3 then COLUPF = ColGreen(12) : rem P3 Yellow
          rem P4 Green
          
          rem Clear the health bar area first
          temp6 = temp4 
          rem Starting X position
          for temp7 = 0 to 15 : rem Clear 15 pixels worth of health bar
          rem pfpixel temp6 temp3 off
          temp6 = temp6 + 1
          if temp6 > 31 then temp6 = 31 
          rem Clamp to playfield width
          next
          
          rem Draw the health bar
          temp6 = temp4 
          if temp2 = 2 then : rem Reset to starting X position
          for temp7 = 0 to temp5 : rem P3: left-to-right
          rem pfpixel temp6 temp3 on
          temp6 = temp6 + 1
          if temp6 > 31 then temp6 = 31
          next
          
          
          if temp2 = 3 then 
          for temp7 = 0 to temp5 : rem P4: right-to-left
          let temp7 = temp6 : rem pfpixel temp6 temp3 on
          temp6 = temp6 - 1
          if temp6 > temp7 then temp6 = 0
          next
          
          
          return

