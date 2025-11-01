          rem ChaosFight - Source/Banks/Bank9.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 9
          
          rem Title sequence (moved from Bank 1 to reduce overflow)
          #include "Source/Routines/TitleSequence.bas"
          
          rem Sound system (moved from Bank 1 to reduce overflow)
          #include "Source/Routines/SoundSystem.bas"
          
          rem Character artwork location system (assembly)
          rem Note: This is included via .include in assembly, not #include
          rem The actual include is in Source/Common/AssemblyFooter.s

