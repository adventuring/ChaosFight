          rem ChaosFight - Source/Banks/Bank8.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

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
#include "Source/Routines/PlayerPhysicsGravity.bas"
#include "Source/Routines/PlayerPhysicsCollisions.bas"
#include "Source/Routines/SpecialMovement.bas"
