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
          ;; that:
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
          ;; Constraints: Must be colocated with UpdatePlayerMovementQuadtariSkip (goto target)
          ;; TODO: for currentPlayer = 0 to 1
          ;; Cross-bank call to UpdatePlayerMovementSingle in bank 8
          lda # >(return_point-1)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(UpdatePlayerMovementSingle-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(UpdatePlayerMovementSingle-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 7
          jmp BS_jsr
return_point:

          ;; Players 2-3 only if Quadtari detected
.pend

next_label_1_L59:.proc
          ;; lda controllerStatus (duplicate)
          and SetQuadtariDetected
          cmp # 0
          bne skip_9367
          ;; jmp UpdatePlayerMovementQuadtariSkip (duplicate)
skip_9367:

          ;; TODO: for currentPlayer = 2 to 3
          ;; Cross-bank call to UpdatePlayerMovementSingle in bank 8
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(UpdatePlayerMovementSingle-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(UpdatePlayerMovementSingle-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 7 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

.pend

next_label_2 .proc
.pend

UpdatePlayerMovementQuadtariSkip .proc
          jsr BS_return

.pend

