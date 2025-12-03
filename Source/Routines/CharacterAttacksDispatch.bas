DispatchCharacterAttack
          rem Returns: Far (return otherbank)

          asm

DispatchCharacterAttack



end

          rem Dispatch to character-specific attack handler (0-31)
          rem Returns: Far (return otherbank)

          rem MethHound uses ShamoneAttack handler

          rem Direct cross-bank gotos route to character-specific logic

          if temp4 >= 32 then return otherbank



          rem Characters 0-15: Implemented attacks

          rem Bernie: dual-direction ground thump

          if temp4 = CharacterBernie then goto BernieAttack bank10

          rem Curler: ranged curling stone along ground

          if temp4 = CharacterCurler then goto PerformGenericAttack bank7

          rem Dragon of Storms: ranged ballistic fireball

          if temp4 = CharacterDragonOfStorms then goto PerformGenericAttack bank7

          rem Zoe Ryen: rapid laser blast

          if temp4 = CharacterZoeRyen then goto PerformGenericAttack bank7

          rem Fat Tony: stationary magic ring laser

          if temp4 = CharacterFatTony then goto PerformGenericAttack bank7

          rem Megax: heavy mêlée breath strike (generic mêlée tables)

          if temp4 = CharacterMegax then goto PerformGenericAttack bank7

          rem Harpy: diagonal swoop attack

          if temp4 = CharacterHarpy then goto HarpyAttack bank10

          rem Knight Guy: sword mêlée swing

          if temp4 = CharacterKnightGuy then goto PerformGenericAttack bank7

          rem Frooty: charge-and-bounce lollipop projectile (Issue #1177)

          if temp4 = CharacterFrooty then goto FrootyAttack bank8

          rem Nefertem: mêlée paw strike

          if temp4 = CharacterNefertem then goto PerformGenericAttack bank7

          rem Ninjish Guy: ranged shuriken

          if temp4 = CharacterNinjishGuy then goto PerformGenericAttack bank7

          rem Pork Chop: mêlée

          if temp4 = CharacterPorkChop then goto PerformGenericAttack bank7

          rem Radish Goblin: mêlée bite lunge

          if temp4 = CharacterRadishGoblin then goto PerformGenericAttack bank7

          rem Robo Tito: mêlée trunk slam

          if temp4 = CharacterRoboTito then goto PerformGenericAttack bank7

          rem Ursulo: claw swipe with mêlée tables

          if temp4 = CharacterUrsulo then goto UrsuloAttack bank7

          rem Shamone: jump + mêlée special

          if temp4 = CharacterShamone then goto ShamoneAttack bank7



          rem Characters 16-30: Basic mêlée attacks

          if temp4 >= 16 && temp4 <= 30 then goto PerformGenericAttack bank7



          rem MethHound uses ShamoneAttack handler

          if temp4 = CharacterMethHound then goto ShamoneAttack bank7



          return otherbank



CheckEnhancedJumpButton
          rem Returns: Far (return otherbank)

          asm

CheckEnhancedJumpButton



end

          rem
          rem Returns: Far (return otherbank)

          rem Shared Enhanced Button Check

          rem Checks Genesis/Joy2b+ Button C/II for jump input

          rem Only players 1-2 can have enhanced controllers (players 3-4 require Quadtari)

          rem

          rem INPUT: currentPlayer (global) = player index (0-3)

          rem

          rem OUTPUT: temp3 = 1 if jump button pressed, 0 otherwise

          rem Uses: INPT0 for players 0; INPT2 for players 1

          rem Players 2-3 cannot have enhanced controllers

          rem Initialize to no jump

          let temp3 = 0



          rem Only players 0-1 can have enhanced controllers

          rem Players 2-3 (Quadtari players) cannot have enhanced controllers

          if currentPlayer = 0 then CEJB_CheckPlayer0

          rem Players 2-3 skip enhanced controller checks

          if currentPlayer = 1 then CEJB_CheckPlayer2

          goto CEJB_Done

CEJB_CheckPlayer0

          rem Player 0: Check Genesis controller first
          rem Returns: Far (return otherbank)

          if !controllerStatus{0} then goto CEJB_CheckPlayer0Joy2bPlus

CEJB_ReadButton0

          rem Shared button read for Player 0 enhanced controllers (Button C/II)
          rem Returns: Far (return otherbank)

          if !INPT0{7} then let temp3 = 1

          goto CEJB_Done

CEJB_CheckPlayer0Joy2bPlus

          rem Player 0: Check Joy2b+ controller (fallback)
          rem Returns: Far (return otherbank)

          if !controllerStatus{1} then CEJB_Done

          goto CEJB_ReadButton0

CEJB_CheckPlayer2

          rem Player 1: Check Genesis controller first
          rem Returns: Far (return otherbank)

          if (controllerStatus & $04) = 0 then CEJB_CheckPlayer2Joy2bPlus

CEJB_ReadButton2

          rem Shared button read for Player 1 enhanced controllers (Button C/II)
          rem Returns: Far (return otherbank)

          if (INPT2 & $80) = 0 then let temp3 = 1

          goto CEJB_Done

CEJB_CheckPlayer2Joy2bPlus

          rem Player 1: Check Joy2b+ controller (fallback)
          rem Returns: Far (return otherbank)

          if (controllerStatus & $08) = 0 then CEJB_Done

          goto CEJB_ReadButton2

CEJB_Done

          rem Enhanced jump button check complete
          rem Returns: Far (return otherbank)

          return otherbank