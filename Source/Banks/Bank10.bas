          rem ChaosFight - Source/Banks/Bank10.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 10
          
          rem Character selection (moved from Bank 1 to reduce overflow)
          rem Grouped with sprite loading to minimize bank switches
          #include "Source/Routines/CharacterSelectMain.bas"
          
          rem Sprite loading system (moved from Bank 1 to reduce overflow)
          rem Grouped with character selection since they work together
          #include "Source/Routines/SpriteLoader.bas"
          
          rem Character art location wrapper with bank switching
          #include "Source/Routines/SpriteLoaderCharacterArt.bas"


          rem Grouped with sprite loading to minimize bank switches
          #include "Source/Routines/CharacterSelectMain.bas"
          
          rem Sprite loading system (moved from Bank 1 to reduce overflow)
          rem Grouped with character selection since they work together
          #include "Source/Routines/SpriteLoader.bas"
          
          rem Character art location wrapper with bank switching
          #include "Source/Routines/SpriteLoaderCharacterArt.bas"

