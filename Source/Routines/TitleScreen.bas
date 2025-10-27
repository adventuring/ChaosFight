rem ChaosFight - Source/Routines/TitleScreen.bas
rem Copyright © 2025 Interworldly Adventuring, LLC.

rem =================================================================
rem TITLE SCREEN WITH CHARACTER PARADE
rem =================================================================

TitleScreen
          rem Initialize title screen
          COLUBK = ColBlue(8)
          
          rem Initialize character parade
          TitleParadeTimer = 0
          TitleParadeChar = 0
          TitleParadeX = 0
          TitleParadeActive = 0
          
          rem Title screen loop
TitleScreenLoop
          rem Handle input - any button press goes to character select
          if joy0fire || joy1fire || joy2fire || joy3fire then goto TitleScreenComplete
          
          rem Update character parade
          gosub UpdateCharacterParade
          
          rem Draw title screen
          gosub DrawTitleScreen
          
          drawscreen
          goto TitleScreenLoop

TitleScreenComplete
          return

rem =================================================================
rem CHARACTER PARADE SYSTEM
rem =================================================================

UpdateCharacterParade
          rem Increment parade timer
          TitleParadeTimer = TitleParadeTimer + 1
          
          rem Start parade after 10 seconds (600 frames at 60fps)
          if TitleParadeTimer < 600 then return
          
          rem Check if we need to start a new character
          if !TitleParadeActive then
                    rem Start new character parade
                    TitleParadeChar = rand & 15  : rem Random character 0-15
                    TitleParadeX = -10  : rem Start off-screen left
                    TitleParadeActive = 1
          else
                    rem Move character across screen
                    TitleParadeX = TitleParadeX + 2  : rem Move 2 pixels per frame
                    
                    rem Check if character has left screen
                    if TitleParadeX > 170 then
                              rem Character has left - wait 1 second (60 frames) before next
                              TitleParadeActive = 0
                              TitleParadeTimer = TitleParadeTimer - 60  : rem Reset timer for next character
                    endif
          endif
          
          return

DrawTitleScreen
          rem Clear playfield
          pf0 = 0 : pf1 = 0 : pf2 = 0
          pf3 = 0 : pf4 = 0 : pf5 = 0
          
          rem Draw title text using playfield
          gosub DrawTitleText
          
          rem Draw character parade if active
          if TitleParadeActive then
                    gosub DrawParadeCharacter
          endif
          
          return

DrawTitleText
          rem Draw "CHAOS FIGHT" title using playfield pixels
          rem This is a simplified text representation
          
          rem C
          pf0 = pf0 | %11100000
          pf1 = pf1 | %10000000
          pf2 = pf2 | %10000000
          pf3 = pf3 | %10000000
          pf4 = pf4 | %10000000
          pf5 = pf5 | %11100000
          
          rem H
          pf0 = pf0 | %00011100
          pf1 = pf1 | %00010000
          pf2 = pf2 | %00010000
          pf3 = pf3 | %00011100
          pf4 = pf4 | %00010000
          pf5 = pf5 | %00010000
          
          rem A
          pf0 = pf0 | %00000011
          pf1 = pf1 | %00000010
          pf2 = pf2 | %00000010
          pf3 = pf3 | %00000011
          pf4 = pf4 | %00000010
          pf5 = pf5 | %00000010
          
          rem O
          pf0 = pf0 | %00000000
          pf1 = pf1 | %00000000
          pf2 = pf2 | %00000000
          pf3 = pf3 | %00000000
          pf4 = pf4 | %00000000
          pf5 = pf5 | %00000000
          
          rem S
          pf0 = pf0 | %00000000
          pf1 = pf1 | %00000000
          pf2 = pf2 | %00000000
          pf3 = pf3 | %00000000
          pf4 = pf4 | %00000000
          pf5 = pf5 | %00000000
          
          rem Space
          pf0 = pf0 | %00000000
          pf1 = pf1 | %00000000
          pf2 = pf2 | %00000000
          pf3 = pf3 | %00000000
          pf4 = pf4 | %00000000
          pf5 = pf5 | %00000000
          
          rem F
          pf0 = pf0 | %00000000
          pf1 = pf1 | %00000000
          pf2 = pf2 | %00000000
          pf3 = pf3 | %00000000
          pf4 = pf4 | %00000000
          pf5 = pf5 | %00000000
          
          rem I
          pf0 = pf0 | %00000000
          pf1 = pf1 | %00000000
          pf2 = pf2 | %00000000
          pf3 = pf3 | %00000000
          pf4 = pf4 | %00000000
          pf5 = pf5 | %00000000
          
          rem G
          pf0 = pf0 | %00000000
          pf1 = pf1 | %00000000
          pf2 = pf2 | %00000000
          pf3 = pf3 | %00000000
          pf4 = pf4 | %00000000
          pf5 = pf5 | %00000000
          
          rem H
          pf0 = pf0 | %00000000
          pf1 = pf1 | %00000000
          pf2 = pf2 | %00000000
          pf3 = pf3 | %00000000
          pf4 = pf4 | %00000000
          pf5 = pf5 | %00000000
          
          rem T
          pf0 = pf0 | %00000000
          pf1 = pf1 | %00000000
          pf2 = pf2 | %00000000
          pf3 = pf3 | %00000000
          pf4 = pf4 | %00000000
          pf5 = pf5 | %00000000
          
          return

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

SetParadeCharacterColor
          rem Set color based on character type for variety
          on TitleParadeChar goto SetChar0, SetChar1, SetChar2, SetChar3, SetChar4, SetChar5, SetChar6, SetChar7, SetChar8, SetChar9, SetChar10, SetChar11, SetChar12, SetChar13, SetChar14, SetChar15
          
          SetChar0:  COLUP0 = ColIndigo(12) : return   : rem Bernie
          SetChar1:  COLUP0 = ColRed(12) : return      : rem Curling Sweeper
          SetChar2:  COLUP0 = ColYellow(12) : return   : rem Dragonet
          SetChar3:  COLUP0 = ColGreen(12) : return    : rem EXO Pilot
          SetChar4:  COLUP0 = ColOrange(12) : return   : rem Fat Tony
          SetChar5:  COLUP0 = ColPurple(12) : return   : rem Grizzard Handler
          SetChar6:  COLUP0 = ColPink(12) : return     : rem Harpy
          SetChar7:  COLUP0 = ColCyan(12) : return     : rem Knight Guy
          SetChar8:  COLUP0 = ColMagenta(12) : return  : rem Magical Faerie
          SetChar9:  COLUP0 = ColLime(12) : return     : rem Mystery Man
          SetChar10: COLUP0 = ColNavy(12) : return     : rem Ninjish Guy
          SetChar11: COLUP0 = ColTeal(12) : return     : rem Pork Chop
          SetChar12: COLUP0 = ColMaroon(12) : return   : rem Radish Goblin
          SetChar13: COLUP0 = ColOlive(12) : return    : rem Robo Tito
          SetChar14: COLUP0 = ColSilver(12) : return   : rem Ursulo
          SetChar15: COLUP0 = ColGold(12) : return     : rem Veg Dog

DrawParadeCharacterSprite
          rem Draw running animation sprite for parade character
          rem Simple running animation with alternating leg positions
          if (TitleParadeTimer & 8) then
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
          else
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
          endif
          return
