          rem ChaosFight - Source/Routines/BeginTitleScreen.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Setup routine for Title Screen. Sets initial state only.

BeginTitleScreen
          rem Initialize Title Screen mode
          rem Note: pfres is defined globally in AssemblyConfig.bas
          
          rem Initialize title parade state
          let titleParadeTimer = 0
          let titleParadeActive = 0
          
          rem Set background color
          COLUBK = ColGray(0)
          
          rem Start Chaotica title music
          let temp1 = MusicChaotica
          gosub StartMusic bank16
          
          rem Set window values for Title screen (ChaosFight only)
          gosub SetTitleWindowValues bank12
          
          rem Note: Bitmap data is loaded automatically by titlescreen
          rem   kernel via includes
          
          return
