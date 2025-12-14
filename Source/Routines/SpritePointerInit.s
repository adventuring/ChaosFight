
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
          ;; Output: player0PointerLo/hi, player1PointerLo/hi,
          ;; player2PointerLo/hi,
          ;; player3PointerLo/hi set to SCRAM read port
          ;; addresses
          ;;
          ;; Mutates: player0PointerLo, player0PointerHi (set to
          ;; $80/$F0 for r000),
          ;; player1PointerLo, player1PointerHi (set to $90/$F0
          ;; for r016),
          ;; player2PointerLo, player2PointerHi (set to $A0/$F0
          ;; for r032),
          ;; player3PointerLo, player3PointerHi (set to $B0/$F0
          ;; for r048)
          ;;
          ;; Called Routines: None (uses inline assembly)
          ;;
          ;; Constraints: Called once at game initialization (from
          ;; ColdStart, BeginGameLoop)
          ;; Set Player 0 pointer to r000 ($F080)
          ;; player0pointer is 16-bit pointer (player0PointerLo +
          ;; player0PointerHi)
          ;; Low byte: $80 (base address of r000)
          ;; High byte: $F0 (SCRAM read port base)
          player0PointerLo = $80
          player0PointerHi = $F0

          ;; Set Player 1 pointer to r016 ($F090)
          ;; player1PointerLo/hi are arrays indexed by sprite number
          ;; Index 0 = Player 1, Index 1 = Player 2, Index 2 = Player 3
          ;; Note: player1PointerLo[0] is actually player1PointerLo
          ;; memory location
          ;; player1PointerLo[1] is player2PointerLo, etc.
          lda #$90
          sta player1PointerLo
          lda #$F0
          sta player1PointerHi

          lda #$A0
          sta player2PointerLo
          lda #$F0
          sta player2PointerHi

          lda #$B0
          sta player3PointerLo
          lda #$F0
          sta player3PointerHi

          ;; Note: Kernel will adjust these pointers for Y offsets
          ;; automatically
          ;; The kernel existing pointer adjustment logic works
          ;; perfectly with RAM
          ;; addresses. No kernel modifications needed!
          ;; InitializeSpritePointers is called both same-bank (from ColdStart bank14)
          and cross-bank (from BeginGameLoop bank11). Since it’s called cross-bank,
          ;; it must always use return otherbank per the fundamental rule.
          jmp BS_return


.pend

