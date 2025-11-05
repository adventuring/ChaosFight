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
          pfcolors ArenaColorsBW
          return

LoadRandomArena
          rem Select random arena (0-15)
          rem Use frame counter for pseudo-random selection
          let LA_arenaIndex = frame & 15
          goto LoadArenaByIndex

LoadArena0Colors
          pfcolors Arena0ColorsColor
          return
LoadArena1Colors
          pfcolors Arena1ColorsColor
          return
LoadArena2Colors
          pfcolors Arena2ColorsColor
          return
LoadArena3Colors
          pfcolors Arena3ColorsColor
          return
LoadArena4Colors
          pfcolors Arena4ColorsColor
          return
LoadArena5Colors
          pfcolors Arena5ColorsColor
          return
LoadArena6Colors
          pfcolors Arena6ColorsColor
          return
LoadArena7Colors
          pfcolors Arena7ColorsColor
          return
LoadArena8Colors
          pfcolors Arena8ColorsColor
          return
LoadArena9Colors
          pfcolors Arena9ColorsColor
          return
LoadArena10Colors
          pfcolors Arena10ColorsColor
          return
LoadArena11Colors
          pfcolors Arena11ColorsColor
          return
LoadArena12Colors
          pfcolors Arena12ColorsColor
          return
LoadArena13Colors
          pfcolors Arena13ColorsColor
          return
LoadArena14Colors
          pfcolors Arena14ColorsColor
          return
LoadArena15Colors
          pfcolors Arena15ColorsColor
          return

LoadArena16Colors
          pfcolors Arena16ColorsColor
          return

LoadArena17Colors
          pfcolors Arena17ColorsColor
          return

LoadArena18Colors
          pfcolors Arena18ColorsColor
          return

LoadArena19Colors
          pfcolors Arena19ColorsColor
          return

LoadArena20Colors
          pfcolors Arena20ColorsColor
          return

LoadArena21Colors
          pfcolors Arena21ColorsColor
          return

LoadArena22Colors
          pfcolors Arena22ColorsColor
          return

LoadArena23Colors
          pfcolors Arena23ColorsColor
          return

LoadArena24Colors
          pfcolors Arena24ColorsColor
          return

LoadArena25Colors
          pfcolors Arena25ColorsColor
          return

LoadArena26Colors
          pfcolors Arena26ColorsColor
          return

LoadArena27Colors
          pfcolors Arena27ColorsColor
          return

LoadArena28Colors
          pfcolors Arena28ColorsColor
          return

LoadArena29Colors
          pfcolors Arena29ColorsColor
          return

LoadArena30Colors
          pfcolors Arena30ColorsColor
          return

LoadArena31Colors
          pfcolors Arena31ColorsColor
          return

LoadArenaColorsBW
          pfcolors ArenaColorsBW
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

