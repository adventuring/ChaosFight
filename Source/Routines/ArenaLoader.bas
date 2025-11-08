          rem
          rem ChaosFight - Source/Routines/ArenaLoader.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem Arena Loader
          rem Loads arena playfield data and colors based on
          rem   selectedArena.
          rem Handles Color/B&W switch: switchbw=1 (B&W/white),
          rem   switchbw=0 (Color/row colors)
          rem SECAM always uses B&W mode regardless of switch.
          rem NOTE: Arena data tables are provided by the bank that
          rem includes this file (Bank1 includes Source/Data/Arenas.bas).

LoadArena
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
          rem Called Routines: GetBWMode - determines B&W mode,
          rem LoadRandomArena (if random selected), LoadArenaByIndex -
          rem loads arena data
          rem Constraints: None
          
          if selectedArena_R = RandomArena then LoadRandomArena : rem Handle random arena selection
          
          let temp1 = selectedArena_R : rem Get arena index (0-15)
          
          gosub GetBWMode : rem Load playfield and colors
          goto LoadArenaByIndex

GetBWMode
          rem Check if B&W mode is active
          rem SECAM: Always B&W mode
          rem
          rem Input: switchbw (global) = B&W switch state, systemFlags
          rem (global) = system flags (bit 6 =
          rem SystemFlagColorBWOverride)
          rem
          rem Output: temp2 (temp2) = B&W mode (1=B&W, 0=Color)
          rem
          rem Mutates: temp2 (temp2 return value)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Applies to all TV standards
          rem Check switchbw and colorBWOverride
          rem switchbw = 1 means B&W mode (white), switchbw = 0 means
          rem   Color mode
          rem systemFlags bit 6 (SystemFlagColorBWOverride) = 1 means
          rem B&W override
          let temp2 = switchbw : rem   (from 7800 pause button)
          if systemFlags & SystemFlagColorBWOverride then let temp2 = 1
          return

LoadArenaByIndex
          rem Load arena playfield and colors by index
          rem
          rem Input: temp1 (temp1) = arena index (0-31),
          rem temp2 (temp2) = B&W mode (1=B&W, 0=Color),
          rem ArenaPF1PointerL[], ArenaPF1PointerH[],
          rem ArenaPF2PointerL[], ArenaPF2PointerH[] (global data
          rem tables) = playfield pointers, ArenaColorPointerL[],
          rem ArenaColorPointerH[] (global data tables) = color
          rem pointers
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
          if temp1 > 31 then let temp1 = 0
          
          rem Load playfield pointers from tables using index
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
          
          if temp2 then goto LoadArenaColorsBW : rem Tail-call B&W color loader
          goto LoadArenaColorsColor
LoadArenaColorsColor
          rem Load arena color table pointer based on arena index
          rem
          rem Input: temp1 (temp1) = arena index (0-31),
          rem ArenaColorPointerL[], ArenaColorPointerH[] (global data
          rem tables) = color pointers
          rem
          rem Output: pfcolortable set to ArenaNColors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: temp1 must already be in 0-31 range
          asm
            ldx temp1
            lda ArenaColorPointerL,x
            sta pfcolortable
            lda ArenaColorPointerH,x
            sta pfcolortable+1
end
          return

LoadArenaColorsBW
          asm
          ;; Load B&W color table (all arenas use same white colors)
          ;;
          ;; Input: ArenaColorsBW (global data table) = B&W color table
          ;;
          ;; Output: pfcolortable set to ArenaColorsBW
          ;;
          ;; Mutates: pfcolortable (TIA register) = color table pointer
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: None
          ;; All arenas use the same B&W colors (all white)
          ;; Set pfcolortable pointer to ArenaColorsBW
            lda #<ArenaColorsBW
            sta pfcolortable
            lda #>ArenaColorsBW
            sta pfcolortable+1
end
          return

LoadRandomArena
          rem Select random arena (0-15) using proper random number
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
          rem Select random arena (0-15) using proper RNG
          let temp1 = rand : rem Get random value (0-255)
          let temp1 = temp1 & 15 : rem Mask to 0-15 range
          goto LoadArenaByIndex

          rem
          rem Reload Arena Colors
          rem Reloads only the arena colors (not playfield) based on
          rem   current
          rem Color/B&W switch state. Called when switch changes during
          rem   gameplay.

ReloadArenaColors
          rem Reload arena colors based on current Color/B&W switch
          rem state
          rem Uses same logic as LoadArenaColors (consolidated to avoid duplication)
          
          let temp1 = selectedArena_R : rem Get current arena index
          if temp1 = RandomArena then let temp1 = rand & 31 : rem Handle random arena (use stored random selection)
          
          rem Get B&W mode state (same logic as GetBWMode)
          let temp2 = switchbw : rem Check switchbw and colorBWOverride
          if systemFlags & SystemFlagColorBWOverride then let temp2 = 1
          
ReloadArenaColorsDispatch
          let temp1 = temp1 : rem Set up for LoadArenaColorsColor/LoadArenaColorsBW
          let temp2 = temp2
          
          if temp2 then goto LoadArenaColorsBW : rem Use existing LoadArena color functions (identical behavior)
          goto LoadArenaColorsColor

