          rem ChaosFight - Source/Routines/RadishGoblinMovement.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Radish Goblin Bounce Movement System
          rem Complete replacement of standard movement for Radish Goblin character
          rem Character bounces off ground and walls with momentum controlled by joystick input

RadishGoblinHandleInput
          asm
RadishGoblinHandleInput
end
          rem Handle joystick input for Radish Goblin bounce movement
          rem Input: temp1 = player index (0-3)
          rem Output: Horizontal momentum added based on stick direction (only when on ground)
          rem Mutates: playerVelocityX[], playerVelocityXL[], playerState[] (facing bit)
          rem Called Routines: None
          rem Constraints: Only adds momentum when player is on ground (not jumping)
          
          rem Check if player is on ground (not jumping)
          if (playerState[temp1] & PlayerStateBitJumping) then return
          rem Player is in air, don't add horizontal momentum from input
          
          rem Determine which joy port to use based on player index
          rem Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)
          if temp1 = 0 then goto RGHI_UseJoy0
          if temp1 = 2 then goto RGHI_UseJoy0
          rem Players 1,3 use joy1
          if !joy1left then goto RGHI_CheckRight
          goto RGHI_HandleLeft
RGHI_UseJoy0
          rem Players 0,2 use joy0
          if !joy0left then goto RGHI_CheckRight
RGHI_HandleLeft
          rem Left movement: add negative velocity
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = playerVelocityX[temp1] - temp6
          let playerVelocityXL[temp1] = 0
          rem Update facing direction (unless preserving during hurt/recovery)
          if (playerState[temp1] & 8) then goto RGHI_AfterLeftSet
          rem Inline ShouldPreserveFacing logic
          gosub GetPlayerAnimationStateFunction bank13
          if temp2 < 5 then goto RGHI_SPF_No1
          if temp2 > 9 then goto RGHI_SPF_No1
          goto RGHI_AfterLeftSet
RGHI_SPF_No1
          let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
RGHI_AfterLeftSet
RGHI_CheckRight
          rem Determine which joy port to use for right movement
          if temp1 = 0 then goto RGHI_CheckRightJoy0
          if temp1 = 2 then goto RGHI_CheckRightJoy0
          rem Players 1,3 use joy1
          if !joy1right then return
          goto RGHI_HandleRight
RGHI_CheckRightJoy0
          rem Players 0,2 use joy0
          if !joy0right then return
RGHI_HandleRight
          rem Right movement: add positive velocity
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = playerVelocityX[temp1] + temp6
          let playerVelocityXL[temp1] = 0
          rem Update facing direction (unless preserving during hurt/recovery)
          if (playerState[temp1] & 8) then return
          rem Inline ShouldPreserveFacing logic
          gosub GetPlayerAnimationStateFunction bank13
          if temp2 < 5 then goto RGHI_SPF_No2
          if temp2 > 9 then goto RGHI_SPF_No2
          return
RGHI_SPF_No2
          let playerState[temp1] = playerState[temp1] | 1
          return

RadishGoblinHandleStickDown
          asm
RadishGoblinHandleStickDown
end
          rem Handle stick down for Radish Goblin (drop momentum + normal guarding)
          rem Input: temp1 = player index (0-3)
          rem Output: All momentum dropped, guarding enabled
          rem Mutates: playerVelocityX[], playerVelocityXL[], playerVelocityY[], playerVelocityYL[]
          rem Called Routines: None
          rem Constraints: Must be called when stick down is pressed
          
          rem Drop all momentum
          let playerVelocityX[temp1] = 0
          let playerVelocityXL[temp1] = 0
          let playerVelocityY[temp1] = 0
          let playerVelocityYL[temp1] = 0
          
          rem Normal guarding behavior is handled by standard guard input system
          rem This function only handles momentum dropping
          return

RadishGoblinCheckGroundBounce
          asm
