          rem ChaosFight - Source/Banks/Bank1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem ASSET BANK: Music/Sound Assets (separate memory budget)
          rem Character theme songs (IDs 6-28): LowRes, RoboTito, SongOfTheBear,
          rem   DucksAway, Character16-30 themes

          bank 1
          asm
            ;; "Start of data" is at CPU space $F100 in Bank 1
            ;; Since RORG $F000 is active, Bank 1 file space $0000-$0FFF maps to CPU $F000-$FFFF
            ;; The scram (256 bytes of $FF) is at file space $0000-$00FF (CPU space $F000-$F0FF)
            ;; "Start of data" is at file space $0100 (CPU space $F100), after the scram
            if . != $F100
                err
            endif
end

          rem
          rem Build Info - Version Tracking And Attribution
          rem Build date in year.julian format (e.g., 2025.256)
          rem Game URL: https://interworldly.com/games/ChaosFight
          rem These strings are embedded in the ROM right up front
          rem Note: Strings are defined in BuildInfo.s and included with
          rem   include (BASIC statement) so BUILD_DATE_STRING expands correctly
          asm
Bank1DataStart
            ; Removed: program counter . not resolvable in echo
BuildInfoStart
end
          include "Source/Common/BuildInfo.s"
          asm
BuildInfoEnd
            echo "// Bank 1: ", [BuildInfoEnd - BuildInfoStart]d, " bytes = BuildInfo"
SongPointers1Start
end

#include "Source/Data/SongPointers1.bas"
          asm
SongPointers1End
            echo "// Bank 1: ", [SongPointers1End - SongPointers1Start]d, " bytes = SongPointers1"
end

          rem Song Data (Bank 1)
          rem Song IDs hosted here: Bank1MinSongID-28 (currently 7-28) - character themes plus admin screen music
          rem Songs 0-Bank15MaxSongID reside in Bank 15

          rem Character theme songs (IDs Bank1MinSongID-25)

          asm
LowResSongStart
end
#ifdef TV_NTSC
#include "Source/Generated/Song.LowRes.NTSC.bas"
#else
#include "Source/Generated/Song.LowRes.PAL.bas"
#endif
          asm
LowResSongEnd
            echo "// Bank 1: ", [LowResSongEnd - LowResSongStart]d, " bytes = Song.LowRes"
RoboTitoSongStart
end

#ifdef TV_NTSC
#include "Source/Generated/Song.RoboTito.NTSC.bas"
#else
#include "Source/Generated/Song.RoboTito.PAL.bas"
#endif
          asm
RoboTitoSongEnd
            echo "// Bank 1: ", [RoboTitoSongEnd - RoboTitoSongStart]d, " bytes = Song.RoboTito"
SongOfTheBearSongStart
end

#ifdef TV_NTSC
#include "Source/Generated/Song.SongOfTheBear.NTSC.bas"
#else
#include "Source/Generated/Song.SongOfTheBear.PAL.bas"
#endif
          asm
SongOfTheBearSongEnd
            echo "// Bank 1: ", [SongOfTheBearSongEnd - SongOfTheBearSongStart]d, " bytes = Song.SongOfTheBear"
DucksAwaySongStart
end

#ifdef TV_NTSC
#include "Source/Generated/Song.DucksAway.NTSC.bas"
#else
#include "Source/Generated/Song.DucksAway.PAL.bas"
#endif
          asm
DucksAwaySongEnd
            echo "// Bank 1: ", [DucksAwaySongEnd - DucksAwaySongStart]d, " bytes = Song.DucksAway"
Character16ThemeSongStart
end

#ifdef TV_NTSC
#include "Source/Generated/Song.Character16Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character16Theme.PAL.bas"
#endif
          asm
Character16ThemeSongEnd
            echo "// Bank 1: ", [Character16ThemeSongEnd - Character16ThemeSongStart]d, " bytes = Song.Character16Theme"
Character17ThemeSongStart
end

#ifdef TV_NTSC
#include "Source/Generated/Song.Character17Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character17Theme.PAL.bas"
#endif
          asm
Character17ThemeSongEnd
            echo "// Bank 1: ", [Character17ThemeSongEnd - Character17ThemeSongStart]d, " bytes = Song.Character17Theme"
Character18ThemeSongStart
end

#ifdef TV_NTSC
#include "Source/Generated/Song.Character18Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character18Theme.PAL.bas"
#endif
          asm
Character18ThemeSongEnd
            echo "// Bank 1: ", [Character18ThemeSongEnd - Character18ThemeSongStart]d, " bytes = Song.Character18Theme"
Character19ThemeSongStart
end

#ifdef TV_NTSC
#include "Source/Generated/Song.Character19Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character19Theme.PAL.bas"
#endif
          asm
Character19ThemeSongEnd
            echo "// Bank 1: ", [Character19ThemeSongEnd - Character19ThemeSongStart]d, " bytes = Song.Character19Theme"
Character20ThemeSongStart
            ; Removed: program counter . not resolvable in echo
end

#ifdef TV_NTSC
#include "Source/Generated/Song.Character20Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character20Theme.PAL.bas"
#endif
          asm
Character20ThemeSongEnd
            echo "// Bank 1: ", [Character20ThemeSongEnd - Character20ThemeSongStart]d, " bytes = Song.Character20Theme"
