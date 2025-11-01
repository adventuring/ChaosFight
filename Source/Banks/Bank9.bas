          rem ChaosFight - Source/Banks/Bank9.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 9
          
          rem Title sequence and preambles (moved from Bank 1)
          rem Grouped together - title screen flow
          #include "Source/Routines/TitleSequence.bas"
          #include "Source/Routines/PublisherPreamble.bas"
          #include "Source/Routines/AuthorPreamble.bas"
          #include "Source/Routines/TitleScreenMain.bas"
          
          rem Sound system (moved from Bank 1 to reduce overflow)
          #include "Source/Routines/SoundSystem.bas"
          
          rem Special sprites data (moved from Bank 1)
          rem Grouped with sprite-related code
          #include "Source/Data/SpecialSprites.bas"
          
          rem Character artwork location system (assembly)
          rem Note: This is included via .include in assembly, not #include
          rem The actual include is in Source/Common/AssemblyFooter.s

