          rem ChaosFight - Source/Banks/Bank16.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem
          rem SPECIAL PURPOSE BANK: Arenas + Drawscreen
          rem Main loop, drawscreen, arena data/loader, special sprites, numbers font, font rendering

          bank 16

          asm
            ;; Align Bank 16 data section to $F100 to skip any batariBASIC auto-generated data
            ;; This ensures user data starts at the expected location
            ORG $F100
            RORG $F100
end

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
           echo "// Bank 16: ", [Bank16AfterArenas - ArenaColorsBWStart]d, " bytes = Total Arenas section"
           echo "// Bank 16: ", [Bank16AfterNumbers - Bank16AfterArenas]d, " bytes = Numbers"
           echo "// Bank 16: ", [Bank16AfterPlayerColors - Bank16AfterNumbers]d, " bytes = PlayerColors"
           echo "// Bank 16: ", [Bank16DataEnds - Bank16AfterPlayerColors]d, " bytes = WinnerScreen"
          endif
end

          rem Second — routines locked to that data. Cannot be moved.
          rem Multisprite kernel (contains drawscreen) must be before MainLoop
          rem Note: vblank_bB_code constant will be defined in VblankHandlers.bas after VblankHandlerDispatcher label
          asm
            ORG Bank16DataEnds
            RORG Bank16DataEnds
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
#include "Source/Routines/VblankHandlerTrampoline.bas"
          asm
Bank16AfterVblankTrampoline
end
          rem Define vblank_bB_code constant pointing to trampoline
          asm
          ifnconst vblank_bB_code
vblank_bB_code = VblankHandlerTrampoline
          endif
end
#include "Source/Routines/SpriteLoader.bas"
          asm
Bank16AfterSpriteLoader
end
#include "Source/Routines/PlayfieldRead.bas"
          asm
Bank16AfterPlayfieldRead
end
#include "Source/Routines/SetPlayerGlyph.bas"
          asm
Bank16AfterSetPlayerGlyph
end
#include "Source/Routines/DisplayWinScreen.bas"
          rem None of these modules above may be moved to other banks.
          asm
Bank16CodeEnds
           echo "// Bank 16: ", [Bank16AfterMultiSpriteKernel - Bank16DataEnds]d, " bytes = MultiSpriteKernel"
           echo "// Bank 16: ", [Bank16AfterArenaLoader - Bank16AfterMultiSpriteKernel]d, " bytes = ArenaLoader"
           echo "// Bank 16: ", [Bank16AfterLoadArenaByIndex - Bank16AfterArenaLoader]d, " bytes = LoadArenaByIndex"
           echo "// Bank 16: ", [Bank16AfterMainLoop - Bank16AfterLoadArenaByIndex]d, " bytes = MainLoop"
           echo "// Bank 16: ", [Bank16AfterVblankTrampoline - Bank16AfterMainLoop]d, " bytes = VblankHandlerTrampoline"
           echo "// Bank 16: ", [Bank16AfterSpriteLoader - Bank16AfterMainLoop]d, " bytes = SpriteLoader"
           echo "// Bank 16: ", [Bank16AfterPlayfieldRead - Bank16AfterSpriteLoader]d, " bytes = PlayfieldRead"
           echo "// Bank 16: ", [Bank16AfterSetPlayerGlyph - Bank16AfterPlayfieldRead]d, " bytes = SetPlayerGlyph (unified)"
           echo "// Bank 16: ", [Bank16CodeEnds - Bank16AfterSetPlayerGlyph]d, " bytes = DisplayWinScreen"
end
