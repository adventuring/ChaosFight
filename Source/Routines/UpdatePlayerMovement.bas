          rem ChaosFight - Source/Routines/UpdatePlayerMovement.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

UpdatePlayerMovement
          asm
UpdatePlayerMovement
end
          rem 8.8 fixed-point movement system using batariBASIC built-in
          rem   support
          rem Movement System Routines
          rem All integers are 8-bit. Position consists of:
          rem - playerX/Y[0-3] = Integer part (8-bit, already exists in
          rem   var0-var7)
          rem - playerSubpixelX/Y[0-3] = High byte of 8.8 fixed-point
          rem   position (var/w array)
          rem - playerSubpixelX/YL[0-3] = Low byte of 8.8 fixed-point
          rem   position (fractional)
          rem Velocity consists of:
          rem - playerVelocityX[0-3] = High byte of 8.8 fixed-point X
          rem   velocity (var20-var23, ZPRAM)
          rem - playerVelocityXL[0-3] = Low byte of 8.8 fixed-point X
          rem
          rem   velocity (var24-var27, ZPRAM)
          rem - playerVelocityY[0-3] = High byte of 8.8 fixed-point Y
          rem   velocity (var28-var31, ZPRAM)
          rem - playerVelocityYL[0-3] = Low byte of 8.8 fixed-point Y
          rem   velocity (var32-var35, ZPRAM)
          rem NOTE: batariBASIC automatically handles carry operations
          rem   for 8.8 fixed-point arithmetic.
          rem When you add two 8.8 values, the compiler generates code
          rem   that:
          rem   1. Adds the low bytes (with carry)
          rem 2. Adds the high bytes (plus carry from low byte addition)
          rem This eliminates the need for manual carry checking and
          rem   propagation.
          rem Update all active players each frame (integer + subpixel positions).
          rem Input: currentPlayer (global scratch), QuadtariDetected,
          rem        playerHealth[], playerSubpixelX/Y (SCRAM arrays),
          rem        playerVelocityX/Y, playerX[], playerY[]
          rem Output: Player positions updated for every active player
          rem Mutates: currentPlayer, player positions (via UpdatePlayerMovementSingle)
          rem Called Routines: UpdatePlayerMovementSingle
          rem Constraints: Must be colocated with UpdatePlayerMovementQuadtariSkip (goto target)
          for currentPlayer = 0 to 1
          gosub UpdatePlayerMovementSingle bank8
          next
          rem Players 2-3 only if Quadtari detected
          if (controllerStatus & SetQuadtariDetected) = 0 then goto UpdatePlayerMovementQuadtariSkip
          for currentPlayer = 2 to 3
          gosub UpdatePlayerMovementSingle bank8
          next
UpdatePlayerMovementQuadtariSkip
          return

