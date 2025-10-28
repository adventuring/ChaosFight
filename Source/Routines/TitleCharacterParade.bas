          rem ChaosFight - Source/Routines/TitleCharacterParade.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem TITLE SCREEN CHARACTER PARADE
          rem =================================================================
          rem Manages the animated character parade that runs across the
          rem bottom of the title screen after 10 seconds.

          rem AVAILABLE VARIABLES (from Variables.bas):
          rem   TitleParadeTimer - Frame counter (increments each frame)
          rem   TitleParadeChar - Current character index (0-15)
          rem   TitleParadeX - X position of parade character
          rem   TitleParadeActive - Boolean: parade currently running

          rem TIMING:
          rem   - Parade starts after 10 seconds (600 frames at 60fps)
          rem   - Each character moves at 2 pixels/frame (left to right)
          rem   - 1 second pause (60 frames) between characters
          rem   - Characters chosen randomly from 16 available

          rem CHARACTER INDICES:
          rem   0=Bernie, 1=Curling, 2=Dragonet, 3=EXO, 4=FatTony, 5=Grizzard,
          rem   6=Harpy, 7=Knight, 8=Magical Faerie, 9=Mystery, 10=Ninjish,
          rem   11=Pork Chop, 12=Radish, 13=Robo Tito, 14=Ursulo, 15=Veg Dog
          rem =================================================================

          rem Update parade state (called every frame)
UpdateCharacterParade
          rem Increment parade timer
          TitleParadeTimer = TitleParadeTimer + 1
          
          rem Start parade after 10 seconds (600 frames at 60fps)
          if TitleParadeTimer < 600 then return
          
          rem Check if we need to start a new character
          if !TitleParadeActive then
                    rem Start new character parade
          TitleParadeChar = rand & 15 
          rem Random character 0-15
          TitleParadeX = 246
          rem Start off-screen left
                    TitleParadeActive = 1

                    rem Move character across screen
          TitleParadeX = TitleParadeX + 2 
          rem Move 2 pixels per frame
                    
                    rem Check if character has left screen
                    if TitleParadeX > 170 then
                              rem Character has left - wait 1 second (60 frames) before next
                              TitleParadeActive = 0
          TitleParadeTimer = TitleParadeTimer - 60 
          rem Reset timer for next character
end
end
          
          return

          rem =================================================================
          rem DRAW PARADE CHARACTER
          rem =================================================================
          rem Renders the current parade character at bottom of screen
          rem INPUT VARIABLES:
          rem   TitleParadeChar - Character index (0-15)
          rem   TitleParadeX - X position on screen
          rem USES:
          rem   player0x, player0y - Sprite position
          rem   COLUP0 - Sprite color
DrawParadeCharacter
          rem Draw the current parade character at the bottom of the screen
          rem Position character at bottom (y=80) and current X position
          player0x = TitleParadeX
          player0y = 80
          
          rem Set character color based on character type
          gosub SetParadeCharacterColor
          
          rem Draw running animation for parade character
          gosub DrawParadeCharacterSprite
          
          return

          rem =================================================================
          rem SET PARADE CHARACTER COLOR
          rem =================================================================
          rem Sets player0 color based on character type for visual variety
          rem INPUT: TitleParadeChar (0-15)
          rem USES: COLUP0
SetParadeCharacterColor
          rem Set color based on character type for variety
          on TitleParadeChar goto SetChar0, SetChar1, SetChar2, SetChar3, SetChar4, SetChar5, SetChar6, SetChar7, SetChar8, SetChar9, SetChar10, SetChar11, SetChar12, SetChar13, SetChar14, SetChar15
          
SetChar0
          COLUP0 = ColIndigo(12) : return  
          rem Bernie
SetChar1
          COLUP0 = ColRed(12) : return     
          rem Curling Sweeper
SetChar2
          COLUP0 = ColYellow(12) : return  
          rem Dragonet
SetChar3
          COLUP0 = ColGreen(12) : return   
          rem EXO Pilot
SetChar4
          COLUP0 = ColOrange(12) : return  
          rem Fat Tony
SetChar5
          COLUP0 = ColPurple(12) : return  
          rem Megax
SetChar6
          COLUP0 = ColPink(12) : return    
          rem Harpy
SetChar7
          COLUP0 = ColCyan(12) : return    
          rem Knight Guy
SetChar8
          COLUP0 = ColMagenta(12) : return 
          rem Magical Faerie
SetChar9
          COLUP0 = ColLime(12) : return    
          rem Mystery Man
SetChar10
          COLUP0 = ColNavy(12) : return    
          rem Ninjish Guy
SetChar11
          COLUP0 = ColTeal(12) : return    
          rem Pork Chop
SetChar12
          COLUP0 = ColMaroon(12) : return  
          rem Radish Goblin
SetChar13
          COLUP0 = ColOlive(12) : return   
          rem Robo Tito
SetChar14
          COLUP0 = ColSilver(12) : return  
          rem Ursulo
SetChar15
          COLUP0 = ColGold(12) : return    
          rem Veg Dog

          rem =================================================================
          rem DRAW PARADE CHARACTER SPRITE
          rem =================================================================
          rem Renders running animation sprite with alternating leg positions
          rem INPUT: TitleParadeTimer (for animation frame selection)
          rem USES: player0 sprite data
DrawParadeCharacterSprite
          rem Draw running animation sprite for parade character
          rem Simple running animation with alternating leg positions
          if (TitleParadeTimer & 8) then goto DrawParadeFrame1
          rem Frame 2 - right leg forward
                    player0:
                    %00011000
                    %00111100
                    %01111110
                    %00011000
                    %00011000
                    %00011000
                    %00011000
                    %00011000
                    end
          return
DrawParadeFrame1
          rem Frame 1 - left leg forward
                    player0:
                    %00011000
                    %00111100
                    %01111110
                    %00011000
                    %00011000
                    %00011000
                    %00011000
                    %00011000
                    end
          return

