          rem ChaosFight - Source/Routines/StandardGuard.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

StandardGuard
          rem Returns: Far (return otherbank)
          asm
StandardGuard = .StandardGuard
end

          rem Standard guard behavior
          rem
          rem INPUT: temp1 = player index
          rem USES: playerState[temp1], playerTimers[temp1]
          rem Used by: Bernie, Curler, Zoe Ryen, Fat Tony, Megax, Knight Guy,
          rem   Nefertem, Ninjish Guy, Pork Chop, Radish Goblin, Ursulo,
          rem   Shamone, MethHound, and placeholder characters (16-30)
          rem NOTE: Flying characters (Frooty, Dragon of Storms, Harpy)
          rem   cannot guard
          rem Standard guard behavior used by most characters (blocks
          rem attacks, forces cyan guard tint)
          rem
          rem Input: temp1 = player index (0-3), playerCharacter[] (global
          rem array) = character types
          rem
          rem Output: Guard activated if allowed (not flying character,
          rem not in cooldown)
          rem
          rem Mutates: temp1-temp4 (used for calculations),
          rem playerState[], playerTimers[] (global arrays) = player
          rem states and timers (via StartGuard)
          rem
          rem Called Routines: CheckGuardCooldown (bank6) - checks
          rem guard cooldown, StartGuard (bank6) - activates guard
          rem
          rem Constraints: Flying characters (Frooty=8, Dragon of
          rem Storms=2, Harpy=6) cannot guard. Guard blocked if in
          rem cooldown
          rem Flying characters cannot guard - DOWN is used for vertical
          rem   movement
          rem Frooty (8): DOWN = fly down (no gravity)
          rem Dragon of Storms (2): DOWN = fly down (no gravity)
          rem Harpy (6): DOWN = fly down (reduced gravity)
          let temp4 = playerCharacter[temp1]

          if temp4 = CharacterFrooty then return otherbank

          if temp4 = CharacterDragonOfStorms then return otherbank

          if temp4 = CharacterHarpy then return otherbank



          rem Check if guard is allowed (not in cooldown)

          gosub CheckGuardCooldown bank6

          rem Guard blocked by cooldown

          if temp2 = 0 then return otherbank



          rem Activate guard state - inlined (StartGuard)

          rem Set guard bit in playerState

          let playerState[temp1] = playerState[temp1] | 2

          rem Set guard duration timer

          let playerTimers_W[temp1] = GuardTimerMaxFrames

          return otherbank

