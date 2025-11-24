DispatchCharacterAttack
          asm
DispatchCharacterAttack

end
          rem Dispatch to character-specific attack handler (0-31)
          rem MethHound uses ShamoneAttack handler
          rem Direct cross-bank gotos route to character-specific logic or the
          rem shared PerformMeleeAttack/PerformRangedAttack helpers
          if temp4 >= 32 then return

          rem Characters 0-15: Implemented attacks
          rem Bernie: dual-direction ground thump
          if temp4 = CharacterBernie then goto BernieAttack bank10
          rem Curler: ranged curling stone along ground
          if temp4 = CharacterCurler then goto PerformRangedAttack bank7
          rem Dragon of Storms: ranged ballistic fireball
          if temp4 = CharacterDragonOfStorms then goto PerformRangedAttack bank7
          rem Zoe Ryen: rapid laser blast
          if temp4 = CharacterZoeRyen then goto PerformRangedAttack bank7
          rem Fat Tony: stationary magic ring laser
          if temp4 = CharacterFatTony then goto PerformRangedAttack bank7
          rem Megax: heavy melee breath strike (generic melee tables)
          if temp4 = CharacterMegax then goto PerformMeleeAttack bank7
          rem Harpy: diagonal swoop attack
          if temp4 = CharacterHarpy then goto HarpyAttack bank10
          rem Knight Guy: sword melee swing
          if temp4 = CharacterKnightGuy then goto PerformMeleeAttack bank7
          rem Frooty: ranged sparkle projectile
          if temp4 = CharacterFrooty then goto PerformRangedAttack bank7
          rem Nefertem: melee paw strike
          if temp4 = CharacterNefertem then goto PerformMeleeAttack bank7
          rem Ninjish Guy: ranged shuriken
          if temp4 = CharacterNinjishGuy then goto PerformRangedAttack bank7
          rem Pork Chop: melee
          if temp4 = CharacterPorkChop then goto PerformMeleeAttack bank7
          rem Radish Goblin: melee bite lunge
          if temp4 = CharacterRadishGoblin then goto PerformMeleeAttack bank7
          rem Robo Tito: melee trunk slam
          if temp4 = CharacterRoboTito then goto PerformMeleeAttack bank7
          rem Ursulo: claw swipe with melee tables - inlined (UrsuloAttack)
          if temp4 = CharacterUrsulo then goto PerformMeleeAttack bank7
          rem Shamone: jump + melee special
          if temp4 = CharacterShamone then goto ShamoneAttack bank7

          rem Characters 16-30: Placeholder attacks (basic melee)
          rem Characters 16-30: placeholder melee entries
          if temp4 >= 16 && temp4 <= 30 then goto PerformMeleeAttack bank7

          rem MethHound uses ShamoneAttack handler
          if temp4 = CharacterMethHound then goto ShamoneAttack bank7

          return otherbank

CheckEnhancedJumpButton
          asm
CheckEnhancedJumpButton

end
          rem
          rem Shared Enhanced Button Check
          rem Checks Genesis/Joy2b+ Button C/II for jump input
          rem Only players 1-2 can have enhanced controllers (players 3-4 require Quadtari)
          rem
          rem INPUT: currentPlayer (global) = player index (0-3)
          rem
          rem OUTPUT: temp3 = 1 if jump button pressed, 0 otherwise
          rem Uses: INPT0 for players 0; INPT2 for players 1
          rem Players 2-3 cannot have enhanced controllers
          let temp3 = 0
          rem Initialize to no jump

          rem Only players 0-1 can have enhanced controllers
          rem Players 2-3 (Quadtari players) cannot have enhanced controllers
          if currentPlayer = 0 then CEJB_CheckPlayer0
          if currentPlayer = 1 then CEJB_CheckPlayer2
          rem Players 2-3 skip enhanced controller checks
          goto CEJB_Done
CEJB_CheckPlayer0
          rem Player 0: Check Genesis controller first
          if !controllerStatus{0} then goto CEJB_CheckPlayer0Joy2bPlus
CEJB_ReadButton0
          rem Shared button read for Player 0 enhanced controllers (Button C/II)
          if !INPT0{7} then temp3 = 1
          goto CEJB_Done
CEJB_CheckPlayer0Joy2bPlus
          rem Player 0: Check Joy2b+ controller (fallback)
          if !controllerStatus{1} then CEJB_Done
          goto CEJB_ReadButton0
CEJB_CheckPlayer2
          rem Player 1: Check Genesis controller first
          if (controllerStatus & $04) = 0 then CEJB_CheckPlayer2Joy2bPlus
CEJB_ReadButton2
          rem Shared button read for Player 1 enhanced controllers (Button C/II)
          if (INPT2 & $80) = 0 then temp3 = 1
          goto CEJB_Done
CEJB_CheckPlayer2Joy2bPlus
          rem Player 1: Check Joy2b+ controller (fallback)
          if (controllerStatus & $08) = 0 then CEJB_Done
          goto CEJB_ReadButton2
CEJB_Done
          rem Enhanced jump button check complete
          return otherbank
