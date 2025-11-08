          rem ChaosFight - Source/Common/Preamble.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem batariBASIC automatically defines constants like
          rem bankswitch, multisprite,
          rem superchip, etc. based on set kernel and set romsize
          rem commands configured in AssemblyConfig.bas.
          rem These constants are written to 2600basic_variable_redefs.h
          rem which is
          rem included by multispritesuperchipheader.asm before the
          rem ifconst bankswitch check.
          rem pfres (playfield resolution) must be defined manually as
          rem it is not auto-generated.

#include "Source/Common/AssemblyConfig.bas"

#include "Source/Common/Colors.h"
#include "Source/Common/Constants.bas"
#include "Source/Common/Enums.bas"
#include "Source/Common/Macros.bas"
#include "Source/Common/Variables.bas"

          rem Restore batariBASIC base equates so generated assembly resolves var0-var47, pf tables, etc.
          asm
          include "2600basic.h"
          end
