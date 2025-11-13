          rem ChaosFight - Source/Routines/CharacterSelectHelpers.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

SelectStickLeft
          rem Handle stick-left navigation for the active player
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        playerCharacter[] (global) = browsing selections
          rem Output: playerCharacter[currentPlayer] decremented with wrap
          rem        to MaxCharacter, lock state cleared on wrap
          rem Mutates: playerCharacter[], temp1, temp2, playerLocked (via
          rem        SetPlayerLocked)
          rem Called Routines: SetPlayerLocked (bank6)
          rem Constraints: currentPlayer must be set by caller
          let playerCharacter[currentPlayer] = playerCharacter[currentPlayer] - 1
          if playerCharacter[currentPlayer] > MaxCharacter then let playerCharacter[currentPlayer] = MaxCharacter
          if playerCharacter[currentPlayer] > MaxCharacter then temp1 = currentPlayer : temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked
          return

SelectStickRight
          rem Handle stick-right navigation for the active player
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        playerCharacter[] (global) = browsing selections
          rem Output: playerCharacter[currentPlayer] incremented with wrap
          rem        to 0, lock state cleared on wrap
          rem Mutates: playerCharacter[], temp1, temp2, playerLocked (via
          rem        SetPlayerLocked)
          rem Called Routines: SetPlayerLocked (bank6)
          rem Constraints: currentPlayer must be set by caller
          let playerCharacter[currentPlayer] = playerCharacter[currentPlayer] + 1
          if playerCharacter[currentPlayer] > MaxCharacter then let playerCharacter[currentPlayer] = 0
          if playerCharacter[currentPlayer] > MaxCharacter then temp1 = currentPlayer : temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked
          return

CharacterSelectDetectQuadtari
          rem Detect Quadtari adapter
          rem Detect Quadtari adapter (canonical detection: check paddle
          rem ports INPT0-3)
          rem
          rem Input: INPT0-3 (hardware registers) = paddle port states,
          rem        controllerStatus (global) = controller detection state,
          rem        SetQuadtariDetected (global constant) = Quadtari detection
          rem        flag
          rem
          rem Output: Quadtari detection flag set if adapter detected
          rem
          rem Mutates: controllerStatus (global) = controller detection
          rem state (Quadtari flag set if detected)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Requires BOTH sides present: Left (INPT0 LOW,
          rem INPT1 HIGH) AND Right (INPT2 LOW, INPT3 HIGH). Uses
          rem monotonic merge (OR) to preserve existing capabilities
          rem (upgrades only, never downgrades). If Quadtari was
          rem previously detected, it remains detected
          rem CANONICAL QUADTARI DETECTION: Check paddle ports INPT0-3
          rem Require BOTH sides present: Left (INPT0 LOW, INPT1 HIGH)
          rem   AND Right (INPT2 LOW, INPT3 HIGH)

          rem Check left side: if INPT0 is HIGH then not detected

          if INPT0{7} then goto CharacterSelectQuadtariAbsent
          rem Check left side: if INPT1 is LOW then not detected
          if !INPT1{7} then goto CharacterSelectQuadtariAbsent

          rem Check right side: if INPT2 is HIGH then not detected

          if INPT2{7} then goto CharacterSelectQuadtariAbsent
          rem Check right side: if INPT3 is LOW then not detected
          if !INPT3{7} then goto CharacterSelectQuadtariAbsent

          goto CharacterSelectQuadtariDetected
          rem All checks passed - Quadtari detected

CharacterSelectQuadtariAbsent
          return
          rem Helper: Quadtari not detected in this detection cycle
          rem
          rem Input: None
          rem
          rem Output: No changes (monotonic detection preserves previous
          rem state)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Helper for CharacterSelectDetectQuadtari; only executes when Quadtari
          rem   is absent. Monotonic detection means controllerStatus is never cleared here.
          rem   DetectPads (SELECT handler) is the sole routine that upgrades controller
          rem   status flags.

CharacterSelectQuadtariDetected
          rem Helper: Quadtari detected - set detection flag
          rem
          rem Input: controllerStatus (global) = controller detection
          rem state, SetQuadtariDetected (global constant) = Quadtari
          rem detection flag
          rem
          rem Output: controllerStatus updated with Quadtari detected flag
          rem
          rem Mutates: controllerStatus (global) = controller detection
          rem state (Quadtari flag set)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Helper for CharacterSelectDetectQuadtari; only executes when Quadtari
          rem   is present. Monotonic detection means controllerStatus flag is set and
          rem   remains set.
          let controllerStatus = controllerStatus | SetQuadtariDetected
          return
