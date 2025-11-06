          rem ChaosFight - Source/Routines/ArenaLoader.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem ARENA LOADER
          rem ==========================================================
          rem Loads arena playfield data and colors based on
          rem   selectedArena.
          rem Handles Color/B&W switch: switchbw=1 (B&W/white),
          rem   switchbw=0 (Color/row colors)
          rem SECAM always uses B&W mode regardless of switch.
          rem ==========================================================

#include "Source/Data/Arenas.bas"
#include "Source/Common/Colors.h"

LoadArena
          dim LA_arenaIndex = temp1
          dim LA_bwMode = temp2
          
          rem Handle random arena selection
          if selectedArena_R = RandomArena then LoadRandomArena
          
          rem Get arena index (0-15)
          let LA_arenaIndex = selectedArena_R
          
          rem Load playfield and colors
          gosub GetBWMode
          goto LoadArenaByIndex

GetBWMode
          rem Check if B&W mode is active
          rem SECAM: Always B&W mode
          #ifdef TV_SECAM
          let LA_bwMode = 1
          return
          #endif
          
          rem NTSC/PAL: Check switchbw and colorBWOverride
          rem switchbw = 1 means B&W mode (white), switchbw = 0 means
          rem   Color mode
          rem systemFlags bit 6 (SystemFlagColorBWOverride) = 1 means B&W override
          rem   (from 7800 pause button)
          let LA_bwMode = switchbw
          if systemFlags & SystemFlagColorBWOverride then let LA_bwMode = 1
          return

LoadArenaByIndex
          rem Validate arena index (0-31 supported by pointer tables)
          rem Note: Only 0-15 are selectable (MaxArenaID), but tables support 0-31
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
          
          rem Load colors based on B&W mode
          if LA_bwMode then LoadArenaColorsBW
          goto LoadArenaColorsColor

LoadArenaColorsColor
          rem Dispatch to color loader based on arena index (0-31)
          dim LACC_tempIndex = temp3
          let LACC_tempIndex = LA_arenaIndex
          if LACC_tempIndex >= 32 then let LACC_tempIndex = 0
          rem Dispatch to arena 0-7
          if LACC_tempIndex < 8 then on LACC_tempIndex goto LoadArena0Colors, LoadArena1Colors, LoadArena2Colors, LoadArena3Colors, LoadArena4Colors, LoadArena5Colors, LoadArena6Colors, LoadArena7Colors
          if LACC_tempIndex < 8 then goto DoneArenaColorLoad
          rem Dispatch to arena 8-15
          let LACC_tempIndex = LACC_tempIndex - 8
          if LACC_tempIndex < 8 then on LACC_tempIndex goto LoadArena8Colors, LoadArena9Colors, LoadArena10Colors, LoadArena11Colors, LoadArena12Colors, LoadArena13Colors, LoadArena14Colors, LoadArena15Colors
          if LACC_tempIndex < 8 then goto DoneArenaColorLoad
          rem Dispatch to arena 16-23
          let LACC_tempIndex = LACC_tempIndex - 8
          if LACC_tempIndex < 8 then on LACC_tempIndex goto LoadArena16Colors, LoadArena17Colors, LoadArena18Colors, LoadArena19Colors, LoadArena20Colors, LoadArena21Colors, LoadArena22Colors, LoadArena23Colors
          if LACC_tempIndex < 8 then goto DoneArenaColorLoad
          rem Dispatch to arena 24-31
          let LACC_tempIndex = LACC_tempIndex - 8
          if LACC_tempIndex < 8 then on LACC_tempIndex goto LoadArena24Colors, LoadArena25Colors, LoadArena26Colors, LoadArena27Colors, LoadArena28Colors, LoadArena29Colors, LoadArena30Colors, LoadArena31Colors
DoneArenaColorLoad
          return

LoadArenaColorsBW
          rem All arenas use the same B&W colors (all white)
          rem Set pfcolortable pointer to ArenaColorsBW
          asm
            lda #<ArenaColorsBW
            sta pfcolortable
            lda #>ArenaColorsBW
            sta pfcolortable+1
end
          return

LoadRandomArena
          rem Select random arena (0-15)
          rem Use frame counter for pseudo-random selection
          let LA_arenaIndex = frame & 15
          goto LoadArenaByIndex

