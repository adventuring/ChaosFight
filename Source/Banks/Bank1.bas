          rem ChaosFight - Source/Banks/Bank1.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.

          bank 1

          rem
          rem Build Info - Version Tracking And Attribution
          rem Build date in year.julian format (e.g., 2025.256)
          rem Game URL: https://interworldly.com/games/ChaosFight
          rem These strings are embedded in the ROM right up front
          rem Note: Strings are defined in BuildInfo.s and included with
          rem   bare "include" directive (not #include) to avoid C
          rem   preprocessor quoting issues

          asm
          include "../Common/BuildInfo.s"
end

#include "Source/Data/SongPointers1.bas"

          rem Song Data (Bank 1)
          rem Song IDs hosted here: Bank1MinSongID-28 (currently 6-28) - character themes plus admin screen music
          rem Songs 0-Bank15MaxSongID reside in Bank 15

          rem Character theme songs (IDs Bank1MinSongID-25)

#ifdef TV_NTSC
#include "Source/Generated/Song.Bolero.NTSC.bas"
#else
#include "Source/Generated/Song.Bolero.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.LowRes.NTSC.bas"
#else
#include "Source/Generated/Song.LowRes.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.RoboTito.NTSC.bas"
#else
#include "Source/Generated/Song.RoboTito.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.SongOfTheBear.NTSC.bas"
#else
#include "Source/Generated/Song.SongOfTheBear.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.DucksAway.NTSC.bas"
#else
#include "Source/Generated/Song.DucksAway.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.Character16Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character16Theme.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.Character17Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character17Theme.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.Character18Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character18Theme.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.Character19Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character19Theme.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.Character20Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character20Theme.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.Character21Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character21Theme.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.Character22Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character22Theme.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.Character23Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character23Theme.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.Character24Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character24Theme.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.Character25Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character25Theme.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.Character26Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character26Theme.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.Character27Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character27Theme.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.Character28Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character28Theme.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.Character29Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character29Theme.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.Character30Theme.NTSC.bas"
#else
#include "Source/Generated/Song.Character30Theme.PAL.bas"
#endif

          rem Admin screen songs (IDs 26-28)
#ifdef TV_NTSC
#include "Source/Generated/Song.Chaotica.NTSC.bas"
#else
#include "Source/Generated/Song.Chaotica.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.AtariToday.NTSC.bas"
#else
#include "Source/Generated/Song.AtariToday.PAL.bas"
#endif

#ifdef TV_NTSC
#include "Source/Generated/Song.Interworldly.NTSC.bas"
#else
#include "Source/Generated/Song.Interworldly.PAL.bas"
#endif
          
          rem
          rem Music System Code (must follow data)
          rem Music system - dedicated 3.5kiB bank for compiled samples
#include "Source/Routines/MusicSystem.bas"
          
          rem Songs bank helper functions (require bank-local symbols)
#include "Source/Routines/MusicBankHelpers.bas"

          rem Title screen code (data is auto-included by batariBASIC)
TitleScreenThunk
          asm
#include "Source/TitleScreen/asm/titlescreen.s"
            jsr titledrawscreen
end
          return
