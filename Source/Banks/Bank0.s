;;; ChaosFight - Source/Banks/Bank0.s
;;; Copyright © 2025 Bruce-Robert Pocock.
;;;
;;; ASSET BANK: Music/Sound Assets (separate memory budget)
;;; Character theme songs (IDs 6-28): LowRes, RoboTito, SongOfTheBear,
;;;   DucksAway, Character16-30 themes

          ;; Set file offset for Bank 0 at the top of the file
          .offs (0 * $1000) - $f000  ; Adjust file offset for Bank 0

          ;; "Start of data" is at CPU space $F100 in Bank 0
          ;; Since .rorg $F000 is active, Bank 0 file space $0000-$0FFF maps to CPU $F000-$FFFF
          ;; The scram (256 bytes of $FF) is at file space $0000-$00FF (CPU space $F000-$F0FF)
          ;; "Start of data" is at file space $0100 (CPU space $F100), after the scram
          * = $F000
          .rept 256
          .byte $ff
          .endrept
          * = $F100
          .if * != $F100
              .error "Bank 0: data must start at $F100"
          .fi

          ;; Build Info - Version Tracking And Attribution
          ;; Build date in year.julian format (e.g., 2025.256)
          ;; Game URL: https://interworldly.com/games/ChaosFight
          ;; These strings are embedded in the ROM right up front
          ;; Note: Strings are defined in BuildInfo.s and included with
          ;; include (BASIC statement) so BUILD_DATE_STRING expands correctly
Bank0DataStart:
BuildInfoStart:
          .include "Source/Common/BuildInfo.s"
BuildInfoEnd:
          .warn format("// Bank 0: %d bytes = BuildInfo", [BuildInfoEnd - BuildInfoStart])
SongPointers1Start:

          .include "Source/Data/SongPointers1.s"
SongPointers1End:
            .warn format("// Bank 0: %d bytes = SongPointers1", [SongPointers1End - SongPointers1Start])

          ;; Song Data (Bank 0)
          ;; Song IDs hosted here: Bank0MinSongID-28 (currently 7-28) - character themes plus admin screen music
          ;; Songs 0-Bank14MaxSongID reside in Bank 14

          ;; Character theme songs (IDs Bank0MinSongID-25)

LowResSongStart:
          .if TVStandard == 0
          .include "Source/Generated/Song.LowRes.NTSC.s"
          .else
          .include "Source/Generated/Song.LowRes.PAL.s"
          .fi
LowResSongEnd:
            .warn format("// Bank 0: %d bytes = Song.LowRes", [LowResSongEnd - LowResSongStart])
RoboTitoSongStart:

.if TVStandard == 0
.include "Source/Generated/Song.RoboTito.NTSC.s"
.else
.include "Source/Generated/Song.RoboTito.PAL.s"
.fi
RoboTitoSongEnd:
            .warn format("// Bank 0: %d bytes = Song.RoboTito", [RoboTitoSongEnd - RoboTitoSongStart])
SongOfTheBearSongStart:

.if TVStandard == 0
.include "Source/Generated/Song.SongOfTheBear.NTSC.s"
.else
.include "Source/Generated/Song.SongOfTheBear.PAL.s"
.fi
SongOfTheBearSongEnd:
            .warn format("// Bank 0: %d bytes = Song.SongOfTheBear", [SongOfTheBearSongEnd - SongOfTheBearSongStart])
DucksAwaySongStart:

.if TVStandard == 0
.include "Source/Generated/Song.DucksAway.NTSC.s"
.else
.include "Source/Generated/Song.DucksAway.PAL.s"
.fi
DucksAwaySongEnd:
            .warn format("// Bank 0: %d bytes = Song.DucksAway", [DucksAwaySongEnd - DucksAwaySongStart])
Character16ThemeSongStart:

.if TVStandard == 0
.include "Source/Generated/Song.Character16Theme.NTSC.s"
.else
.include "Source/Generated/Song.Character16Theme.PAL.s"
.fi
Character16ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character16Theme", [Character16ThemeSongEnd - Character16ThemeSongStart])
Character17ThemeSongStart:

.if TVStandard == 0
.include "Source/Generated/Song.Character17Theme.NTSC.s"
.else
.include "Source/Generated/Song.Character17Theme.PAL.s"
.fi
Character17ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character17Theme", [Character17ThemeSongEnd - Character17ThemeSongStart])
Character18ThemeSongStart:

.if TVStandard == 0
.include "Source/Generated/Song.Character18Theme.NTSC.s"
.else
.include "Source/Generated/Song.Character18Theme.PAL.s"
.fi
Character18ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character18Theme", [Character18ThemeSongEnd - Character18ThemeSongStart])
Character19ThemeSongStart:

.if TVStandard == 0
.include "Source/Generated/Song.Character19Theme.NTSC.s"
.else
.include "Source/Generated/Song.Character19Theme.PAL.s"
.fi
Character19ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character19Theme", [Character19ThemeSongEnd - Character19ThemeSongStart])
Character20ThemeSongStart:
            ; Removed: program counter . not resolvable in .error

