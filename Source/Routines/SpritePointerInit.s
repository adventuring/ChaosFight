
InitializeSpritePointers .proc

          ;;
          ;; Returns: Far (return otherbank)
          ;; ChaosFight - Source/Routines/SpritePointerInit.bas
          ;; Copyright © 2025 Bruce-Robert Pocock.
          ;; Sprite Pointer Initialization
          ;;
          ;; Sets all sprite pointers to point to SCRAM buffers
          ;; Called once at game initialization
          ;;
          ;; RAM Buffer Layout (64 bytes total):
          ;; P0: r000-r015 ($F080-$F08F) - 16 bytes
          ;; P1: r016-r031 ($F090-$F09F) - 16 bytes
          ;; P2: r032-r047 ($F0A0-$F0AF) - 16 bytes
          ;; P3: r048-r063 ($F0B0-$F0BF) - 16 bytes
          ;; Note: Pointers are set to SCRAM read ports (r000-r063)
          ;; Kernel will automatically adjust these pointers for Y
          ;; offsets
          ;; during rendering. The kernel existing pointer adjustment
          ;; logic works perfectly with RAM addresses.
          ;; Sets all sprite pointers to point to SCRAM buffers
          ;;
          ;; Input: None (initialization routine)
          ;;
          ;; Output: player0pointerlo/hi, player1pointerlo/hi,
          ;; player2pointerlo/hi,
          ;; player3pointerlo/hi set to SCRAM read port
          ;; addresses
          ;;
          ;; Mutates: player0pointerlo, player0pointerhi (set to
          ;; $80/$F0 for r000),
          ;; player1pointerlo, player1pointerhi (set to $90/$F0
          ;; for r016),
          ;; player2pointerlo, player2pointerhi (set to $A0/$F0
          ;; for r032),
          ;; player3pointerlo, player3pointerhi (set to $B0/$F0
          ;; for r048)
          ;;
          ;; Called Routines: None (uses inline assembly)
          ;;
          ;; Constraints: Called once at game initialization (from
          ;; ColdStart, BeginGameLoop)
          ;; Set Player 0 pointer to r000 ($F080)
          ;; player0pointer is 16-bit pointer (player0pointerlo +
          ;; player0pointerhi)
          ;; Low byte: $80 (base address of r000)
          ;; High byte: $F0 (SCRAM read port base)
          player0pointerlo = $80
          player0pointerhi = $F0

          ;; Set Player 1 pointer to r016 ($F090)
          ;; player1pointerlo/hi are arrays indexed by sprite number
          ;; Index 0 = Player 1, Index 1 = Player 2, Index 2 = Player 3
          ;; Note: player1pointerlo[0] is actually player1pointerlo
          ;; memory location
          ;; player1pointerlo[1] is player2pointerlo, etc.
            lda #$90
            ; Low byte for r016 ($F090)
            sta player1pointerlo  ; Player 1 pointer low byte
            lda #$F0
            ; High byte (SCRAM read port)
            sta player1pointerhi  ; Player 1 pointer high byte

            lda #$A0
            ; Low byte for r032 ($F0A0)
            sta player2pointerlo  ; Player 2 pointer low byte
            lda #$F0
            ; High byte (SCRAM read port)
            sta player2pointerhi  ; Player 2 pointer high byte

            lda #$B0
            ; Low byte for r048 ($F0B0)
            sta player3pointerlo  ; Player 3 pointer low byte
            lda #$F0
            ; High byte (SCRAM read port)
            sta player3pointerhi  ; Player 3 pointer high byte

          ;; Note: Kernel will adjust these pointers for Y offsets
          ;; automatically
          ;; The kernel existing pointer adjustment logic works
          ;; perfectly with RAM
          ;; addresses. No kernel modifications needed!
          ;; InitializeSpritePointers is called both same-bank (from ColdStart bank14)
          and cross-bank (from BeginGameLoop bank11). Since it’s called cross-bank,
          ;; it must always use return otherbank per the fundamental rule.
          jsr BS_return


.pend

