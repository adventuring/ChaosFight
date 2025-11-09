          rem ChaosFight - Source/Banks/Bank14.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Console handling (detection, controllers, game mode transitions,
          rem   character controls, startup routines)

          bank 14

          rem Routines moved from Bank 1 - not needed for drawscreen
          rem calls
          rem These are called before/after drawscreen, not during it
          
          rem Console detection and handling
#include "Source/Routines/ConsoleDetection.bas"
#include "Source/Routines/ControllerDetection.bas"
          
          rem Game mode transitions
#include "Source/Routines/ChangeGameMode.bas"
          
          rem Player locked helpers
#include "Source/Routines/CharacterControls.bas"
#include "Source/Routines/ArenaReloadUtils.bas"
#include "Source/Routines/SpritePointerInit.bas"
#include "Source/Routines/ColdStart.bas"
#include "Source/Routines/BeginPublisherPrelude.bas"
#include "Source/Routines/PublisherPrelude.bas"
#include "Source/Routines/BeginAuthorPrelude.bas"
#include "Source/Routines/AuthorPrelude.bas"
#include "Source/Routines/BeginAttractMode.bas"
#include "Source/Routines/AttractMode.bas"

