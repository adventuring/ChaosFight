          rem ChaosFight - Source/Routines/LevelSelect1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

LevelSelect1
          dim SelectedLevel = a
          SelectedLevel = 0
          
          COLUBK = ColBlue(8)
          
LevelSelect1Loop
          if joy0left then SelectedLevel = SelectedLevel - 1 : if SelectedLevel < 0 then SelectedLevel = NumLevels
          if joy0right then SelectedLevel = SelectedLevel + 1 : if SelectedLevel > NumLevels then SelectedLevel = 0
          
          if SelectedLevel = 0 then
                    player0x = 80 : player0y = 80
                    player1x = 90 : player1y = 80
                    player0:
                    %00011000
                    %00011000
                    %00000000
                    %00011000
                    %00011000
                    %00000000
                    %00011000
                    %00011000
                    end
                    player1:
                    %00011000
                    %00011000
                    %00000000
                    %00011000
                    %00011000
                    %00000000
                    %00011000
                    %00011000
                    end
          else
                    player0x = 80 : player0y = 80
                    player1x = 90 : player1y = 80
                    player0:
                    %00111100
                    %01100110
                    %01100110
                    %01100110
                    %01100110
                    %01100110
                    %00111100
                    %00000000
                    end
                    player1:
                    %00111100
                    %01100110
                    %01100110
                    %01100110
                    %01100110
                    %01100110
                    %00111100
                    %00000000
                    end
          
          if joy0fire then goto StartGame1
          
          drawscreen
          goto LevelSelect1Loop

StartGame1
          return