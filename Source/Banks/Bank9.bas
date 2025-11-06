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
          
          rem Special movement routines moved from Bank 11
#include "Source/Routines/SpecialMovement.bas"
          
          rem Physics collision detection moved from Bank 8
#include "Source/Routines/PlayerPhysicsCollisions.bas"

          rem Titlescreen kernel is included in Bank 1 (minikernel for
          rem   multisprite)
          rem The title screen routines in this bank call it via gosub
          rem   titledrawscreen bank1


