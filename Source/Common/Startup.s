; ChaosFight - Source/Common/Startup.s
; Copyright © 2025 Interworldly Adventuring, LLC.
; Derived from Tools/batariBASIC/includes/startup.asm (CC0)
; Clean start initialization - clears registers, stack, and memory

start     SET ColdStart          ; Alias for bankswitch return mechanism

          cld                    ; Clear decimal mode
          
          ldx #$ff
          txs

          ldx #$7f
          lda # 0                    ; A = 0
          tay                    ; Y = 0
clearmem
          sta $00,x              ; Clear TIA registers (and then some)
          sta $80,x              ; Clear zero page RAM
          sta w000,x             ; Clear SCRAM (SuperChip RAM at $F000)
          dex                    ; Decrement X
          bpl clearmem           ; Loop until X wraps to 0

          sta SWACNT             ; Port A DDR = 0 (INPUT mode)
          sta SWBCNT             ; Port B DDR = 0 (INPUT mode)

          lda #1                 ; Initialize playfield control
          sta CTRLPF
          ora INTIM              ; Seed random number generator from timer
          sta rand

          lda # 16                ; Initialize playfield height
          sta pfheight

          ldx # 4                 ; Initialize sprite graphics indices
StartupSetCopyHeight
          txa
          sta SpriteGfxIndex, x
          sta spritesort, x
          dex
          bpl StartupSetCopyHeight

          ; since we can’t turn off pf, point PF to BlankPlayfield in Bank 16
          lda #>BlankPlayfield
          sta PF2pointer+1
          sta PF1pointer+1
          lda #<BlankPlayfield
          sta PF2pointer
          sta PF1pointer

          jmp MainLoop
