;;; ChaosFight - Source/Routines/DisplayHealth.bas

;;; Copyright © 2025 Bruce-Robert Pocock.




DisplayHealth .proc




          ;;
          ;; Returns: Far (return otherbank)

          ;; Display Health

          ;; Shows health status for all active players.

          ;; Flashes sprites when health is critically low.

          ;; Shows health status for all active players by flashing

          ;; sprites when health is critically low

          ;;
          ;; Input: playerHealth[] (global array) = player health

          ;; values, playerRecoveryFrames[] (global array) = recovery

          ;; frame counts, controllerStatus (global) = controller

          ;; state, playerCharacter[] (global array) = selections,

          ;; frame (global) = frame counter

          ;;
          ;; Output: Sprites flashed (hidden) when health < 25 and not

          ;; in recovery

          ;;
          ;; Mutates: player0x, player1x, player2x, player3x (TIA

          ;; registers) = sprite positions (set to 200 to hide when

          ;; flashing)

          ;;
          ;; Called Routines: None

          ;;
          ;; Constraints: Only flashes when health < 25 and not in

          ;; recovery. Players 3/4 only checked if Quadtari detected

          ;; and selected

          ;; Flash Participant 1 sprite (array [0], P0) if health is

          ;; low (but not during recovery)

          ;; Use skip-over pattern to avoid complex || operator

                    ;; if playerHealth[0] >= 25 then goto DoneParticipant1Flash

                    ;; if playerRecoveryFrames[0] = 0 then FlashParticipant1
          lda # 0
          asl
          tax
          ;; lda playerRecoveryFrames,x (duplicate)
          bne skip_9594
          jmp FlashParticipant1
skip_9594:
          ;; jmp DoneParticipant1Flash (duplicate)

.pend

FlashParticipant1 .proc

                    ;; if frame & 8 then let player0x = 200
          ;; lda frame (duplicate)
          and 8
          beq skip_3682
          ;; lda # 200 (duplicate)
          sta player0x
skip_3682:

DoneParticipant1Flash

          ;; Hide P0 sprite
          ;; Returns: Far (return otherbank)



          ;; Flash Participant 2 sprite (array [1], P1) if health is

          ;; low

          ;; Use skip-over pattern to avoid complex || operator

                    ;; if playerHealth[1] >= 25 then goto DoneParticipant2Flash

                    ;; if playerRecoveryFrames[1] = 0 then FlashParticipant2
          ;; lda # 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerRecoveryFrames,x (duplicate)
          ;; bne skip_6320 (duplicate)
          ;; jmp FlashParticipant2 (duplicate)
skip_6320:
          ;; jmp DoneParticipant2Flash (duplicate)

.pend

FlashParticipant2 .proc

                    ;; if frame & 8 then let player1x = 200
          ;; lda frame (duplicate)
          ;; and 8 (duplicate)
          ;; beq skip_4325 (duplicate)
          ;; lda # 200 (duplicate)
          ;; sta player1x (duplicate)
skip_4325:

DoneParticipant2Flash



          ;; Flash Player 3 sprite if health is low (but alive)



          ;; lda controllerStatus (duplicate)
          ;; and SetQuadtariDetected (duplicate)
          cmp # 0
          ;; bne skip_8664 (duplicate)
          ;; jmp DonePlayer3Flash (duplicate)
skip_8664:


                    ;; if playerCharacter[2] = NoCharacter then goto DonePlayer3Flash

          ;; ;; if ! playerHealth[2] then goto DonePlayer3Flash
          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerHealth,x (duplicate)
          ;; bne skip_6091 (duplicate)
          ;; jmp DonePlayer3Flash (duplicate)
skip_6091:

          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerHealth,x (duplicate)
          ;; bne skip_190 (duplicate)
          ;; jmp DonePlayer3Flash (duplicate)
skip_190:



                    ;; if playerHealth[2] >= 25 then goto DonePlayer3Flash

                    ;; if playerRecoveryFrames[2] = 0 then FlashPlayer3
          ;; lda # 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerRecoveryFrames,x (duplicate)
          ;; bne skip_5628 (duplicate)
          ;; jmp FlashPlayer3 (duplicate)
skip_5628:
          ;; jmp DonePlayer3Flash (duplicate)

.pend

FlashPlayer3 .proc

                    ;; if frame & 8 then let player2x = 200
          ;; lda frame (duplicate)
          ;; and 8 (duplicate)
          ;; beq skip_46 (duplicate)
          ;; lda # 200 (duplicate)
          ;; sta player2x (duplicate)
skip_46:

DonePlayer3Flash

          ;; Player 3 uses player2 sprite
          ;; Returns: Far (return otherbank)



          ;; Flash Player 4 sprite if health is low (but alive)



          ;; lda controllerStatus (duplicate)
          ;; and SetQuadtariDetected (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_1843 (duplicate)
          ;; jmp DonePlayer4Flash (duplicate)
skip_1843:


                    ;; if playerCharacter[3] = NoCharacter then goto DonePlayer4Flash

          ;; ;; if ! playerHealth[3] then goto DonePlayer4Flash
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerHealth,x (duplicate)
          ;; bne skip_6517 (duplicate)
          ;; jmp DonePlayer4Flash (duplicate)
skip_6517:

          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerHealth,x (duplicate)
          ;; bne skip_2604 (duplicate)
          ;; jmp DonePlayer4Flash (duplicate)
skip_2604:



                    ;; if playerHealth[3] >= 25 then goto DonePlayer4Flash

                    ;; if playerRecoveryFrames[3] = 0 then FlashPlayer4
          ;; lda # 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerRecoveryFrames,x (duplicate)
          ;; bne skip_5482 (duplicate)
          ;; jmp FlashPlayer4 (duplicate)
skip_5482:
          ;; jmp DonePlayer4Flash (duplicate)

.pend

FlashPlayer4 .proc

                    ;; if frame & 8 then let player3x = 200
          ;; lda frame (duplicate)
          ;; and 8 (duplicate)
          ;; beq skip_7229 (duplicate)
          ;; lda # 200 (duplicate)
          ;; sta player3x (duplicate)
skip_7229:

DonePlayer4Flash

          ;; Player 4 uses player3 sprite
          ;; Returns: Far (return otherbank)



          jsr BS_return

.pend

