;;; ChaosFight - Source/Routines/DispatchCharacterJump.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


DispatchCharacterJump .proc

          ;; Dispatch to character-specific jump function
          ;; Returns: Near (return thisbank)
          ;;
          ;; Input: temp1 = player index (0-3), temp4 = character index (0-31)
          ;;
          ;; Output: Character-specific jump executed
          ;;
          ;; Mutates: temp1 (passed to jump functions), temp4 (character index)
          ;;
          ;; Called Routines: Character-specific jump functions in bank11
          ;;
          ;; Constraints: Now in Bank 7 (same bank as ProcessJumpInput). Jump functions are in Bank 11.
          ;; Handle out-of-range characters (>= 32)
          ;; Characters 16-30 (unused) and Meth Hound mirror Shamone
          ;; if temp4 >= 32 then goto DCJ_StandardJump
          lda temp4
          cmp 32
          bcs DCJ_StandardJump

          ;; Check for specific characters
          lda temp4
          cmp CharacterBernie
          beq DCJ_BernieJump

          lda temp4
          cmp CharacterDragonOfStorms
          beq DCJ_DragonJump

          lda temp4
          cmp CharacterHarpy
          beq DCJ_HarpyJump

          lda temp4
          cmp CharacterFrooty
          beq DCJ_FrootyJump

          lda temp4
          cmp CharacterRoboTito
          beq DCJ_RoboTitoJump

          ;; Default: StandardJump for all other characters
          jmp DCJ_StandardJump

.pend

DCJ_StandardJump .proc
          ;; Tail call: ProcessUpAction tail-calls DispatchCharacterJump, so we can tail-call StandardJump
          ;; Cross-bank call to StandardJump in bank 11
          lda # >(StandardJump-1)
          pha
          lda # <(StandardJump-1)
          pha
          ldx # 10
          jmp BS_jsr
.pend

DCJ_BernieJump .proc
          ;; Tail call: ProcessUpAction tail-calls DispatchCharacterJump, so we can tail-call BernieJump
          ;; Cross-bank call to BernieJump in bank 11
          lda # >(BernieJump-1)
          pha
          lda # <(BernieJump-1)
          pha
          ldx # 10
          jmp BS_jsr
.pend

DCJ_DragonJump .proc
          ;; Tail call: ProcessUpAction tail-calls DispatchCharacterJump, so we can tail-call CCJ_FreeFlightCharacterJump
          ;; DragonOfStormsJump is empty and should call CCJ_FreeFlightCharacterJump
          ;; Cross-bank call to CCJ_FreeFlightCharacterJump in bank 11
          lda # >(CCJ_FreeFlightCharacterJump-1)
          pha
          lda # <(CCJ_FreeFlightCharacterJump-1)
          pha
          ldx # 10
          jmp BS_jsr
.pend

DCJ_HarpyJump .proc
          ;; Tail call: ProcessUpAction tail-calls DispatchCharacterJump, so we can tail-call HarpyJump
          ;; Cross-bank call to HarpyJump in bank 11
          lda # >(HarpyJump-1)
          pha
          lda # <(HarpyJump-1)
          pha
          ldx # 10
          jmp BS_jsr
.pend

DCJ_FrootyJump .proc
          ;; Tail call: ProcessUpAction tail-calls DispatchCharacterJump, so we can tail-call FrootyJump
          ;; Cross-bank call to FrootyJump in bank 11
          lda # >(FrootyJump-1)
          pha
          lda # <(FrootyJump-1)
          pha
          ldx # 10
          jmp BS_jsr
.pend

DCJ_RoboTitoJump .proc
          ;; Tail call: ProcessUpAction tail-calls DispatchCharacterJump, so we can tail-call RoboTitoJump
          ;; Cross-bank call to RoboTitoJump in bank 10
          lda # >(RoboTitoJump-1)
          pha
          lda # <(RoboTitoJump-1)
          pha
          ldx # 9
          jmp BS_jsr
.pend

