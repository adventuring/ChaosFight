;;; ChaosFight - Source/Routines/ConsolidatedPlayerInput.s
;;; Copyright © 2025 Bruce-Robert Pocock.
;;;
;;; Consolidated player input snapshot.
;;;
;;; Four bytes, one per player, refreshed once per frame.  Every byte uses
;;; the same layout:
;;;
;;;   $80  controller disconnected
;;;   $40  button 3 - console Game Select / select / pause
;;;   $20  button 2 - jump
;;;   $10  button 1 - fire
;;;   $08  right
;;;   $04  left
;;;   $02  down
;;;   $01  up
;;;
;;; Sources:
;;;   SWCHA   the two joystick directions, active-low, bits 7-4 for
;;;           player 1 and bits 3-0 for player 2.
;;;   INPT4   player 1 fire button, active-low.
;;;   INPT5   player 2 fire button, active-low.
;;;   INPT0   left port enhanced button (Genesis Button C, Joy2B+
;;;           Button II) - the button the jump code reads.
;;;   INPT1   left port Joy2B+ Button III - the select/pause button.
;;;   INPT2   right port enhanced button (as INPT0).
;;;   INPT3   right port Joy2B+ Button III (as INPT1).
;;;   SWCHB   console switches; bit 1 is the Game Select switch,
;;;           which is active-low and applies to every player.
;;;
;;; Players 3 and 4 only exist when a Quadtari is attached.  The Quadtari
;;; time-multiplexes the two joysticks between the four players, so those
;;; two bytes carry the same port state as players 1 and 2; without a
;;; Quadtari they are reported as disconnected ($80).
;;;
;;; The bytes live in dedicated zero page locations ($FB-$FE) so that they
;;; are never aliased by the temp1-temp6 scratch words or by the
;;; scorePointers block that the display kernels scribble over.
;;;
;;; NOTE: the INPTx registers are active-low - bit 7 clear means "pressed".
;;; They must be read with "lda": the 6502 "bit" instruction ANDs the
;;; operand into A and sets N/Z from the result, so "bit INPTx" would test
;;; bit 7 of (A & INPTx) and never see the input register at all.
;;;
;;; WHY THIS LIVES IN BANK 15 AND NOT IN THE VBLANK HANDLER:
;;; The multi-sprite game kernel calls the bank 10 vblank dispatcher, so
;;; UpdateJoystickState runs every frame in game modes.  The 48x2 title
;;; kernel (bank 8) has NO vblank hook at all, so a vblank-only update
;;; never runs on the publisher prelude, author prelude or title screen.
;;; MainLoop (bank 15) runs on every frame in every mode, so the
;;; consolidated snapshot is refreshed from there.

ConsolidatedPlayerInput .proc
          ;; Returns: Near (return thisbank)
          ;; Refreshes player0Input-player3Input ($FB-$FE) from the TIA
          ;; input registers and the console switches.
          ;;
          ;; Mutates: player0Input, player1Input, player2Input, player3Input
          ;;          (A only - no scratch registers are touched, so this is
          ;;          safe to call from the middle of MainLoop)
          ;; Constraints: Must be in the same bank as its caller so that a
          ;;          plain "jsr"/"rts" is used.  A cross-bank call would
          ;;          need the callee to finish with "jmp BS_return";
          ;;          UpdateJoystickState finishes with a plain "rts" and
          ;;          would leave the CPU executing the wrong bank.

          ;; Player 1: left port.  SWCHA bits 7-4 hold right/left/down/up,
          ;; which have to be shifted down four places to line up with the
          ;; $08/$04/$02/$01 layout of the consolidated byte.
          lda SWCHA
          eor # $ff              ; a set bit now means "pressed"
          and # $f0
          lsr a
          lsr a
          lsr a
          lsr a
          sta player0Input
          lda INPT4
          bmi NoP0Fire
          lda player0Input
          ora # $10
          sta player0Input
 NoP0Fire:
          lda controllerStatus
          and # (SetLeftPortGenesis | SetLeftPortJoy2bPlus)
          beq NoLeftJumpButton
          lda INPT0
          bmi NoLeftJumpButton
          lda player0Input
          ora # $20
          sta player0Input
 NoLeftJumpButton:
          lda controllerStatus
          and # SetLeftPortJoy2bPlus
          beq NoLeftSelectButton
          lda INPT1
          bmi NoLeftSelectButton
          lda player0Input
          ora # $40
          sta player0Input
 NoLeftSelectButton:

          ;; Player 2: right port.  SWCHA bits 3-0 already use the same
          ;; order as the consolidated byte, so no shift is needed.
          lda SWCHA
          eor # $ff
          and # $0f
          sta player1Input
          lda INPT5
          bmi NoP1Fire
          lda player1Input
          ora # $10
          sta player1Input
 NoP1Fire:
          lda controllerStatus
          and # (SetRightPortGenesis | SetRightPortJoy2bPlus)
          beq NoRightJumpButton
          lda INPT2
          bmi NoRightJumpButton
          lda player1Input
          ora # $20
          sta player1Input
 NoRightJumpButton:
          lda controllerStatus
          and # SetRightPortJoy2bPlus
          beq NoRightSelectButton
          lda INPT3
          bmi NoRightSelectButton
          lda player1Input
          ora # $40
          sta player1Input
 NoRightSelectButton:

          ;; Players 3 and 4 share the two joysticks with players 1 and 2
          ;; when a Quadtari is present.
          lda player0Input
          sta player2Input
          lda player1Input
          sta player3Input

          ;; The console Game Select switch is a global select/pause event,
          ;; so it is ORed into all four bytes.
          lda SWCHB
          and # SWCHBSelect
          bne NoGameSelect
          lda player0Input
          ora # $40
          sta player0Input
          lda player1Input
          ora # $40
          sta player1Input
          lda player2Input
          ora # $40
          sta player2Input
          lda player3Input
          ora # $40
          sta player3Input
 NoGameSelect:

          ;; Without a Quadtari there are no players 3 and 4.
          lda controllerStatus
          and # SetQuadtariDetected
          bne QuadPlayersPresent
          lda player2Input
          ora # $80
          sta player2Input
          lda player3Input
          ora # $80
          sta player3Input
 QuadPlayersPresent:

          jmp BS_return
.pend