RadishGoblinCheckGroundBounce
end
          rem Check for ground contact and apply bounce for Radish Goblin
          rem Input: currentPlayer = player index (0-3) (global)
          rem Output: Bounce applied if ground contact detected
          rem Mutates: playerVelocityY[], playerVelocityYL[], radishGoblinBounceState[], radishGoblinLastContactY[]
          rem Called Routines: PlayfieldRead (bank16), CheckEnhancedJumpButton
          rem Constraints: Must be called after collision detection in game loop
          
          rem Check if this player is Radish Goblin
          let temp1 = currentPlayer
          if playerCharacter[temp1] <> CharacterRadishGoblin then return
          
          rem Check if player is falling (positive Y velocity)
          if playerVelocityY[temp1] <= 0 then goto RGBGB_CheckBounceStateClear
          rem Player is falling, check for ground contact
          
          rem Convert player X position to playfield column
          let temp2 = playerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          asm
            lsr temp2
            lsr temp2
          end
          if temp2 > 31 then temp2 = 31
          if temp2 & $80 then temp2 = 0
          let temp6 = temp2
          rem Save playfield column
          
          rem Calculate row where player feet are (bottom of sprite)
          let temp3 = playerY[temp1] + PlayerSpriteHeight
          rem Feet are at playerY + PlayerSpriteHeight (16 pixels)
          let temp2 = temp3
          rem Divide by pfrowheight (16) using 4 right shifts
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
          end
          let temp4 = temp2
          rem feetRow = row where feet are
          
          rem Check if there is a playfield pixel in the row below the feet
          if temp4 >= pfrows then goto RGBGB_CheckBounceStateClear
          rem Feet are at or below bottom of playfield, continue falling
          
          let temp5 = temp4 + 1
          rem rowBelow = row below feet
          if temp5 >= pfrows then goto RGBGB_CheckBounceStateClear
          rem Beyond playfield bounds
          
          rem Check if playfield pixel exists in row below feet
          let temp3 = 0
          rem Track pfread result (1 = ground pixel set)
          let temp4 = temp1
          let temp1 = temp6
          let temp2 = temp5
          gosub PlayfieldRead bank16
          if temp1 then let temp3 = 1
          let temp1 = temp4
          if temp3 = 0 then goto RGBGB_CheckBounceStateClear
          rem No ground detected, continue falling
          
          rem Ground detected! Check if we've already bounced on this contact
          if radishGoblinBounceState_R[temp1] = 1 then goto RGBGB_CheckBounceStateClear
          rem Already bounced on this contact, wait until player leaves ground
          
          rem Check if player has moved away from last contact point
          rem If Y position changed significantly, clear bounce state
          let temp2 = playerY[temp1]
          let temp3 = radishGoblinLastContactY_R[temp1]
          if temp2 < temp3 then goto RGBGB_ClearBounceState
          let temp4 = temp2 - temp3
          if temp4 > 8 then goto RGBGB_ClearBounceState
          rem Player hasn't moved far enough, still on same contact
          goto RGBGB_ApplyBounce
          
RGBGB_ClearBounceState
          rem Player has moved away from contact point, clear bounce state
          let radishGoblinBounceState_W[temp1] = 0
          goto RGBGB_ApplyBounce
          
RGBGB_ApplyBounce
          rem Apply bounce based on fall speed and jump button
          rem Calculate bounce height
          let temp2 = RadishGoblinBounceNormal
          rem Default: normal bounce (10 pixels)
          
          rem Check if high-speed fall (TerminalVelocity or greater)
          if playerVelocityY[temp1] < TerminalVelocity then goto RGBGB_CheckJumpButton
          rem High-speed fall, use reduced bounce
          let temp2 = RadishGoblinBounceHighSpeed
          
RGBGB_CheckJumpButton
          rem Check if jump button is pressed (enhanced button or stick up)
          let temp3 = 0
          rem Check enhanced button (Genesis/Joy2b+ Button C/II)
          if temp1 = 0 then goto RGBGB_CheckEnhanced0
          if temp1 = 1 then goto RGBGB_CheckEnhanced1
          if temp1 = 2 then goto RGBGB_CheckEnhanced2
          if temp1 = 3 then goto RGBGB_CheckEnhanced3
          goto RGBGB_ApplyBounceVelocity
RGBGB_CheckEnhanced0
          if (enhancedButtonStates_R & 1) then let temp3 = 1
          goto RGBGB_CheckStickUp
RGBGB_CheckEnhanced1
          if (enhancedButtonStates_R & 2) then let temp3 = 1
          goto RGBGB_CheckStickUp
RGBGB_CheckEnhanced2
          rem Players 2-3 cannot have enhanced controllers (require Quadtari)
          goto RGBGB_CheckStickUp
RGBGB_CheckEnhanced3
          rem Players 2-3 cannot have enhanced controllers (require Quadtari)
          goto RGBGB_CheckStickUp
RGBGB_CheckStickUp
          rem Check stick up (joy0up for players 0,2; joy1up for players 1,3)
          if temp1 = 0 then goto RGBGB_CheckStickUpJoy0
          if temp1 = 2 then goto RGBGB_CheckStickUpJoy0
          rem Players 1,3 use joy1
          if joy1up then let temp3 = 1
          goto RGBGB_ApplyBounceVelocity
