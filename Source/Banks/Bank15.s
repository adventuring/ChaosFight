;;; ChaosFight - Source/Banks/Bank15.s
;;;Copyright © 2025 Bruce-Robert Pocock.

;;;SPECIAL PURPOSE BANK: Arenas + Drawscreen
;;;Main loop, drawscreen, arena data/loader, special sprites, numbers font, font rendering

          ;; Set file offset for Bank 15 at the top of the file
          .offs (15 * $1000) - $f000  ; Adjust file offset for Bank 15
          * = $F000
          .rept 256
          .byte $ff
          .endrept  ;; Scram shadow (256 bytes of $FF)
          * = $F100

            ;; Align Bank 15:data section to $F100 to skip any batariBASIC auto-generated data
            ;; This ensures user data starts at the expected location
          * = $F100

          ;; First — data. Must come first. Cannot be moved.
.include "Source/Data/Arenas.s"
          ;; Bank15AfterArenas label is defined at end of Arenas.bas

.include "Source/Generated/Numbers.s"
Bank15AfterNumbers:

.include "Source/Data/PlayerColors.s"
Bank15AfterPlayerColors:

.include "Source/Data/WinnerScreen.s"

Bank15DataEnds:
          .if Bank15DataEnds > $F100
           .warn format("// Bank 15: %d bytes = ArenaColorsBW", [ArenaColorsBWEnd - ArenaColorsBWStart])
           .warn format("// Bank 15: %d bytes = BlankPlayfield", [BlankPlayfieldEnd - BlankPlayfieldStart])
           .warn format("// Bank 15: %d bytes = BlankPlayfieldColors", [BlankPlayfieldColorsEnd - BlankPlayfieldColorsStart])
           .warn format("// Bank 15: %d bytes = 32 Arenas (Arena0-31)", [Arena31PlayfieldEnd - Arena0PlayfieldStart])
           .warn format("// Bank 15: %d bytes = Total Arenas section", [Bank15AfterArenas - ArenaColorsBWStart])
           .warn format("// Bank 15: %d bytes = Numbers", [Bank15AfterNumbers - Bank15AfterArenas])
           .warn format("// Bank 15: %d bytes = PlayerColors", [Bank15AfterPlayerColors - Bank15AfterNumbers])
           .warn format("// Bank 15: %d bytes = WinnerScreen", [Bank15DataEnds - Bank15AfterPlayerColors])
          .fi

          ;; Second — routines locked to that data. Cannot be moved.
          ;; Multisprite kernel (contains drawscreen) must be before MainLoop
          ;; Define vblank_bB_code before MultiSpriteKernel.s uses it
vblank_bB_code = VblankHandlerTrampoline
          ;; Note: .offs persists from line 10, no need to reset it when changing *
          * = Bank15DataEnds
.include "Source/Common/MultiSpriteKernel.s"
Bank15AfterMultiSpriteKernel:
.include "Source/Routines/ArenaLoader.s"
Bank15AfterArenaLoader:
.include "Source/Routines/LoadArenaByIndex.s"
Bank15AfterLoadArenaByIndex:
.include "Source/Routines/MainLoop.s"
Bank15AfterMainLoop:
.include "Source/Routines/VblankHandlerTrampoline.s"
Bank15AfterVblankTrampoline:
.include "Source/Routines/SpriteLoader.s"
Bank15AfterSpriteLoader:
.include "Source/Routines/PlayfieldRead.s"
Bank15AfterPlayfieldRead:
.include "Source/Routines/SetPlayerGlyph.s"
Bank15AfterSetPlayerGlyph:
.include "Source/Routines/DisplayWinScreen.s"
          ;; None of these modules above may be moved to other banks.
Bank15CodeEnds:
           .warn format("// Bank 15: %d bytes = MultiSpriteKernel", [Bank15AfterMultiSpriteKernel - Bank15DataEnds])
           .warn format("// Bank 15: %d bytes = ArenaLoader", [Bank15AfterArenaLoader - Bank15AfterMultiSpriteKernel])
           .warn format("// Bank 15: %d bytes = LoadArenaByIndex", [Bank15AfterLoadArenaByIndex - Bank15AfterArenaLoader])
           .warn format("// Bank 15: %d bytes = MainLoop", [Bank15AfterMainLoop - Bank15AfterLoadArenaByIndex])
           .warn format("// Bank 15: %d bytes = VblankHandlerTrampoline", [Bank15AfterVblankTrampoline - Bank15AfterMainLoop])
           .warn format("// Bank 15: %d bytes = SpriteLoader", [Bank15AfterSpriteLoader - Bank15AfterMainLoop])
           .warn format("// Bank 15: %d bytes = PlayfieldRead", [Bank15AfterPlayfieldRead - Bank15AfterSpriteLoader])
           .warn format("// Bank 15: %d bytes = SetPlayerGlyph (unified)", [Bank15AfterSetPlayerGlyph - Bank15AfterPlayfieldRead])
           .warn format("// Bank 15: %d bytes = DisplayWinScreen", [Bank15CodeEnds - Bank15AfterSetPlayerGlyph])

          ;; Include BankSwitching.s in Bank 15
          ;; Wrap in .block to create namespace Bank15BS (avoids duplicate definitions)
Bank15BS: .block
          current_bank = 15
                    ;; Set file offset and CPU address for bankswitch code
          ;; File offset: (15 * $1000) + ($FFE0 - bscode_length - $F000) = $15FC8
          ;; CPU address: $FFE0 - bscode_length = $FFC8
          ;; Use .org to set file offset, then * = to set CPU address
          ;; Code appears at $ECA but should be at $FC8, difference is $FE
          ;; So adjust .org by $FE
          * = $FFE0 - bscode_length
          
          
          .include "Source/Common/BankSwitching.s"
          .bend
