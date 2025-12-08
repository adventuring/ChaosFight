;;;; ChaosFight - Source/Common/Startup.s
;;;; Copyright © 2025 Bruce-Robert Pocock.
;;;; Derived from Tools/batariBASIC/includes/startup.asm (CC0)
;;;; Clean start initialization - clears registers, stack, and memory

start = ColdStart          ;;; Alias for bankswitch return mechanism

StartupInit .proc
          cld              ;;; Clear decimal mode
          
          ldx #$ff
          txs

          ;; ldx #$7f (duplicate)
          lda # 0           ;;; A = 0
          ldy systemFlags
clearmem:
          sta $00,x        ;;; Clear TIA registers (and then some)
          ;; sta $80,x        ;;; Clear zero page RAM (duplicate)
          ;; sta w000,x       ;;; Clear SCRAM (SuperChip RAM at $F000) (duplicate)
          dex              ;;; Decrement X
          bpl clearmem     ;;; Loop until X wraps to 0

          sty systemFlags
          ;; sta SWACNT       ;;; Port A DDR = 0 (INPUT mode) (duplicate)
          ;; sta SWBCNT       ;;; Port B DDR = 0 (INPUT mode) (duplicate)

          ;; lda # 1           ;;; Initialize playfield control (duplicate)
          ;; sta CTRLPF (duplicate)
          ora INTIM        ;;; Seed random number generator from timer
          ;; sta rand (duplicate)

          ;; lda # 16          ;;; Initialize playfield height (duplicate)
          ;; sta pfheight (duplicate)

          ;; ldx # 4           ;;; Initialize sprite graphics indices (duplicate)
StartupSetCopyHeight:
          txa
          ;; sta SpriteGfxIndex,x (duplicate)
          ;; sta spritesort,x (duplicate)
          ;; dex (duplicate)
          ;; bpl StartupSetCopyHeight (duplicate)

          ;;; since we can't turn off pf, point PF to BlankPlayfield in Bank 16
          ;; lda # >BlankPlayfield (duplicate)
          ;; sta PF2pointer+1 (duplicate)
          ;; sta PF1pointer+1 (duplicate)
          ;; lda # <BlankPlayfield (duplicate)
          ;; sta PF2pointer (duplicate)
          ;; sta PF1pointer (duplicate)

          ;;; NOTE: Do NOT jump to MainLoop here - ColdStart.bas handles the
          ;;; transition to MainLoop in Bank 16 using proper bank switching.
          ;;; This file is included in Bank 14, but MainLoop is in Bank 16.
          ;;; ColdStart.bas line 99 does: goto MainLoop bank16
          rts
.pend
