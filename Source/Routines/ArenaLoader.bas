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
          rem Jump to appropriate arena loader based on index
          if LA_arenaIndex < 8 then on LA_arenaIndex goto LoadArena0, LoadArena1, LoadArena2, LoadArena3, LoadArena4, LoadArena5, LoadArena6, LoadArena7
          if LA_arenaIndex < 8 then goto DoneArenaDispatch
          LA_arenaIndex = LA_arenaIndex - 8
          on LA_arenaIndex goto LoadArena8, LoadArena9, LoadArena10, LoadArena11, LoadArena12, LoadArena13, LoadArena14, LoadArena15
DoneArenaDispatch
          
          rem Default to arena 0 if invalid index
          goto LoadArena0

LoadRandomArena
          rem Select random arena (0-15)
          rem Use frame counter for pseudo-random selection
          let LA_arenaIndex = frame & 15
          goto LoadArenaByIndex

LoadArena0
          rem Load Arena 1: The Pit
          rem Set playfield pointers to Arena1Playfield data
          asm
            lda #<Arena1Playfield
              sta PF1pointer
            lda #>Arena1Playfield
              sta PF1pointer+1
            lda #<Arena1Playfield
              sta PF2pointer
            lda #>Arena1Playfield
              sta PF2pointer+1
          end
          if LA_bwMode then LoadArena0BW
          pfcolors Arena1ColorsColor
          return
LoadArena0BW
          pfcolors Arena1ColorsBW
          return

LoadArena1
          rem Load Arena 2: Battlefield
          asm
            lda #<Arena2Playfield
            sta PF1pointer
          lda #>Arena2Playfield
            sta PF1pointer+1
          lda #<Arena2Playfield
            sta PF2pointer
          lda #>Arena2Playfield
            sta PF2pointer+1
          end
          if LA_bwMode then LoadArena1BW
          pfcolors Arena2ColorsColor
          return
LoadArena1BW
          pfcolors Arena2ColorsBW
          return

LoadArena2
          rem Load Arena 3: King of the Hill
          asm
            lda #<Arena3Playfield
            sta PF1pointer
          lda #>Arena3Playfield
            sta PF1pointer+1
          lda #<Arena3Playfield
            sta PF2pointer
          lda #>Arena3Playfield
            sta PF2pointer+1
          end
          if LA_bwMode then LoadArena2BW
          pfcolors Arena3ColorsColor
          return
LoadArena2BW
          pfcolors Arena3ColorsBW
          return

LoadArena3
          rem Load Arena 4: The Bridge
          asm
            lda #<Arena4Playfield
            sta PF1pointer
          lda #>Arena4Playfield
            sta PF1pointer+1
          lda #<Arena4Playfield
            sta PF2pointer
          lda #>Arena4Playfield
            sta PF2pointer+1
          end
          if LA_bwMode then LoadArena3BW
          pfcolors Arena4ColorsColor
          return
LoadArena3BW
          pfcolors Arena4ColorsBW
          return

LoadArena4
          rem Load Arena 5: Corner Trap
          asm
            lda #<Arena5Playfield
            sta PF1pointer
          lda #>Arena5Playfield
            sta PF1pointer+1
          lda #<Arena5Playfield
            sta PF2pointer
          lda #>Arena5Playfield
            sta PF2pointer+1
          end
          if LA_bwMode then LoadArena4BW
          pfcolors Arena5ColorsColor
          return
LoadArena4BW
          pfcolors Arena5ColorsBW
          return

LoadArena5
          rem Load Arena 6: Multi-Platform
          asm
            lda #<Arena6Playfield
            sta PF1pointer
          lda #>Arena6Playfield
            sta PF1pointer+1
          lda #<Arena6Playfield
            sta PF2pointer
          lda #>Arena6Playfield
            sta PF2pointer+1
          end
          if LA_bwMode then LoadArena5BW
          pfcolors Arena6ColorsColor
          return
LoadArena5BW
          pfcolors Arena6ColorsBW
          return

LoadArena6
          rem Load Arena 7: The Gauntlet
          asm
            lda #<Arena7Playfield
            sta PF1pointer
          lda #>Arena7Playfield
            sta PF1pointer+1
          lda #<Arena7Playfield
            sta PF2pointer
          lda #>Arena7Playfield
            sta PF2pointer+1
          end
          if LA_bwMode then LoadArena6BW
          pfcolors Arena7ColorsColor
          return
LoadArena6BW
          pfcolors Arena7ColorsBW
          return

