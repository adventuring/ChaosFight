          rem ChaosFight - Source/Routines/VblankHandlerTrampoline.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

          rem Vblank handler trampoline - small stub in Bank 16 that calls the real handler in Bank 11
          rem This allows VblankHandlers to be in Bank 11 while still being callable from the kernel
          rem The kernel calls this trampoline via jsr vblank_bB_code (near call within Bank 16)
          rem The trampoline then does a cross-bank call to VblankHandlerDispatcher in Bank 11

VblankHandlerTrampoline
          rem Returns: Near (return thisbank)  
          rem Cross-bank call to VblankHandlerDispatcher in Bank 11
          rem Uses batariBASIC’s cross-bank gosub mechanism
          rem Note: VblankHandlerDispatcher is defined in VblankHandlers.bas in Bank 11
          gosub VblankHandlerDispatcher bank11
          return thisbank

