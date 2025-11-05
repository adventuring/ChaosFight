          rem ChaosFight - Source/Common/Preamble.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem NAMING CONVENTIONS:
          rem - Built-in batariBasic identifiers (temp1-temp6, joy0up,
          rem   frame, etc.) are lowercase
          rem - User-defined variables: camelCase (gameState, playerX,
          rem   etc.)
          rem - Constants and Enums: PascalCase (MaxCharacter,
          rem   ActionStanding, etc.)
          rem - Labels/Routines: PascalCase (LoadCharacterSprite, etc.)
          rem - Do NOT use "dim" for built-in variables - they already
          rem   exist!
          rem - Built-in variables: temp1-temp6, qtcontroller,
          rem   joy0up/down/left/right/fire, frame
          rem - TIA registers: player0x, player0y, COLUP0, NUSIZ0,
          rem   pf0-pf2, etc.
          rem - Our variables: gameState, playerX, selectedChar1, etc.

          includesfile multisprite_superchip.inc

          set kernel multisprite
          set kernel_options playercolors player1colors pfcolors
          set romsize 64kSC
          set optimization size
          set smartbranching on

#include "Source/Common/Colors.h"
#include "Source/Common/Constants.bas"
#include "Source/Common/Enums.bas"
#include "Source/Common/Macros.bas"
#include "Source/Common/Variables.bas"
