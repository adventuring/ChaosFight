          rem ChaosFight - Source/Banks/Bank1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 1

          rem MainLoop, drawscreen, arenas, numeric font, and special sprites
          rem must all be in Bank 1 for EF bankswitching (kernel is in Bank 1)
          rem Titlescreen graphics and kernel moved to Bank 9 (only used during title screens)
          
          rem Special sprites and numeric font
#include "Source/Data/SpecialSprites.bas"
#include "Source/Routines/FontRendering.bas"

          rem Arena data (includes playfield and pfcolors data)
          rem Needed for drawscreen playfield rendering
#include "Source/Routines/ArenaLoader.bas"
          
          rem Main loop and drawscreen
          rem MainLoop calls drawscreen, must be in same bank as kernel
#include "Source/Routines/MainLoop.bas"

          goto ColdStart bank13

