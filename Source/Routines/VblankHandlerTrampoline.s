;;; ChaosFight - Source/Routines/VblankHandlerTrampoline.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; Vblank handler trampoline - small stub in Bank 16 that calls the real handler in Bank 11
;;; This allows VblankHandlers to be in Bank 11 while still being callable from the kernel
;;; The kernel calls this trampoline via jsr vblank_bB_code (near call within Bank 16)
          ;; The trampoline then does a cross-bank call to VblankHandlerDispatcher in Bank 11


VblankHandlerTrampoline .proc
          ;; Returns: Near (return thisbank)
          ;; Cross-bank call to VblankHandlerDispatcher in Bank 11
          ;; Uses batariBASIC’s cross-bank gosub mechanism
          ;; Note: VblankHandlerDispatcher is defined in VblankHandlers.bas in Bank 11
          ;; Cross-bank call to VblankHandlerDispatcher in bank 11
          lda # >(return_point-1)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(VblankHandlerDispatcher-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(VblankHandlerDispatcher-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 10
          jmp BS_jsr
return_point:


          rts

.pend

