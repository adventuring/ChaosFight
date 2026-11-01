;; Player 3: NoCharacter (locked)
          lda # 2
          tax
          lda # NoCharacter
          sta playerCharacter,x
          ;; Player 4: NoCharacter (locked)
          lda # 3
          tax
          lda # NoCharacter
          sta playerCharacter,x
          ;; Initialize playerLocked (bit-packed)
          lda # 0
          sta playerLocked