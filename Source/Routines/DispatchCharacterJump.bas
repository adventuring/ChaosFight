          rem ChaosFight - Source/Routines/DispatchCharacterJump.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

DispatchCharacterJump
          rem Returns: Near (return thisbank)
          asm
DispatchCharacterJump

end
          rem Dispatch to character-specific jump function
          rem Returns: Near (return thisbank)
          rem
          rem Input: temp1 = player index (0-3), temp4 = character index (0-31)
          rem
          rem Output: Character-specific jump executed
          rem
          rem Mutates: temp1 (passed to jump functions), temp4 (character index)
          rem
          rem Called Routines: Character-specific jump functions in bank12
          rem
          rem Constraints: Now in Bank 8 (same bank as ProcessJumpInput). Jump functions are in Bank 12.
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
          rem CRITICAL: Must use gosub/return, not goto, because ProcessUpAction expects return
          gosub StandardJump bank12
          return thisbank
DCJ_BernieJump
          rem CRITICAL: Must use gosub/return, not goto, because ProcessUpAction expects return
          gosub BernieJump bank12
          return thisbank
DCJ_DragonJump
          rem CRITICAL: Must use gosub/return, not goto, because ProcessUpAction expects return
          gosub DragonOfStormsJump bank12
          return thisbank
DCJ_HarpyJump
          rem CRITICAL: Must use gosub/return, not goto, because ProcessUpAction expects return
          gosub HarpyJump bank12
          return thisbank
DCJ_FrootyJump
          rem CRITICAL: Must use gosub/return, not goto, because ProcessUpAction expects return
          gosub FrootyJump bank12
          return thisbank
DCJ_RoboTitoJump
          rem CRITICAL: Must use gosub/return, not goto, because ProcessUpAction expects return
          gosub RoboTitoJump
          return thisbank
