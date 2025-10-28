          rem Animation system constants
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Platform-specific animation timing constants for 10fps character animation

          rem =================================================================
          rem ANIMATION TIMING CONSTANTS
          rem =================================================================
          rem Character frame animation runs at 10fps regardless of TV standard
          rem Movement updates run at full frame rate (60fps NTSC, 50fps PAL)

          #ifdef TV_NTSC
          const AnimationFrameDelay = 6    ; 60fps / 10fps = 6 frames
          const MovementFrameRate = 60     ; 60fps movement updates

          #ifdef TV_PAL  
          const AnimationFrameDelay = 5    ; 50fps / 10fps = 5 frames
          const MovementFrameRate = 50     ; 50fps movement updates

          #ifdef TV_SECAM
          const AnimationFrameDelay = 5    ; Same as PAL (50fps / 10fps = 5 frames)
          const MovementFrameRate = 50     ; 50fps movement updates

          rem =================================================================
          rem ANIMATION SEQUENCE CONSTANTS
          rem =================================================================
          rem 16 animation sequences (0-15) with 8 frames each
          const AnimationSequenceCount = 16
          const FramesPerSequence = 8

          rem Animation sequence indices
          const AnimStanding = 0      ; Standing still (facing right)
          const AnimIdle = 1          ; Idle (resting)
          const AnimGuarding = 2      ; Standing still guarding
          const AnimWalking = 3       ; Walking/running
          const AnimStopping = 4      ; Coming to stop
          const AnimHit = 5           ; Taking a hit
          const AnimFallBack = 6      ; Falling backwards
          const AnimFallDown = 7      ; Falling down
          const AnimFallen = 8        ; Fallen down
          const AnimRecovering = 9    ; Recovering to standing
          const AnimJumping = 10      ; Jumping
          const AnimFalling = 11      ; Falling after jump
          const AnimLanding = 12      ; Landing
          const AnimAttackWindup = 13 ; Attack windup
          const AnimAttackExecute = 14; Attack execution
          const AnimAttackRecovery = 15; Attack recovery

          rem =================================================================
          rem SUBPIXEL POSITION CONSTANTS
          rem =================================================================
          rem 16-bit position system: 8.8 fixed point
          rem Upper 8 bits = integer sprite position
          rem Lower 8 bits = fractional subpixel position
          const SubpixelBits = 8      ; 8 bits of subpixel precision
          const SubpixelScale = 256   ; 2^8 = 256 subpixel units per pixel
          const MaxSubpixelPos = 65535; Maximum 16-bit position value

          rem =================================================================
          rem ANIMATION STATE VARIABLES
          rem =================================================================
          rem These will be defined in Variables.bas but referenced here for clarity
          rem dim AnimationCounter[4]     ; Animation frame counter for each player (0 to AnimationFrameDelay-1)
          rem dim CurrentAnimationFrame[4]; Current frame within animation sequence (0-7)
          rem dim CurrentAnimationSeq[4]  ; Current animation sequence (0-15)
          rem dim PlayerSubpixelX[4]      ; 16-bit subpixel X position for each player
          rem dim PlayerSubpixelY[4]      ; 16-bit subpixel Y position for each player
          rem dim PlayerVelocityX[4]      ; 16-bit subpixel X velocity for each player
          rem dim PlayerVelocityY[4]      ; 16-bit subpixel Y velocity for each player
