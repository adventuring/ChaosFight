          rem ChaosFight - Source/Common/Preamble.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          set kernel multisprite
          set kernel_options playercolors player1colors pfcolors
          set romsize 4k
          set optimization size
          set smartbranching on
          set optimization noinlinedata
          set optimization inlinerand

          #include "Source/Common/Constants.bas"
          #include "Source/Common/Macros.bas"
          #include "Source/Common/Variables.bas"