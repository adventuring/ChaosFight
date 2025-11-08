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
          rem tables) = playfield pointers
          rem
          rem Output: Arena playfield and colors loaded
          rem
          rem Mutates: temp1 (temp1 validated), PF1pointer,
          rem PF2pointer (TIA registers) = playfield pointers,
          rem pfcolortable (TIA register) = color table pointer (via
          rem color loaders)
          rem
          rem Called Routines: LoadArenaColorsBW (if B&W mode),
          rem LoadArenaColorsColor (if Color mode),
          rem LoadArena0Colors-LoadArena31Colors (via
          rem LoadArenaColorsColor dispatch)
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
          
          if temp2 then LoadArenaColorsBW : rem Load colors based on B&W mode
          goto LoadArenaColorsColor

LoadArenaColorsColor
          rem Dispatch to arena-specific color loader based on arena
          rem index (0-31)
          rem
          rem Input: temp1 (temp1) = arena index (0-31)
          rem
          rem Output: Arena color table loaded via dispatch to
          rem LoadArenaXColors
          rem
          rem Mutates: temp3 (used for dispatch index), pfcolortable
          rem (TIA register) = color table pointer (via
          rem LoadArenaXColors)
          rem
          rem Called Routines: LoadArena0Colors-LoadArena31Colors
          rem (dispatched based on arena index)
          rem
          rem Constraints: None
          rem Dispatch to color loader based on arena index (0-31)
          let temp3 = temp1
          if temp3 >= 32 then let temp3 = 0
          if temp3 < 8 then on temp3 goto LoadArena0Colors LoadArena1Colors LoadArena2Colors LoadArena3Colors LoadArena4Colors LoadArena5Colors LoadArena6Colors LoadArena7Colors : rem Dispatch to arena 0-7
          if temp3 < 8 then goto DoneArenaColorLoad
          let temp3 = temp3 - 8 : rem Dispatch to arena 8-15
          if temp3 < 8 then on temp3 goto LoadArena8Colors LoadArena9Colors LoadArena10Colors LoadArena11Colors LoadArena12Colors LoadArena13Colors LoadArena14Colors LoadArena15Colors
          if temp3 < 8 then goto DoneArenaColorLoad
          let temp3 = temp3 - 8 : rem Dispatch to arena 16-23
          if temp3 < 8 then on temp3 goto LoadArena16Colors LoadArena17Colors LoadArena18Colors LoadArena19Colors LoadArena20Colors LoadArena21Colors LoadArena22Colors LoadArena23Colors
          if temp3 < 8 then goto DoneArenaColorLoad
          let temp3 = temp3 - 8 : rem Dispatch to arena 24-31
          if temp3 < 8 then on temp3 goto LoadArena24Colors LoadArena25Colors LoadArena26Colors LoadArena27Colors LoadArena28Colors LoadArena29Colors LoadArena30Colors LoadArena31Colors
DoneArenaColorLoad
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

LoadArena0Colors
          asm
          ; Load color table for arena 0
          ;
          ; Input: Arena0Colors (global data table) = arena 0 color
          ; table
          ;
          ; Output: pfcolortable set to Arena0Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena0Colors
            lda #<Arena0Colors
            sta pfcolortable
            lda #>Arena0Colors
            sta pfcolortable+1
end
          return
LoadArena1Colors
          asm
          ; Load color table for arena 1
          ;
          ; Input: Arena1Colors (global data table) = arena 1 color
          ; table
          ;
          ; Output: pfcolortable set to Arena1Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena1Colors
            lda #<Arena1Colors
            sta pfcolortable
            lda #>Arena1Colors
            sta pfcolortable+1
end
          return
LoadArena2Colors
          asm
          ; Load color table for arena 2
          ;
          ; Input: Arena2Colors (global data table) = arena 2 color
          ; table
          ;
          ; Output: pfcolortable set to Arena2Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena2Colors
            lda #<Arena2Colors
            sta pfcolortable
            lda #>Arena2Colors
            sta pfcolortable+1
end
          return
LoadArena3Colors
          asm
          ; Load color table for arena 3
          ;
          ; Input: Arena3Colors (global data table) = arena 3 color
          ; table
          ;
          ; Output: pfcolortable set to Arena3Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena3Colors
            lda #<Arena3Colors
            sta pfcolortable
            lda #>Arena3Colors
            sta pfcolortable+1
end
          return
LoadArena4Colors
          asm
          ; Load color table for arena 4
          ;
          ; Input: Arena4Colors (global data table) = arena 4 color
          ; table
          ;
          ; Output: pfcolortable set to Arena4Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena4Colors
            lda #<Arena4Colors
            sta pfcolortable
            lda #>Arena4Colors
            sta pfcolortable+1
end
          return
LoadArena5Colors
          asm
          ; Load color table for arena 5
          ;
          ; Input: Arena5Colors (global data table) = arena 5 color
          ; table
          ;
          ; Output: pfcolortable set to Arena5Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena5Colors
            lda #<Arena5Colors
            sta pfcolortable
            lda #>Arena5Colors
            sta pfcolortable+1