RGBGB_CheckStickUpJoy0
          rem Players 0,2 use joy0
          if joy0up then let temp3 = 1
          
RGBGB_ApplyBounceVelocity
          rem Apply bounce velocity (double if jump button pressed)
          if temp3 = 0 then goto RGBGB_ApplyNormalBounce
          rem Jump button pressed, double the bounce
          asm
            lda temp2
            asl a
            sta temp2
          end
RGBGB_ApplyNormalBounce
          rem Convert bounce height to upward velocity (negative = upward)
          let temp3 = 0
          let temp3 = temp3 - temp2
          let playerVelocityY[temp1] = temp3
          let playerVelocityYL[temp1] = 0
          
          rem Set jumping flag so gravity applies
          let playerState[temp1] = playerState[temp1] | PlayerStateBitJumping
          
          rem Mark that we've bounced on this contact
          let radishGoblinBounceState_W[temp1] = 1
          
          rem Store contact Y position for detecting when player leaves ground
          let radishGoblinLastContactY_W[temp1] = playerY[temp1]
          
          return
          
RGBGB_CheckBounceStateClear
          rem Check if player has moved away from last contact point to clear bounce state
          if radishGoblinBounceState_R[temp1] = 0 then return
          rem No bounce state to clear
          
          let temp2 = playerY[temp1]
          let temp3 = radishGoblinLastContactY_R[temp1]
          if temp2 < temp3 then goto RGBGB_ClearBounceState2
          let temp4 = temp2 - temp3
          if temp4 > 8 then goto RGBGB_ClearBounceState2
          rem Player hasn't moved far enough, keep bounce state
          return
          
RGBGB_ClearBounceState2
          rem Player has moved away from contact point, clear bounce state
          let radishGoblinBounceState_W[temp1] = 0
          return

RadishGoblinCheckWallBounce
          asm
RadishGoblinCheckWallBounce
end
          rem Check for wall contact and apply horizontal bounce for Radish Goblin
          rem Input: currentPlayer = player index (0-3) (global)
          rem Output: Horizontal bounce applied if wall contact detected
          rem Mutates: playerVelocityX[], playerVelocityXL[], radishGoblinLastContactX[]
          rem Called Routines: None
          rem Constraints: Must be called after collision detection in game loop
          
          rem Check if this player is Radish Goblin
          let temp1 = currentPlayer
          if playerCharacter[temp1] <> CharacterRadishGoblin then return
          
          rem Check if horizontal velocity was zeroed (indicates wall collision)
          rem This happens when collision system detects wall and zeros velocity
          rem We need to detect this and reverse the momentum
          
          rem Check if we're moving left (negative velocity) and hit left wall
          rem Or moving right (positive velocity) and hit right wall
          rem The collision system zeros velocity, so we check if we should have velocity
          rem but don't (this is tricky - we'll use a different approach)
          
          rem Instead, check if player is at a wall boundary and has no horizontal velocity
          rem but should be bouncing (this is simpler)
          
          rem For now, wall bounce is handled by reversing horizontal momentum when
          rem collision system detects wall contact. We'll detect this by checking
          rem if player is at wall position but has no velocity (collision system zeroed it)
          
          rem This is a simplified approach - in practice, we may need to track
          rem previous frame's velocity to detect when collision system zeroed it
          
          rem For initial implementation, we'll skip wall bounce detection here
          rem and handle it in the collision system modification
          rem (Wall bounce will be handled by preserving and reversing velocity in collision system)
          
          return

RadishGoblinHandleStickDownRelease
          asm
RadishGoblinHandleStickDownRelease
end
          rem Handle stick down release for Radish Goblin (short bounce if on ground)
          rem Input: temp1 = player index (0-3)
          rem Output: Short bounce applied if on ground
          rem Mutates: playerVelocityY[], playerVelocityYL[], playerState[]
          rem Called Routines: None
          rem Constraints: Must be called when stick down is released
          
          rem Check if player is on ground (not jumping)
          if (playerState[temp1] & PlayerStateBitJumping) then return
          rem Player is in air, don't apply short bounce
          
          rem Apply short bounce (5 pixels upward)
          let temp2 = 0
          let temp2 = temp2 - RadishGoblinBounceShort
          let playerVelocityY[temp1] = temp2
          let playerVelocityYL[temp1] = 0
          
          rem Set jumping flag so gravity applies
          let playerState[temp1] = playerState[temp1] | PlayerStateBitJumping
          
          rem Clear bounce state so normal bounce procedure takes over
          let radishGoblinBounceState_W[temp1] = 0
          
          return


