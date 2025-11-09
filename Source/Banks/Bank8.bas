          rem ChaosFight - Source/Banks/Bank8.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Physics system (gravity, movement, special abilities) + screen layout +
          rem   health bars

          bank 8
 
          rem Data segment
#include "Source/Data/HealthBarPatterns.bas"

          rem NOTE: VisualEffects.bas was phased out - damage indicators
          rem   now handled in Combat.bas and MissileSystem.bas
#include "Source/Routines/ScreenLayout.bas"
#include "Source/Routines/HealthBarSystem.bas"
          
          rem Physics and rendering routines moved from Bank 11
          rem PlayerPhysics.bas split into two files to reduce bank size
          rem Collision handling colocated with gravity/rendering for
          rem   tighter coupling
          rem AnimationSystem.bas moved to Bank 11 (character
          rem animations)
          rem PlayerRendering.bas moved to Bank 10 (sprite rendering)
#include "Source/Routines/PlayerLockedHelpers.bas"
#include "Source/Routines/CharacterAttacks.bas"

