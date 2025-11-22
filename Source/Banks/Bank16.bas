          rem ChaosFight - Source/Banks/Bank16.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem SPECIAL PURPOSE BANK: Arenas + Drawscreen
          rem Main loop, drawscreen, arena data/loader, special sprites, numbers font, font rendering

          bank 16

          rem First — data. Must come first. Cannot be moved.
#include "Source/Data/Arenas.bas"
          rem Bank16AfterArenas label is defined at end of Arenas.bas

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
          if Bank16DataEnds > $F100
           echo "// Bank 16: ", [ArenaColorsBWEnd - ArenaColorsBWStart]d, " bytes = ArenaColorsBW"
           echo "// Bank 16: ", [BlankPlayfieldEnd - BlankPlayfieldStart]d, " bytes = BlankPlayfield"
           echo "// Bank 16: ", [BlankPlayfieldColorsEnd - BlankPlayfieldColorsStart]d, " bytes = BlankPlayfieldColors"
           echo "// Bank 16: ", [Arena31PlayfieldEnd - Arena0PlayfieldStart]d, " bytes = 32 Arenas (Arena0-31)"
           echo "// Bank 16: ", [Bank16AfterArenas - $F100]d, " bytes = Total Arenas section"
           echo "// Bank 16: ", [Bank16AfterNumbers - Bank16AfterArenas]d, " bytes = Numbers"
           echo "// Bank 16: ", [Bank16AfterPlayerColors - Bank16AfterNumbers]d, " bytes = PlayerColors"
           echo "// Bank 16: ", [Bank16DataEnds - Bank16AfterPlayerColors]d, " bytes = WinnerScreen"
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
           echo "// Bank 16: ", [Bank16AfterMultiSpriteKernel - Bank16DataEnds]d, " bytes = MultiSpriteKernel"
           echo "// Bank 16: ", [Bank16AfterArenaLoader - Bank16AfterMultiSpriteKernel]d, " bytes = ArenaLoader"
           echo "// Bank 16: ", [Bank16AfterLoadArenaByIndex - Bank16AfterArenaLoader]d, " bytes = LoadArenaByIndex"
           echo "// Bank 16: ", [Bank16AfterMainLoop - Bank16AfterLoadArenaByIndex]d, " bytes = MainLoop"
           echo "// Bank 16: ", [Bank16AfterSpriteLoader - Bank16AfterMainLoop]d, " bytes = SpriteLoader"
           echo "// Bank 16: ", [Bank16AfterPlayfieldRead - Bank16AfterSpriteLoader]d, " bytes = PlayfieldRead"
           echo "// Bank 16: ", [Bank16AfterCopyGlyphToPlayer - Bank16AfterPlayfieldRead]d, " bytes = CopyGlyphToPlayer"
           echo "// Bank 16: ", [Bank16AfterSetPlayerGlyphFromFont - Bank16AfterCopyGlyphToPlayer]d, " bytes = SetPlayerGlyphFromFont"
           echo "// Bank 16: ", [Bank16AfterFontRendering - Bank16AfterSetPlayerGlyphFromFont]d, " bytes = FontRendering"
           echo "// Bank 16: ", [Bank16CodeEnds - Bank16AfterFontRendering]d, " bytes = DisplayWinScreen"
end
