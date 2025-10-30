          rem ChaosFight - Source/Common/Preamble.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem NAMING CONVENTIONS:
          rem - Built-in batariBasic identifiers (temp1-temp6, joy0up, frame, etc.) are lowercase
          rem - User-defined variables and labels use PascalCase (GameState, PlayerX, etc.)
          rem - Do NOT use "dim" for built-in variables - they already exist!
          rem - Built-in variables: temp1-temp6, qtcontroller, joy0up/down/left/right/fire, frame
          rem - TIA registers: player0x, player0y, COLUP0, NUSIZ0, pf0-pf2, etc.
          rem - Our variables: GameState, QuadtariDetected, PlayerX, SelectedChar1, etc.

          include Source/Routines/CharacterArt.s
          includesfile multisprite_superchip.inc

          set kernel multisprite
          set kernel_options playercolors player1colors pfcolors
          set romsize 64kSC
          set optimization size
          set smartbranching on

          #include "Source/Common/Colors.h"
          #include "Source/Common/Constants.bas"
          #include "Source/Common/Macros.bas"
          #include "Source/Common/Variables.bas"
