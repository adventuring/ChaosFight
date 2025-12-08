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
          cmp # 0
          bne skip_5663
          ;; TODO: HCSF_CheckJoy0
skip_5663:


          ;; Players 1,3 use joy1

          ;; lda temp1 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_3179 (duplicate)
          ;; TODO: HCSF_CheckJoy0
skip_3179:


          jsr BS_return

          ;; lda # 1 (duplicate)
          sta temp2

                    ;; if joy1down then let temp4 = 1 : goto HCSF_HandleFire          lda joy1down          beq skip_7055
skip_7055:
          jmp skip_7055
          ;; lda # 0 (duplicate)
          ;; sta temp4 (duplicate)

          ;; jmp HCSF_HandleFire (duplicate)

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

          ;; jsr BS_return (duplicate)

          ;; lda # 1 (duplicate)
          ;; sta temp2 (duplicate)

                    ;; if joy0down then let temp4 = 1 : goto HCSF_HandleFire          lda joy0down          beq skip_7286
skip_7286:
          ;; jmp skip_7286 (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta temp4 (duplicate)

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

                    ;; if playerCharacter[temp1] = RandomCharacter then goto HCSF_HandleRandom

          ;; if temp4 then HCSF_HandleHandicap
          ;; lda temp4 (duplicate)
          beq skip_1914
          ;; jmp HCSF_HandleHandicap (duplicate)
skip_1914:
          

          ;; lda temp1 (duplicate)
          ;; sta temp3 (duplicate)

          ;; lda temp3 (duplicate)
          ;; sta temp1 (duplicate)

          ;; lda PlayerLockedNormal (duplicate)
          ;; sta temp2 (duplicate)

          ;; Cross-bank call to SetPlayerLocked in bank 6
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 5
          ;; jmp BS_jsr (duplicate)
return_point:


          ;; Play selection sound

          ;; lda SoundMenuSelect (duplicate)
          ;; sta temp1 (duplicate)

          ;; Cross-bank call to PlaySoundEffect in bank 15
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 14 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jsr BS_return (duplicate)

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

          ;; lda temp1 (duplicate)
          ;; sta temp3 (duplicate)

          ;; lda temp3 (duplicate)
          ;; sta temp1 (duplicate)

          ;; lda PlayerHandicapped (duplicate)
          ;; sta temp2 (duplicate)

          ;; Cross-bank call to SetPlayerLocked in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Play selection sound

          ;; lda SoundMenuSelect (duplicate)
          ;; sta temp1 (duplicate)

          ;; Cross-bank call to PlaySoundEffect in bank 15
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 14 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jsr BS_return (duplicate)

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

          ;; if handicap, 0 otherwise)

          ;;
          ;; Called Routines: PlaySoundEffect (bank15)

          ;;
          ;; Constraints: Must be colocated with

          ;; HandleCharacterSelectFire

          ;; Random selection initiated - will be handled by

          ;; CharacterSelectHandleRandomRolls

          ;; Store handicap flag if down was held

                    ;; if temp4 then let randomSelectFlags_W[temp1] = TRUE : goto HCSF_HandleRandomSound          lda temp4          beq skip_9263
skip_9263:
          ;; jmp skip_9263 (duplicate)
          ;; lda temp1 (duplicate)
          asl
          tax
          ;; lda 0 (duplicate)
          ;; sta randomSelectFlags_W,x (duplicate)

.pend

HCSF_HandleRandomSound .proc

          ;; Play selection sound
          ;; Returns: Far (return otherbank)

          ;; lda SoundMenuSelect (duplicate)
          ;; sta temp1 (duplicate)

          ;; Fall through - character will stay as RandomCharacter

          ;; Cross-bank call to PlaySoundEffect in bank 15
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 14 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; until roll succeeds

          ;; jsr BS_return (duplicate)

.pend