LoadArena7
          rem Load Arena 8: Scattered Blocks
          asm
            lda #<Arena8Playfield
            sta PF1pointer
          lda #>Arena8Playfield
            sta PF1pointer+1
          lda #<Arena8Playfield
            sta PF2pointer
          lda #>Arena8Playfield
            sta PF2pointer+1
          end
          if LA_bwMode then LoadArena7BW
          pfcolors Arena8ColorsColor
          return
LoadArena7BW
          pfcolors Arena8ColorsBW
          return

LoadArena8
          rem Load Arena 9: The Deep Pit
          asm
            lda #<Arena9Playfield
            sta PF1pointer
          lda #>Arena9Playfield
            sta PF1pointer+1
          lda #<Arena9Playfield
            sta PF2pointer
          lda #>Arena9Playfield
            sta PF2pointer+1
          end
          if LA_bwMode then LoadArena8BW
          pfcolors Arena9ColorsColor
          return
LoadArena8BW
          pfcolors Arena9ColorsBW
          return

LoadArena9
          rem Load Arena 10: Sky Battlefield
          asm
            lda #<Arena10Playfield
            sta PF1pointer
          lda #>Arena10Playfield
            sta PF1pointer+1
          lda #<Arena10Playfield
            sta PF2pointer
          lda #>Arena10Playfield
            sta PF2pointer+1
          end
          if LA_bwMode then LoadArena9BW
          pfcolors Arena10ColorsColor
          return
LoadArena9BW
          pfcolors Arena10ColorsBW
          return

LoadArena10
          rem Load Arena 11: Floating Platforms
          asm
            lda #<Arena11Playfield
            sta PF1pointer
          lda #>Arena11Playfield
            sta PF1pointer+1
          lda #<Arena11Playfield
            sta PF2pointer
          lda #>Arena11Playfield
            sta PF2pointer+1
          end
          if LA_bwMode then LoadArena10BW
          pfcolors Arena11ColorsColor
          return
LoadArena10BW
          pfcolors Arena11ColorsBW
          return

LoadArena11
          rem Load Arena 12: The Chasm
          asm
            lda #<Arena12Playfield
            sta PF1pointer
          lda #>Arena12Playfield
            sta PF1pointer+1
          lda #<Arena12Playfield
            sta PF2pointer
          lda #>Arena12Playfield
            sta PF2pointer+1
          end
          if LA_bwMode then LoadArena11BW
          pfcolors Arena12ColorsColor
          return
LoadArena11BW
          pfcolors Arena12ColorsBW
          return

LoadArena12
          rem Load Arena 13: Fortress Walls
          asm
            lda #<Arena13Playfield
            sta PF1pointer
          lda #>Arena13Playfield
            sta PF1pointer+1
          lda #<Arena13Playfield
            sta PF2pointer
          lda #>Arena13Playfield
            sta PF2pointer+1
          end
          if LA_bwMode then LoadArena12BW
          pfcolors Arena13ColorsColor
          return
LoadArena12BW
          pfcolors Arena13ColorsBW
          return

LoadArena13
          rem Load Arena 14: Floating Islands
          asm
            lda #<Arena14Playfield
            sta PF1pointer
          lda #>Arena14Playfield
            sta PF1pointer+1
          lda #<Arena14Playfield
            sta PF2pointer
          lda #>Arena14Playfield
            sta PF2pointer+1
          end
          if LA_bwMode then LoadArena13BW
          pfcolors Arena14ColorsColor
          return
LoadArena13BW
          pfcolors Arena14ColorsBW
          return

LoadArena14
          rem Load Arena 15: The Labyrinth
          asm
            lda #<Arena15Playfield
            sta PF1pointer
          lda #>Arena15Playfield
            sta PF1pointer+1
          lda #<Arena15Playfield
            sta PF2pointer
          lda #>Arena15Playfield
            sta PF2pointer+1
          end
          if LA_bwMode then LoadArena14BW
          pfcolors Arena15ColorsColor
          return
LoadArena14BW
          pfcolors Arena15ColorsBW
          return

LoadArena15
          rem Load Arena 16: Danger Zone
          asm
            lda #<Arena16Playfield
            sta PF1pointer
          lda #>Arena16Playfield
            sta PF1pointer+1
          lda #<Arena16Playfield
            sta PF2pointer
          lda #>Arena16Playfield
            sta PF2pointer+1
          end
          if LA_bwMode then LoadArena15BW
          pfcolors Arena16ColorsColor
          return
LoadArena15BW
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

