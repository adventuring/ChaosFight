          rem ChaosFight - Source/Banks/Bank16.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.
          rem
          rem SPECIAL PURPOSE BANK: Arenas + Drawscreen
          rem Main loop, drawscreen, arena data/loader, special sprites, numbers font, font rendering

          bank 16

          rem First — data. Must come first. Cannot be moved.
#include "Source/Data/Arenas.bas"
#include "Source/Data/QuestionMarkSprite.bas"
#include "Source/Data/CPUSprite.bas"
#include "Source/Data/NoSprite.bas"
#include "Source/Generated/Numbers.bas"

          rem Then — general code. must stay in this bank, but
          rem some sections may be vunerable to relocation if needed.
#include "Source/Routines/MainLoop.bas"
#include "Source/Routines/SpriteLoader.bas"
#include "Source/Routines/FontRendering.bas"