.if TVStandard == 0
.include "Source/Generated/Song.Character20Theme.NTSC.s"
.else
.include "Source/Generated/Song.Character20Theme.PAL.s"
.fi
Character20ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character20Theme", [Character20ThemeSongEnd - Character20ThemeSongStart])
Character21ThemeSongStart:

.if TVStandard == 0
.include "Source/Generated/Song.Character21Theme.NTSC.s"
.else
.include "Source/Generated/Song.Character21Theme.PAL.s"
.fi
Character21ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character21Theme", [Character21ThemeSongEnd - Character21ThemeSongStart])
Character22ThemeSongStart:

.if TVStandard == 0
.include "Source/Generated/Song.Character22Theme.NTSC.s"
.else
.include "Source/Generated/Song.Character22Theme.PAL.s"
.fi
Character22ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character22Theme", [Character22ThemeSongEnd - Character22ThemeSongStart])
Character23ThemeSongStart:

.if TVStandard == 0
.include "Source/Generated/Song.Character23Theme.NTSC.s"
.else
.include "Source/Generated/Song.Character23Theme.PAL.s"
.fi
Character23ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character23Theme", [Character23ThemeSongEnd - Character23ThemeSongStart])
Character24ThemeSongStart:

.if TVStandard == 0
.include "Source/Generated/Song.Character24Theme.NTSC.s"
.else
.include "Source/Generated/Song.Character24Theme.PAL.s"
.fi
Character24ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character24Theme", [Character24ThemeSongEnd - Character24ThemeSongStart])
Character25ThemeSongStart:

.if TVStandard == 0
.include "Source/Generated/Song.Character25Theme.NTSC.s"
.else
.include "Source/Generated/Song.Character25Theme.PAL.s"
.fi
Character25ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character25Theme", [Character25ThemeSongEnd - Character25ThemeSongStart])
Character26ThemeSongStart:

.if TVStandard == 0
.include "Source/Generated/Song.Character26Theme.NTSC.s"
.else
.include "Source/Generated/Song.Character26Theme.PAL.s"
.fi
Character26ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character26Theme", [Character26ThemeSongEnd - Character26ThemeSongStart])
Character27ThemeSongStart:

.if TVStandard == 0
.include "Source/Generated/Song.Character27Theme.NTSC.s"
.else
.include "Source/Generated/Song.Character27Theme.PAL.s"
.fi
Character27ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character27Theme", [Character27ThemeSongEnd - Character27ThemeSongStart])
Character28ThemeSongStart:

.if TVStandard == 0
.include "Source/Generated/Song.Character28Theme.NTSC.s"
.else
.include "Source/Generated/Song.Character28Theme.PAL.s"
.fi
Character28ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character28Theme", [Character28ThemeSongEnd - Character28ThemeSongStart])
Character29ThemeSongStart:

.if TVStandard == 0
.include "Source/Generated/Song.Character29Theme.NTSC.s"
.else
.include "Source/Generated/Song.Character29Theme.PAL.s"
.fi
Character29ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character29Theme", [Character29ThemeSongEnd - Character29ThemeSongStart])
Character30ThemeSongStart:

.if TVStandard == 0
.include "Source/Generated/Song.Character30Theme.NTSC.s"
.else
.include "Source/Generated/Song.Character30Theme.PAL.s"
.fi
Character30ThemeSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Character30Theme", [Character30ThemeSongEnd - Character30ThemeSongStart])
ChaoticaSongStart:

          ;; Admin screen songs (IDs 26-28)
.if TVStandard == 0
.include "Source/Generated/Song.Chaotica.NTSC.s"
.else
.include "Source/Generated/Song.Chaotica.PAL.s"
.fi
ChaoticaSongEnd:
            .warn format("// Bank 0: %d bytes = Song.Chaotica", [ChaoticaSongEnd - ChaoticaSongStart])
AtariTodaySongStart:

.if TVStandard == 0
.include "Source/Generated/Song.AtariToday.NTSC.s"
.else
.include "Source/Generated/Song.AtariToday.PAL.s"
.fi
AtariTodaySongEnd:
            .warn format("// Bank 0: %d bytes = Song.AtariToday", [AtariTodaySongEnd - AtariTodaySongStart])
InterworldlySongStart:

.if TVStandard == 0
.include "Source/Generated/Song.Interworldly.NTSC.s"
.else
.include "Source/Generated/Song.Interworldly.PAL.s"
.fi
InterworldlySongEnd:
            .warn format("// Bank 0: %d bytes = Song.Interworldly", [InterworldlySongEnd - InterworldlySongStart])
Bank0DataEnds:

MusicBankHelpersStart:
.include "Source/Routines/MusicBankHelpers.s"
MusicBankHelpersEnd:
            .warn format("// Bank 0: %d bytes = MusicBankHelpers", [MusicBankHelpersEnd - MusicBankHelpersStart])
          ;; MusicSystem moved to Bank 14 to fix cross-bank label resolution
Bank0CodeEnds:

          ;; Include BankSwitching.s in Bank 0
          ;; Wrap in .block to create namespace Bank0BS (avoids duplicate definitions)
Bank0BS: .block
          current_bank = 0
          * = $FFE0 - bscode_length
          .include "Source/Common/BankSwitching.s"
          .bend
