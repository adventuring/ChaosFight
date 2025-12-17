;;; ChaosFight - Source/Routines/UpdatePlayerMovement.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


UpdatePlayerMovement .proc
          ;; 8.8 fixed-point movement system using batariBASIC built-in
          ;; Returns: Far (return otherbank)
          ;; support
          ;; Movement System Routines
          ;; All integers are 8-bit. Position consists of:
          ;; - playerX/Y[0-3] = Integer part (8-bit, already exists in
          ;; var0-var7)
          ;; - playerSubpixelX/Y[0-3] = High byte of 8.8 fixed-point
          ;; position (var/w array)
          ;; - playerSubpixelX/YL[0-3] = Low byte of 8.8 fixed-point
          ;; position (fractional)
          ;; Velocity consists of:
          ;; - playerVelocityX[0-3] = High byte of 8.8 fixed-point X
          ;; velocity (var20-var23, ZPRAM)
          ;; - playerVelocityXL[0-3] = Low byte of 8.8 fixed-point X
          ;; velocity (var24-var27, ZPRAM)
          ;; - playerVelocityY[0-3] = High byte of 8.8 fixed-point Y
          ;; velocity (var28-var31, ZPRAM)
          ;; - playerVelocityYL[0-3] = Low byte of 8.8 fixed-point Y
          ;; velocity (var32-var35, ZPRAM)
          ;; NOTE: batariBASIC automatically handles carry operations
          ;; for 8.8 fixed-point arithmetic.
          ;; When you add two 8.8 values, the compiler generates code
          that:
          ;; 1. Adds the low bytes (with carry)
          ;; 2. Adds the high bytes (plus carry from low byte addition)
          ;; This eliminates the need for manual carry checking and
          ;; propagation.
          ;; Update all active players each frame (integer + subpixel positions).
          ;; Input: currentPlayer (global scratch), QuadtariDetected,
          ;; playerHealth[], playerSubpixelX/Y (SCRAM arrays),
          ;; playerVelocityX/Y, playerX[], playerY[]
          ;; Output: Player positions updated for every active player
          ;; Mutates: currentPlayer, player positions (via UpdatePlayerMovementSingle)
          ;; Called Routines: UpdatePlayerMovementSingle
          ;; Constraints: Must be colocated with UpdatePlayerMovementQuadtariSkip (jmp target)
          ;; Issue #1254: Loop through currentPlayer = 0 to 1
          lda # 0
          sta currentPlayer
UPM_Players01Loop:
          ;; Cross-bank call to UpdatePlayerMovementSingle in bank 7
          ;; Return address: ENCODED with caller bank 7 ($70) for BS_return to decode
          lda # ((>(AfterUpdatePlayerMovementSingle-1)) & $0f) | $70  ;;; Encode bank 7 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterUpdatePlayerMovementSingle hi (encoded)]
          lda # <(AfterUpdatePlayerMovementSingle-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterUpdatePlayerMovementSingle hi (encoded)] [SP+0: AfterUpdatePlayerMovementSingle lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(UpdatePlayerMovementSingle-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterUpdatePlayerMovementSingle hi (encoded)] [SP+1: AfterUpdatePlayerMovementSingle lo] [SP+0: UpdatePlayerMovementSingle hi (raw)]
          lda # <(UpdatePlayerMovementSingle-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterUpdatePlayerMovementSingle hi (encoded)] [SP+2: AfterUpdatePlayerMovementSingle lo] [SP+1: UpdatePlayerMovementSingle hi (raw)] [SP+0: UpdatePlayerMovementSingle lo]
          ldx # 7
          jmp BS_jsr

AfterUpdatePlayerMovementSingle:
          ;; Issue #1254: Loop increment and check
          inc currentPlayer
          lda currentPlayer
          cmp # 2
          bcs UPM_Players01LoopDone
          jmp UPM_Players01Loop
UPM_Players01LoopDone:

          ;; Players 2-3 only if Quadtari detected

.pend

UpdatePlayerMovementQuadtariCheck .proc
          lda controllerStatus
          and # SetQuadtariDetected
          bne UpdatePlayerMovementQuadtari

          jmp UpdatePlayerMovementQuadtariSkip

UpdatePlayerMovementQuadtari:

          ;; Issue #1254: Loop through currentPlayer = 2 to 3
          lda # 2
          sta currentPlayer
UPM_Players23Loop:
          ;; Cross-bank call to UpdatePlayerMovementSingle in bank 7
          ;; Return address: ENCODED with caller bank 7 ($70) for BS_return to decode
          lda # ((>(AfterUpdatePlayerMovementSingleQuadtari-1)) & $0f) | $70  ;;; Encode bank 7 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterUpdatePlayerMovementSingleQuadtari hi (encoded)]
          lda # <(AfterUpdatePlayerMovementSingleQuadtari-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterUpdatePlayerMovementSingleQuadtari hi (encoded)] [SP+0: AfterUpdatePlayerMovementSingleQuadtari lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(UpdatePlayerMovementSingle-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterUpdatePlayerMovementSingleQuadtari hi (encoded)] [SP+1: AfterUpdatePlayerMovementSingleQuadtari lo] [SP+0: UpdatePlayerMovementSingle hi (raw)]
          lda # <(UpdatePlayerMovementSingle-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterUpdatePlayerMovementSingleQuadtari hi (encoded)] [SP+2: AfterUpdatePlayerMovementSingleQuadtari lo] [SP+1: UpdatePlayerMovementSingle hi (raw)] [SP+0: UpdatePlayerMovementSingle lo]
          ldx # 7
          jmp BS_jsr

AfterUpdatePlayerMovementSingleQuadtari:
          ;; Issue #1254: Loop increment and check
          inc currentPlayer
          lda currentPlayer
          cmp # 4
          bcs UPM_Players23LoopDone
          jmp UPM_Players23Loop
UPM_Players23LoopDone:

.pend

UpdatePlayerMovementQuadtariSkip .proc
          jmp BS_return

.pend