end
          return
LoadArena6Colors
          asm
          ; Load color table for arena 6
          ;
          ; Input: Arena6Colors (global data table) = arena 6 color
          ; table
          ;
          ; Output: pfcolortable set to Arena6Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena6Colors
            lda #<Arena6Colors
            sta pfcolortable
            lda #>Arena6Colors
            sta pfcolortable+1
end
          return
LoadArena7Colors
          asm
          ; Load color table for arena 7
          ;
          ; Input: Arena7Colors (global data table) = arena 7 color
          ; table
          ;
          ; Output: pfcolortable set to Arena7Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena7Colors
            lda #<Arena7Colors
            sta pfcolortable
            lda #>Arena7Colors
            sta pfcolortable+1
end
          return
LoadArena8Colors
          asm
          ; Load color table for arena 8
          ;
          ; Input: Arena8Colors (global data table) = arena 8 color
          ; table
          ;
          ; Output: pfcolortable set to Arena8Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena8Colors
            lda #<Arena8Colors
            sta pfcolortable
            lda #>Arena8Colors
            sta pfcolortable+1
end
          return
LoadArena9Colors
          asm
          ; Load color table for arena 9
          ;
          ; Input: Arena9Colors (global data table) = arena 9 color
          ; table
          ;
          ; Output: pfcolortable set to Arena9Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena9Colors
            lda #<Arena9Colors
            sta pfcolortable
            lda #>Arena9Colors
            sta pfcolortable+1
end
          return
LoadArena10Colors
          asm
          ; Load color table for arena 10
          ;
          ; Input: Arena10Colors (global data table) = arena 10 color
          ; table
          ;
          ; Output: pfcolortable set to Arena10Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena10Colors
            lda #<Arena10Colors
            sta pfcolortable
            lda #>Arena10Colors
            sta pfcolortable+1
end
          return
LoadArena11Colors
          asm
          ; Load color table for arena 11
          ;
          ; Input: Arena11Colors (global data table) = arena 11 color
          ; table
          ;
          ; Output: pfcolortable set to Arena11Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena11Colors
            lda #<Arena11Colors
            sta pfcolortable
            lda #>Arena11Colors
            sta pfcolortable+1
end
          return
LoadArena12Colors
          asm
          ; Load color table for arena 12
          ;
          ; Input: Arena12Colors (global data table) = arena 12 color
          ; table
          ;
          ; Output: pfcolortable set to Arena12Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena12Colors
            lda #<Arena12Colors
            sta pfcolortable
            lda #>Arena12Colors
            sta pfcolortable+1
end
          return
LoadArena13Colors
          asm
          ; Load color table for arena 13
          ;
          ; Input: Arena13Colors (global data table) = arena 13 color
          ; table
          ;
          ; Output: pfcolortable set to Arena13Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena13Colors
            lda #<Arena13Colors
            sta pfcolortable
            lda #>Arena13Colors
            sta pfcolortable+1
end
          return
LoadArena14Colors
          asm
          ; Load color table for arena 14
          ;
          ; Input: Arena14Colors (global data table) = arena 14 color
          ; table
          ;
          ; Output: pfcolortable set to Arena14Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena14Colors
            lda #<Arena14Colors
            sta pfcolortable
            lda #>Arena14Colors
            sta pfcolortable+1
end
          return
LoadArena15Colors
          asm
          ; Load color table for arena 15
          ;
          ; Input: Arena15Colors (global data table) = arena 15 color
          ; table
          ;
          ; Output: pfcolortable set to Arena15Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena15Colors
            lda #<Arena15Colors
            sta pfcolortable
            lda #>Arena15Colors
            sta pfcolortable+1
end
          return

LoadArena16Colors
          asm
          ; Load color table for arena 16
          ;
          ; Input: Arena16Colors (global data table) = arena 16 color
          ; table
          ;
          ; Output: pfcolortable set to Arena16Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena16Colors
            lda #<Arena16Colors
            sta pfcolortable
            lda #>Arena16Colors
            sta pfcolortable+1
end
          return

LoadArena17Colors
          asm
          ; Load color table for arena 17
          ;
          ; Input: Arena17Colors (global data table) = arena 17 color
          ; table
          ;
          ; Output: pfcolortable set to Arena17Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena17Colors
            lda #<Arena17Colors
            sta pfcolortable
            lda #>Arena17Colors
            sta pfcolortable+1
end
          return

LoadArena18Colors
          asm
          ; Load color table for arena 18
          ;
          ; Input: Arena18Colors (global data table) = arena 18 color
          ; table
          ;
          ; Output: pfcolortable set to Arena18Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena18Colors
            lda #<Arena18Colors
            sta pfcolortable
            lda #>Arena18Colors
            sta pfcolortable+1
end
          return

