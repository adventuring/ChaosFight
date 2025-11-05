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
          rem Indices 16-31 wrap around to 0-15 (repeat color patterns)
          dim LACC_tempIndex = temp3
          let LACC_tempIndex = LA_arenaIndex
          if LACC_tempIndex >= 16 then LACC_tempIndex = LACC_tempIndex - 16
          if LACC_tempIndex < 8 then on LACC_tempIndex goto LoadArena0Colors, LoadArena1Colors, LoadArena2Colors, LoadArena3Colors, LoadArena4Colors, LoadArena5Colors, LoadArena6Colors, LoadArena7Colors
          if LACC_tempIndex < 8 then goto DoneArenaColorLoad
          LACC_tempIndex = LACC_tempIndex - 8
          if LACC_tempIndex < 8 then on LACC_tempIndex goto LoadArena8Colors, LoadArena9Colors, LoadArena10Colors, LoadArena11Colors, LoadArena12Colors, LoadArena13Colors, LoadArena14Colors, LoadArena15Colors
DoneArenaColorLoad
          return

LoadArenaColorsBW
          rem Dispatch to B&W color loader based on arena index (0-31)
          rem Indices 16-31 wrap around to 0-15 (repeat color patterns)
          dim LACBW_tempIndex = temp3
          let LACBW_tempIndex = LA_arenaIndex
          if LACBW_tempIndex >= 16 then LACBW_tempIndex = LACBW_tempIndex - 16
          if LACBW_tempIndex < 8 then on LACBW_tempIndex goto LoadArena0ColorsBW, LoadArena1ColorsBW, LoadArena2ColorsBW, LoadArena3ColorsBW, LoadArena4ColorsBW, LoadArena5ColorsBW, LoadArena6ColorsBW, LoadArena7ColorsBW
          if LACBW_tempIndex < 8 then goto DoneArenaBWColorLoad
          LACBW_tempIndex = LACBW_tempIndex - 8
          if LACBW_tempIndex < 8 then on LACBW_tempIndex goto LoadArena8ColorsBW, LoadArena9ColorsBW, LoadArena10ColorsBW, LoadArena11ColorsBW, LoadArena12ColorsBW, LoadArena13ColorsBW, LoadArena14ColorsBW, LoadArena15ColorsBW
DoneArenaBWColorLoad
          return

LoadRandomArena
          rem Select random arena (0-15)
          rem Use frame counter for pseudo-random selection
          let LA_arenaIndex = frame & 15
          goto LoadArenaByIndex

LoadArena0Colors
          pfcolors Arena1ColorsColor
          return
LoadArena1Colors
          pfcolors Arena2ColorsColor
          return
LoadArena2Colors
          pfcolors Arena3ColorsColor
          return
LoadArena3Colors
          pfcolors Arena4ColorsColor
          return
LoadArena4Colors
          pfcolors Arena5ColorsColor
          return
LoadArena5Colors
          pfcolors Arena6ColorsColor
          return
LoadArena6Colors
          pfcolors Arena7ColorsColor
          return
LoadArena7Colors
          pfcolors Arena8ColorsColor
          return
LoadArena8Colors
          pfcolors Arena9ColorsColor
          return
LoadArena9Colors
          pfcolors Arena10ColorsColor
          return
LoadArena10Colors
          pfcolors Arena11ColorsColor
          return
LoadArena11Colors
          pfcolors Arena12ColorsColor
          return
LoadArena12Colors
          pfcolors Arena13ColorsColor
          return
LoadArena13Colors
          pfcolors Arena14ColorsColor
          return
LoadArena14Colors
          pfcolors Arena15ColorsColor
          return
LoadArena15Colors
          pfcolors Arena16ColorsColor
          return

LoadArena0ColorsBW
          pfcolors Arena1ColorsBW
          return
LoadArena1ColorsBW
          pfcolors Arena2ColorsBW
          return
LoadArena2ColorsBW
          pfcolors Arena3ColorsBW
          return
LoadArena3ColorsBW
          pfcolors Arena4ColorsBW
          return
LoadArena4ColorsBW
          pfcolors Arena5ColorsBW
          return
LoadArena5ColorsBW
          pfcolors Arena6ColorsBW
          return
LoadArena6ColorsBW
          pfcolors Arena7ColorsBW
          return
LoadArena7ColorsBW
          pfcolors Arena8ColorsBW
          return
LoadArena8ColorsBW
          pfcolors Arena9ColorsBW
          return
LoadArena9ColorsBW
          pfcolors Arena10ColorsBW
          return
LoadArena10ColorsBW
          pfcolors Arena11ColorsBW
          return
LoadArena11ColorsBW
          pfcolors Arena12ColorsBW
          return
LoadArena12ColorsBW
          pfcolors Arena13ColorsBW
          return
LoadArena13ColorsBW
          pfcolors Arena14ColorsBW
          return
LoadArena14ColorsBW
          pfcolors Arena15ColorsBW
          return
