          rem ChaosFight - Source/Banks/Bank12.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Character data system (definitions, cycles, falling animation, fall damage) +
          rem Titlescreen graphics and kernel

          bank 12

          rem Titlescreen assets are in Bank 9 - this bank contains only logic

#include "Source/Routines/CharacterData.bas"
#include "Source/Routines/PerformRangedAttack.bas"
#include "Source/Routines/AnimationSystem.bas"
#include "Source/Routines/MissileSystem.bas"
#include "Source/Routines/PlayerElimination.bas"

