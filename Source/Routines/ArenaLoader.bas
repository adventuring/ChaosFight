          rem
          rem ChaosFight - Source/Routines/ArenaLoader.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem Arena Loader
          rem Loads arena playfield data and colors based on
          rem   selectedArena.
          rem Handles Color/B&W switch: switchbw=1 (B&W/white),
          rem   switchbw=0 (Color/row colors)
          rem SECAM always uses B&W mode regardless of switch.

#include "Source/Data/Arenas.bas"
#include "Source/Common/Colors.h"

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
          dim LA_arenaIndex = temp1 : rem Constraints: None
          dim LA_bwMode = temp2
          
          if selectedArena_R = RandomArena then LoadRandomArena : rem Handle random arena selection
          
          let LA_arenaIndex = selectedArena_R : rem Get arena index (0-15)
          
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
          rem Output: LA_bwMode (temp2) = B&W mode (1=B&W, 0=Color)
          rem
          rem Mutates: temp2 (LA_bwMode return value)
          rem
          rem Called Routines: None
          rem
          rem Constraints: SECAM always returns B&W mode (compile-time
          rem check)
          #ifdef TV_SECAM
          let LA_bwMode = 1
          return
          #endif
          
          rem NTSC/PAL: Check switchbw and colorBWOverride
          rem switchbw = 1 means B&W mode (white), switchbw = 0 means
          rem   Color mode
          rem systemFlags bit 6 (SystemFlagColorBWOverride) = 1 means
          rem B&W override
          let LA_bwMode = switchbw : rem   (from 7800 pause button)
          if systemFlags & SystemFlagColorBWOverride then let LA_bwMode = 1
          return

LoadArenaByIndex
          rem Load arena playfield and colors by index
          rem
          rem Input: LA_arenaIndex (temp1) = arena index (0-31),
          rem LA_bwMode (temp2) = B&W mode (1=B&W, 0=Color),
          rem ArenaPF1PointerL[], ArenaPF1PointerH[],
          rem ArenaPF2PointerL[], ArenaPF2PointerH[] (global data
          rem tables) = playfield pointers
          rem
          rem Output: Arena playfield and colors loaded
          rem
          rem Mutates: temp1 (LA_arenaIndex validated), PF1pointer,
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
          if LA_arenaIndex > 31 then let LA_arenaIndex = 0
          
          rem Load playfield pointers from tables using index
          asm
            ldx LA_arenaIndex
            lda ArenaPF1PointerL,x
            sta PF1pointer
            lda ArenaPF1PointerH,x
            sta PF1pointer+1
            lda ArenaPF2PointerL,x
            sta PF2pointer
            lda ArenaPF2PointerH,x
            sta PF2pointer+1
end
          
          if LA_bwMode then LoadArenaColorsBW : rem Load colors based on B&W mode
          goto LoadArenaColorsColor

LoadArenaColorsColor
          rem Dispatch to arena-specific color loader based on arena
          rem index (0-31)
          rem
          rem Input: LA_arenaIndex (temp1) = arena index (0-31)
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
          dim LACC_tempIndex = temp3 : rem Dispatch to color loader based on arena index (0-31)
          let LACC_tempIndex = LA_arenaIndex
          if LACC_tempIndex >= 32 then let LACC_tempIndex = 0
          if LACC_tempIndex < 8 then on LACC_tempIndex goto LoadArena0Colors, LoadArena1Colors, LoadArena2Colors, LoadArena3Colors, LoadArena4Colors, LoadArena5Colors, LoadArena6Colors, LoadArena7Colors : rem Dispatch to arena 0-7
          if LACC_tempIndex < 8 then goto DoneArenaColorLoad
          let LACC_tempIndex = LACC_tempIndex - 8 : rem Dispatch to arena 8-15
          if LACC_tempIndex < 8 then on LACC_tempIndex goto LoadArena8Colors, LoadArena9Colors, LoadArena10Colors, LoadArena11Colors, LoadArena12Colors, LoadArena13Colors, LoadArena14Colors, LoadArena15Colors
          if LACC_tempIndex < 8 then goto DoneArenaColorLoad
          let LACC_tempIndex = LACC_tempIndex - 8 : rem Dispatch to arena 16-23
          if LACC_tempIndex < 8 then on LACC_tempIndex goto LoadArena16Colors, LoadArena17Colors, LoadArena18Colors, LoadArena19Colors, LoadArena20Colors, LoadArena21Colors, LoadArena22Colors, LoadArena23Colors
          if LACC_tempIndex < 8 then goto DoneArenaColorLoad
          let LACC_tempIndex = LACC_tempIndex - 8 : rem Dispatch to arena 24-31
          if LACC_tempIndex < 8 then on LACC_tempIndex goto LoadArena24Colors, LoadArena25Colors, LoadArena26Colors, LoadArena27Colors, LoadArena28Colors, LoadArena29Colors, LoadArena30Colors, LoadArena31Colors