LoadArena15ColorsBW
          pfcolors Arena16ColorsBW
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
          dim RAC_arenaIndex = temp1
          dim RAC_bwMode = temp2
          
          rem Get current arena index
          let RAC_arenaIndex = selectedArena_R
          rem Handle random arena (use stored random selection)
          if RAC_arenaIndex = RandomArena then let RAC_arenaIndex = frame & 15
          
          rem Get B&W mode state
          gosub GetBWModeReload
          
          rem Jump to appropriate color loader based on arena index
          if RAC_arenaIndex < 4 then on RAC_arenaIndex goto ReloadArena0Colors, ReloadArena1Colors, ReloadArena2Colors, ReloadArena3Colors
          if RAC_arenaIndex < 4 then goto DoneArenaColorDispatch
          RAC_arenaIndex = RAC_arenaIndex - 4
          if RAC_arenaIndex < 4 then on RAC_arenaIndex goto ReloadArena4Colors, ReloadArena5Colors, ReloadArena6Colors, ReloadArena7Colors
          if RAC_arenaIndex < 4 then goto DoneArenaColorDispatch
          temp1 = RAC_arenaIndex - 4
          if temp1 < 4 then on temp1 goto ReloadArena8Colors, ReloadArena9Colors, ReloadArena10Colors, ReloadArena11Colors
          if temp1 < 4 then goto DoneArenaColorDispatch
          temp1 = temp1 - 4
          if temp1 < 4 then on temp1 goto ReloadArena12Colors, ReloadArena13Colors, ReloadArena14Colors, ReloadArena15Colors
DoneArenaColorDispatch
          
          rem Default to arena 0 if invalid index
          goto ReloadArena0Colors

GetBWModeReload
          rem Check if B&W mode is active (for reload)
          rem SECAM: Always B&W mode
          #ifdef TV_SECAM
          let RAC_bwMode = 1
          return
          #endif
          
          rem NTSC/PAL: Check switchbw and colorBWOverride
          let RAC_bwMode = switchbw
          if systemFlags & SystemFlagColorBWOverride then let RAC_bwMode = 1
          return

ReloadArena0Colors
          if RAC_bwMode then ReloadArena0ColorsBW
          pfcolors Arena1ColorsColor
          return
ReloadArena0ColorsBW
          pfcolors Arena1ColorsBW
          return

ReloadArena1Colors
          if RAC_bwMode then ReloadArena1ColorsBW
          pfcolors Arena2ColorsColor
          return
ReloadArena1ColorsBW
          pfcolors Arena2ColorsBW
          return

ReloadArena2Colors
          if RAC_bwMode then ReloadArena2ColorsBW
          pfcolors Arena3ColorsColor
          return
ReloadArena2ColorsBW
          pfcolors Arena3ColorsBW
          return

ReloadArena3Colors
          if RAC_bwMode then ReloadArena3ColorsBW
          pfcolors Arena4ColorsColor
          return
ReloadArena3ColorsBW
          pfcolors Arena4ColorsBW
          return

ReloadArena4Colors
          if RAC_bwMode then ReloadArena4ColorsBW
          pfcolors Arena5ColorsColor
          return
ReloadArena4ColorsBW
          pfcolors Arena5ColorsBW
          return

ReloadArena5Colors
          if RAC_bwMode then ReloadArena5ColorsBW
          pfcolors Arena6ColorsColor
          return
ReloadArena5ColorsBW
          pfcolors Arena6ColorsBW
          return

ReloadArena6Colors
          if RAC_bwMode then ReloadArena6ColorsBW
          pfcolors Arena7ColorsColor
          return
ReloadArena6ColorsBW
          pfcolors Arena7ColorsBW
          return

ReloadArena7Colors
          if RAC_bwMode then ReloadArena7ColorsBW
          pfcolors Arena8ColorsColor
          return
ReloadArena7ColorsBW
          pfcolors Arena8ColorsBW
          return

ReloadArena8Colors
          if RAC_bwMode then ReloadArena8ColorsBW
          pfcolors Arena9ColorsColor
          return
ReloadArena8ColorsBW
          pfcolors Arena9ColorsBW
          return

ReloadArena9Colors
          if RAC_bwMode then ReloadArena9ColorsBW
          pfcolors Arena10ColorsColor
          return
ReloadArena9ColorsBW
          pfcolors Arena10ColorsBW
          return

ReloadArena10Colors
          if RAC_bwMode then ReloadArena10ColorsBW
          pfcolors Arena11ColorsColor
          return
ReloadArena10ColorsBW
          pfcolors Arena11ColorsBW
          return

ReloadArena11Colors
          if RAC_bwMode then ReloadArena11ColorsBW
          pfcolors Arena12ColorsColor
          return
ReloadArena11ColorsBW
          pfcolors Arena12ColorsBW
          return

ReloadArena12Colors
          if RAC_bwMode then ReloadArena12ColorsBW
          pfcolors Arena13ColorsColor
          return
ReloadArena12ColorsBW
          pfcolors Arena13ColorsBW
          return

ReloadArena13Colors
          if RAC_bwMode then ReloadArena13ColorsBW
          pfcolors Arena14ColorsColor
          return
ReloadArena13ColorsBW
          pfcolors Arena14ColorsBW
          return

ReloadArena14Colors
          if RAC_bwMode then ReloadArena14ColorsBW
          pfcolors Arena15ColorsColor
          return
ReloadArena14ColorsBW
          pfcolors Arena15ColorsBW
          return

ReloadArena15Colors
          if RAC_bwMode then ReloadArena15ColorsBW
          pfcolors Arena16ColorsColor
          return
ReloadArena15ColorsBW
          pfcolors Arena16ColorsBW
          return

