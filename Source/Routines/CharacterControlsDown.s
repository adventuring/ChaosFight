;;; DOWN BUTTON HANDLERS (Called via on goto from PlayerInput)

DragonOfStormsDown
;;; Returns: Far (return otherbank)

          jsr BS_return


          ;; TODO: DragonOfStormsDown = .DragonOfStormsDown


          ;; DRAGON OF STORMS (2) - FLY DOWN (no guard action)
          ;; Returns: Far (return otherbank)

          ;; Dragon of Storms flies down instead of guarding

          ;;
          ;; INPUT: temp1 = player index

          ;; USES: playerX[temp1], playerY[temp1], temp2, temp3, temp4

          ;; Dragon of Storms flies down with playfield collision check

          ;;
          ;; Input: temp1 = player index (0-3), playerX[], playerY[]

          ;; (global arrays) = player positions, ScreenInsetX (global

          ;; constant) = screen × inset

          ;;
          ;; Output: Downward velocity applied if clear below, guard

          ;; bit cleared

          ;;
          ;; Mutates: temp1-temp4 (used for calculations),

          ;; playerVelocityY[], playerVelocityYL[] (global arrays) =

          ;; vertical velocity, playerState[] (global array) = player

          ;; states (guard bit cleared)

          ;;
          ;; Called Routines: None

          ;;
          ;; Constraints: Only moves down if row below is clear. Cannot

          ;; move if already at bottom. Uses inline coordinate

          ;; conversion (not shared subroutine)

          ;; Fly down with playfield collision check

          ;; Check collision before moving

                    ;; let temp2 = playerX[temp1]         
          lda temp1
          asl
          tax
          ;; lda playerX,x (duplicate)
          sta temp2

          ;; ;; let temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc ScreenInsetX          sta temp2
          ;; lda temp2 (duplicate)
          sec
          sbc ScreenInsetX
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp2 (duplicate)


          ;; pfColumn = playfield column (0-31)

          ;; ;; let temp2 = temp2 / 4          lda temp2          lsr          lsr          sta temp2
          ;; lda temp2 (duplicate)
          lsr
          ;; lsr (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; sta temp2 (duplicate)


          ;; Check for wraparound: if subtraction wrapped negative, result ≥ 128

                    ;; if temp2 & $80 then let temp2 = 0
          ;; lda temp2 (duplicate)
          cmp # 32
          bcc skip_2621
          ;; lda # 31 (duplicate)
          ;; sta temp2 (duplicate)
skip_2621:




          ;; Check row below player (feet at bottom of sprite)

                    ;; let temp3 = playerY[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp3 (duplicate)

          ;; pfrowheight is always 16, so divide by 16

          ;; lda temp3 (duplicate)
          clc
          adc # 16
          ;; sta temp3 (duplicate)

          ;; feetY = feet Y position

                    ;; let temp4 = temp3 / 16

          ;; feetRow = row below feet

          ;; Check if at or beyond bottom row

          ;; At bottom, cannot move down
          ;; jsr BS_return (duplicate)

          ;; Check if playfield pixel is clear

          ;; Track pfread result (1 = blocked)

          ;; lda # 0 (duplicate)
          ;; sta temp5 (duplicate)

          ;; lda temp1 (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sta temp1 (duplicate)

          ;; lda temp4 (duplicate)
          ;; sta temp2 (duplicate)

          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 15
          jmp BS_jsr
return_point:


                    ;; if temp1 then let temp5 = 1          lda temp1          beq skip_955
skip_955:
          ;; jmp skip_955 (duplicate)
          ;; lda temp6 (duplicate)
          ;; sta temp1 (duplicate)

          ;; Blocked, cannot move down

          ;; jsr BS_return (duplicate)



          ;; Clear below - apply downward velocity impulse

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 2 (duplicate)
          ;; sta playerVelocityY,x (duplicate)

          ;; +2 pixels/frame downward

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityYL,x (duplicate)

          ;; Ensure guard bit clear

                    ;; let playerState[temp1] = playerState[temp1] & !2
          ;; jsr BS_return (duplicate)




HarpyDown .proc
          ;; Returns: Far (return otherbank)

          ;; jsr BS_return (duplicate)


          ;; TODO: HarpyDown = .HarpyDown


          ;; HARPY (6) - FLY DOWN (no guard action)
          ;; Returns: Far (return otherbank)

          ;; Harpy flies down instead of guarding

          ;;
          ;; INPUT: temp1 = player index

          ;; USES: playerX[temp1], playerY[temp1], temp2, temp3, temp4

          ;; Harpy flies down with playfield collision check, sets dive

          ;; mode if airborne

          ;;
          ;; Input: temp1 = player index (0-3), playerX[], playerY[]

          ;; (global arrays) = player positions, playerState[] (global

          ;; array) = player states, characterStateFlags_R[] (global

          ;; SCRAM array) = character state flags, ScreenInsetX (global

          ;; constant) = screen × inset

          ;;
          ;; Output: Downward velocity applied if clear below, dive

          ;; mode set if airborne, guard bit cleared

          ;;
          ;; Mutates: temp1-temp4 (used for calculations),

          ;; playerVelocityY[], playerVelocityYL[] (global arrays) =

          ;; vertical velocity, playerState[] (global array) = player

          ;; states (guard bit cleared), characterStateFlags_W[]

          ;; (global SCRAM array) = character state flags (dive mode

          ;; set if airborne)

          ;;
          ;; Called Routines: None

          ;;
          ;; Constraints: Only moves down if row below is clear. Cannot

          ;; move if already at bottom. Sets dive mode if airborne

          ;; (jumping flag set or Y < 60). Uses inline coordinate

          ;; conversion (not shared subroutine)

          ;; Check if Harpy is airborne and set dive mode

                    ;; if (playerState[temp1] & 4) then HarpySetDive

          ;; Jumping bit set, airborne

                    ;; let temp2 = playerY[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp2 (duplicate)

          ;; ;; if temp2 < 60 then HarpySetDive
          ;; lda temp2 (duplicate)
          ;; cmp # 60 (duplicate)
          bcs skip_953
          ;; jmp HarpySetDive (duplicate)
skip_953:

          ;; lda temp2 (duplicate)
          ;; cmp # 60 (duplicate)
          ;; bcs skip_8696 (duplicate)
          ;; jmp HarpySetDive (duplicate)
skip_8696:



          ;; Above ground level, airborne

          ;; jmp HarpyNormalDown (duplicate)

.pend

HarpySetDive .proc

          ;; Helper: Sets dive mode flag for Harpy when airborne
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: temp1 = player index, characterStateFlags_R[]

          ;; (global SCRAM array) = character state flags

          ;;
          ;; Output: Dive mode flag set (bit 2)

          ;;
          ;; Mutates: temp5 (scratch), characterStateFlags_W[] (global

          ;; SCRAM array) = character state flags (dive mode set)

          ;;
          ;; Called Routines: None

          ;; Constraints: Internal helper for HarpyDown, only called when airborne

          ;; Set dive mode flag for increased damage and normal gravity

          ;; dim HSD_stateFlags = temp5 (dim removed - variable definitions handled elsewhere)

          ;; Fix RMW: Read from _R, modify, write to _W

                    ;; let HSD_stateFlags = characterStateFlags_R[temp1] | 4         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda characterStateFlags_R,x (duplicate)
          ;; sta HSD_stateFlags (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda HSD_stateFlags (duplicate)
          ;; sta characterStateFlags_W,x (duplicate)

.pend

HarpyNormalDown .proc

          ;; Set bit 2 (dive mode)
          ;; Returns: Far (return otherbank)

          ;; Helper: Handles Harpy flying down with collision check

          ;;
          ;; Input: temp1 = player index, playerX[], playerY[] (global

          ;; arrays) = player positions, ScreenInsetX (global consta


          ;; = screen × inset

          ;;
          ;; Output: Downward velocity applied if clear below, guard

          ;; bit cleared

          ;;
          ;; Mutates: temp1-temp4 (used for calculations),

          ;; playerVelocityY[], playerVelocityYL[] (global arrays) =

          ;; vertical velocity, playerState[] (global array) = player

          ;; states (guard bit cleared)

          ;;
          ;; Called Routines: None

          ;; Constraints: Internal helper for HarpyDown, handles downward movement

          ;; Fly down with playfield collision check

          ;; Check collision before moving

                    ;; let temp2 = playerX[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sta temp2 (duplicate)

          ;; ;; let temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc ScreenInsetX          sta temp2
          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp2 (duplicate)


          ;; pfColumn = playfield column (0-31)

          ;; ;; let temp2 = temp2 / 4          lda temp2          lsr          lsr          sta temp2
          ;; lda temp2 (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; sta temp2 (duplicate)


          ;; Check for wraparound: if subtraction wrapped negative, result ≥ 128

                    ;; if temp2 & $80 then let temp2 = 0
          ;; lda temp2 (duplicate)
          ;; cmp # 32 (duplicate)
          ;; bcc skip_2621 (duplicate)
          ;; lda # 31 (duplicate)
          ;; sta temp2 (duplicate)
;; skip_2621: (duplicate)




          ;; Check row below player (feet at bottom of sprite)

                    ;; let temp3 = playerY[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp3 (duplicate)

          ;; pfrowheight is always 16, so divide by 16

          ;; lda temp3 (duplicate)
          ;; clc (duplicate)
          ;; adc # 16 (duplicate)
          ;; sta temp3 (duplicate)

          ;; feetY = feet Y position

                    ;; let temp4 = temp3 / 16

          ;; feetRow = row below feet

          ;; Check if at or beyond bottom row

          ;; At bottom, cannot move down
          ;; jsr BS_return (duplicate)

          ;; Check if playfield pixel is clear

          ;; Track pfread result (1 = blocked)

          ;; lda # 0 (duplicate)
          ;; sta temp5 (duplicate)

          ;; lda temp1 (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sta temp1 (duplicate)

          ;; lda temp4 (duplicate)
          ;; sta temp2 (duplicate)

          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


                    ;; if temp1 then let temp5 = 1          lda temp1          beq skip_955
;; skip_955: (duplicate)
          ;; jmp skip_955 (duplicate)
          ;; lda temp6 (duplicate)
          ;; sta temp1 (duplicate)

          ;; Blocked, cannot move down

          ;; jsr BS_return (duplicate)



          ;; Clear below - apply downward velocity impulse

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 2 (duplicate)
          ;; sta playerVelocityY,x (duplicate)

          ;; +2 pixels/frame downward

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityYL,x (duplicate)

          ;; Ensure guard bit clear

                    ;; let playerState[temp1] = playerState[temp1] & !2
          ;; jsr BS_return (duplicate)

.pend

FrootyDown .proc

          ;; jsr BS_return (duplicate)


          ;; TODO: FrootyDown = .FrootyDown


          ;; FROOTY (8) - FLY DOWN (no guard action)

          ;; Frooty flies down instead of guarding

          ;;
          ;; INPUT: temp1 = player index

          ;; USES: playerX[temp1], playerY[temp1], temp2, temp3, temp4

          ;; Frooty flies down with playfield collision check

          ;; (permanent flight)

          ;;
          ;; Input: temp1 = player index (0-3), playerX[], playerY[]

          ;; (global arrays) = player positions, ScreenInsetX (global

          ;; constant) = screen × inset

          ;;
          ;; Output: Downward velocity applied if clear below, guard

          ;; bit cleared

          ;;
          ;; Mutates: temp1-temp4 (used for calculations),

          ;; playerVelocityY[], playerVelocityYL[] (global arrays) =

          ;; vertical velocity, playerState[] (global array) = player

          ;; states (guard bit cleared)

          ;;
          ;; Called Routines: None

          ;;
          ;; Constraints: Only moves down if row below is clear. Cannot

          ;; move if already at bottom. Uses inline coordinate

          ;; conversion (not shared subroutine)

          ;; Fly down with playfield collision check

          ;; Check collision before moving

                    ;; let temp2 = playerX[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sta temp2 (duplicate)

          ;; ;; let temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc ScreenInsetX          sta temp2
          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp2 (duplicate)


          ;; pfColumn = playfield column (0-31)

          ;; ;; let temp2 = temp2 / 4          lda temp2          lsr          lsr          sta temp2
          ;; lda temp2 (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; sta temp2 (duplicate)


          ;; result ≥ 128

          ;; Check for wraparound: if subtraction wrapped negative,

                    ;; if temp2 & $80 then let temp2 = 0
          ;; lda temp2 (duplicate)
          ;; cmp # 32 (duplicate)
          ;; bcc skip_2621 (duplicate)
          ;; lda # 31 (duplicate)
          ;; sta temp2 (duplicate)
;; skip_2621: (duplicate)




          ;; Check row below player (feet at bottom of sprite)

                    ;; let temp3 = playerY[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp3 (duplicate)

          ;; pfrowheight is always 16, so divide by 16

                    ;; let temp4 = temp3 / 16

          ;; feetY = feet Y position

          dec temp4

          ;; feetRow = row below feet

          ;; Check if at or beyond bottom row

          ;; At bottom, cannot move down
          ;; jsr BS_return (duplicate)

          ;; Check if playfield pixel is clear

          ;; Track pfread result (1 = blocked)

          ;; lda # 0 (duplicate)
          ;; sta temp5 (duplicate)

          ;; lda temp1 (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sta temp1 (duplicate)

          ;; lda temp4 (duplicate)
          ;; sta temp2 (duplicate)

          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


                    ;; if temp1 then let temp5 = 1          lda temp1          beq skip_955
;; skip_955: (duplicate)
          ;; jmp skip_955 (duplicate)
          ;; lda temp6 (duplicate)
          ;; sta temp1 (duplicate)

          ;; Blocked, cannot move down

          ;; jsr BS_return (duplicate)



          ;; Clear below - apply downward velocity impulse

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 2 (duplicate)
          ;; sta playerVelocityY,x (duplicate)

          ;; +2 pixels/frame downward

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityYL,x (duplicate)

          ;; Ensure guard bit clear

                    ;; let playerState[temp1] = playerState[temp1] & !2
          ;; jsr BS_return (duplicate)



.pend

RoboTitoDown .proc


          ;; ROBO TITO (13) - DOWN: Drops if latched, else guards
          ;; Returns: Far (return otherbank)

          ;; Voluntary drop from ceiling if latched; otherwise standard guard

          ;; Input: temp1 = player index

          ;; Output: Drop (cleared latched bit, falling state) or guard

          ;; Mutates: temp2 (drop flag), characterStateFlags_W[], playerState[],

          ;; missileStretchHeight_W[]

          ;; Calls: StandardGuard if not latched via dispatcher helper

          ;; If latched, drop; else guard

          ;; lda # 0 (duplicate)
          ;; sta temp2 (duplicate)

          ;; Not latched, dispatcher will fall through to StandardGuard

          ;; lda characterStateFlags_R[temp1] (duplicate)
          and 1
          ;; cmp # 0 (duplicate)
          bne skip_3661
skip_3661:


          ;; jsr BS_return (duplicate)

.pend

RoboTitoInitiateDrop .proc

          ;; Signal dispatcher to skip guard after voluntary drop
          ;; Returns: Far (return otherbank)

          ;; lda # 1 (duplicate)
          ;; sta temp2 (duplicate)

          ;; fall through to RoboTitoVoluntaryDrop



.pend

RoboTitoVoluntaryDrop .proc

          ;; RoboTito drops from ceiling on DOWN; clears latched bit, sets falling, resets stretch height
          ;; Returns: Far (return otherbank)

          ;; Fix RMW: Read from _R, modify, write to _W

                    ;; let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & ($ff ^ PlayerStateBitFacing)

          ;; Clear latched bit (bit 0)

                    ;; let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionFallingShifted
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; and MaskPlayerStateFlags (duplicate)
          ora ActionFallingShifted
          ;; sta playerState,x (duplicate)

          ;; Set falling animation

          ;; Clear stretch missile height when dropping
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta missileStretchHeight_W,x (duplicate)

          ;; jsr BS_return (duplicate)



          ;; StandardJump is defined in CharacterControlsJump.bas (bank 12)

          ;; This duplicate definition has been removed to fix label conflict

          ;; Apply upward velocity impulse (input applies impulse to

          ;; rigid body)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 246 (duplicate)
          ;; sta playerVelocityY,x (duplicate)

          ;; -10 in 8-bit two’s complement: 256 - 10 = 246

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityYL,x (duplicate)

          ;; Set jumping bit

                    ;; let playerState[temp1] = playerState[temp1] | 4
          ;; jsr BS_return (duplicate)

.pend

StandardGuard .proc

          ;; jsr BS_return (duplicate)


;; StandardGuard = .StandardGuard (duplicate)


          ;; Standard guard behavior

          ;;
          ;; INPUT: temp1 = player index

          ;; USES: playerState[temp1], playerTimers[temp1]

          ;; Used by: Bernie, Curler, Zoe Ryen, Fat Tony, Megax, Knight Guy,

          ;; Nefertem, Ninjish Guy, Pork Chop, Radish Goblin, Ursulo,

          ;; Shamone, MethHound, and placeholder characters (16-30)

          ;; NOTE: Flying characters (Frooty, Dragon of Storms, Harpy)

          ;; cannot guard

          ;; Standard guard behavior used by most characters (blocks

          ;; attacks, forces cyan guard tint)

          ;;
          ;; Input: temp1 = player index (0-3), playerCharacter[] (global

          ;; array) = character types

          ;;
          ;; Output: Guard activated if allowed (not flying character,

          ;; not in cooldown)

          ;;
          ;; Mutates: temp1-temp4 (used for calculations),

          ;; playerState[], playerTimers[] (global arrays) = player

          ;; states and timers (via StartGuard)

          ;;
          ;; Called Routines: CheckGuardCooldown (bank6) - checks

          ;; guard cooldown, StartGuard (bank6) - activates guard

          ;;
          ;; Constraints: Flying characters (Frooty=8, Dragon of

          ;; Storms=2, Harpy=6) cannot guard. Guard blocked if in

          ;; cooldown

          ;; Flying characters cannot guard - DOWN is used for vertical

          ;; movement

          ;; Frooty (8): DOWN = fly down (no gravity)

          ;; Dragon of Storms (2): DOWN = fly down (no gravity)

          ;; Harpy (6): DOWN = fly down (reduced gravity)

                    ;; let temp4 = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp4 (duplicate)

          ;; jsr BS_return (duplicate)

          ;; jsr BS_return (duplicate)

          ;; jsr BS_return (duplicate)



          ;; Check if guard is allowed (not in cooldown)

          ;; Cross-bank call to CheckGuardCooldown in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(CheckGuardCooldown-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(CheckGuardCooldown-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Guard blocked by cooldown

          ;; jsr BS_return (duplicate)



          ;; Activate guard state - inlined (StartGuard)

          ;; Set guard bit in playerState

                    ;; let playerState[temp1] = playerState[temp1] | 2

          ;; Set guard duration timer
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda GuardTimerMaxFrames (duplicate)
          ;; sta playerTimers_W,x (duplicate)

          ;; jsr BS_return (duplicate)



.pend

