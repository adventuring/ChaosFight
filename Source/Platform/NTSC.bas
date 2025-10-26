          rem ChaosFight - Source/Platform/NTSC.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          #define TV_NTSC
          #include "Source/Common/Colors.h"

          const TVStandard = NTSC
          set tv ntsc

          include bankswitch.inc

          #include "Source/Common/Preamble.bas"
          #include "Source/Banks/Banks.bas"