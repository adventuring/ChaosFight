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
          #endif

          #ifdef TV_PAL  
          const AnimationFrameDelay = 5    ; 50fps / 10fps = 5 frames
          const MovementFrameRate = 50     ; 50fps movement updates
          #endif

          #ifdef TV_SECAM
          const AnimationFrameDelay = 5    ; Same as PAL (50fps / 10fps = 5 frames)
          const MovementFrameRate = 50     ; 50fps movement updates
          #endif

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
          rem Fixed-point scheme: 8.8 (integer.fraction), implemented with 8-bit bB vars
          rem NOTE: batariBASIC variables are 8-bit. Use two 8-bit arrays to represent
          rem       a 16-bit fixed-point value: Hi = integer pixels, Lo = subpixel (0..255).
          const SubpixelBits = 8      ; 8 bits of subpixel precision (0..255)
          const SubpixelScale = 256   ; 2^8 = 256 subpixel units per pixel

          rem =================================================================
          rem ANIMATION STATE VARIABLE NOTES (documentation only)
          rem =================================================================
          rem In Variables.bas, represent 8.8 fixed-point with two 8-bit arrays per axis:
          rem   PosXHi[n] = integer X pixels,  PosXLo[n] = X subpixels (0..255)
          rem   PosYHi[n] = integer Y pixels,  PosYLo[n] = Y subpixels (0..255)
          rem   VelXHi[n], VelXLo[n] for velocity; similarly VelYHi/VelYLo.
          rem Update pattern (addition):
          rem   PosXLo += VelXLo : if PosXLo < VelXLo then PosXHi += 1  ; carry
          rem   PosXHi += VelXHi
          rem Update pattern (subtraction):
          rem   borrow = (PosXLo < VelXLo)
          rem   PosXLo -= VelXLo : if borrow then PosXHi -= 1
          rem   PosXHi -= VelXHi
          rem Repeat for Y.
