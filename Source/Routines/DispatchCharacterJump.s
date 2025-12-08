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
          ;; Called Routines: Character-specific jump functions in bank12
          ;;
          ;; Constraints: Now in Bank 8 (same bank as ProcessJumpInput). Jump functions are in Bank 12.
          ;; Handle out-of-range characters (>= 32)
          ;; Characters 16-30 (unused) and Meth Hound mirror Shamone
          ;; if temp4 >= 32 then goto DCJ_StandardJump
          lda temp4
          cmp 32

          bcc skip_6033

          jmp skip_6033

          skip_6033:
          ;; if temp4 >= 16 then goto DCJ_StandardJump
          ;; lda temp4 (duplicate)
          ;; cmp 16 (duplicate)

          ;; bcc skip_1019 (duplicate)

          ;; jmp skip_1019 (duplicate)

          skip_1019:
          ;; lda temp4 (duplicate)
          ;; cmp CharacterBernie (duplicate)
          bne skip_539
          ;; jmp DCJ_BernieJump (duplicate)
skip_539:

          ;; lda temp4 (duplicate)
          ;; cmp CharacterDragonOfStorms (duplicate)
          ;; bne skip_2630 (duplicate)
          ;; jmp DCJ_DragonJump (duplicate)
skip_2630:

          ;; lda temp4 (duplicate)
          ;; cmp CharacterHarpy (duplicate)
          ;; bne skip_1796 (duplicate)
          ;; jmp DCJ_HarpyJump (duplicate)
skip_1796:

          ;; lda temp4 (duplicate)
          ;; cmp CharacterFrooty (duplicate)
          ;; bne skip_3871 (duplicate)
          ;; jmp DCJ_FrootyJump (duplicate)
skip_3871:

          ;; lda temp4 (duplicate)
          ;; cmp CharacterRoboTito (duplicate)
          ;; bne skip_3489 (duplicate)
          ;; jmp DCJ_RoboTitoJump (duplicate)
skip_3489:

.pend

DCJ_StandardJump .proc
          ;; CRITICAL: Must use gosub/return, not goto, because ProcessUpAction expects return
          ;; Cross-bank call to StandardJump in bank 12
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(StandardJump-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(StandardJump-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 11
          ;; jmp BS_jsr (duplicate)
return_point:

          rts
.pend

DCJ_BernieJump .proc
          ;; CRITICAL: Must use gosub/return, not goto, because ProcessUpAction expects return
          ;; Cross-bank call to BernieJump in bank 12
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(BernieJump-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(BernieJump-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 11 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

          ;; rts (duplicate)
DCJ_DragonJump
          ;; CRITICAL: Must use gosub/return, not goto, because ProcessUpAction expects return
          ;; Cross-bank call to DragonOfStormsJump in bank 12
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(DragonOfStormsJump-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(DragonOfStormsJump-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 11 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

          ;; rts (duplicate)
.pend

DCJ_HarpyJump .proc
          ;; CRITICAL: Must use gosub/return, not goto, because ProcessUpAction expects return
          ;; Cross-bank call to HarpyJump in bank 12
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(HarpyJump-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(HarpyJump-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 11 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

          ;; rts (duplicate)
.pend

DCJ_FrootyJump .proc
          ;; CRITICAL: Must use gosub/return, not goto, because ProcessUpAction expects return
          ;; Cross-bank call to FrootyJump in bank 12
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(FrootyJump-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(FrootyJump-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 11 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

          ;; rts (duplicate)
.pend

DCJ_RoboTitoJump .proc
          ;; CRITICAL: Must use gosub/return, not goto, because ProcessUpAction expects return
          ;; CRITICAL: RoboTitoJump is in Bank 10, not Bank 8, so must use bank specifier
          ;; Cross-bank call to RoboTitoJump in bank 10
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(RoboTitoJump-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(RoboTitoJump-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 9 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

          ;; rts (duplicate)

.pend

