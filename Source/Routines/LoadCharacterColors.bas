          rem ChaosFight - Source/Routines/LoadCharacterColors.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Character color loading function

LoadCharacterColors
          asm
; Load character color based on TV standard and hurt state
; Input: temp1=char, temp2=hurt, temp3=player
; Output: Sets COLUP0-3 based on TV standard (char colors on NTSC/PAL, player colors on SECAM)
; WARNING: temp6 is mutated during execution. Do not use temp6 after calling this subroutine.
end

          ; Determine color based on hurt state
          if temp2 = 0 then let temp6 = PlayerColors12[temp3] : goto SetColorLabel

          ; Hurt state: magenta (SECAM) or dimmed player colors (NTSC/PAL)
#ifdef TV_SECAM
          let temp6 = ColMagenta(14)
#else
          let temp6 = PlayerColors6[temp3]
#endif

SetColorLabel
          ; Set the appropriate color register
          if temp3 = 0 then COLUP0 = temp6 : return
          if temp3 = 1 then _COLUP1 = temp6 : return
          if temp3 = 2 then COLUP2 = temp6 : return
          COLUP3 = temp6
          return
