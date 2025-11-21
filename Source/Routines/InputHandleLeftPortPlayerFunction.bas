          rem ChaosFight - Source/Routines/InputHandleLeftPortPlayerFunction.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

InputHandleLeftPortPlayerFunction
          asm
InputHandleLeftPortPlayerFunction

end
          rem
          rem LEFT PORT PLAYER INPUT HANDLER (joy0 - Players 1 & 3)
          rem
          rem INPUT: temp1 = player index (0 or 2)
          rem USES: joy0left, joy0right, joy0up, joy0down, joy0fire
          let currentPlayer = temp1
          rem Cache animation state at start (used for movement, jump,
          rem and attack checks)
          gosub GetPlayerAnimationStateFunction
          rem   block movement during attack animations (states 13-15)
          if temp2 >= 13 then goto DoneLeftPortMovement
          rem Block movement during attack windup/execute/recovery

          rem Process left/right movement (with playfield collision for
          rem   flying characters)
          rem Frooty (8) and Dragon of Storms (2) need collision checks
          let temp5 = playerCharacter[temp1]
          rem   for horizontal movement
          if temp5 = 8 then goto IHLP_FlyingMovement
          if temp5 = 2 then goto IHLP_FlyingMovement

          rem Standard horizontal movement (uses shared routine)
          gosub ProcessStandardMovement

DoneLeftPortMovement
IHLP_FlyingMovement
          gosub HandleFlyingCharacterMovement bank12
IHLP_DoneFlyingLeftRight

          rem Process UP input for character-specific behaviors
          gosub ProcessUpInput
          rem Returns with temp3 = 1 if UP used for jump, 0 if special ability

          rem Process jump input from enhanced buttons (must be identical
          rem   effect to ProcessUpInput for all characters)
          gosub ProcessJumpInput bank8
InputDoneLeftPortJump

          gosub HandleGuardInput bank12
          gosub HandleGuardInput bank12
          rem Process down/guard input

          rem Process attack input
          gosub ProcessAttackInput bank10
InputDoneLeftPortAttack

          return
