InitializeSpritePointers
          asm
InitializeSpritePointers

end
          rem
          rem ChaosFight - Source/Routines/SpritePointerInit.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Sprite Pointer Initialization
          rem
          rem Sets all sprite pointers to point to SCRAM buffers
          rem Called once at game initialization
          rem
          rem RAM Buffer Layout (64 bytes total):
          rem   P0: r000-r015 ($F080-$F08F) - 16 bytes
          rem   P1: r016-r031 ($F090-$F09F) - 16 bytes
          rem   P2: r032-r047 ($F0A0-$F0AF) - 16 bytes
          rem   P3: r048-r063 ($F0B0-$F0BF) - 16 bytes
          rem Note: Pointers are set to SCRAM read ports (r000-r063)
          rem   Kernel will automatically adjust these pointers for Y
          rem   offsets
          rem   during rendering. The kernel existing pointer adjustment
          rem   logic works perfectly with RAM addresses.
          rem Sets all sprite pointers to point to SCRAM buffers
          rem
          rem Input: None (initialization routine)
          rem
          rem Output: player0pointerlo/hi, player1pointerlo/hi,
          rem player2pointerlo/hi,
          rem         player3pointerlo/hi set to SCRAM read port
          rem         addresses
          rem
          rem Mutates: player0pointerlo, player0pointerhi (set to
          rem $80/$F0 for r000),
          rem         player1pointerlo, player1pointerhi (set to $90/$F0
          rem         for r016),
          rem         player2pointerlo, player2pointerhi (set to $A0/$F0
          rem         for r032),
          rem         player3pointerlo, player3pointerhi (set to $B0/$F0
          rem         for r048)
          rem
          rem Called Routines: None (uses inline assembly)
          rem
          rem Constraints: Called once at game initialization (from
          rem ColdStart, BeginGameLoop)
          rem Set Player 0 pointer to r000 ($F080)
          rem player0pointer is 16-bit pointer (player0pointerlo +
          rem player0pointerhi)
          rem Low byte: $80 (base address of r000)
          rem High byte: $F0 (SCRAM read port base)
          player0pointerlo = $80
          player0pointerhi = $F0

          rem Set Player 1 pointer to r016 ($F090)
          rem player1pointerlo/hi are arrays indexed by sprite number
          rem Index 0 = Player 1, Index 1 = Player 2, Index 2 = Player 3
          rem Note: player1pointerlo[0] is actually player1pointerlo
          rem memory location
          rem   player1pointerlo[1] is player2pointerlo, etc.
          asm
            lda #$90              ; Low byte for r016 ($F090)
            sta player1pointerlo  ; Player 1 pointer low byte
            lda #$F0              ; High byte (SCRAM read port)
            sta player1pointerhi  ; Player 1 pointer high byte

            lda #$A0              ; Low byte for r032 ($F0A0)
            sta player2pointerlo  ; Player 2 pointer low byte
            lda #$F0              ; High byte (SCRAM read port)
            sta player2pointerhi  ; Player 2 pointer high byte

            lda #$B0              ; Low byte for r048 ($F0B0)
            sta player3pointerlo  ; Player 3 pointer low byte
            lda #$F0              ; High byte (SCRAM read port)
            sta player3pointerhi  ; Player 3 pointer high byte
end

          rem Note: Kernel will adjust these pointers for Y offsets
          rem automatically
          rem The kernel existing pointer adjustment logic works
          rem perfectly with RAM
          rem   addresses. No kernel modifications needed!
          return otherbank

