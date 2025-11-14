; Provided under the CC0 license. See the included LICENSE.txt for details.

; every bank has this stuff at the same place
; this code can switch to/from any bank at any entry point
; and can preserve register values
; note: lines not starting with a space are not placed in all banks
;
; line below tells the compiler how long this is - do not remove
;size=48  (actual size for 64kSC bankswitching with bank encoding)

begin_bscode
          ldx #$ff
          txs
          lda #(>(start-1) & $0F)
          ora #(current_bank << 4)
          pha
          lda #<(start-1)
          pha
BS_return
          pha
          txa
          pha
          tsx

          lda 4,x ; get encoded high byte of return address from stack
          tay ; save encoded byte for restoration
          and #$F0 ; extract bank number from high nibble
          lsr ; shift right once
          lsr ; shift right twice
          lsr ; shift right three times
          lsr ; shift right four times - bank now in low nibble
          pha ; save bank number temporarily
          tya ; get saved encoded byte
          and #$0F ; mask low nibble with original address info
          ora #$F0 ; restore to $Fx format
          sta 4,x ; store restored address back to stack (X still has stack pointer)
          pla ; restore bank number
          tax ; bank number (0-F) now in X
          inx ; convert to 1-based index (bank 0 -> 1, bank 1 -> 2, etc.)
BS_jsr
          lda bankswitch_hotspot-1,x
          pla
          tax
          pla
          rts
          if ((. & $1FFF) > ((bankswitch_hotspot & $1FFF) - 1))
          echo "WARNING: size parameter in BankSwitching.s too small - the program probably will not work."
          echo "Change to ", [. - start_bank1]d, " and try again."
          endif


