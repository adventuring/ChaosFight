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
          rem Set pfcolortable pointer to Arena0ColorsColor
          asm
            lda #<Arena0ColorsColor
            sta pfcolortable
            lda #>Arena0ColorsColor
            sta pfcolortable+1
end
          return
LoadArena1Colors
          rem Set pfcolortable pointer to Arena1ColorsColor
          asm
            lda #<Arena1ColorsColor
            sta pfcolortable
            lda #>Arena1ColorsColor
            sta pfcolortable+1
end
          return
LoadArena2Colors
          rem Set pfcolortable pointer to Arena2ColorsColor
          asm
            lda #<Arena2ColorsColor
            sta pfcolortable
            lda #>Arena2ColorsColor
            sta pfcolortable+1
end
          return
LoadArena3Colors
          rem Set pfcolortable pointer to Arena3ColorsColor
          asm
            lda #<Arena3ColorsColor
            sta pfcolortable
            lda #>Arena3ColorsColor
            sta pfcolortable+1
end
          return
LoadArena4Colors
          rem Set pfcolortable pointer to Arena4ColorsColor
          asm
            lda #<Arena4ColorsColor
            sta pfcolortable
            lda #>Arena4ColorsColor
            sta pfcolortable+1
end
          return
LoadArena5Colors
          rem Set pfcolortable pointer to Arena5ColorsColor
          asm
            lda #<Arena5ColorsColor
            sta pfcolortable
            lda #>Arena5ColorsColor
            sta pfcolortable+1
end
          return
LoadArena6Colors
          rem Set pfcolortable pointer to Arena6ColorsColor
          asm
            lda #<Arena6ColorsColor
            sta pfcolortable
            lda #>Arena6ColorsColor
            sta pfcolortable+1
end
          return
LoadArena7Colors
          rem Set pfcolortable pointer to Arena7ColorsColor
          asm
            lda #<Arena7ColorsColor
            sta pfcolortable
            lda #>Arena7ColorsColor
            sta pfcolortable+1
end
          return
LoadArena8Colors
          rem Set pfcolortable pointer to Arena8ColorsColor
          asm
            lda #<Arena8ColorsColor
            sta pfcolortable
            lda #>Arena8ColorsColor
            sta pfcolortable+1
end
          return
LoadArena9Colors
          rem Set pfcolortable pointer to Arena9ColorsColor
          asm
            lda #<Arena9ColorsColor
            sta pfcolortable
            lda #>Arena9ColorsColor
            sta pfcolortable+1
end
          return
LoadArena10Colors
          rem Set pfcolortable pointer to Arena10ColorsColor
          asm
            lda #<Arena10ColorsColor
            sta pfcolortable
            lda #>Arena10ColorsColor
            sta pfcolortable+1
end
          return
LoadArena11Colors
          rem Set pfcolortable pointer to Arena11ColorsColor
          asm
            lda #<Arena11ColorsColor
            sta pfcolortable
            lda #>Arena11ColorsColor
            sta pfcolortable+1
end
          return
LoadArena12Colors
          rem Set pfcolortable pointer to Arena12ColorsColor
          asm
            lda #<Arena12ColorsColor
            sta pfcolortable
            lda #>Arena12ColorsColor
            sta pfcolortable+1
end
          return
LoadArena13Colors
          rem Set pfcolortable pointer to Arena13ColorsColor
          asm
            lda #<Arena13ColorsColor
            sta pfcolortable
            lda #>Arena13ColorsColor
            sta pfcolortable+1
end
          return
LoadArena14Colors
          rem Set pfcolortable pointer to Arena14ColorsColor
          asm
            lda #<Arena14ColorsColor
            sta pfcolortable
            lda #>Arena14ColorsColor
            sta pfcolortable+1
end
          return
LoadArena15Colors
          rem Set pfcolortable pointer to Arena15ColorsColor
          asm
            lda #<Arena15ColorsColor
            sta pfcolortable
            lda #>Arena15ColorsColor
            sta pfcolortable+1
end
          return

