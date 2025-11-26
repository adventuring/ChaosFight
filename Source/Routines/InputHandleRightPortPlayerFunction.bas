          rem ChaosFight - Source/Routines/InputHandleRightPortPlayerFunction.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

InputHandleRightPortPlayerFunction
          asm
InputHandleRightPortPlayerFunction

end
          rem
          rem RIGHT PORT PLAYER INPUT HANDLER (joy1 - Players 2 & 4)
          rem
          rem INPUT: temp1 = player index (1 or 3)
          rem USES: joy1left, joy1right, joy1up, joy1down, joy1fire
          rem Cache animation state at start (used for movement, jump,
          let currentPlayer = temp1
          rem and attack checks)
          rem   block movement during attack animations (states 13-15)
          let temp2 = playerState[temp1] / 16
          rem Block movement during attack windup/execute/recovery
          if temp2 >= 13 then goto DoneRightPortMovement

          rem Process left/right movement (with playfield collision for
          rem   flying characters)
          rem Check if player is guarding - guard blocks movement
          let temp6 = playerState[temp1] & 2
          rem Guarding - block movement
          if temp6 then goto DoneRightPortMovement

          rem Frooty (8) and Dragon of Storms (2) need collision checks
          rem   for horizontal movement
          let temp5 = playerCharacter[temp1]
          if temp5 = 8 then goto IHRP_FlyingMovement
          if temp5 = 2 then goto IHRP_FlyingMovement

          rem Standard horizontal movement (uses shared routine)
          gosub ProcessStandardMovement bank13

DoneRightPortMovement
IHRP_FlyingMovement
          gosub HandleFlyingCharacterMovement bank12
IHRP_DoneFlyingLeftRight

          rem Process UP input for character-specific behaviors
          rem Returns with temp3 = 1 if UP used for jump, 0 if special ability
          gosub ProcessUpInput

          rem Process jump input from enhanced buttons (must be identical
          rem   effect to ProcessUpInput for all characters)
          gosub ProcessJumpInput bank8
InputDoneRightPortJump

          gosub HandleGuardInput bank12
          rem Process down/guard input
          gosub HandleGuardInput bank12

          rem Process attack input
          gosub ProcessAttackInput bank10
InputDoneRightPortAttack

          return thisbank