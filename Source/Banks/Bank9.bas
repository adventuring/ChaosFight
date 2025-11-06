          rem ChaosFight - Source/Banks/Bank9.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 9
          
          rem Title sequence and preludes
          rem Grouped together - title screen flow
          rem TitleSequence.bas has been split into separate files below
#include "Source/Routines/BeginPublisherPrelude.bas"
#include "Source/Routines/PublisherPrelude.bas"
#include "Source/Routines/BeginAuthorPrelude.bas"
#include "Source/Routines/AuthorPrelude.bas"
#include "Source/Routines/BeginTitleScreen.bas"
#include "Source/Routines/TitleScreenMain.bas"
#include "Source/Routines/TitleScreenRender.bas"
#include "Source/Routines/TitleCharacterParade.bas"
#include "Source/Routines/BeginAttractMode.bas"
#include "Source/Routines/AttractMode.bas"
          
          rem Special movement routines moved from Bank 11
#include "Source/Routines/SpecialMovement.bas"
          
          rem Physics collision detection moved from Bank 8
#include "Source/Routines/PlayerPhysicsCollisions.bas"

          rem Titlescreen kernel is included in Bank 14 (minikernel for
          rem   multisprite, same bank as MainLoop and drawscreen)
          rem The title screen routines in this bank call it via gosub
          rem   titledrawscreen bank14


