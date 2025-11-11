          rem ChaosFight - Source/Routines/LoadArenaByIndex.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Arena loading function

LoadArenaByIndex
          rem Load arena data by index into playfield RAM
          rem Input: temp1 = arena index (0-31)
          rem Output: Playfield RAM loaded with arena data
          rem Mutates: PF1pointer, PF2pointer, temp variables
          rem Constraints: PF0pointer remains glued to the status bar layout

          rem Look up playfield loader entry points via pointer tables
          asm
            ldx temp1
            lda ArenaPF1PointerL,x
            sta PF1pointer
            lda ArenaPF1PointerH,x
            sta PF1pointer+1

            lda ArenaPF2PointerL,x
            sta PF2pointer
            lda ArenaPF2PointerH,x
            sta PF2pointer+1
end
          return
