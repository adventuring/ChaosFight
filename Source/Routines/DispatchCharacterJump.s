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
          ;; if temp4 >= 32 then jmp DCJ_StandardJump
          lda temp4
          cmp # 32
          bcs DCJ_StandardJump

          ;; Check for specific characters
          lda temp4
          cmp # CharacterBernie
          beq DCJ_BernieJump

          lda temp4
          cmp # CharacterDragonOfStorms
          beq DCJ_DragonJump

          lda temp4
          cmp # CharacterHarpy
          beq DCJ_HarpyJump

          lda temp4
          cmp # CharacterFrooty
          beq DCJ_FrootyJump

          lda temp4
          cmp # CharacterRoboTito
          bne DCJ_NotRoboTito
          jmp DCJ_RoboTitoJump
DCJ_NotRoboTito:

          ;; Default: StandardJump for all other characters
          jmp DCJ_StandardJump

.pend

DCJ_StandardJump .proc
          ;; Tail call: ProcessUpAction tail-calls DispatchCharacterJump, so we can tail-call StandardJump
          ;; Preserve the return address from DispatchCharacterJump's caller (ProcessUpAction in Bank 7)
          ;; and re-encode it for BS_jsr
          pla
          sta temp6  ;;; Save low byte
          pla
          sta temp7  ;;; Save high byte (raw address in Bank 7)
          ;; Encode return address with caller bank 7 ($70) for BS_return to decode
          lda temp7
          and # $0f  ;;; Get low nybble
          ora # $70  ;;; Encode bank 7 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: return hi (encoded with bank 7)]
          lda temp6
          pha
          ;; STACK PICTURE: [SP+1: return hi (encoded)] [SP+0: return lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(StandardJump-1)
          pha
          ;; STACK PICTURE: [SP+2: return hi (encoded)] [SP+1: return lo] [SP+0: StandardJump hi (raw)]
          lda # <(StandardJump-1)
          pha
          ;; STACK PICTURE: [SP+3: return hi (encoded)] [SP+2: return lo] [SP+1: StandardJump hi (raw)] [SP+0: StandardJump lo]
          ldx # 10
          jmp BS_jsr

.pend

DCJ_BernieJump .proc
          ;; Tail call: ProcessUpAction tail-calls DispatchCharacterJump, so we can tail-call BernieJump
          ;; Preserve the return address from DispatchCharacterJump's caller (ProcessUpAction in Bank 7)
          ;; and re-encode it for BS_jsr
          pla
          sta temp6  ;;; Save low byte
          pla
          sta temp7  ;;; Save high byte (raw address in Bank 7)
          ;; Encode return address with caller bank 7 ($70) for BS_return to decode
          lda temp7
          and # $0f  ;;; Get low nybble
          ora # $70  ;;; Encode bank 7 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: return hi (encoded with bank 7)]
          lda temp6
          pha
          ;; STACK PICTURE: [SP+1: return hi (encoded)] [SP+0: return lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(BernieJump-1)
          pha
          ;; STACK PICTURE: [SP+2: return hi (encoded)] [SP+1: return lo] [SP+0: BernieJump hi (raw)]
          lda # <(BernieJump-1)
          pha
          ;; STACK PICTURE: [SP+3: return hi (encoded)] [SP+2: return lo] [SP+1: BernieJump hi (raw)] [SP+0: BernieJump lo]
          ldx # 10
          jmp BS_jsr

.pend

DCJ_DragonJump .proc
          ;; Tail call: ProcessUpAction tail-calls DispatchCharacterJump, so we can tail-call FreeFlightCharacterJump
          ;; DragonOfStormsJump is empty and should call FreeFlightCharacterJump
          ;; Preserve the return address from DispatchCharacterJump's caller (ProcessUpAction in Bank 7)
          ;; and re-encode it for BS_jsr
          pla
          sta temp6  ;;; Save low byte
          pla
          sta temp7  ;;; Save high byte (raw address in Bank 7)
          ;; Encode return address with caller bank 7 ($70) for BS_return to decode
          lda temp7
          and # $0f  ;;; Get low nybble
          ora # $70  ;;; Encode bank 7 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: return hi (encoded with bank 7)]
          lda temp6
          pha
          ;; STACK PICTURE: [SP+1: return hi (encoded)] [SP+0: return lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(FreeFlightCharacterJump-1)
          pha
          ;; STACK PICTURE: [SP+2: return hi (encoded)] [SP+1: return lo] [SP+0: FreeFlightCharacterJump hi (raw)]
          lda # <(FreeFlightCharacterJump-1)
          pha
          ;; STACK PICTURE: [SP+3: return hi (encoded)] [SP+2: return lo] [SP+1: FreeFlightCharacterJump hi (raw)] [SP+0: FreeFlightCharacterJump lo]
          ldx # 10
          jmp BS_jsr
.pend

DCJ_HarpyJump .proc
          ;; Tail call: ProcessUpAction tail-calls DispatchCharacterJump, so we can tail-call HarpyJump
          ;; Preserve the return address from DispatchCharacterJump's caller (ProcessUpAction in Bank 7)
          ;; and re-encode it for BS_jsr
          pla
          sta temp6  ;;; Save low byte
          pla
          sta temp7  ;;; Save high byte (raw address in Bank 7)
          ;; Encode return address with caller bank 7 ($70) for BS_return to decode
          lda temp7
          and # $0f  ;;; Get low nybble
          ora # $70  ;;; Encode bank 7 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: return hi (encoded with bank 7)]
          lda temp6
          pha
          ;; STACK PICTURE: [SP+1: return hi (encoded)] [SP+0: return lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(HarpyJump-1)
          pha
          ;; STACK PICTURE: [SP+2: return hi (encoded)] [SP+1: return lo] [SP+0: HarpyJump hi (raw)]
          lda # <(HarpyJump-1)
          pha
          ;; STACK PICTURE: [SP+3: return hi (encoded)] [SP+2: return lo] [SP+1: HarpyJump hi (raw)] [SP+0: HarpyJump lo]
          ldx # 10
          jmp BS_jsr
.pend

DCJ_FrootyJump .proc
          ;; Tail call: ProcessUpAction tail-calls DispatchCharacterJump, so we can tail-call FrootyJump
          ;; Preserve the return address from DispatchCharacterJump's caller (ProcessUpAction in Bank 7)
          ;; and re-encode it for BS_jsr
          pla
          sta temp6  ;;; Save low byte
          pla
          sta temp7  ;;; Save high byte (raw address in Bank 7)
          ;; Encode return address with caller bank 7 ($70) for BS_return to decode
          lda temp7
          and # $0f  ;;; Get low nybble
          ora # $70  ;;; Encode bank 7 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: return hi (encoded with bank 7)]
          lda temp6
          pha
          ;; STACK PICTURE: [SP+1: return hi (encoded)] [SP+0: return lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(FrootyJump-1)
          pha
          ;; STACK PICTURE: [SP+2: return hi (encoded)] [SP+1: return lo] [SP+0: FrootyJump hi (raw)]
          lda # <(FrootyJump-1)
          pha
          ;; STACK PICTURE: [SP+3: return hi (encoded)] [SP+2: return lo] [SP+1: FrootyJump hi (raw)] [SP+0: FrootyJump lo]
          ldx # 10
          jmp BS_jsr
.pend

DCJ_RoboTitoJump .proc
          ;; Tail call: ProcessUpAction tail-calls DispatchCharacterJump, so we can tail-call RoboTitoJump
          ;; Preserve the return address from DispatchCharacterJump's caller (ProcessUpAction in Bank 7)
          ;; and re-encode it for BS_jsr
          pla
          sta temp6  ;;; Save low byte
          pla
          sta temp7  ;;; Save high byte (raw address in Bank 7)
          ;; Encode return address with caller bank 7 ($70) for BS_return to decode
          lda temp7
          and # $0f  ;;; Get low nybble
          ora # $70  ;;; Encode bank 7 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: return hi (encoded with bank 7)]
          lda temp6
          pha
          ;; STACK PICTURE: [SP+1: return hi (encoded)] [SP+0: return lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(RoboTitoJump-1)
          pha
          ;; STACK PICTURE: [SP+2: return hi (encoded)] [SP+1: return lo] [SP+0: RoboTitoJump hi (raw)]
          lda # <(RoboTitoJump-1)
          pha
          ;; STACK PICTURE: [SP+3: return hi (encoded)] [SP+2: return lo] [SP+1: RoboTitoJump hi (raw)] [SP+0: RoboTitoJump lo]
          ldx # 9
          jmp BS_jsr
.pend

