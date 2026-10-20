;;; ChaosFight - Source/Banks/Bank0.s
;;; Copyright © 2025 Bruce-Robert Pocock.
;;;
;;; ASSET BANK: Music/Sound Assets (separate memory budget)
;;; Character theme songs (IDs 6-28): LowRes, RoboTito, SongOfTheBear,
;;;   DucksAway, Character16-30 themes

          BANK = 0

          .include "StartBank.s"


Bank0DataStart:

BuildInfoStart:
          .include "BuildInfo.s"
BuildInfoEnd:

SongPointers1Start:
          .include "SongPointers1.s"
SongPointers1End:

LowResSongStart:
          .if TVStandard == NTSC
          .include "Song.LowRes.NTSC.s"
          .else
          .include "Song.LowRes.PAL.s"
          .fi
LowResSongEnd:
            .warn format("// Bank 0: %d bytes = Song.LowRes", [LowResSongEnd - LowResSongStart])
RoboTitoSongStart:

.if TVStandard == NTSC
.include "Song.RoboTito.NTSC.s"
.else
.include "Song.RoboTito.PAL.s"
.fi
RoboTitoSongEnd:
            .warn format("// Bank 0: %d bytes = Song.RoboTito", [RoboTitoSongEnd - RoboTitoSongStart])
SongOfTheBearSongStart:

.if TVStandard == NTSC
.include "Song.SongOfTheBear.NTSC.s"
.else
.include "Song.SongOfTheBear.PAL.s"
.fi
SongOfTheBearSongEnd:
            .warn format("// Bank 0: %d bytes = Song.SongOfTheBear", [SongOfTheBearSongEnd - SongOfTheBearSongStart])
DucksAwaySongStart:

.if TVStandard == NTSC
.include "Song.DucksAway.NTSC.s"
.else
.include "Song.DucksAway.PAL.s"
.fi
DucksAwaySongEnd:
            .warn format("// Bank 0: %d bytes = Song.DucksAway", [DucksAwaySongEnd - DucksAwaySongStart])
Character16ThemeSongStart:

.if TVStandard == NTSC
.include "Song.Character16Theme.NTSC.s"
.else
.include "Song.Character16Theme.PAL.s"
.fi
Character16ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character16Theme", [Character16ThemeSongEnd - Character16ThemeSongStart])
Character17ThemeSongStart:

.if TVStandard == NTSC
.include "Song.Character17Theme.NTSC.s"
.else
.include "Song.Character17Theme.PAL.s"
.fi
Character17ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character17Theme", [Character17ThemeSongEnd - Character17ThemeSongStart])
Character18ThemeSongStart:

.if TVStandard == NTSC
.include "Song.Character18Theme.NTSC.s"
.else
.include "Song.Character18Theme.PAL.s"
.fi
Character18ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character18Theme", [Character18ThemeSongEnd - Character18ThemeSongStart])
Character19ThemeSongStart:

.if TVStandard == NTSC
.include "Song.Character19Theme.NTSC.s"
.else
.include "Song.Character19Theme.PAL.s"
.fi
Character19ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character19Theme", [Character19ThemeSongEnd - Character19ThemeSongStart])
Character20ThemeSongStart:
            ; Removed: program counter . not resolvable in .error

.if TVStandard == NTSC
.include "Song.Character20Theme.NTSC.s"
.else
.include "Song.Character20Theme.PAL.s"
.fi
Character20ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character20Theme", [Character20ThemeSongEnd - Character20ThemeSongStart])
Character21ThemeSongStart:

.if TVStandard == NTSC
.include "Song.Character21Theme.NTSC.s"
.else
.include "Song.Character21Theme.PAL.s"
.fi
Character21ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character21Theme", [Character21ThemeSongEnd - Character21ThemeSongStart])
Character22ThemeSongStart:

.if TVStandard == NTSC
.include "Song.Character22Theme.NTSC.s"
.else
.include "Song.Character22Theme.PAL.s"
.fi
Character22ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character22Theme", [Character22ThemeSongEnd - Character22ThemeSongStart])
Character23ThemeSongStart:

.if TVStandard == NTSC
.include "Song.Character23Theme.NTSC.s"
.else
.include "Song.Character23Theme.PAL.s"
.fi
Character23ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character23Theme", [Character23ThemeSongEnd - Character23ThemeSongStart])
Character24ThemeSongStart:

