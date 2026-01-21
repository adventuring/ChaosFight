;;; ChaosFight - Source/Routines/CharacterSelectFire.bas

;;; Copyright © 2025 Bruce-Robert Pocock.




HandleCharacterSelectFire .proc




          ;; Handle fire input (selection)
          ;; Returns: Far (return otherbank)

          ;;
          ;; Handle fire input (selection) for a player

          ;;
          ;; Input: temp1 = player index (0-3)

          ;; joy0fire/joy0down (players 0,2) or joy1fire/joy1down (players 1,3)

          ;; playerCharacter[] (global array) = current character selections

          ;; randomSelectFlags[] (global array) = random selection flags

          ;; Output: playerLocked state updated, randomSelectFlags[] updated if random selected

          ;;
          ;; Mutates: playerLocked state (set to normal or handicap),

          ;; randomSelectFlags[] (if random),

          ;; temp1, temp2, temp3, temp4 (passed to helper

          ;; routines)

          ;;
          ;; Called Routines: SetPlayerLocked (bank6) - accesses

          ;; playerLocked sta


          ;; PlaySoundEffect (bank15) - plays selection sound

          ;;
          ;; Constraints: Must be colocated with HCSF_CheckJoy0,

          ;; HCSF_HandleFire,

          ;; HCSF_HandleHandicap, HCSF_HandleRandom (all called via goto)

          ;; Determine which joy port to use

          lda temp1
          bne CheckPlayer2Joy
          jmp HCSF_CheckJoy0
CheckPlayer2Joy:


          ;; Players 1,3 use joy1

          lda temp1
          cmp # 2
          bne CheckJoy1
          jmp HCSF_CheckJoy0
CheckJoy1:


          jmp BS_return

          lda # 1
          sta temp2

          ;; If joy1down, set temp4 = 1 and jmp HCSF_HandleFire
          lda joy1down
          beq SetNormalLock

          lda # 1
          sta temp4
          jmp HCSF_HandleFire

SetNormalLock:
          lda # 0
          sta temp4

          jmp HCSF_HandleFire

.pend

HCSF_CheckJoy0 .proc
          ;; Check joy0 for players 0,2
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: temp1 (from HandleCharacterSelectFire)

          ;; joy0fire, joy0down (hardware) = joystick sta


          ;;
          ;; Output: Dispatches to HCSF_HandleFire or returns

          ;;
          ;; Mutates: temp2, temp4

          ;;
          ;; Called Routines: None

          ;;
          ;; Constraints: Must be colocated with

          ;; HandleCharacterSelectFire

          ;; Players 0,2 use joy0

          jmp BS_return

          lda # 1
          sta temp2

          ;; If joy0down, set temp4 = 1 and jmp HCSF_HandleFire
          lda joy0down
          beq SetNormalLockJoy0

          lda # 1
          sta temp4
          jmp HCSF_HandleFire

SetNormalLockJoy0:
          lda # 0
          sta temp4

          jmp HCSF_HandleFire
          lda # 0
          sta temp4

.pend

HCSF_HandleFire .proc

          ;; Handle fire button press
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: temp1, temp4 (from

          ;; HandleCharacterSelectFire)

          ;; playerCharacter[] (global array) = current character

          ;; selections

          ;;
          ;; Output: Dispatches to HCSF_HandleRandom,

          ;; HCSF_HandleHandicap, or locks normally

          ;;
          ;; Mutates: playerLocked state, randomSelectFlags[] (if

          ;; random)

          ;;
          ;; Called Routines: SetPlayerLocked (bank6),

          ;; PlaySoundEffect (bank15)

          ;;
          ;; Constraints: Must be colocated with

          ;; HandleCharacterSelectFire

          ;; Check if RandomCharacter selected

          ;; Check for handicap mode (down+fire = 75% health)

          ;; If playerCharacter[temp1] = RandomCharacter then jmp HCSF_HandleRandom

          ;; If temp4, then HCSF_HandleHandicap
          lda temp4
          beq SetNormalLockHandleFire
          jmp HCSF_HandleHandicap
SetNormalLockHandleFire:
          

          lda temp1
          sta temp3

          lda temp3
          sta temp1

          lda PlayerLockedNormal
          sta temp2

          ;; Cross-bank call to SetPlayerLocked in bank 5
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(AfterSetPlayerLockedNormal-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSetPlayerLockedNormal hi (encoded)]
          lda # <(AfterSetPlayerLockedNormal-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSetPlayerLockedNormal hi (encoded)] [SP+0: AfterSetPlayerLockedNormal lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSetPlayerLockedNormal hi (encoded)] [SP+1: AfterSetPlayerLockedNormal lo] [SP+0: SetPlayerLocked hi (raw)]
          lda # <(SetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSetPlayerLockedNormal hi (encoded)] [SP+2: AfterSetPlayerLockedNormal lo] [SP+1: SetPlayerLocked hi (raw)] [SP+0: SetPlayerLocked lo]
          ldx # 5
          jmp BS_jsr