DoneArenaColorLoad
          return

LoadArenaColorsBW
          asm
          rem Load B&W color table (all arenas use same white colors)
          rem
          rem Input: ArenaColorsBW (global data table) = B&W color table
          rem
          rem Output: pfcolortable set to ArenaColorsBW
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem All arenas use the same B&W colors (all white)
          rem Set pfcolortable pointer to ArenaColorsBW
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
          rem Mutates: temp1 (LA_arenaIndex set to random value), rand
          rem (global) = random number generator state
          rem
          rem Called Routines: LoadArenaByIndex (tail call) - loads
          rem selected random arena
          rem
          rem Constraints: None
          rem Select random arena (0-15) using proper RNG
          let LA_arenaIndex = rand : rem Get random value (0-255)
          let LA_arenaIndex = LA_arenaIndex & 15 : rem Mask to 0-15 range
          goto LoadArenaByIndex

LoadArena0Colors
          asm
          rem Load color table for arena 0
          rem
          rem Input: Arena0Colors (global data table) = arena 0 color
          rem table
          rem
          rem Output: pfcolortable set to Arena0Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena0Colors
            lda #<Arena0Colors
            sta pfcolortable
            lda #>Arena0Colors
            sta pfcolortable+1
end
          return
LoadArena1Colors
          asm
          rem Load color table for arena 1
          rem
          rem Input: Arena1Colors (global data table) = arena 1 color
          rem table
          rem
          rem Output: pfcolortable set to Arena1Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena1Colors
            lda #<Arena1Colors
            sta pfcolortable
            lda #>Arena1Colors
            sta pfcolortable+1
end
          return
LoadArena2Colors
          asm
          rem Load color table for arena 2
          rem
          rem Input: Arena2Colors (global data table) = arena 2 color
          rem table
          rem
          rem Output: pfcolortable set to Arena2Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena2Colors
            lda #<Arena2Colors
            sta pfcolortable
            lda #>Arena2Colors
            sta pfcolortable+1
end
          return
LoadArena3Colors
          asm
          rem Load color table for arena 3
          rem
          rem Input: Arena3Colors (global data table) = arena 3 color
          rem table
          rem
          rem Output: pfcolortable set to Arena3Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena3Colors
            lda #<Arena3Colors
            sta pfcolortable
            lda #>Arena3Colors
            sta pfcolortable+1
end
          return
LoadArena4Colors
          asm
          rem Load color table for arena 4
          rem
          rem Input: Arena4Colors (global data table) = arena 4 color
          rem table
          rem
          rem Output: pfcolortable set to Arena4Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena4Colors
            lda #<Arena4Colors
            sta pfcolortable
            lda #>Arena4Colors
            sta pfcolortable+1
end
          return
LoadArena5Colors
          asm
          rem Load color table for arena 5
          rem
          rem Input: Arena5Colors (global data table) = arena 5 color
          rem table
          rem
          rem Output: pfcolortable set to Arena5Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena5Colors
            lda #<Arena5Colors
            sta pfcolortable
            lda #>Arena5Colors
            sta pfcolortable+1
end
          return
LoadArena6Colors
          asm
          rem Load color table for arena 6
          rem
          rem Input: Arena6Colors (global data table) = arena 6 color
          rem table
          rem
          rem Output: pfcolortable set to Arena6Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena6Colors
            lda #<Arena6Colors
            sta pfcolortable
            lda #>Arena6Colors
            sta pfcolortable+1
end
          return
LoadArena7Colors
          asm
          rem Load color table for arena 7
          rem
          rem Input: Arena7Colors (global data table) = arena 7 color
          rem table
          rem
          rem Output: pfcolortable set to Arena7Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena7Colors
            lda #<Arena7Colors
            sta pfcolortable
            lda #>Arena7Colors
            sta pfcolortable+1
end
          return
LoadArena8Colors
          asm
          rem Load color table for arena 8
          rem
          rem Input: Arena8Colors (global data table) = arena 8 color
          rem table
          rem
          rem Output: pfcolortable set to Arena8Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena8Colors
            lda #<Arena8Colors
            sta pfcolortable
            lda #>Arena8Colors
            sta pfcolortable+1
end
          return
LoadArena9Colors
          asm
          rem Load color table for arena 9
          rem
          rem Input: Arena9Colors (global data table) = arena 9 color
          rem table
          rem
          rem Output: pfcolortable set to Arena9Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena9Colors
            lda #<Arena9Colors
            sta pfcolortable
            lda #>Arena9Colors
            sta pfcolortable+1
