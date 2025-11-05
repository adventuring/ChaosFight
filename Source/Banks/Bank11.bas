          rem ChaosFight - Source/Banks/Bank11.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 11

          rem Game loop main routines
          #include "Source/Routines/GameLoopInit.bas"
          #include "Source/Routines/GameLoopMain.bas"
          
          rem Gameplay subsystems called from GameLoopMain
          #include "Source/Routines/Combat.bas"
          #include "Source/Routines/CharacterAttacks.bas"
          rem CharacterAttacks must be included before PlayerInput
          rem   (which uses on-goto to call attack routines)
          #include "Source/Routines/PlayerInput.bas"
          #include "Source/Routines/AnimationSystem.bas"
          #include "Source/Routines/MovementSystem.bas"
          #include "Source/Routines/PlayerPhysics.bas"
          #include "Source/Routines/SpecialMovement.bas"
          #include "Source/Routines/PlayerRendering.bas"
          #include "Source/Routines/ConsoleHandling.bas"
          #include "Source/Routines/UpdateAttackCooldowns.bas"
