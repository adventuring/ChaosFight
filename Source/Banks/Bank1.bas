          rem ChaosFight - Source/Banks/Bank1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 1
          
          rem Large includes moved here from Preamble.bas to reduce Bank 1 size
          rem These are placed AFTER the bank 1 statement but still in Bank 1
          rem because "bank 1" is ignored by batariBASIC (everything before "bank 2" goes to Bank 1)
          rem However, moving them here allows the kernel to be processed first
          #include "Source/Common/Constants.bas"
          #include "Source/Common/Enums.bas"
          #include "Source/Common/Macros.bas"
          #include "Source/Common/Variables.bas"
          
          rem Entry point - far goto to ColdStart in Bank 13
          rem ColdStart falls through to MainLoop in same bank
          goto bank13 ColdStart
          
