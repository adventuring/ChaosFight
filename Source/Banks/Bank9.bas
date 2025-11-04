          rem ChaosFight - Source/Banks/Bank9.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 9
          
          rem Title sequence and preambles
          rem Grouped together - title screen flow
          rem TitleSequence.bas has been split into separate files below
          #include "Source/Routines/PublisherPreamble.bas"
          #include "Source/Routines/BeginAuthorPrelude.bas"
          #include "Source/Routines/AuthorPreamble.bas"
          #include "Source/Routines/BeginTitleScreen.bas"
          #include "Source/Routines/TitleScreenMain.bas"
          #include "Source/Routines/BeginAttractMode.bas"

          #include "Source/Data/SpecialSprites.bas"

          rem Titlescreen kernel is included in Bank 1 (minikernel for multisprite)
          rem The title screen routines in this bank call it via gosub titledrawscreen bank1


