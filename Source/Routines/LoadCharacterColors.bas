          rem ChaosFight - Source/Routines/LoadCharacterColors.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Character color loading function

LoadCharacterColors
          asm
; Load character color based on hurt state
; Input: temp2=hurt state (0-1), temp3=player number (0-3)
; Output: Sets COLUP0-3 based on hurt state (dimmed colors when hurt)
; TODO: Implement full TV standard support, flashing states, character-specific colors
end

          rem Determine color based on hurt state
          if temp2 = 0 then temp6 = PlayerColors12[temp3] : goto SetColorLabel
          temp6 = PlayerColors6[temp3]

SetColorLabel
          ; Set the appropriate color register
          if temp3 = 0 then COLUP0 = temp6 : return
          if temp3 = 1 then _COLUP1 = temp6 : return
          if temp3 = 2 then COLUP2 = temp6 : return
          COLUP3 = temp6
          return
