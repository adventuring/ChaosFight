          rem ChaosFight - Source/Banks/Bank1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 1
          
          rem Entry point - far goto to ColdStart in Bank 13
          rem ColdStart falls through to MainLoop in same bank
          goto bank13 ColdStart
          
