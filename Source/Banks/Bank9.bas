          rem ChaosFight - Source/Banks/Bank9.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.

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
#include "Source/Routines/PlayerLockedHelpers.bas"
#include "Source/Routines/CharacterAttacks.bas"
#include "Source/Routines/PerformMeleeAttack.bas"
#include "Source/Routines/PerformRangedAttack.bas"

          rem Moved from Bank 11 for space optimization
#include "Source/Routines/CheckRoboTitoStretchMissileCollisions.bas"


