; ChaosFight - Source/Common/Startup.s
; Copyright © 2025 Interworldly Adventuring, LLC.
; Derived from Tools/batariBASIC/includes/startup.asm (CC0)

start
          sei
          cld
          ldx # 0
          txa
clearmem
          sta 0, x
          sta w000, x
          dex
          bne clearmem

          lda # 1
          sta CTRLPF
          ora INTIM
          sta rand

          lda # 16
          sta pfheight

          ldx # 4
StartupSetCopyHeight
          txa
          sta SpriteGfxIndex, x
          sta spritesort, x
          dex
          bpl StartupSetCopyHeight

          ; since we can’t turn off pf, point PF to BlankPlayfield in Bank 16
          lda # >BlankPlayfield
          sta PF2pointer+1
          sta PF1pointer+1
          lda # <BlankPlayfield
          sta PF2pointer
          sta PF1pointer

          jmp MainLoop

