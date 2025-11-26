          rem ChaosFight - Source/Routines/DispatchCharacterJump.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

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
          rem Handle out-of-range characters (>= 32)
          rem Characters 16-30 (unused) and Meth Hound mirror Shamone
          if temp4 >= 32 then goto DCJ_StandardJump
          if temp4 >= 16 then goto DCJ_StandardJump
          if temp4 = CharacterBernie then goto DCJ_BernieJump
          if temp4 = CharacterDragonOfStorms then goto DCJ_DragonJump
          if temp4 = CharacterHarpy then goto DCJ_HarpyJump
          if temp4 = CharacterFrooty then goto DCJ_FrootyJump
          if temp4 = CharacterRoboTito then goto DCJ_RoboTitoJump
DCJ_StandardJump
          gosub StandardJump bank12
          return otherbank
DCJ_BernieJump
          gosub BernieJump bank12
          return otherbank
DCJ_DragonJump
          gosub DragonOfStormsJump bank12
          return otherbank
DCJ_HarpyJump
          gosub HarpyJump bank12
          return otherbank
DCJ_FrootyJump
          gosub FrootyJump bank12
          return otherbank
DCJ_RoboTitoJump
          gosub RoboTitoJump
          return otherbank