LoadArena0Colors
          rem Set pfcolortable pointer to Arena0Colors
          asm
            lda #<Arena0Colors
            sta pfcolortable
            lda #>Arena0Colors
            sta pfcolortable+1
end
          return
LoadArena1Colors
          rem Set pfcolortable pointer to Arena1Colors
          asm
            lda #<Arena1Colors
            sta pfcolortable
            lda #>Arena1Colors
            sta pfcolortable+1
end
          return
LoadArena2Colors
          rem Set pfcolortable pointer to Arena2Colors
          asm
            lda #<Arena2Colors
            sta pfcolortable
            lda #>Arena2Colors
            sta pfcolortable+1
end
          return
LoadArena3Colors
          rem Set pfcolortable pointer to Arena3Colors
          asm
            lda #<Arena3Colors
            sta pfcolortable
            lda #>Arena3Colors
            sta pfcolortable+1
end
          return
LoadArena4Colors
          rem Set pfcolortable pointer to Arena4Colors
          asm
            lda #<Arena4Colors
            sta pfcolortable
            lda #>Arena4Colors
            sta pfcolortable+1
end
          return
LoadArena5Colors
          rem Set pfcolortable pointer to Arena5Colors
          asm
            lda #<Arena5Colors
            sta pfcolortable
            lda #>Arena5Colors
            sta pfcolortable+1
end
          return
LoadArena6Colors
          rem Set pfcolortable pointer to Arena6Colors
          asm
            lda #<Arena6Colors
            sta pfcolortable
            lda #>Arena6Colors
            sta pfcolortable+1
end
          return
LoadArena7Colors
          rem Set pfcolortable pointer to Arena7Colors
          asm
            lda #<Arena7Colors
            sta pfcolortable
            lda #>Arena7Colors
            sta pfcolortable+1
end
          return
LoadArena8Colors
          rem Set pfcolortable pointer to Arena8Colors
          asm
            lda #<Arena8Colors
            sta pfcolortable
            lda #>Arena8Colors
            sta pfcolortable+1
end
          return
LoadArena9Colors
          rem Set pfcolortable pointer to Arena9Colors
          asm
            lda #<Arena9Colors
            sta pfcolortable
            lda #>Arena9Colors
            sta pfcolortable+1
end
          return
LoadArena10Colors
          rem Set pfcolortable pointer to Arena10Colors
          asm
            lda #<Arena10Colors
            sta pfcolortable
            lda #>Arena10Colors
            sta pfcolortable+1
end
          return
LoadArena11Colors
          rem Set pfcolortable pointer to Arena11Colors
          asm
            lda #<Arena11Colors
            sta pfcolortable
            lda #>Arena11Colors
            sta pfcolortable+1
end
          return
LoadArena12Colors
          rem Set pfcolortable pointer to Arena12Colors
          asm
            lda #<Arena12Colors
            sta pfcolortable
            lda #>Arena12Colors
            sta pfcolortable+1
end
          return
LoadArena13Colors
          rem Set pfcolortable pointer to Arena13Colors
          asm
            lda #<Arena13Colors
            sta pfcolortable
            lda #>Arena13Colors
            sta pfcolortable+1
end
          return
LoadArena14Colors
          rem Set pfcolortable pointer to Arena14Colors
          asm
            lda #<Arena14Colors
            sta pfcolortable
            lda #>Arena14Colors
            sta pfcolortable+1
end
          return
LoadArena15Colors
          rem Set pfcolortable pointer to Arena15Colors
          asm
            lda #<Arena15Colors
            sta pfcolortable
            lda #>Arena15Colors
            sta pfcolortable+1
end
          return

LoadArena16Colors
          rem Set pfcolortable pointer to Arena16Colors
          asm
            lda #<Arena16Colors
            sta pfcolortable
            lda #>Arena16Colors
            sta pfcolortable+1
end
          return

LoadArena17Colors
          rem Set pfcolortable pointer to Arena17Colors
          asm
            lda #<Arena17Colors
            sta pfcolortable
            lda #>Arena17Colors
            sta pfcolortable+1
end
          return

LoadArena18Colors
          rem Set pfcolortable pointer to Arena18Colors
          asm
            lda #<Arena18Colors
            sta pfcolortable
            lda #>Arena18Colors
            sta pfcolortable+1
end
          return

LoadArena19Colors
          rem Set pfcolortable pointer to Arena19Colors
          asm
            lda #<Arena19Colors
            sta pfcolortable
            lda #>Arena19Colors
            sta pfcolortable+1
