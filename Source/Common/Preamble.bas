          rem ChaosFight - Source/Common/Preamble.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem NAMING CONVENTIONS:
          rem - Built-in batariBasic identifiers (temp1-temp6, joy0up, frame, etc.) are lowercase
          rem - User-defined variables and labels use PascalCase (GameState, PlayerX, etc.)
          rem - Do NOT use "dim" for built-in variables - they already exist!
          rem - Built-in variables: temp1-temp6, qtcontroller, joy0up/down/left/right/fire, frame
          rem - TIA registers: player0x, player0y, COLUP0, NUSIZ0, pf0-pf2, etc.
          rem - Our variables: GameState, QuadtariDetected, PlayerX, SelectedChar1, etc.

          includesfile multisprite_superchip.inc

          set kernel multisprite
          set kernel_options playercolors player1colors pfcolors
          set romsize 64kSC
          set optimization size
          set smartbranching on

          rem Minimal includes needed before kernel (Bank 1)
          rem Colors.h is needed early for kernel options
          #include "Source/Common/Colors.h"
          
          rem CRITICAL: Switch to Bank 2 early to move large includes out of Bank 1
          rem Bank 1 contains: header, bB.asm (code before first bank>1), kernel, routines
          rem By switching to bank 2 here, Constants/Variables/etc. go to Bank 2 instead
          bank 2
          
          rem Large includes moved to Bank 2 to reduce Bank 1 size
          #include "Source/Common/Constants.bas"
          #include "Source/Common/Enums.bas"
          #include "Source/Common/Macros.bas"
          #include "Source/Common/Variables.bas"
          
          rem Switch back to Bank 1 for kernel and main code
          bank 1