LoadArena16Colors
          rem Set pfcolortable pointer to Arena16ColorsColor
          asm
            lda #<Arena16ColorsColor
            sta pfcolortable
            lda #>Arena16ColorsColor
            sta pfcolortable+1
end
          return

LoadArena17Colors
          rem Set pfcolortable pointer to Arena17ColorsColor
          asm
            lda #<Arena17ColorsColor
            sta pfcolortable
            lda #>Arena17ColorsColor
            sta pfcolortable+1
end
          return

LoadArena18Colors
          rem Set pfcolortable pointer to Arena18ColorsColor
          asm
            lda #<Arena18ColorsColor
            sta pfcolortable
            lda #>Arena18ColorsColor
            sta pfcolortable+1
end
          return

LoadArena19Colors
          rem Set pfcolortable pointer to Arena19ColorsColor
          asm
            lda #<Arena19ColorsColor
            sta pfcolortable
            lda #>Arena19ColorsColor
            sta pfcolortable+1
end
          return

LoadArena20Colors
          rem Set pfcolortable pointer to Arena20ColorsColor
          asm
            lda #<Arena20ColorsColor
            sta pfcolortable
            lda #>Arena20ColorsColor
            sta pfcolortable+1
end
          return

LoadArena21Colors
          rem Set pfcolortable pointer to Arena21ColorsColor
          asm
            lda #<Arena21ColorsColor
            sta pfcolortable
            lda #>Arena21ColorsColor
            sta pfcolortable+1
end
          return

LoadArena22Colors
          rem Set pfcolortable pointer to Arena22ColorsColor
          asm
            lda #<Arena22ColorsColor
            sta pfcolortable
            lda #>Arena22ColorsColor
            sta pfcolortable+1
end
          return

LoadArena23Colors
          rem Set pfcolortable pointer to Arena23ColorsColor
          asm
            lda #<Arena23ColorsColor
            sta pfcolortable
            lda #>Arena23ColorsColor
            sta pfcolortable+1
end
          return

LoadArena24Colors
          rem Set pfcolortable pointer to Arena24ColorsColor
          asm
            lda #<Arena24ColorsColor
            sta pfcolortable
            lda #>Arena24ColorsColor
            sta pfcolortable+1
end
          return

LoadArena25Colors
          rem Set pfcolortable pointer to Arena25ColorsColor
          asm
            lda #<Arena25ColorsColor
            sta pfcolortable
            lda #>Arena25ColorsColor
            sta pfcolortable+1
end
          return

LoadArena26Colors
          rem Set pfcolortable pointer to Arena26ColorsColor
          asm
            lda #<Arena26ColorsColor
            sta pfcolortable
            lda #>Arena26ColorsColor
            sta pfcolortable+1
end
          return

LoadArena27Colors
          rem Set pfcolortable pointer to Arena27ColorsColor
          asm
            lda #<Arena27ColorsColor
            sta pfcolortable
            lda #>Arena27ColorsColor
            sta pfcolortable+1
end
          return

LoadArena28Colors
          rem Set pfcolortable pointer to Arena28ColorsColor
          asm
            lda #<Arena28ColorsColor
            sta pfcolortable
            lda #>Arena28ColorsColor
            sta pfcolortable+1
end
          return

LoadArena29Colors
          rem Set pfcolortable pointer to Arena29ColorsColor
          asm
            lda #<Arena29ColorsColor
            sta pfcolortable
            lda #>Arena29ColorsColor
            sta pfcolortable+1
end
          return

LoadArena30Colors
          rem Set pfcolortable pointer to Arena30ColorsColor
          asm
            lda #<Arena30ColorsColor
            sta pfcolortable
            lda #>Arena30ColorsColor
            sta pfcolortable+1
end
          return

LoadArena31Colors
          rem Set pfcolortable pointer to Arena31ColorsColor
          asm
            lda #<Arena31ColorsColor
            sta pfcolortable
            lda #>Arena31ColorsColor
            sta pfcolortable+1
end
          return

LoadArenaColorsBW
          rem Set pfcolortable pointer to ArenaColorsBW
          asm
            lda #<ArenaColorsBW
            sta pfcolortable
            lda #>ArenaColorsBW
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