AfterSetPlayerLockedNormal:


          ;; Play selection sound

          lda SoundMenuSelect
          sta temp1

          ;; Cross-bank call to PlaySoundEffect in bank 14
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(AfterPlaySoundEffectNormal-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlaySoundEffectNormal hi (encoded)]
          lda # <(AfterPlaySoundEffectNormal-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlaySoundEffectNormal hi (encoded)] [SP+0: AfterPlaySoundEffectNormal lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlaySoundEffect-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlaySoundEffectNormal hi (encoded)] [SP+1: AfterPlaySoundEffectNormal lo] [SP+0: PlaySoundEffect hi (raw)]
          lda # <(PlaySoundEffect-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlaySoundEffectNormal hi (encoded)] [SP+2: AfterPlaySoundEffectNormal lo] [SP+1: PlaySoundEffect hi (raw)] [SP+0: PlaySoundEffect lo]
          ldx # 14
          jmp BS_jsr
AfterPlaySoundEffectNormal:


          jmp BS_return

.pend

HCSF_HandleHandicap .proc

          ;; Handle handicap mode selection (75% health)
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: temp1 (from HandleCharacterSelectFire)

          ;;
          ;; Output: playerLocked state set to handicap

          ;;
          ;; Mutates: playerLocked state (set to handicap)

          ;;
          ;; Called Routines: SetPlayerLocked (bank6),

          ;; PlaySoundEffect (bank15)

          ;; Constraints: Must be colocated with HandleCharacterSelectFire

          lda temp1
          sta temp3

          lda temp3
          sta temp1

          lda PlayerHandicapped
          sta temp2

          ;; Cross-bank call to SetPlayerLocked in bank 5
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(AfterSetPlayerLockedHandicap-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSetPlayerLockedHandicap hi (encoded)]
          lda # <(AfterSetPlayerLockedHandicap-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSetPlayerLockedHandicap hi (encoded)] [SP+0: AfterSetPlayerLockedHandicap lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSetPlayerLockedHandicap hi (encoded)] [SP+1: AfterSetPlayerLockedHandicap lo] [SP+0: SetPlayerLocked hi (raw)]
          lda # <(SetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSetPlayerLockedHandicap hi (encoded)] [SP+2: AfterSetPlayerLockedHandicap lo] [SP+1: SetPlayerLocked hi (raw)] [SP+0: SetPlayerLocked lo]
          ldx # 5
          jmp BS_jsr
AfterSetPlayerLockedHandicap:


          ;; Play selection sound

          lda SoundMenuSelect
          sta temp1

          ;; Cross-bank call to PlaySoundEffect in bank 14
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(AfterPlaySoundEffectHandicap-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlaySoundEffectHandicap hi (encoded)]
          lda # <(AfterPlaySoundEffectHandicap-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlaySoundEffectHandicap hi (encoded)] [SP+0: AfterPlaySoundEffectHandicap lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlaySoundEffect-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlaySoundEffectHandicap hi (encoded)] [SP+1: AfterPlaySoundEffectHandicap lo] [SP+0: PlaySoundEffect hi (raw)]
          lda # <(PlaySoundEffect-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlaySoundEffectHandicap hi (encoded)] [SP+2: AfterPlaySoundEffectHandicap lo] [SP+1: PlaySoundEffect hi (raw)] [SP+0: PlaySoundEffect lo]
          ldx # 14
          jmp BS_jsr
AfterPlaySoundEffectHandicap:


          jmp BS_return

.pend

HCSF_HandleRandom .proc

          ;; Handle random character selection
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: temp1, temp4 (from

          ;; HandleCharacterSelectFire)

          ;; randomSelectFlags[] (global array) = random

          ;; selection flags

          ;;
          ;; Output: randomSelectFlags[temp1] set, selection

          ;; sound played

          ;;
          ;; Mutates: randomSelectFlags[temp1] (set to $80

          if handicap, 0 otherwise)

          ;;
          ;; Called Routines: PlaySoundEffect (bank15)

          ;;
          ;; Constraints: Must be colocated with

          ;; HandleCharacterSelectFire

          ;; Random selection initiated - will be handled by

          ;; CharacterSelectHandleRandomRolls

          ;; Store handicap flag if down was held
          ;; If temp4, set randomSelectFlags_W[temp1] = TRUE and jmp HCSF_HandleRandomSound
          lda temp4
          beq HCSF_HandleRandomSound
          lda temp1
          asl
          tax
          lda # TRUE
          sta randomSelectFlags_W,x
HCSF_HandleRandomSound:
          jmp HCSF_HandleRandomSound
          lda temp1
          asl
          tax
          lda # 0
          sta randomSelectFlags_W,x

.pend

HCSF_HandleRandomSound .proc

          ;; Play selection sound
          ;; Returns: Far (return otherbank)

          lda SoundMenuSelect
          sta temp1

          ;; Fall through - character will stay as RandomCharacter

          ;; Cross-bank call to PlaySoundEffect in bank 14
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(AfterPlaySoundEffectRandom-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlaySoundEffectRandom hi (encoded)]
          lda # <(AfterPlaySoundEffectRandom-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlaySoundEffectRandom hi (encoded)] [SP+0: AfterPlaySoundEffectRandom lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlaySoundEffect-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlaySoundEffectRandom hi (encoded)] [SP+1: AfterPlaySoundEffectRandom lo] [SP+0: PlaySoundEffect hi (raw)]
          lda # <(PlaySoundEffect-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlaySoundEffectRandom hi (encoded)] [SP+2: AfterPlaySoundEffectRandom lo] [SP+1: PlaySoundEffect hi (raw)] [SP+0: PlaySoundEffect lo]
          ldx # 14
          jmp BS_jsr
AfterPlaySoundEffectRandom:


          ;; until roll succeeds

          jmp BS_return

.pend

