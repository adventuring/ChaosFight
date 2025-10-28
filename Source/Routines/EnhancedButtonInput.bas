git          rem ChaosFight - Source/Routines/EnhancedButtonInput.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem Enhanced button reading for Genesis Button C and Joy2B+ Buttons II/III
          rem Uses INPT0-3 (paddle ports) to read additional buttons
          
          rem =================================================================
          rem READ ENHANCED BUTTONS
          rem =================================================================
          rem Reads Genesis Button C or Joy2B+ Buttons II/III from paddle ports
          rem Only active if Genesis or Joy2B+ detected
          rem
          rem Button states stored in temp variables:
          rem   temp5 = ButtonC_P1 (Genesis/Joy2B+ Button C/II for Player 1)
          rem   temp4 = ButtonC_P2 (Genesis/Joy2B+ Button C/II for Player 2)
          rem   temp3 = ButtonIII_P1 (Joy2B+ Button III for Player 1)
          rem   temp2 = ButtonIII_P2 (Joy2B+ Button III for Player 2)
          
ReadEnhancedButtons
          rem Clear button states (using temp variables)
          temp5 = 0  : rem ButtonC_P1
          temp4 = 0  : rem ButtonC_P2
          temp3 = 0  : rem ButtonIII_P1
          temp2 = 0  : rem ButtonIII_P2
          
          rem Only read if enhanced controller detected
          if !GenesisDetected && !Joy2bPlusDetected then return
          
          rem Read Button C/II (jump) for Player 1 (INPT0)
          temp1 = INPT0
          if !(temp1 & $80) then temp5 = 1  : rem ButtonC_P1 (button pressed when 0)
          
          rem Read Button C/II (jump) for Player 2 (INPT2)
          temp1 = INPT2
          if !(temp1 & $80) then temp4 = 1  : rem ButtonC_P2
          
          rem Read Button III (pause) only for Joy2B+
          if Joy2bPlusDetected then
                    rem Read Button III for Player 1 (INPT1)
                    temp1 = INPT1
                    if !(temp1 & $80) then temp3 = 1  : rem ButtonIII_P1
                    
                    rem Read Button III for Player 2 (INPT3)
                    temp1 = INPT3
                    if !(temp1 & $80) then temp2 = 1  : rem ButtonIII_P2
          endif
          
          return

          rem =================================================================
          rem CHECK ENHANCED JUMP BUTTONS
          rem =================================================================
          rem Returns 1 in temp1 if jump button pressed (UP or Button C/II)
          rem Player number in temp2 (0=P1, 1=P2)
          
CheckEnhancedJump
          rem Check traditional UP button first (temp2 = player index)
          if temp2 = 0 then
                    if joy0up then temp1 = 1 : return
                    rem Check Button C/II if enhanced controller (stored in temp5)
                    if temp5 then temp1 = 1 : return
          else
                    if joy1up then temp1 = 1 : return
                    rem Check Button C/II if enhanced controller (stored in temp4)
                    if temp4 then temp1 = 1 : return
          endif
          
          temp1 = 0
          return

          rem =================================================================
          rem CHECK ENHANCED PAUSE BUTTONS
          rem =================================================================
          rem Returns 1 in temp1 if pause button pressed (SELECT or Button III)
          rem Player number in temp2 (0=P1, 1=P2)
          
CheckEnhancedPause
          rem Check console SELECT switch first
          if switchselect then temp1 = 1 : return
          
          rem Check Button III if Joy2B+ (temp2 = player index)
          if !Joy2bPlusDetected then temp1 = 0 : return
          
          if temp2 = 0 then
                    if temp3 then temp1 = 1 : return  : rem ButtonIII_P1
          else
                    if temp2 then temp1 = 1 : return  : rem ButtonIII_P2  
          endif
          
          temp1 = 0
          return


