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

          bit cleared

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

                    let temp2 = playerX[temp1]         
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp2

          ;; let temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc ScreenInsetX          sta temp2
          lda temp2
          sec
          sbc ScreenInsetX
          sta temp2

          lda temp2
          sec
          sbc ScreenInsetX
          sta temp2


          ;; pfColumn = playfield column (0-31)

          ;; let temp2 = temp2 / 4          lda temp2          lsr          lsr          sta temp2
          lda temp2
          lsr
          lsr
          sta temp2

          lda temp2
          lsr
          lsr
          sta temp2


          ;; Check for wraparound: if subtraction wrapped negative, result ≥ 128

                    if temp2 & $80 then let temp2 = 0
          lda temp2
          cmp # 32
          bcc skip_2492
          lda # 31
          sta temp2
skip_2492:




          ;; Check row below player (feet at bottom of sprite)

                    let temp3 = playerY[temp1]         
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp3

          ;; pfrowheight is always 16, so divide by 16

          lda temp3
          clc
          adc # 16
          sta temp3

          ;; feetY = feet Y position

                    let temp4 = temp3 / 16

          ;; feetRow = row below feet

          ;; Check if at or beyond bottom row

          ;; At bottom, cannot move down
          jsr BS_return

          ;; Check if playfield pixel is clear

          ;; Track pfread result (1 = blocked)

          lda # 0
          sta temp5

          lda temp1
          sta temp6

          lda temp2
          sta temp1

          lda temp4
          sta temp2

          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(CDH_return_point_1-1)
          pha
          lda # <(CDH_return_point_1-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
CDH_return_point_1:


                    if temp1 then let temp5 = 1          lda temp1          beq skip_955
skip_955:
          jmp skip_955
          lda temp6
          sta temp1

          ;; Blocked, cannot move down

          jsr BS_return



          ;; Clear below - apply downward velocity impulse

          lda temp1
          asl
          tax
          lda 2
          sta playerVelocityY,x

          ;; +2 pixels/frame downward

          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityYL,x

          ;; Ensure guard bit clear

                    let playerState[temp1] = playerState[temp1] & !2
          jsr BS_return




HarpyDown .proc
          ;; Returns: Far (return otherbank)

          jsr BS_return


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

                    if (playerState[temp1] & 4) then HarpySetDive

          ;; Jumping bit set, airborne

                    let temp2 = playerY[temp1]         
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp2

          ;; if temp2 < 60 then HarpySetDive
          lda temp2
          cmp # 60
          bcs skip_953
          jmp HarpySetDive
skip_953:

          lda temp2
          cmp # 60
          bcs skip_8696
          jmp HarpySetDive
skip_8696:



          ;; Above ground level, airborne

          jmp HarpyNormalDown

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


          ;; Fix RMW: Read from _R, modify, write to _W

                    let HSD_stateFlags = characterStateFlags_R[temp1] | 4         
          lda temp1
          asl
          tax
          lda characterStateFlags_R,x
          sta HSD_stateFlags

          lda temp1
          asl
          tax
          lda HSD_stateFlags
          sta characterStateFlags_W,x

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

          bit cleared

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

                    let temp2 = playerX[temp1]         
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp2

          ;; let temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc ScreenInsetX          sta temp2
          lda temp2
          sec
          sbc ScreenInsetX
          sta temp2

          lda temp2
          sec
          sbc ScreenInsetX
          sta temp2


          ;; pfColumn = playfield column (0-31)

          ;; let temp2 = temp2 / 4          lda temp2          lsr          lsr          sta temp2
          lda temp2
          lsr
          lsr
          sta temp2

          lda temp2
          lsr
          lsr
          sta temp2


          ;; Check for wraparound: if subtraction wrapped negative, result ≥ 128

                    if temp2 & $80 then let temp2 = 0
          lda temp2
          cmp # 32
          bcc skip_2492
          lda # 31
          sta temp2
skip_2492:




          ;; Check row below player (feet at bottom of sprite)

                    let temp3 = playerY[temp1]         
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp3

          ;; pfrowheight is always 16, so divide by 16

          lda temp3
          clc
          adc # 16
          sta temp3

          ;; feetY = feet Y position

                    let temp4 = temp3 / 16

          ;; feetRow = row below feet

          ;; Check if at or beyond bottom row

          ;; At bottom, cannot move down
          jsr BS_return

          ;; Check if playfield pixel is clear

          ;; Track pfread result (1 = blocked)

          lda # 0
          sta temp5

          lda temp1
          sta temp6

          lda temp2
          sta temp1

          lda temp4
          sta temp2

          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
