;;;; ChaosFight - Source/Common/Startup.s
;;;; Copyright © 2025 Bruce-Robert Pocock.
;;;; Derived from Tools/batariBASIC/includes/startup.asm (CC0)
;;;; Clean start initialization - clears registers, stack, and memory

start = ColdStart          ;;; Alias for bankswitch return mechanism

StartupInit .block
          ;; CRITICAL: This code executes inline when included - clears stack and RAM
          ;; before any stack operations (pha, jsr, etc.)
          cld              ;;; Clear decimal mode
          
          ldx #$ff
          txs              ;;; Initialize stack pointer to $FF (top of stack at $01FF)

          lda # 0           ;;; A = 0
          ldy systemFlags
clearmem:
          sta $00,x        ;;; Clear TIA registers and zero-page RAM ($00-$FF)
          ;; Due to page mirroring, this also clears stack area ($01F0-$01FF)
          dex              ;;; Decrement X
          bpl clearmem     ;;; Loop until X wraps to 0

          sty systemFlags
          ora INTIM        ;;; Seed random number generator from timer

          ;;; NOTE: Do NOT jump to MainLoop here - ColdStart handles the
          ;;; transition to MainLoop using proper bank switching.
.bend
