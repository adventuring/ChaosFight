          rem ChaosFight - Source/Common/Preamble.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          set kernel multisprite
          set kernel_options playercolors player1colors pfcolors
          set romsize 64kSC
          set optimization size
          set smartbranching on
          set optimization noinlinedata
          set optimization inlinerand

          #include "Source/Common/Constants.bas"
          #include "Source/Common/Macros.bas"
          #include "Source/Common/Variables.bas"
          #include "Source/Generated/Characters.bas"
          #include "Source/Generated/Playfields.bas"