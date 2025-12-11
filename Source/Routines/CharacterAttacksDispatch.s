
DispatchCharacterAttack .proc




          ;; Dispatch to character-specific attack handler (0-31)
          ;; Returns: Far (return otherbank)

          ;; MethHound uses ShamoneAttack handler

          ;; Direct cross-bank gotos route to character-specific logic

          jsr BS_return



          ;; Characters 0-15: Implemented attacks

          ;; Bernie: dual-direction ground thump

          lda temp4
          cmp # CharacterBernie
          bne CheckCurler

          jmp BernieAttack

CheckCurler:

          ;; Curler: ranged curling stone along ground

          lda temp4
          cmp # CharacterCurler
          bne CheckDragonOfStorms

          jmp PerformGenericAttack

CheckDragonOfStorms:

          ;; Dragon of Storms: ranged ballistic fireball

          lda temp4
          cmp # CharacterDragonOfStorms
          bne CheckZoeRyen

          jmp PerformGenericAttack

CheckZoeRyen:

          ;; Zoe Ryen: rapid laser blast

          lda temp4
          cmp # CharacterZoeRyen
          bne CheckFatTony

          jmp PerformGenericAttack

CheckFatTony:

          ;; Fat Tony: stationary magic ring laser

          lda temp4
          cmp # CharacterFatTony
          bne CheckMegax

          jmp PerformGenericAttack

CheckMegax:

          ;; Megax: heavy mêlée breath strike (generic mêlée tables)

          lda temp4
          cmp # CharacterMegax
          bne CheckHarpy

          jmp PerformGenericAttack

CheckHarpy:

          ;; Harpy: diagonal swoop attack

          lda temp4
          cmp # CharacterHarpy
          bne CheckKnightGuy

          jmp HarpyAttack

CheckKnightGuy:


          ;; Knight Guy: sword mêlée swing

          lda temp4
          cmp CharacterKnightGuy
          bne CheckFrooty
          jmp PerformGenericAttack
CheckFrooty:


          ;; Frooty: charge-and-bounce lollipop projectile (Issue #1177)

          lda temp4
          cmp CharacterFrooty
          bne CheckNefertem
          jmp FrootyAttack
CheckNefertem:


          ;; Nefertem: mêlée paw strike

          lda temp4
          cmp CharacterNefertem
          bne CheckNinjishGuy
          jmp PerformGenericAttack
CheckNinjishGuy:


          ;; Ninjish Guy: ranged shuriken

          lda temp4
          cmp CharacterNinjishGuy
          bne CheckPorkChop
          jmp PerformGenericAttack
CheckPorkChop:


          ;; Pork Chop: mêlée

          lda temp4
          cmp CharacterPorkChop
          bne CheckRadishGoblin
          jmp PerformGenericAttack
CheckRadishGoblin:


          ;; Radish Goblin: mêlée bite lunge

          lda temp4
          cmp CharacterRadishGoblin
          bne CheckRoboTito
          jmp PerformGenericAttack
CheckRoboTito:


          ;; Robo Tito: mêlée trunk slam

          lda temp4
          cmp CharacterRoboTito
          bne CheckUrsulo
          jmp PerformGenericAttack
CheckUrsulo:


          ;; Ursulo: claw swipe with mêlée tables

          lda temp4
          cmp CharacterUrsulo
          bne CheckShamone
          jmp UrsuloAttack
CheckShamone:


          ;; Shamone: jump + mêlée special

          lda temp4
          cmp CharacterShamone
          bne CheckMethHound
          jmp ShamoneAttack
CheckMethHound:




          ;; Characters 16-30: Basic mêlée attacks

          ;; if temp4 >= 16 && temp4 <= 30 then goto PerformGenericAttack bank7



          ;; MethHound uses ShamoneAttack handler
          lda temp4
          cmp CharacterMethHound
          bne DispatchCharacterAttackDone
          jmp ShamoneAttack
DispatchCharacterAttackDone:




          jsr BS_return



CheckEnhancedJumpButton:
          ;; Returns: Far (return otherbank)




          ;;
          ;; Returns: Far (return otherbank)

          ;; Shared Enhanced Button Check

          ;; Checks Genesis/Joy2b+ Button C/II for jump input

          ;; Only players 1-2 can have enhanced controllers (players 3-4 require Quadtari)

          ;;
          ;; INPUT: currentPlayer (global) = player index (0-3)

          ;;
          ;; OUTPUT: temp3 = 1 if jump button pressed, 0 otherwise

          ;; Uses: INPT0 for players 0; INPT2 for players 1

          ;; Players 2-3 cannot have enhanced controllers

          ;; Initialize to no jump

          lda # 0
          sta temp3



          ;; Only players 0-1 can have enhanced controllers

          ;; Players 2-3 (Quadtari players) cannot have enhanced controllers

          lda currentPlayer
          cmp # 0
          bne CheckPlayer1Enhanced
          ;; TODO: CEJB_CheckPlayer0
CheckPlayer1Enhanced:


          ;; Players 2-3 skip enhanced controller checks

          lda currentPlayer
          cmp # 1
          bne CEJB_Done
          ;; TODO: #1308 CEJB_CheckPlayer2
CEJB_Done:


          jmp CEJB_Done

.pend

CEJB_CheckPlayer0 .proc

          ;; Player 0: Check Genesis controller first
          ;; Returns: Far (return otherbank)

                    if !controllerStatus{0} then goto CEJB_CheckPlayer0Joy2bPlus

CEJB_ReadButton0

          ;; Shared button read for Player 0 enhanced controllers (Button C/II)
          ;; Returns: Far (return otherbank)

                    if !INPT0{7} then let
          bit INPT0
          bmi CEJB_Done
          jmp let_label
CEJB_Done: temp3 = 1
          jmp CEJB_Done

.pend

CEJB_CheckPlayer0Joy2bPlus .proc

          ;; Player 0: Check Joy2b+ controller (fallback)
          ;; Returns: Far (return otherbank)

                    if !controllerStatus{1} then CEJB_Done
          jmp CEJB_ReadButton0

.pend

CEJB_CheckPlayer2 .proc

          ;; Player 1: Check Genesis controller first
          ;; Returns: Far (return otherbank)

          lda controllerStatus
          and # 4
          cmp # 0
          bne CEJB_ReadButton2
CEJB_ReadButton2:


CEJB_ReadButton2

          ;; Shared button read for Player 1 enhanced controllers (Button C/II)
          ;; Returns: Far (return otherbank)

          lda INPT2
          and # 128
          cmp # 0
          bne CEJB_Done
          lda # 1
          sta temp3
CEJB_Done:


          jmp CEJB_Done

.pend

CEJB_CheckPlayer2Joy2bPlus .proc

          ;; Player 1: Check Joy2b+ controller (fallback)
          ;; Returns: Far (return otherbank)

          lda controllerStatus
          and # 8
          cmp # 0
          bne CEJB_ReadButton2
CEJB_ReadButton2:


          jmp CEJB_ReadButton2

CEJB_Done

          ;; Enhanced jump button check complete
          ;; Returns: Far (return otherbank)

          jsr BS_return
.pend