end
          return

LoadArena20Colors
          rem Set pfcolortable pointer to Arena20Colors
          asm
            lda #<Arena20Colors
            sta pfcolortable
            lda #>Arena20Colors
            sta pfcolortable+1
end
          return

LoadArena21Colors
          rem Set pfcolortable pointer to Arena21Colors
          asm
            lda #<Arena21Colors
            sta pfcolortable
            lda #>Arena21Colors
            sta pfcolortable+1
end
          return

LoadArena22Colors
          rem Set pfcolortable pointer to Arena22Colors
          asm
            lda #<Arena22Colors
            sta pfcolortable
            lda #>Arena22Colors
            sta pfcolortable+1
end
          return

LoadArena23Colors
          rem Set pfcolortable pointer to Arena23Colors
          asm
            lda #<Arena23Colors
            sta pfcolortable
            lda #>Arena23Colors
            sta pfcolortable+1
end
          return

LoadArena24Colors
          rem Set pfcolortable pointer to Arena24Colors
          asm
            lda #<Arena24Colors
            sta pfcolortable
            lda #>Arena24Colors
            sta pfcolortable+1
end
          return

LoadArena25Colors
          rem Set pfcolortable pointer to Arena25Colors
          asm
            lda #<Arena25Colors
            sta pfcolortable
            lda #>Arena25Colors
            sta pfcolortable+1
end
          return

LoadArena26Colors
          rem Set pfcolortable pointer to Arena26Colors
          asm
            lda #<Arena26Colors
            sta pfcolortable
            lda #>Arena26Colors
            sta pfcolortable+1
end
          return

LoadArena27Colors
          rem Set pfcolortable pointer to Arena27Colors
          asm
            lda #<Arena27Colors
            sta pfcolortable
            lda #>Arena27Colors
            sta pfcolortable+1
end
          return

LoadArena28Colors
          rem Set pfcolortable pointer to Arena28Colors
          asm
            lda #<Arena28Colors
            sta pfcolortable
            lda #>Arena28Colors
            sta pfcolortable+1
end
          return

LoadArena29Colors
          rem Set pfcolortable pointer to Arena29Colors
          asm
            lda #<Arena29Colors
            sta pfcolortable
            lda #>Arena29Colors
            sta pfcolortable+1
end
          return

LoadArena30Colors
          rem Set pfcolortable pointer to Arena30Colors
          asm
            lda #<Arena30Colors
            sta pfcolortable
            lda #>Arena30Colors
            sta pfcolortable+1
end
          return

LoadArena31Colors
          rem Set pfcolortable pointer to Arena31Colors
          asm
            lda #<Arena31Colors
            sta pfcolortable
            lda #>Arena31Colors
            sta pfcolortable+1
end
          return

          rem ==========================================================
          rem RELOAD ARENA COLORS
          rem ==========================================================
          rem Reloads only the arena colors (not playfield) based on
          rem   current
          rem Color/B&W switch state. Called when switch changes during
          rem   gameplay.
          rem ==========================================================

ReloadArenaColors
          rem Reload arena colors based on current Color/B&W switch state
          rem Uses same logic as LoadArenaColors (consolidated to avoid duplication)
          dim RAC_arenaIndex = temp1
          dim RAC_bwMode = temp2
          
          rem Get current arena index
          let RAC_arenaIndex = selectedArena_R
          rem Handle random arena (use stored random selection)
          if RAC_arenaIndex = RandomArena then let RAC_arenaIndex = rand & 31
          
          rem Get B&W mode state (same logic as GetBWMode)
          #ifdef TV_SECAM
          let RAC_bwMode = 1
          goto ReloadArenaColorsDispatch
          #endif
          
          rem NTSC/PAL: Check switchbw and colorBWOverride
          let RAC_bwMode = switchbw
          if systemFlags & SystemFlagColorBWOverride then let RAC_bwMode = 1
          
ReloadArenaColorsDispatch
          rem Set up for LoadArenaColorsColor/LoadArenaColorsBW
          let LA_arenaIndex = RAC_arenaIndex
          let LA_bwMode = RAC_bwMode
          
          rem Use existing LoadArena color functions (identical behavior)
          if LA_bwMode then goto LoadArenaColorsBW
          goto LoadArenaColorsColor

