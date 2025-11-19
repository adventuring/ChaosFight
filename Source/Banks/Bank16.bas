          rem ChaosFight - Source/Banks/Bank16.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem SPECIAL PURPOSE BANK: Arenas + Drawscreen
          rem Main loop, drawscreen, arena data/loader, special sprites, numbers font, font rendering

          bank 16

          rem First — data. Must come first. Cannot be moved.
#include "Source/Data/Arenas.bas"
          asm
Bank16AfterArenas
end

#include "Source/Generated/Numbers.bas"
          asm
Bank16AfterNumbers
end

#include "Source/Data/PlayerColors.bas"
          asm
Bank16AfterPlayerColors
end

#include "Source/Data/WinnerScreen.bas"

          asm
Bank16DataEnds
          echo "Bank 16 module sizes:"
          if Bank16DataEnds > $F100
           echo "  Arenas: ", [Bank16AfterArenas - $F100]d, " bytes"
           echo "  Numbers: ", [Bank16AfterNumbers - Bank16AfterArenas]d, " bytes"
           echo "  PlayerColors: ", [Bank16AfterPlayerColors - Bank16AfterNumbers]d, " bytes"
           echo "  WinnerScreen: ", [Bank16DataEnds - Bank16AfterPlayerColors]d, " bytes"
           echo "  Total data: ", [Bank16DataEnds - $F100]d, " bytes"
          endif
end

          rem Second — routines locked to that data. Cannot be moved.
          rem Multisprite kernel (contains drawscreen) must be before MainLoop
          asm
#include "Source/Common/MultiSpriteKernel.s"
Bank16AfterMultiSpriteKernel
end
#include "Source/Routines/ArenaLoader.bas"
          asm
Bank16AfterArenaLoader
end
#include "Source/Routines/LoadArenaByIndex.bas"
          asm
Bank16AfterLoadArenaByIndex
end
#include "Source/Routines/MainLoop.bas"
          asm
Bank16AfterMainLoop
end
#include "Source/Routines/SpriteLoader.bas"
          asm
Bank16AfterSpriteLoader
end
#include "Source/Routines/PlayfieldRead.bas"
          asm
Bank16AfterPlayfieldRead
end
#include "Source/Routines/CopyGlyphToPlayer.bas"
          asm
Bank16AfterCopyGlyphToPlayer
end
#include "Source/Routines/SetPlayerGlyphFromFont.bas"
          asm
Bank16AfterSetPlayerGlyphFromFont
end
#include "Source/Routines/FontRendering.bas"
          asm
Bank16AfterFontRendering
end
#include "Source/Routines/DisplayWinScreen.bas"
          rem None of these modules above may be moved to other banks.
          asm
Bank16CodeEnds
           echo "Bank 16 code module sizes:"
           echo "  MultiSpriteKernel: ", [Bank16AfterMultiSpriteKernel - Bank16DataEnds]d, " bytes"
           echo "  ArenaLoader: ", [Bank16AfterArenaLoader - Bank16AfterMultiSpriteKernel]d, " bytes"
           echo "  LoadArenaByIndex: ", [Bank16AfterLoadArenaByIndex - Bank16AfterArenaLoader]d, " bytes"
           echo "  MainLoop: ", [Bank16AfterMainLoop - Bank16AfterLoadArenaByIndex]d, " bytes"
           echo "  SpriteLoader: ", [Bank16AfterSpriteLoader - Bank16AfterMainLoop]d, " bytes"
           echo "  PlayfieldRead: ", [Bank16AfterPlayfieldRead - Bank16AfterSpriteLoader]d, " bytes"
           echo "  CopyGlyphToPlayer: ", [Bank16AfterCopyGlyphToPlayer - Bank16AfterPlayfieldRead]d, " bytes"
           echo "  SetPlayerGlyphFromFont: ", [Bank16AfterSetPlayerGlyphFromFont - Bank16AfterCopyGlyphToPlayer]d, " bytes"
           echo "  FontRendering: ", [Bank16AfterFontRendering - Bank16AfterSetPlayerGlyphFromFont]d, " bytes"
           echo "  DisplayWinScreen: ", [Bank16CodeEnds - Bank16AfterFontRendering]d, " bytes"
           echo "  Total code: ", [Bank16CodeEnds - Bank16DataEnds]d, " bytes"
end
