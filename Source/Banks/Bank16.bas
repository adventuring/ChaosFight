          rem ChaosFight - Source/Banks/Bank16.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem SPECIAL PURPOSE BANK: Arenas + Drawscreen
          rem Main loop, drawscreen, arena data/loader, special sprites, numbers font, font rendering

          bank 16

          rem First — data. Must come first. Cannot be moved.
#include "Source/Data/Arenas.bas"
          asm
Bank16AfterArenas = .
end

#include "Source/Generated/Numbers.bas"
          asm
Bank16AfterNumbers = .
end

#include "Source/Data/PlayerColors.bas"
          asm
Bank16AfterPlayerColors = .
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
          else
           echo "  No data in Bank 16 (data starts at $F100)"
          endif
end

          rem Second — routines locked to that data. Cannot be moved.
          rem Multisprite kernel (contains drawscreen) must be before MainLoop
          asm
#include "Source/Common/MultiSpriteKernel.s"
end
#include "Source/Routines/ArenaLoader.bas"
#include "Source/Routines/LoadArenaByIndex.bas"
#include "Source/Routines/PlayfieldRead.bas"
#include "Source/Routines/MainLoop.bas"
#include "Source/Routines/SpriteLoader.bas"
#include "Source/Routines/CopyGlyphToPlayer.bas"
#include "Source/Routines/SetPlayerGlyphFromFont.bas"
#include "Source/Routines/FontRendering.bas"
#include "Source/Routines/DisplayWinScreen.bas"
          rem None of these modules above may be moved to other banks.
          asm
; Bank 16's bankswitching code and vector table
; These MUST be at the end of Bank 16, after Bank16CodeEnds.
; NOTE: The shared 64kSC bankswitch stub, EFSC header, and Reset/IRQ vectors
; are now provided exclusively by `Source/Common/BankSwitching.s` for ALL banks.
; Do not emit an extra ORG/$FFFC vector table here, or it will overwrite
; the per‑bank Reset vectors back to $0000.
Bank16CodeEnds

#include "Source/Common/BankSwitching.s"
end
