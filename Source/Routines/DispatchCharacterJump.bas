          rem ChaosFight - Source/Routines/DispatchCharacterJump.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

DispatchCharacterJump
          asm
DispatchCharacterJump

end
          rem Dispatch to character-specific jump function
          rem
          rem Input: temp1 = player index (0-3), temp4 = character index (0-31)
          rem
          rem Output: Character-specific jump executed
          rem
          rem Mutates: temp1 (passed to jump functions), temp4 (character index)
          rem
          rem Called Routines: Character-specific jump functions in bank12
          rem
          rem Constraints: Must be in Bank 10. Jump functions are in Bank 12.
          rem Handle special case: CharacterMethHound (31) uses StandardJump
          if temp4 = CharacterMethHound then gosub StandardJump bank12 : return
          rem Handle out-of-range characters (>= 32) - use StandardJump
          if temp4 >= 32 then gosub StandardJump bank12 : return
          rem Handle characters 16-30 (unused slots) - use StandardJump
          if temp4 >= 16 && temp4 <= 30 then gosub StandardJump bank12 : return
          rem Dispatch to character-specific jump function based on character index
          rem Character 0: BernieJump
          if temp4 = 0 then gosub BernieJump bank12 : return
          rem Character 1: StandardJump (Curler)
          if temp4 = 1 then gosub StandardJump bank12 : return
          rem Character 2: DragonOfStormsJump
          if temp4 = 2 then gosub DragonOfStormsJump bank12 : return
          rem Character 3: StandardJump (ZoeRyen - removed wrapper function)
          if temp4 = 3 then gosub StandardJump bank12 : return
          rem Character 4: StandardJump (FatTony - removed wrapper function)
          if temp4 = 4 then gosub StandardJump bank12 : return
          rem Character 5: StandardJump (Megax)
          if temp4 = 5 then gosub StandardJump bank12 : return
          rem Character 6: HarpyJump
          if temp4 = 6 then gosub HarpyJump bank12 : return
          rem Character 7: StandardJump (KnightGuy - removed wrapper function)
          if temp4 = 7 then gosub StandardJump bank12 : return
          rem Character 8: FrootyJump
          if temp4 = 8 then gosub FrootyJump bank12 : return
          rem Character 9: StandardJump (Nefertem)
          if temp4 = 9 then gosub StandardJump bank12 : return
          rem Character 10: StandardJump (NinjishGuy - removed wrapper function)
          if temp4 = 10 then gosub StandardJump bank12 : return
          rem Character 11: StandardJump (PorkChop - removed wrapper function)
          if temp4 = 11 then gosub StandardJump bank12 : return
          rem Character 12: StandardJump (RadishGoblin - removed wrapper function)
          if temp4 = 12 then gosub StandardJump bank12 : return
          rem Character 13: RoboTitoJump
          if temp4 = 13 then gosub RoboTitoJump bank12 : return
          rem Character 14: StandardJump (Ursulo - removed wrapper function)
          if temp4 = 14 then gosub StandardJump bank12 : return
          rem Character 15: StandardJump (Shamone - removed wrapper function)
          if temp4 = 15 then gosub StandardJump bank12 : return
          rem Fallback to StandardJump for any unhandled case
          gosub StandardJump bank12
          return otherbank

