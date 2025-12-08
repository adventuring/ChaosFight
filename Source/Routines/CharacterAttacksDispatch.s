
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

          ;; lda temp4 (duplicate)
          ;; cmp CharacterCurler (duplicate)
          ;; bne skip_3787 (duplicate)
          ;; jmp PerformGenericAttack (duplicate)
skip_3787:


          ;; Dragon of Storms: ranged ballistic fireball

          ;; lda temp4 (duplicate)
          ;; cmp CharacterDragonOfStorms (duplicate)
          ;; bne skip_7828 (duplicate)
          ;; jmp PerformGenericAttack (duplicate)
skip_7828:


          ;; Zoe Ryen: rapid laser blast

          ;; lda temp4 (duplicate)
          ;; cmp CharacterZoeRyen (duplicate)
          ;; bne skip_3333 (duplicate)
          ;; jmp PerformGenericAttack (duplicate)
skip_3333:


          ;; Fat Tony: stationary magic ring laser

          ;; lda temp4 (duplicate)
          ;; cmp CharacterFatTony (duplicate)
          ;; bne skip_1009 (duplicate)
          ;; jmp PerformGenericAttack (duplicate)
skip_1009:


          ;; Megax: heavy mêlée breath strike (generic mêlée tables)

          ;; lda temp4 (duplicate)
          ;; cmp CharacterMegax (duplicate)
          ;; bne skip_3534 (duplicate)
          ;; jmp PerformGenericAttack (duplicate)
skip_3534:


          ;; Harpy: diagonal swoop attack

          ;; lda temp4 (duplicate)
          ;; cmp CharacterHarpy (duplicate)
          ;; bne skip_9677 (duplicate)
          ;; jmp HarpyAttack (duplicate)
skip_9677:


          ;; Knight Guy: sword mêlée swing

          ;; lda temp4 (duplicate)
          ;; cmp CharacterKnightGuy (duplicate)
          ;; bne skip_2923 (duplicate)
          ;; jmp PerformGenericAttack (duplicate)
skip_2923:


          ;; Frooty: charge-and-bounce lollipop projectile (Issue #1177)

          ;; lda temp4 (duplicate)
          ;; cmp CharacterFrooty (duplicate)
          ;; bne skip_3446 (duplicate)
          ;; jmp FrootyAttack (duplicate)
skip_3446:


          ;; Nefertem: mêlée paw strike

          ;; lda temp4 (duplicate)
          ;; cmp CharacterNefertem (duplicate)
          ;; bne skip_2059 (duplicate)
          ;; jmp PerformGenericAttack (duplicate)
skip_2059:


          ;; Ninjish Guy: ranged shuriken

          ;; lda temp4 (duplicate)
          ;; cmp CharacterNinjishGuy (duplicate)
          ;; bne skip_1855 (duplicate)
          ;; jmp PerformGenericAttack (duplicate)
skip_1855:


          ;; Pork Chop: mêlée

          ;; lda temp4 (duplicate)
          ;; cmp CharacterPorkChop (duplicate)
          ;; bne skip_1132 (duplicate)
          ;; jmp PerformGenericAttack (duplicate)
skip_1132:


          ;; Radish Goblin: mêlée bite lunge

          ;; lda temp4 (duplicate)
          ;; cmp CharacterRadishGoblin (duplicate)
          ;; bne skip_9972 (duplicate)
          ;; jmp PerformGenericAttack (duplicate)
skip_9972:


          ;; Robo Tito: mêlée trunk slam

          ;; lda temp4 (duplicate)
          ;; cmp CharacterRoboTito (duplicate)
          ;; bne skip_9265 (duplicate)
          ;; jmp PerformGenericAttack (duplicate)
skip_9265:


          ;; Ursulo: claw swipe with mêlée tables

          ;; lda temp4 (duplicate)
          ;; cmp CharacterUrsulo (duplicate)
          ;; bne skip_8405 (duplicate)
          ;; jmp UrsuloAttack (duplicate)
skip_8405:


          ;; Shamone: jump + mêlée special

          ;; lda temp4 (duplicate)
          ;; cmp CharacterShamone (duplicate)
          ;; bne skip_3871 (duplicate)
          ;; jmp ShamoneAttack (duplicate)
skip_3871:




          ;; Characters 16-30: Basic mêlée attacks

                    ;; if temp4 >= 16 && temp4 <= 30 then goto PerformGenericAttack bank7



          ;; MethHound uses ShamoneAttack handler
          ;; lda temp4 (duplicate)
          ;; cmp CharacterMethHound (duplicate)
          ;; bne skip_9432 (duplicate)
          ;; jmp ShamoneAttack (duplicate)
skip_9432:




          ;; jsr BS_return (duplicate)



CheckEnhancedJumpButton
          ;; Returns: Far (return otherbank)


;; CheckEnhancedJumpButton (duplicate)




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

          ;; lda # 0 (duplicate)
          sta temp3



          ;; Only players 0-1 can have enhanced controllers

          ;; Players 2-3 (Quadtari players) cannot have enhanced controllers

          ;; lda currentPlayer (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_7988 (duplicate)
          ;; TODO: CEJB_CheckPlayer0
skip_7988:


          ;; Players 2-3 skip enhanced controller checks

          ;; lda currentPlayer (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bne skip_316 (duplicate)
          ;; TODO: CEJB_CheckPlayer2
skip_316:


          ;; jmp CEJB_Done (duplicate)

.pend

CEJB_CheckPlayer0 .proc

          ;; Player 0: Check Genesis controller first
          ;; Returns: Far (return otherbank)

                    ;; if !controllerStatus{0} then goto CEJB_CheckPlayer0Joy2bPlus

CEJB_ReadButton0

          ;; Shared button read for Player 0 enhanced controllers (Button C/II)
          ;; Returns: Far (return otherbank)

                    ;; if !INPT0{7} then let
          bit INPT0
          bmi skip_1048
          ;; jmp let_label (duplicate)
skip_1048: temp3 = 1
          ;; jmp CEJB_Done (duplicate)

.pend

CEJB_CheckPlayer0Joy2bPlus .proc

          ;; Player 0: Check Joy2b+ controller (fallback)
          ;; Returns: Far (return otherbank)

                    ;; if !controllerStatus{1} then CEJB_Done
          ;; jmp CEJB_ReadButton0 (duplicate)

.pend

CEJB_CheckPlayer2 .proc

          ;; Player 1: Check Genesis controller first
          ;; Returns: Far (return otherbank)

          ;; lda controllerStatus (duplicate)
          and # 4
          ;; cmp # 0 (duplicate)
          ;; bne skip_785 (duplicate)
skip_785:


CEJB_ReadButton2

          ;; Shared button read for Player 1 enhanced controllers (Button C/II)
          ;; Returns: Far (return otherbank)

          ;; lda INPT2 (duplicate)
          ;; and # 128 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_879 (duplicate)
          ;; lda # 1 (duplicate)
          ;; sta temp3 (duplicate)
skip_879:


          ;; jmp CEJB_Done (duplicate)

.pend

CEJB_CheckPlayer2Joy2bPlus .proc

          ;; Player 1: Check Joy2b+ controller (fallback)
          ;; Returns: Far (return otherbank)

          ;; lda controllerStatus (duplicate)
          ;; and # 8 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_6737 (duplicate)
skip_6737:


          ;; jmp CEJB_ReadButton2 (duplicate)

CEJB_Done

          ;; Enhanced jump button check complete
          ;; Returns: Far (return otherbank)

          ;; jsr BS_return (duplicate)
.pend

