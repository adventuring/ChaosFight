          rem ChaosFight - Source/Banks/Bank13.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Input system (movement, player input, guard effects)

          bank 13

#include "Source/Routines/GuardEffects.bas"
#include "Source/Routines/SpritePointerInit.bas"
#include "Source/Routines/ArenaReloadUtils.bas"
#include "Source/Routines/BeginFallingAnimation.bas"
#include "Source/Routines/ConsoleDetection.bas"
#include "Source/Routines/ControllerDetection.bas"
#include "Source/Routines/ChangeGameMode.bas"
#include "Source/Routines/PlayerInput.bas"
#include "Source/Routines/CharacterControlsDown.bas"