return_point:


                    if temp1 then let temp5 = 1          lda temp1          beq skip_955
skip_955:
          jmp skip_955
          lda temp6
          sta temp1

          ;; Blocked, cannot move down

          jsr BS_return



          ;; Clear below - apply downward velocity impulse

          lda temp1
          asl
          tax
          lda 2
          sta playerVelocityY,x

          ;; +2 pixels/frame downward

          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityYL,x

          ;; Ensure guard bit clear

                    let playerState[temp1] = playerState[temp1] & !2
          jsr BS_return

.pend

FrootyDown .proc

          jsr BS_return


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

          bit cleared

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

                    let temp2 = playerX[temp1]         
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp2

          ;; let temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc ScreenInsetX          sta temp2
          lda temp2
          sec
          sbc ScreenInsetX
          sta temp2

          lda temp2
          sec
          sbc ScreenInsetX
          sta temp2


          ;; pfColumn = playfield column (0-31)

          ;; let temp2 = temp2 / 4          lda temp2          lsr          lsr          sta temp2
          lda temp2
          lsr
          lsr
          sta temp2

          lda temp2
          lsr
          lsr
          sta temp2


          ;; result ≥ 128

          ;; Check for wraparound: if subtraction wrapped negative,

                    if temp2 & $80 then let temp2 = 0
          lda temp2
          cmp # 32
          bcc skip_2492
          lda # 31
          sta temp2
skip_2492:




          ;; Check row below player (feet at bottom of sprite)

                    let temp3 = playerY[temp1]         
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp3

          ;; pfrowheight is always 16, so divide by 16

                    let temp4 = temp3 / 16

          ;; feetY = feet Y position

          dec temp4

          ;; feetRow = row below feet

          ;; Check if at or beyond bottom row

          ;; At bottom, cannot move down
          jsr BS_return

          ;; Check if playfield pixel is clear

          ;; Track pfread result (1 = blocked)

          lda # 0
          sta temp5

          lda temp1
          sta temp6

          lda temp2
          sta temp1

          lda temp4
          sta temp2

          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
return_point:


                    if temp1 then let temp5 = 1          lda temp1          beq skip_955
skip_955:
          jmp skip_955
          lda temp6
          sta temp1

          ;; Blocked, cannot move down

          jsr BS_return



          ;; Clear below - apply downward velocity impulse

          lda temp1
          asl
          tax
          lda 2
          sta playerVelocityY,x

          ;; +2 pixels/frame downward

          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityYL,x

          ;; Ensure guard bit clear

                    let playerState[temp1] = playerState[temp1] & !2
          jsr BS_return



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

          If latched, drop; else guard

          lda # 0
          sta temp2

          ;; Not latched, dispatcher will fall through to StandardGuard

          lda characterStateFlags_R[temp1]
          and 1
          cmp # 0
          bne skip_9964
skip_9964:


          jsr BS_return

.pend

RoboTitoInitiateDrop .proc

          ;; Signal dispatcher to skip guard after voluntary drop
          ;; Returns: Far (return otherbank)

          lda # 1
          sta temp2

          ;; fall through to RoboTitoVoluntaryDrop



.pend

RoboTitoVoluntaryDrop .proc

          ;; RoboTito drops from ceiling on DOWN; clears latched bit, sets falling, resets stretch height
          ;; Returns: Far (return otherbank)

          ;; Fix RMW: Read from _R, modify, write to _W

                    let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & ($ff ^ PlayerStateBitFacing)

          ;; Clear latched bit (bit 0)

                    let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionFallingShifted
          lda temp1
          asl
          tax
          lda playerState,x
          and MaskPlayerStateFlags
          ora ActionFallingShifted
          sta playerState,x

          ;; Set falling animation

          ;; Clear stretch missile height when dropping
          lda temp1
          asl
          tax
          lda 0
          sta missileStretchHeight_W,x

          jsr BS_return



          ;; StandardJump is defined in CharacterControlsJump.bas (bank 12)

          ;; This duplicate definition has been removed to fix label conflict

          ;; Apply upward velocity impulse (input applies impulse to

          ;; rigid body)

          lda temp1
          asl
          tax
          lda 246
          sta playerVelocityY,x

          ;; -10 in 8-bit two’s complement: 256 - 10 = 246

          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityYL,x

          ;; Set jumping bit

                    let playerState[temp1] = playerState[temp1] | 4
          jsr BS_return

          ;; StandardGuard is in Bank 12 (same bank as HandleGuardInput)




.pend

