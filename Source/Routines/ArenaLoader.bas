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
          rem Called Routines: DWS_GetBWMode (bank12) - determines B&W mode,
          rem LoadRandomArena (if random selected), LoadArenaByIndex -
          rem loads arena data
          rem Constraints: None
          
          rem Handle random arena selection
          
          if selectedArena_R = RandomArena then LoadRandomArena
          
          let temp1 = selectedArena_R
          rem Get arena index (0-15)
          
          gosub DWS_GetBWMode bank12

LoadArenaByIndex
          rem Load arena playfield and colors by index
          rem
          rem Input: temp1 (temp1) = arena index (0-31),
          rem temp2 (temp2) = B&W mode (1=B&W, 0=Color),
          rem ArenaPF1PointerL[], ArenaPF1PointerH[] (global data
          rem tables) = playfield pointers (PF2 mirrors PF1),
          rem ArenaColorPointerL[], ArenaColorPointerH[] (global data
          rem tables) = color pointers
          rem
          rem Output: Arena playfield and colors loaded
          rem
          rem Mutates: temp1 (temp1 validated), PF1pointer,
          rem PF2pointer (TIA registers) = playfield pointers,
          rem pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: LoadArenaColorsBW (if B&W mode),
          rem LoadArenaColorsColor (if Color mode)
          rem
          rem Constraints: Arena index validated to 0-31 range
          rem Validate arena index (0-31 supported by pointer tables)
          rem Note: Only 0-15 are selectable (MaxArenaID), but tables
          rem support 0-31
          if temp1 > 31 then temp1 = 0
          
          rem Load playfield pointers from tables using index (compute PF2 from PF1)
          asm
            ldx temp1
            lda ArenaPF1PointerL, x
            sta PF1pointer
            lda ArenaPF1PointerH, x
            sta PF1pointer+1
            ; PF2pointer = PF1pointer + 8, aligned so PF2 8-byte block does not cross a page
            lda PF1pointer
            clc
            adc #8
            sta PF2pointer
            ; Test if (PF1_low + 16) crosses page; if so, align PF2 to next page (low=0, high+1)
            clc
            adc #8
            bcc .NoAlignPF2
            lda #0
            sta PF2pointer
            lda PF1pointer+1
            clc
            adc #1
            sta PF2pointer+1
            jmp .PF2Done
.NoAlignPF2
            lda PF1pointer+1
            sta PF2pointer+1
.PF2Done
end
          
          rem Tail-call B&W color loader
          if temp2 then goto LoadArenaColorsBW
LoadArenaColorsColor
          rem Load arena color table pointer based on arena index
          asm
            ; pfcolortable = Arena0Colors + (temp1 << 3)
            ; Compute (temp1 << 3) into A (low) and X (high via ROLs)
            lda temp1
            ldx #0
            asl
            rol x
            asl
            rol x
            asl
            rol x
            ; Add low byte to base low
            clc
            adc #<Arena0Colors
            sta pfcolortable
            ; Add high nibble (X) and carry to base high
            txa
            adc #>Arena0Colors
            sta pfcolortable+1
end
          return

LoadArenaColorsBW
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
          goto LoadArenaByIndex

          
          