LoadArena19Colors
          asm
          ; Load color table for arena 19
          ;
          ; Input: Arena19Colors (global data table) = arena 19 color
          ; table
          ;
          ; Output: pfcolortable set to Arena19Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena19Colors
            lda #<Arena19Colors
            sta pfcolortable
            lda #>Arena19Colors
            sta pfcolortable+1
end
          return

LoadArena20Colors
          asm
          ; Load color table for arena 20
          ;
          ; Input: Arena20Colors (global data table) = arena 20 color
          ; table
          ;
          ; Output: pfcolortable set to Arena20Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena20Colors
            lda #<Arena20Colors
            sta pfcolortable
            lda #>Arena20Colors
            sta pfcolortable+1
end
          return

LoadArena21Colors
          asm
          ; Load color table for arena 21
          ;
          ; Input: Arena21Colors (global data table) = arena 21 color
          ; table
          ;
          ; Output: pfcolortable set to Arena21Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena21Colors
            lda #<Arena21Colors
            sta pfcolortable
            lda #>Arena21Colors
            sta pfcolortable+1
end
          return

LoadArena22Colors
          asm
          ; Load color table for arena 22
          ;
          ; Input: Arena22Colors (global data table) = arena 22 color
          ; table
          ;
          ; Output: pfcolortable set to Arena22Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena22Colors
            lda #<Arena22Colors
            sta pfcolortable
            lda #>Arena22Colors
            sta pfcolortable+1
end
          return

LoadArena23Colors
          asm
          ; Load color table for arena 23
          ;
          ; Input: Arena23Colors (global data table) = arena 23 color
          ; table
          ;
          ; Output: pfcolortable set to Arena23Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena23Colors
            lda #<Arena23Colors
            sta pfcolortable
            lda #>Arena23Colors
            sta pfcolortable+1
end
          return

LoadArena24Colors
          asm
          ; Load color table for arena 24
          ;
          ; Input: Arena24Colors (global data table) = arena 24 color
          ; table
          ;
          ; Output: pfcolortable set to Arena24Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena24Colors
            lda #<Arena24Colors
            sta pfcolortable
            lda #>Arena24Colors
            sta pfcolortable+1
end
          return

LoadArena25Colors
          asm
          ; Load color table for arena 25
          ;
          ; Input: Arena25Colors (global data table) = arena 25 color
          ; table
          ;
          ; Output: pfcolortable set to Arena25Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena25Colors
            lda #<Arena25Colors
            sta pfcolortable
            lda #>Arena25Colors
            sta pfcolortable+1
end
          return

LoadArena26Colors
          asm
          ; Load color table for arena 26
          ;
          ; Input: Arena26Colors (global data table) = arena 26 color
          ; table
          ;
          ; Output: pfcolortable set to Arena26Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena26Colors
            lda #<Arena26Colors
            sta pfcolortable
            lda #>Arena26Colors
            sta pfcolortable+1
end
          return

LoadArena27Colors
          asm
          ; Load color table for arena 27
          ;
          ; Input: Arena27Colors (global data table) = arena 27 color
          ; table
          ;
          ; Output: pfcolortable set to Arena27Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena27Colors
            lda #<Arena27Colors
            sta pfcolortable
            lda #>Arena27Colors
            sta pfcolortable+1
end
          return

LoadArena28Colors
          asm
          ; Load color table for arena 28
          ;
          ; Input: Arena28Colors (global data table) = arena 28 color
          ; table
          ;
          ; Output: pfcolortable set to Arena28Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena28Colors
            lda #<Arena28Colors
            sta pfcolortable
            lda #>Arena28Colors
            sta pfcolortable+1
end
          return

LoadArena29Colors
          asm
          ; Load color table for arena 29
          ;
          ; Input: Arena29Colors (global data table) = arena 29 color
          ; table
          ;
          ; Output: pfcolortable set to Arena29Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena29Colors
            lda #<Arena29Colors
            sta pfcolortable
            lda #>Arena29Colors
            sta pfcolortable+1
end
          return

LoadArena30Colors
          asm
          ; Load color table for arena 30
          ;
          ; Input: Arena30Colors (global data table) = arena 30 color
          ; table
          ;
          ; Output: pfcolortable set to Arena30Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena30Colors
            lda #<Arena30Colors
            sta pfcolortable
            lda #>Arena30Colors
            sta pfcolortable+1
end
          return

LoadArena31Colors
          asm
          ; Load color table for arena 31
          ;
          ; Input: Arena31Colors (global data table) = arena 31 color
          ; table
          ;
          ; Output: pfcolortable set to Arena31Colors
          ;
          ; Mutates: pfcolortable (TIA register) = color table pointer
          ;
          ; Called Routines: None
          ;
          ; Constraints: None
          ; Set pfcolortable pointer to Arena31Colors
            lda #<Arena31Colors
            sta pfcolortable
            lda #>Arena31Colors
            sta pfcolortable+1
end
          return

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

