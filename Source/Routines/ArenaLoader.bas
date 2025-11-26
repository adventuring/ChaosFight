          rem
          rem ChaosFight - Source/Routines/ArenaLoader.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

LoadArena
          asm
LoadArena

end
          rem Arena Loader
          rem Loads arena playfield data and colors based on
          rem   selectedArena.
          rem Handles Color/B&W switch: switchbw=1 (B&W/white),
          rem   switchbw=0 (Color/row colors)
          rem SECAM always uses B&W mode regardless of switch.
          rem NOTE: Arena data tables are provided by the bank that
          rem includes this file (Bank1 includes Source/Data/Arenas.bas).
          rem
          rem Load arena playfield data and colors based on
          rem selectedArena
          rem
          rem Input: selectedArena_R (global SCRAM) = selected arena
          rem index (0-15 or RandomArena), switchbw (global) = B&W
          rem switch state, systemFlags (global) = system flags, frame
          rem (global) = frame counter (for random), RandomArena (global
          rem constant) = random arena constant
          rem
          rem Output: Arena playfield and colors loaded
          rem
          rem Mutates: temp1 (arena index), temp2 (B&W scratch), temp6
          rem (B&W flag), PF1pointer, PF2pointer (TIA registers) =
          rem playfield pointers, pfcolortable (TIA register) = color
          rem table pointer
          rem
          rem Called Routines: DWS_GetBWMode (bank15), LoadArenaRandom,
          rem LoadArenaByIndex (bank16)
          rem Constraints: None

          rem Handle random arena selection

          if selectedArena_R = RandomArena then LoadArenaRandom

          let temp1 = selectedArena_R
          rem Get arena index (0-15)

LoadArenaDispatch
          gosub DWS_GetBWMode bank15
          let temp6 = temp2
          gosub LoadArenaByIndex bank16
          if temp6 then goto LA_LoadBWColors
          rem Load color color table - fall through to LoadArenaColorsColor
          goto LA_LoadColorColors
LA_LoadBWColors
          rem Load B&W color table (shared routine)
          gosub LoadArenaColorsBW
          return thisbank
LA_LoadColorColors

LoadArenaColorsColor
          asm
LoadArenaColorsColor

end
          rem Load arena color table pointer using stride calculation
          asm
            lda #<Arena0Colors
            sta pfcolortable
            lda #>Arena0Colors
            sta pfcolortable+1

            ldx temp1
            beq .SetArenaColorPointerDone

.AdvanceArenaColorPointer
            clc
            lda pfcolortable
            adc #<(Arena1Colors - Arena0Colors)
            sta pfcolortable
            lda pfcolortable+1
            adc #>(Arena1Colors - Arena0Colors)
            sta pfcolortable+1
            dex
            bne .AdvanceArenaColorPointer

.SetArenaColorPointerDone
end
          return otherbank

LoadArenaColorsBW
          asm
LoadArenaColorsBW
end
          rem Shared B&W color table loader
          rem
          rem Input: None
          rem
          rem Output: pfcolortable pointer set to ArenaColorsBW
          rem
          rem Mutates: pfcolortable (playfield color table pointer)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with LoadArena
          asm
            lda #<ArenaColorsBW
            sta pfcolortable
            lda #>ArenaColorsBW
            sta pfcolortable+1
end
          return thisbank
LoadArenaRandom
          rem Select random arena (0-31) using proper random number
          rem generator
          rem
          rem Input: rand (global) = random number generator
          rem
          rem Output: Random arena loaded via LoadArenaByIndex
          rem
          rem Mutates: temp1 (temp1 set to random value), rand
          rem (global) = random number generator state
          rem
          rem Called Routines: LoadArenaByIndex (tail call) - loads
          rem selected random arena
          rem
          rem Constraints: None
          rem Select random arena (0-31) using proper RNG
          rem Get random value (0-255)
          let temp1 = rand
          let temp1 = temp1 & 31
          if temp1 > MaxArenaID then LoadArenaRandom
          rem Fall through to LoadArenaDispatch logic (inline to avoid goto)
          gosub DWS_GetBWMode bank15
          let temp6 = temp2
          gosub LoadArenaByIndex bank16
          if temp6 then goto LAR_LoadBWColors
          rem Load color color table (use gosub to avoid goto)
          gosub LoadArenaColorsColor bank16
          return thisbank
LAR_LoadBWColors
          rem Load B&W color table (shared routine)
          gosub LoadArenaColorsBW
          return thisbank