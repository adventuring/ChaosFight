;;; ChaosFight - Source/Routines/VblankHandlerTrampoline.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; Vblank handler trampoline - small stub in Bank 16 that calls the real handler in Bank 11
;;; This allows VblankHandlers to be in Bank 11 while still being callable from the kernel
;;; The kernel calls this trampoline via jsr vblank_bB_code (near call within Bank 16)
          ;; The trampoline then does a cross-bank call to VblankHandlerDispatcher in Bank 11


VblankHandlerTrampoline .proc
          ;; Returns: Near (return thisbank)
          ;; Cross-bank call to VblankHandlerDispatcher in Bank 11
          ;; Uses batariBASIC’s cross-bank cross-bank call to mechanism
          ;; Note: VblankHandlerDispatcher is defined in VblankHandlers.bas in Bank 11
          ;; Cross-bank call to VblankHandlerDispatcher in bank 10
          ;; Return address: ENCODED with caller bank 15 ($f0) for BS_return to decode
          lda # ((>(AfterVblankHandlerDispatcher-1)) & $0f) | $f0  ;;; Encode bank 15 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterVblankHandlerDispatcher hi (encoded)]
          lda # <(AfterVblankHandlerDispatcher-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterVblankHandlerDispatcher hi (encoded)] [SP+0: AfterVblankHandlerDispatcher lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(VblankHandlerDispatcher-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterVblankHandlerDispatcher hi (encoded)] [SP+1: AfterVblankHandlerDispatcher lo] [SP+0: VblankHandlerDispatcher hi (raw)]
          lda # <(VblankHandlerDispatcher-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterVblankHandlerDispatcher hi (encoded)] [SP+2: AfterVblankHandlerDispatcher lo] [SP+1: VblankHandlerDispatcher hi (raw)] [SP+0: VblankHandlerDispatcher lo]
          ldx # 10
          jmp BS_jsr
AfterVblankHandlerDispatcher:


          rts

.pend

