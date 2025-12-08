;;; ChaosFight - Source/Routines/CheckGuardCooldown.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


CheckGuardCooldown .proc

          ;;
          ;; Returns: Far (return otherbank)
          ;; Check guard cooldown (1 second lockout after guard ends).
          ;; Input: temp1 = player index (0-3)
          ;; playerState[] (global array) = player state flags
          ;; (bit 1 = guarding)
          ;; playerTimers_R[] (global SCRAM array) = guard
          ;; cooldown timers
          ;;
          ;; Output: temp2 = 1 if guard allowed, 0 if in cooldown
          ;;
          ;; Mutates: temp2 (set to 0 or 1)
          ;;
          ;; Called Routines: None
          ;; Constraints: Must be colocated with GuardCooldownBlocked (called via goto)
          ;; Check if player is currently guarding
                    ;; let temp3 = playerState[temp1] & 2         
          lda temp1
          asl
          tax
          ;; lda playerState,x (duplicate)
          sta temp3
          ;; if temp3 then GuardCooldownBlocked
          ;; lda temp3 (duplicate)
          beq skip_9915
          jmp GuardCooldownBlocked
skip_9915:
          

          ;; Check cooldown timer (stored in playerTimers array)
          ;; playerTimers stores frames remaining in cooldown
                    ;; let temp3 = playerTimers_R[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerTimers_R,x (duplicate)
          ;; sta temp3 (duplicate)

          ;; lda temp3 (duplicate)
          cmp # 1
          bcc skip_892
skip_892:


          ;; Cooldown expired, guard allowed
          ;; lda # 1 (duplicate)
          ;; sta temp2 (duplicate)
          jsr BS_return

.pend

GuardCooldownBlocked .proc
          ;; Currently guarding or in cooldown - not allowed to sta

          ;; Returns: Far (return otherbank)
          ;; new guard
          ;;
          ;; Input: None (called from CheckGuardCooldown)
          ;;
          ;; Output: temp2 set to 0
          ;;
          ;; Mutates: temp2 (set to 0)
          ;;
          ;; Called Routines: None
          ;; Constraints: Must be colocated with CheckGuardCooldown
          ;; Currently guarding or in cooldown - not allowed to sta

          ;; new guard
          ;; lda # 0 (duplicate)
          ;; sta temp2 (duplicate)
          ;; jsr BS_return (duplicate)

.pend

