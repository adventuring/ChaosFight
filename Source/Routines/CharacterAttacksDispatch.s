
DispatchCharacterAttack .proc




          ;; Dispatch to character-specific attack handler (0-31)
          ;; Returns: Far (return otherbank)

          ;; MethHound uses ShamoneAttack handler

          ;; Direct cross-bank gotos route to character-specific logic

          jsr BS_return



          ;; Characters 0-15: Implemented attacks

          ;; Bernie: dual-direction ground thump

          lda temp4
          cmp CharacterBernie
          bne skip_8965
          jmp BernieAttack
skip_8965:


          ;; Curler: ranged curling stone along ground

          lda temp4
          cmp CharacterCurler
          bne skip_3787
          jmp PerformGenericAttack
skip_3787:


          ;; Dragon of Storms: ranged ballistic fireball

          lda temp4
          cmp CharacterDragonOfStorms
          bne skip_7828
          jmp PerformGenericAttack
skip_7828:


          ;; Zoe Ryen: rapid laser blast

          lda temp4
          cmp CharacterZoeRyen
          bne skip_3333
          jmp PerformGenericAttack
skip_3333:


          ;; Fat Tony: stationary magic ring laser

          lda temp4
          cmp CharacterFatTony
          bne skip_1009
          jmp PerformGenericAttack
skip_1009:


          ;; Megax: heavy mêlée breath strike (generic mêlée tables)

          lda temp4
          cmp CharacterMegax
          bne skip_3534
          jmp PerformGenericAttack
skip_3534:


          ;; Harpy: diagonal swoop attack

          lda temp4
          cmp CharacterHarpy
          bne skip_9677
          jmp HarpyAttack
skip_9677:


          ;; Knight Guy: sword mêlée swing

          lda temp4
          cmp CharacterKnightGuy
          bne skip_2923
          jmp PerformGenericAttack
skip_2923:


          ;; Frooty: charge-and-bounce lollipop projectile (Issue #1177)

          lda temp4
          cmp CharacterFrooty
          bne skip_3446
          jmp FrootyAttack
skip_3446:


          ;; Nefertem: mêlée paw strike

          lda temp4
          cmp CharacterNefertem
          bne skip_2059
          jmp PerformGenericAttack
skip_2059:


          ;; Ninjish Guy: ranged shuriken

          lda temp4
          cmp CharacterNinjishGuy
          bne skip_1855
          jmp PerformGenericAttack
skip_1855:


          ;; Pork Chop: mêlée

          lda temp4
          cmp CharacterPorkChop
          bne skip_1132
          jmp PerformGenericAttack
skip_1132:


          ;; Radish Goblin: mêlée bite lunge

          lda temp4
          cmp CharacterRadishGoblin
          bne skip_9972
          jmp PerformGenericAttack
skip_9972:


          ;; Robo Tito: mêlée trunk slam

          lda temp4
          cmp CharacterRoboTito
          bne skip_9265
          jmp PerformGenericAttack
skip_9265:


          ;; Ursulo: claw swipe with mêlée tables

          lda temp4
          cmp CharacterUrsulo
          bne skip_8405
          jmp UrsuloAttack
skip_8405:


          ;; Shamone: jump + mêlée special

          lda temp4
          cmp CharacterShamone
          bne skip_3871
          jmp ShamoneAttack
skip_3871:




          ;; Characters 16-30: Basic mêlée attacks

                    if temp4 >= 16 && temp4 <= 30 then goto PerformGenericAttack bank7



          ;; MethHound uses ShamoneAttack handler
          lda temp4
          cmp CharacterMethHound
          bne skip_9432
          jmp ShamoneAttack
skip_9432:




          jsr BS_return



CheckEnhancedJumpButton
          ;; Returns: Far (return otherbank)


CheckEnhancedJumpButton




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
          bne skip_7988
          ;; TODO: CEJB_CheckPlayer0
skip_7988:


          ;; Players 2-3 skip enhanced controller checks

          lda currentPlayer
          cmp # 1
          bne skip_316
          ;; TODO: CEJB_CheckPlayer2
skip_316:


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
          bmi skip_1048
          jmp let_label
skip_1048: temp3 = 1
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
          bne skip_785
skip_785:


CEJB_ReadButton2

          ;; Shared button read for Player 1 enhanced controllers (Button C/II)
          ;; Returns: Far (return otherbank)

          lda INPT2
          and # 128
          cmp # 0
          bne skip_879
          lda # 1
          sta temp3
skip_879:


          jmp CEJB_Done

.pend

CEJB_CheckPlayer2Joy2bPlus .proc

          ;; Player 1: Check Joy2b+ controller (fallback)
          ;; Returns: Far (return otherbank)

          lda controllerStatus
          and # 8
          cmp # 0
          bne skip_6737
skip_6737:


          jmp CEJB_ReadButton2

CEJB_Done

          ;; Enhanced jump button check complete
          ;; Returns: Far (return otherbank)

          jsr BS_return
.pend