end
          return
LoadArena10Colors
          asm
          rem Load color table for arena 10
          rem
          rem Input: Arena10Colors (global data table) = arena 10 color
          rem table
          rem
          rem Output: pfcolortable set to Arena10Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena10Colors
            lda #<Arena10Colors
            sta pfcolortable
            lda #>Arena10Colors
            sta pfcolortable+1
end
          return
LoadArena11Colors
          asm
          rem Load color table for arena 11
          rem
          rem Input: Arena11Colors (global data table) = arena 11 color
          rem table
          rem
          rem Output: pfcolortable set to Arena11Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena11Colors
            lda #<Arena11Colors
            sta pfcolortable
            lda #>Arena11Colors
            sta pfcolortable+1
end
          return
LoadArena12Colors
          asm
          rem Load color table for arena 12
          rem
          rem Input: Arena12Colors (global data table) = arena 12 color
          rem table
          rem
          rem Output: pfcolortable set to Arena12Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena12Colors
            lda #<Arena12Colors
            sta pfcolortable
            lda #>Arena12Colors
            sta pfcolortable+1
end
          return
LoadArena13Colors
          asm
          rem Load color table for arena 13
          rem
          rem Input: Arena13Colors (global data table) = arena 13 color
          rem table
          rem
          rem Output: pfcolortable set to Arena13Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena13Colors
            lda #<Arena13Colors
            sta pfcolortable
            lda #>Arena13Colors
            sta pfcolortable+1
end
          return
LoadArena14Colors
          asm
          rem Load color table for arena 14
          rem
          rem Input: Arena14Colors (global data table) = arena 14 color
          rem table
          rem
          rem Output: pfcolortable set to Arena14Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena14Colors
            lda #<Arena14Colors
            sta pfcolortable
            lda #>Arena14Colors
            sta pfcolortable+1
end
          return
LoadArena15Colors
          asm
          rem Load color table for arena 15
          rem
          rem Input: Arena15Colors (global data table) = arena 15 color
          rem table
          rem
          rem Output: pfcolortable set to Arena15Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena15Colors
            lda #<Arena15Colors
            sta pfcolortable
            lda #>Arena15Colors
            sta pfcolortable+1
end
          return

LoadArena16Colors
          asm
          rem Load color table for arena 16
          rem
          rem Input: Arena16Colors (global data table) = arena 16 color
          rem table
          rem
          rem Output: pfcolortable set to Arena16Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena16Colors
            lda #<Arena16Colors
            sta pfcolortable
            lda #>Arena16Colors
            sta pfcolortable+1
end
          return

LoadArena17Colors
          asm
          rem Load color table for arena 17
          rem
          rem Input: Arena17Colors (global data table) = arena 17 color
          rem table
          rem
          rem Output: pfcolortable set to Arena17Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena17Colors
            lda #<Arena17Colors
            sta pfcolortable
            lda #>Arena17Colors
            sta pfcolortable+1
end
          return

LoadArena18Colors
          asm
          rem Load color table for arena 18
          rem
          rem Input: Arena18Colors (global data table) = arena 18 color
          rem table
          rem
          rem Output: pfcolortable set to Arena18Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena18Colors
            lda #<Arena18Colors
            sta pfcolortable
            lda #>Arena18Colors
            sta pfcolortable+1
end
          return

LoadArena19Colors
          asm
          rem Load color table for arena 19
          rem
          rem Input: Arena19Colors (global data table) = arena 19 color
          rem table
          rem
          rem Output: pfcolortable set to Arena19Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena19Colors
            lda #<Arena19Colors
            sta pfcolortable
            lda #>Arena19Colors
            sta pfcolortable+1
end
          return

LoadArena20Colors
          asm
          rem Load color table for arena 20
          rem
          rem Input: Arena20Colors (global data table) = arena 20 color
          rem table
          rem
          rem Output: pfcolortable set to Arena20Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena20Colors
            lda #<Arena20Colors
            sta pfcolortable
            lda #>Arena20Colors
            sta pfcolortable+1
end
          return

LoadArena21Colors
          asm
          rem Load color table for arena 21
          rem
          rem Input: Arena21Colors (global data table) = arena 21 color
          rem table
          rem
          rem Output: pfcolortable set to Arena21Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena21Colors
            lda #<Arena21Colors
            sta pfcolortable
            lda #>Arena21Colors
            sta pfcolortable+1
end
          return

