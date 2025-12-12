;;; ChaosFight - Source/Routines/HarpyAttack.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


HarpyAttack .proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; Harpy (character 6) - Diagonal downward swoop attack
          ;; Attack moves the character along a 45° downward path; the sprite acts
          ;; as the hitbox for the 5-frame swoop animation.
          ;; Input: temp1 = attacker player index (0-3)
          ;; playerState[] (global array) = player state flags
          ;; characterStateFlags_R[] (global SCRAM array) =
          ;; character state flags
          ;; MaskPlayerStateFlags (constant) = bitmask to
          ;; preserve state flags
          ;; ActionAttackExecuteShifted (constant) = attack
          ;; execution animation sta

          ;; PlayerStateBitFacing (constant) = facing direction
          ;; bit
          ;;
          ;; Output: Animation state set, player velocity set for
          ;; diagonal swoop, jumping flag set,
          ;; swoop attack flag set
          ;;
          ;; Mutates: temp1-temp5 (used for calculations),
          ;; playerState[] (animation state and jumping flag set),
          ;; playerVelocityX[], playerVelocityXL[],
          ;; playerVelocityY[], playerVelocityYL[] (set for
          ;; swoop),
          ;; characterStateFlags_W[] (swoop attack flag set)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with HarpySetLeftVelocity,
          ;; HarpySetVerticalVelocity (called via jmp)

          ;; Set attack animation sta

          ;; Use temp1 directly for indexed addressing (batariBASIC
          ;; does not resolve dim aliases)
          ;; Set animation state 14 (attack execution)
          ;; playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionAttackExecuteShifted
          lda temp1
          asl
          tax
          lda playerState,x
          and # MaskPlayerStateFlags
          ora # ActionAttackExecuteShifted
          sta playerState,x

          ;; Get facing direction (bit 0: 0=left, 1=right)
          ;; Set temp2 = playerState[temp1] & PlayerStateBitFacing         
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2

          ;; Set diagonal velocity at 45° angle (4 pixels/frame
          ;; horizontal, 4 pixels/frame vertical)
          ;; Horizontal: 4 pixels/frame in facing direction
          ;; Use explicit assignment to dodge unsupported multiply op
          ;; When temp2=0 (left): want 252 (-4), when temp2≠ 0 (right): want 4
          lda # 252
          sta temp4
          ;; If temp2, then temp4 = 4
          lda temp2
          beq HarpyAttackDone
          lda # 4
          sta temp4
HarpyAttackDone:
          beq HarpySetVerticalVelocity

          lda # 4
          sta temp4

HarpySetVerticalVelocity:

.pend

HarpySetLeftVelocity .proc
          ;; Label for documentation - velocity already set above
          ;; Constraints: Must be colocated with HarpyAttack,
          ;; HarpySetVerticalVelocity

.pend

HarpySetVerticalVelocity .proc
          ;; Set vertical velocity for Harpy swoop
          ;;
          ;; Input: None (called from HarpyAttack)
          ;;
          ;; Output: temp3 set to 4, player velocity arrays set
          ;;
          ;; Mutates: temp3 (temp3 set to 4), playerVelocityX[],
          ;; playerVelocityXL[],
          ;; playerVelocityY[], playerVelocityYL[],
          ;; playerState[], characterStateFlags_W[]
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with HarpyAttack,
          ;; HarpySetLeftVelocity
          ;; Vertical: 4 pixels/frame downward (positive Y = down)
          lda # 4
          sta temp3

          ;; Set player velocity for diagonal swoop (45° angle:
          ;; 4px/frame X, 4px/frame Y) - inlined for performance
          ;; Use temp1 directly for indexed addressing (batariBASIC
          ;; does not resolve dim aliases)
          lda temp1
          asl
          tax
          lda temp4
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x
          lda temp1
          asl
          tax
          lda temp3
          sta playerVelocityY,x
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityYL,x

          ;; Set jumping state so character can move vertically during
          ;; swoop
          ;; This allows vertical movement without being on ground
          ;; Use temp1 directly for indexed addressing (batariBASIC
          ;; does not resolve dim aliases)
          ;; Set bit 2 (jumping flag)
          ;; Set playerState[temp1] = playerState[temp1] | 4
          lda temp1
          asl
          tax
          lda playerState,x
          ora # 4
          sta playerState,x

          ;; Set swoop attack flag for collision detection
          bit 2 = swoop active (used to extend hitbox below
          ;; character during swoop)
          ;; Collision system will check for hits below character
          ;; during swoop
          ;; Fix RMW: Read from _R, modify, write to _W
          ;; Use temp1 directly for indexed addressing (batariBASIC
          ;; does not resolve dim aliases)
          ;; Set temp5 = characterStateFlags_R[temp1] | 4         
          lda temp1
          asl
          tax
          lda characterStateFlags_R,x
          sta temp5
          lda temp1
          asl
          tax
          lda temp5
          sta characterStateFlags_W,x

          ;; Attack behavior:
          ;; - Character moves diagonally down at 45° (4px/frame X,
          ;; 4px/frame Y)
          ;; - Attack hitbox is below character during movement
          ;; - 5-frame attack animation duration (handled by animation
          ;; system)
          ;; - Movement continues until collision or attack animation
          ;; completes
          ;; - No missile spawned - character movement IS the attack
          ;; - Hit players are damaged and pushed (knockback handled by
          ;; collision system)
          rts

.pend

