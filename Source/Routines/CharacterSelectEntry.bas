          rem ChaosFight - Source/Routines/CharacterSelectEntry.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CharacterSelectEntry
          rem Initializes character select screen state
          rem Notes: PlayerLockedHelpers.bas resides in Bank 6
          rem
          rem Input: None (entry point)
          rem
          rem Output: playerCharacter[] initialized, playerLocked
          rem initialized, animation state initialized,
          rem         COLUBK set, Quadtari detection called
          rem
          rem Mutates: playerCharacter[0-3] (set to 0), playerLocked (set to
          rem 0), characterSelectAnimationTimer,
          rem         characterSelectAnimationState, characterSelectCharacterIndex,
          rem         characterSelectAnimationFrame, COLUBK (TIA register)
          rem
          rem Called Routines: CharacterSelectDetectQuadtari - accesses controller
          rem detection state
          rem
          rem Constraints: Entry point for character select screen
          rem initialization
          rem              Per-frame loop is handled by CharacterSelectInputEntry
          rem              (in CharacterSelectMain.bas, called from MainLoop)
          let playerCharacter[0] = 0
          rem Initialize character selections
          let playerCharacter[1] = 0
          let playerCharacter[2] = 0
          let playerCharacter[3] = 0
          let playerLocked = 0
          rem Initialize playerLocked (bit-packed, all unlocked)
          rem NOTE: Do NOT clear controllerStatus flags here - monotonic
          rem   detection (upgrades only)
          rem Controller detection is handled by DetectPads with
          rem   monotonic state machine

          let characterSelectAnimationTimer  = 0
          rem Initialize character select animations
          let characterSelectAnimationState  = 0
          let characterSelectCharacterIndex  = 0
          rem Start with idle animation
          let characterSelectAnimationFrame  = 0
          rem Start with first character

          rem Check for Quadtari adapter (inlined for performance)
          rem CANONICAL QUADTARI DETECTION: Check paddle ports INPT0-3
          rem Require BOTH sides present: Left (INPT0 LOW, INPT1 HIGH) AND Right (INPT2 LOW, INPT3 HIGH)
          if INPT0{7} then goto CharacterSelectQuadtariAbsent
          if !INPT1{7} then goto CharacterSelectQuadtariAbsent
          if INPT2{7} then goto CharacterSelectQuadtariAbsent
          if !INPT3{7} then goto CharacterSelectQuadtariAbsent
          rem All checks passed - Quadtari detected
          let controllerStatus = controllerStatus | SetQuadtariDetected
CharacterSelectQuadtariAbsent

          COLUBK = ColGray(0)
          rem Set background color (B&W safe)
          rem Always black background

          return
          rem Initialization complete - per-frame loop handled by CharacterSelectInputEntry
