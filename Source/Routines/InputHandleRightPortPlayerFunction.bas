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
          let currentPlayer = temp1
          rem Cache animation state at start (used for movement, jump,
          rem and attack checks)
          gosub GetPlayerAnimationStateFunction
          rem   block movement during attack animations (states 13-15)
          if temp2 >= 13 then goto DoneRightPortMovement
          rem Block movement during attack windup/execute/recovery

          rem Process left/right movement (with playfield collision for
          rem   flying characters)
          let temp6 = playerState[temp1] & 2
          rem Check if player is guarding - guard blocks movement
          if temp6 then goto DoneRightPortMovement
          rem Guarding - block movement

          rem Frooty (8) and Dragon of Storms (2) need collision checks
          let temp5 = playerCharacter[temp1]
          rem   for horizontal movement
          if temp5 = 8 then goto IHRP_FlyingMovement
          if temp5 = 2 then goto IHRP_FlyingMovement

          rem Standard horizontal movement (uses shared routine)
          gosub ProcessStandardMovement

DoneRightPortMovement
IHRP_FlyingMovement
          gosub HandleFlyingCharacterMovement
IHRP_DoneFlyingLeftRight

          rem Process UP input for character-specific behaviors
          gosub ProcessUpInput
          rem Returns with temp3 = 1 if UP used for jump, 0 if special ability

          rem Process jump input from enhanced buttons (must be identical
          rem   effect to ProcessUpInput for all characters)
          gosub ProcessJumpInput
InputDoneRightPortJump

          gosub HandleGuardInput
          rem Process down/guard input

          rem Process attack input
          gosub ProcessAttackInput
InputDoneRightPortAttack

          return