Character21ThemeSongStart
end

#ifdef TV_NTSC
#include "Source/Generated/Song.Character21Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character21Theme.PAL.bas"
#endif
          asm
Character21ThemeSongEnd
            echo "// Bank 1: ", [Character21ThemeSongEnd - Character21ThemeSongStart]d, " bytes = Song.Character21Theme"
Character22ThemeSongStart
end

#ifdef TV_NTSC
#include "Source/Generated/Song.Character22Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character22Theme.PAL.bas"
#endif
          asm
Character22ThemeSongEnd
            echo "// Bank 1: ", [Character22ThemeSongEnd - Character22ThemeSongStart]d, " bytes = Song.Character22Theme"
Character23ThemeSongStart
end

#ifdef TV_NTSC
#include "Source/Generated/Song.Character23Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character23Theme.PAL.bas"
#endif
          asm
Character23ThemeSongEnd
            echo "// Bank 1: ", [Character23ThemeSongEnd - Character23ThemeSongStart]d, " bytes = Song.Character23Theme"
Character24ThemeSongStart
end

#ifdef TV_NTSC
#include "Source/Generated/Song.Character24Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character24Theme.PAL.bas"
#endif
          asm
Character24ThemeSongEnd
            echo "// Bank 1: ", [Character24ThemeSongEnd - Character24ThemeSongStart]d, " bytes = Song.Character24Theme"
Character25ThemeSongStart
end

#ifdef TV_NTSC
#include "Source/Generated/Song.Character25Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character25Theme.PAL.bas"
#endif
          asm
Character25ThemeSongEnd
            echo "// Bank 1: ", [Character25ThemeSongEnd - Character25ThemeSongStart]d, " bytes = Song.Character25Theme"
Character26ThemeSongStart
end

#ifdef TV_NTSC
#include "Source/Generated/Song.Character26Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character26Theme.PAL.bas"
#endif
          asm
Character26ThemeSongEnd
            echo "// Bank 1: ", [Character26ThemeSongEnd - Character26ThemeSongStart]d, " bytes = Song.Character26Theme"
Character27ThemeSongStart
end

#ifdef TV_NTSC
#include "Source/Generated/Song.Character27Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character27Theme.PAL.bas"
#endif
          asm
Character27ThemeSongEnd
            echo "// Bank 1: ", [Character27ThemeSongEnd - Character27ThemeSongStart]d, " bytes = Song.Character27Theme"
Character28ThemeSongStart
end

#ifdef TV_NTSC
#include "Source/Generated/Song.Character28Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character28Theme.PAL.bas"
#endif
          asm
Character28ThemeSongEnd
            echo "// Bank 1: ", [Character28ThemeSongEnd - Character28ThemeSongStart]d, " bytes = Song.Character28Theme"
Character29ThemeSongStart
end

#ifdef TV_NTSC
#include "Source/Generated/Song.Character29Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character29Theme.PAL.bas"
#endif
          asm
Character29ThemeSongEnd
            echo "// Bank 1: ", [Character29ThemeSongEnd - Character29ThemeSongStart]d, " bytes = Song.Character29Theme"
Character30ThemeSongStart
end

#ifdef TV_NTSC
#include "Source/Generated/Song.Character30Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character30Theme.PAL.bas"
#endif
          asm
Character30ThemeSongEnd
            echo "// Bank 1: ", [Character30ThemeSongEnd - Character30ThemeSongStart]d, " bytes = Song.Character30Theme"
ChaoticaSongStart
end

          rem Admin screen songs (IDs 26-28)
#ifdef TV_NTSC
#include "Source/Generated/Song.Chaotica.NTSC.bas"
#else
#include "Source/Generated/Song.Chaotica.PAL.bas"
#endif
          asm
ChaoticaSongEnd
            echo "// Bank 1: ", [ChaoticaSongEnd - ChaoticaSongStart]d, " bytes = Song.Chaotica"
AtariTodaySongStart
end

#ifdef TV_NTSC
#include "Source/Generated/Song.AtariToday.NTSC.bas"
#else
#include "Source/Generated/Song.AtariToday.PAL.bas"
#endif
          asm
AtariTodaySongEnd
            echo "// Bank 1: ", [AtariTodaySongEnd - AtariTodaySongStart]d, " bytes = Song.AtariToday"
InterworldlySongStart
end

#ifdef TV_NTSC
#include "Source/Generated/Song.Interworldly.NTSC.bas"
#else
#include "Source/Generated/Song.Interworldly.PAL.bas"
#endif
          asm
InterworldlySongEnd
            echo "// Bank 1: ", [InterworldlySongEnd - InterworldlySongStart]d, " bytes = Song.Interworldly"
Bank1DataEnds
end

          asm
MusicBankHelpersStart
end
#include "Source/Routines/MusicBankHelpers.bas"
          asm
MusicBankHelpersEnd
            echo "// Bank 1: ", [MusicBankHelpersEnd - MusicBankHelpersStart]d, " bytes = MusicBankHelpers"
end
          rem MusicSystem moved to Bank 15 to fix cross-bank label resolution
          rem (Bank 14 calls Bank 15 = forward reference, works with DASM)
          asm
Bank1CodeEnds
end
