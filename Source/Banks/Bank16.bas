          rem ChaosFight - Source/Banks/Bank16.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem SPECIAL PURPOSE BANK: Arenas + Drawscreen
          rem Main loop, drawscreen, arena data/loader, special sprites, numbers font, font rendering


          rem First — data. Must come first. Cannot be moved.
#include "Source/Data/Arenas.bas"
#include "Source/Generated/Numbers.bas"
#include "Source/Data/PlayerColors.bas"

Bank16DataEnds

          rem Second — routines locked to that data. Cannot be moved.
#include "Source/Routines/ArenaLoader.bas"
#include "Source/Routines/LoadArenaByIndex.bas"
#include "Source/Routines/MainLoop.bas"
#include "Source/Routines/SpriteLoader.bas"
#include "Source/Routines/CopyGlyphToPlayer.bas"
#include "Source/Routines/SetPlayerGlyphFromFont.bas"
#include "Source/Routines/FontRendering.bas"
          rem None of these modules above may be moved to other banks.
Bank16CodeEnds
