          rem ChaosFight - Source/Banks/Bank16.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 16
          
          rem Data segment (loaded before any routines)
#include "Source/Data/CharacterTables.bas"
#include "Source/Data/SpecialSprites.bas"
#include "Source/Data/Arenas.bas"

          rem MainLoop, drawscreen, arenas, numeric font, and special
          rem sprites must all be in Bank 16 for multisprite EF
          rem bankswitching. Titlescreen graphics and kernel moved to
          rem Bank 9 (only used during title screens)

#include "Source/Common/CharacterDefinitions.bas"
#include "Source/Routines/FontRendering.bas"
#include "Source/Routines/ArenaLoader.bas"
#include "Source/Routines/MainLoop.bas"
game
          rem Entry point jumped to by batariBASIC startup
          rem
          rem Input: None (hardware already reset by startup.asm)
          rem Output: Transfers execution to ColdStart routine
          rem Mutates: None (falls through to banked goto)
          rem Constraints: Must remain in Bank 16 for startup vector
          goto ColdStart bank13
