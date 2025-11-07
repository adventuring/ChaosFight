          rem ChaosFight - Source/Common/Preamble.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem batariBASIC automatically defines constants like
          rem bankswitch, multisprite,
          rem superchip, etc. based on set kernel and set romsize
          rem commands below.
          rem These constants are written to 2600basic_variable_redefs.h
          rem which is
          rem included by multispritesuperchipheader.asm before the
          rem ifconst bankswitch check.
          rem pfres (playfield resolution) must be defined manually as
          rem it is not auto-generated.

#include "Source/Common/AssemblyConfig.bas"

          rem includesfile must execute before any set statements so batariBASIC
          rem keeps multispritesuperchipheader.asm (which pulls in superchip.h)
          includesfile multisprite_superchip.inc

          set kernel multisprite
          set kernel_options playercolors player1colors pfcolors
          set romsize 64kSC
          set optimization size
          rem Enable smartbranching; filter-smartbranch converts bB v1.9 guards to DASM .if/.else/.endif syntax
          set smartbranching on

#include "Source/Common/Colors.h"
#include "Source/Common/Constants.bas"
#include "Source/Common/Enums.bas"
#include "Source/Common/CharacterDefinitions.bas"
#include "Source/Common/Macros.bas"
#include "Source/Common/Variables.bas"
