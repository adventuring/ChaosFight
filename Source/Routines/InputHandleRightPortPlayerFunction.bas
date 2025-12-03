          rem ChaosFight - Source/Routines/InputHandleRightPortPlayerFunction.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

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
          rem Tail call: goto instead of gosub to save 2 bytes on stack
          goto HandleFlyingCharacterMovement bank12
IHRP_DoneFlyingLeftRight

          rem Process UP input for character-specific behaviors
          rem Returns with temp3 = 1 if UP used for jump, 0 if special ability
          gosub HandleUpInput

          rem Process jump input from enhanced buttons (must be identical
          rem   effect to HandleUpInput for all characters)
          gosub ProcessJumpInput bank8
InputDoneRightPortJump

          rem Process down/guard input (fully inlined to save 2 bytes on stack)
          rem Check joy1down (right port uses joy1)
          if !joy1down then goto IHRP_CheckGuardRelease

IHRP_HandleDownPressed
          rem DOWN pressed - dispatch to character-specific down handler
          let temp4 = playerCharacter[temp1]
          if temp4 >= 32 then goto IHRP_ProcessAttack
          if temp4 = 2 then goto DragonOfStormsDown bank13
          if temp4 = 6 then goto HarpyDown bank13
          if temp4 = 8 then goto FrootyDown bank13
          if temp4 = 13 then goto IHRP_HandleRoboTitoDown
          rem Same-bank call (both in Bank 12) - saves 2 bytes vs cross-bank
          goto StandardGuard bank12

IHRP_HandleRoboTitoDown
          gosub RoboTitoDown bank13
          if temp2 = 1 then goto IHRP_ProcessAttack
          goto StandardGuard bank12

IHRP_CheckGuardRelease
          rem DOWN released - check for early guard release (inlined to save 2 bytes)
          let temp6 = playerState[temp1] & PlayerStateBitGuarding
          rem Not guarding, nothing to do
          if !temp6 then goto IHRP_ProcessAttack
          rem Stop guard early and start cooldown
          let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitGuarding)
          rem Start cooldown timer
          let playerTimers_W[temp1] = GuardTimerMaxFrames

IHRP_ProcessAttack
          rem Process attack input
          gosub ProcessAttackInput bank10
InputDoneRightPortAttack

          return thisbank