LoadArena22Colors
          asm
          rem Load color table for arena 22
          rem
          rem Input: Arena22Colors (global data table) = arena 22 color
          rem table
          rem
          rem Output: pfcolortable set to Arena22Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena22Colors
            lda #<Arena22Colors
            sta pfcolortable
            lda #>Arena22Colors
            sta pfcolortable+1
end
          return

LoadArena23Colors
          asm
          rem Load color table for arena 23
          rem
          rem Input: Arena23Colors (global data table) = arena 23 color
          rem table
          rem
          rem Output: pfcolortable set to Arena23Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena23Colors
            lda #<Arena23Colors
            sta pfcolortable
            lda #>Arena23Colors
            sta pfcolortable+1
end
          return

LoadArena24Colors
          asm
          rem Load color table for arena 24
          rem
          rem Input: Arena24Colors (global data table) = arena 24 color
          rem table
          rem
          rem Output: pfcolortable set to Arena24Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena24Colors
            lda #<Arena24Colors
            sta pfcolortable
            lda #>Arena24Colors
            sta pfcolortable+1
end
          return

LoadArena25Colors
          asm
          rem Load color table for arena 25
          rem
          rem Input: Arena25Colors (global data table) = arena 25 color
          rem table
          rem
          rem Output: pfcolortable set to Arena25Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena25Colors
            lda #<Arena25Colors
            sta pfcolortable
            lda #>Arena25Colors
            sta pfcolortable+1
end
          return

LoadArena26Colors
          asm
          rem Load color table for arena 26
          rem
          rem Input: Arena26Colors (global data table) = arena 26 color
          rem table
          rem
          rem Output: pfcolortable set to Arena26Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena26Colors
            lda #<Arena26Colors
            sta pfcolortable
            lda #>Arena26Colors
            sta pfcolortable+1
end
          return

LoadArena27Colors
          asm
          rem Load color table for arena 27
          rem
          rem Input: Arena27Colors (global data table) = arena 27 color
          rem table
          rem
          rem Output: pfcolortable set to Arena27Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena27Colors
            lda #<Arena27Colors
            sta pfcolortable
            lda #>Arena27Colors
            sta pfcolortable+1
end
          return

LoadArena28Colors
          asm
          rem Load color table for arena 28
          rem
          rem Input: Arena28Colors (global data table) = arena 28 color
          rem table
          rem
          rem Output: pfcolortable set to Arena28Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena28Colors
            lda #<Arena28Colors
            sta pfcolortable
            lda #>Arena28Colors
            sta pfcolortable+1
end
          return

LoadArena29Colors
          asm
          rem Load color table for arena 29
          rem
          rem Input: Arena29Colors (global data table) = arena 29 color
          rem table
          rem
          rem Output: pfcolortable set to Arena29Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena29Colors
            lda #<Arena29Colors
            sta pfcolortable
            lda #>Arena29Colors
            sta pfcolortable+1
end
          return

LoadArena30Colors
          asm
          rem Load color table for arena 30
          rem
          rem Input: Arena30Colors (global data table) = arena 30 color
          rem table
          rem
          rem Output: pfcolortable set to Arena30Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena30Colors
            lda #<Arena30Colors
            sta pfcolortable
            lda #>Arena30Colors
            sta pfcolortable+1
end
          return

LoadArena31Colors
          asm
          rem Load color table for arena 31
          rem
          rem Input: Arena31Colors (global data table) = arena 31 color
          rem table
          rem
          rem Output: pfcolortable set to Arena31Colors
          rem
          rem Mutates: pfcolortable (TIA register) = color table pointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Set pfcolortable pointer to Arena31Colors
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
          dim RAC_arenaIndex = temp1 : rem Uses same logic as LoadArenaColors (consolidated to avoid duplication)
          dim RAC_bwMode = temp2
          
          let RAC_arenaIndex = selectedArena_R : rem Get current arena index
          if RAC_arenaIndex = RandomArena then let RAC_arenaIndex = rand & 31 : rem Handle random arena (use stored random selection)
          
          rem Get B&W mode state (same logic as GetBWMode)
          #ifdef TV_SECAM
          let RAC_bwMode = 1
          goto ReloadArenaColorsDispatch
          #endif
          
          let RAC_bwMode = switchbw : rem NTSC/PAL: Check switchbw and colorBWOverride
          if systemFlags & SystemFlagColorBWOverride then let RAC_bwMode = 1
          
ReloadArenaColorsDispatch
          let LA_arenaIndex = RAC_arenaIndex : rem Set up for LoadArenaColorsColor/LoadArenaColorsBW
          let LA_bwMode = RAC_bwMode
          
          if LA_bwMode then goto LoadArenaColorsBW : rem Use existing LoadArena color functions (identical behavior)
          goto LoadArenaColorsColor