.if TVStandard == NTSC
.include "Song.Character24Theme.NTSC.s"
.else
.include "Song.Character24Theme.PAL.s"
.fi
Character24ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character24Theme", [Character24ThemeSongEnd - Character24ThemeSongStart])
Character25ThemeSongStart:

.if TVStandard == NTSC
.include "Song.Character25Theme.NTSC.s"
.else
.include "Song.Character25Theme.PAL.s"
.fi
Character25ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character25Theme", [Character25ThemeSongEnd - Character25ThemeSongStart])
Character26ThemeSongStart:

.if TVStandard == NTSC
.include "Song.Character26Theme.NTSC.s"
.else
.include "Song.Character26Theme.PAL.s"
.fi
Character26ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character26Theme", [Character26ThemeSongEnd - Character26ThemeSongStart])
Character27ThemeSongStart:

.if TVStandard == NTSC
.include "Song.Character27Theme.NTSC.s"
.else
.include "Song.Character27Theme.PAL.s"
.fi
Character27ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character27Theme", [Character27ThemeSongEnd - Character27ThemeSongStart])
Character28ThemeSongStart:

.if TVStandard == NTSC
.include "Song.Character28Theme.NTSC.s"
.else
.include "Song.Character28Theme.PAL.s"
.fi
Character28ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character28Theme", [Character28ThemeSongEnd - Character28ThemeSongStart])
Character29ThemeSongStart:

.if TVStandard == NTSC
.include "Song.Character29Theme.NTSC.s"
.else
.include "Song.Character29Theme.PAL.s"
.fi
Character29ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character29Theme", [Character29ThemeSongEnd - Character29ThemeSongStart])
Character30ThemeSongStart:

.if TVStandard == NTSC
.include "Song.Character30Theme.NTSC.s"
.else
.include "Song.Character30Theme.PAL.s"
.fi
Character30ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character30Theme", [Character30ThemeSongEnd - Character30ThemeSongStart])
ChaoticaSongStart:

          ;; Admin screen songs (IDs 26-28)
.if TVStandard == NTSC
.include "Song.Chaotica.NTSC.s"
.else
.include "Song.Chaotica.PAL.s"
.fi
ChaoticaSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Chaotica", [ChaoticaSongEnd - ChaoticaSongStart])
AtariTodaySongStart:

.if TVStandard == NTSC
.include "Song.AtariToday.NTSC.s"
.else
.include "Song.AtariToday.PAL.s"
.fi
AtariTodaySongEnd:
            .warn format("// Bank 0: %d bytes = Song.AtariToday", [AtariTodaySongEnd - AtariTodaySongStart])
InterworldlySongStart:

.if TVStandard == NTSC
.include "Song.Interworldly.NTSC.s"
.else
.include "Song.Interworldly.PAL.s"
.fi
InterworldlySongEnd:
            .warn format("// Bank 0: %d bytes = Song.Interworldly", [InterworldlySongEnd - InterworldlySongStart])
Bank0DataEnds:

MusicBankHelpersStart:
          .include "MusicBankHelpers.s"
MusicBankHelpersEnd:
            .warn format("// Bank 0: %d bytes = MusicBankHelpers", [MusicBankHelpersEnd - MusicBankHelpersStart])
          ;; MusicSystem moved to Bank 14 to fix cross-bank label resolution
Bank0CodeEnds:

          ;; Cold-start shim for Bank 0.  EFSC power-on/reset may leave the
          ;; CPU in Bank 0, whose $F960 was otherwise empty (BRK).  Replicate
          ;; the ColdStart entry here so RESET works regardless of the active
          ;; bank.  Bank-switch to Bank 12 before jumping to WarmStart.
          * = $F950
Bank0ColdStartShim:
          cld
          ldx #$ff
          txs
          lda console7800Detected
          cmp #$00
          beq Bank0ColdStartShimProceed
          cmp #$80
          beq Bank0ColdStartShimProceed
          lda #$00
          sta console7800Detected
Bank0ColdStartShimProceed:
          nop $ffec
          jmp WarmStart

          ;; Include BankSwitching.s in Bank 0
          ;; Wrap in .block to create namespace Bank0BS (avoids duplicate definitions)
Bank0BS: .block
          current_bank = 0
          .include "BankSwitching.s"
          .bend
