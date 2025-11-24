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
          rem Mutates: playerCharacter[0-3] (P1=RandomCharacter, P2=CPUCharacter,
          rem P3/P4=NoCharacter), playerLocked (P2/P3/P4 locked),
          rem characterSelectAnimationTimer,
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
          rem Player 1: RandomCharacter (not locked)
          let playerCharacter[0] = RandomCharacter
          rem Player 2: CPUCharacter (locked)
          let playerCharacter[1] = CPUCharacter
          rem Player 3: NoCharacter (locked)
          let playerCharacter[2] = NoCharacter
          rem Player 4: NoCharacter (locked)
          let playerCharacter[3] = NoCharacter
          rem Initialize playerLocked (bit-packed)
          let playerLocked = 0
          rem Lock Player 2 (CPUCharacter)
          let temp1 = 1 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank6
          rem Lock Player 3 (NoCharacter)
          let temp1 = 2 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank6
          rem Lock Player 4 (NoCharacter)
          let temp1 = 3 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank6
          rem NOTE: Do NOT clear controllerStatus flags here - monotonic
          rem   detection (upgrades only)
          rem Controller detection is handled by DetectPads with
          rem   monotonic state machine

          rem Initialize character select animations
          let characterSelectAnimationTimer  = 0
          let characterSelectAnimationState  = 0
          rem Start with idle animation
          let characterSelectCharacterIndex_W = 0
          rem Start with first character
          let characterSelectAnimationFrame  = 0

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

          rem Set background color (B&W safe)
          rem Always black background
          COLUBK = ColGray(0)

          rem Initialization complete - per-frame loop handled by CharacterSelectInputEntry
          return
