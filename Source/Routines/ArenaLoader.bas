          rem
          rem ChaosFight - Source/Routines/ArenaLoader.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
LoadArena
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
          rem Mutates: temp1 (used for arena index), temp2 (used for B&W
          rem mode), PF1pointer, PF2pointer (TIA registers) = playfield
          rem pointers, pfcolortable (TIA register) = color table
          rem pointer
          rem
          rem Called Routines: DWS_GetBWMode (bank15) - determines B&W mode,
          rem LoadRandomArena (if random selected), LoadArenaByIndex -
          rem loads arena data
          rem Constraints: None
          
          rem Handle random arena selection
          
          if selectedArena_R = RandomArena then LoadRandomArena
          
          let temp1 = selectedArena_R
          rem Get arena index (0-15)
          
          gosub DWS_GetBWMode bank15

LoadArenaColorsColor
          rem Load arena color table pointer from contiguous ArenaColors table
          rem Since colors are now contiguous: ArenaColors + (arena_index * 8)
          asm
            ; Compute color_offset = temp1 << 3 (temp1 * 8)
            lda temp1
            asl
            asl
            asl
            sta temp4
            ; Add to ArenaColors base address
            lda #<ArenaColors
            clc
            adc temp4
            sta pfcolortable
            lda #>ArenaColors
            adc #0
            sta pfcolortable+1
end
          return

LoadArenaColorsBWLabel
          asm
          ;; Load B&W color table - all arenas use same white colors
          ;; Set pfcolortable pointer to ArenaColorsBW
            lda #<ArenaColorsBW
            sta pfcolortable
            lda #>ArenaColorsBW
            sta pfcolortable+1
end
          return

LoadRandomArena
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
          if temp1 > MaxArenaID then LoadRandomArena
          gosub LoadArenaByIndex


          

