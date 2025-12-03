          rem ChaosFight - Source/Routines/DispatchCharacterJump.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

DispatchCharacterJump
          rem Returns: Far (return otherbank) - but uses goto internally, so tail calls don’t add stack
          asm
DispatchCharacterJump

end
          rem Dispatch to character-specific jump function
          rem Returns: Far (return otherbank) - but uses goto internally, so tail calls don’t add stack
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
          rem Tail call: goto instead of gosub to save 2 bytes on stack
          goto StandardJump bank12
DCJ_BernieJump
          rem Tail call: goto instead of gosub to save 2 bytes on stack
          goto BernieJump bank12
DCJ_DragonJump
          rem Tail call: goto instead of gosub to save 2 bytes on stack
          goto DragonOfStormsJump bank12
DCJ_HarpyJump
          rem Tail call: goto instead of gosub to save 2 bytes on stack
          goto HarpyJump bank12
DCJ_FrootyJump
          rem Tail call: goto instead of gosub to save 2 bytes on stack
          goto FrootyJump bank12
DCJ_RoboTitoJump
          rem Tail call: goto instead of gosub to save 2 bytes on stack
          goto RoboTitoJump
