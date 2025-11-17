; Provided under the CC0 license. See the included LICENSE.txt for details.

; every bank has this stuff at the same place
; this code can switch to/from any bank at any entry point
; and can preserve register values
; note: lines not starting with a space are not placed in all banks
;

begin_bscode:
          ldx #$ff
          txs
          lda #(>(start-1) & $0F)
          ora #(current_bank << 4)
          pha
          lda #<(start-1)
          pha
BS_return:
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
BS_jsr:
          lda bankswitch_hotspot-1,x
          pla
          tax
          pla
          rts

          if (($fff & .) > ($fff & bankswitch_hotspot))
          echo "WARNING: size parameter in BankSwitching.s too small - the program probably will not work."
          echo "Change to ", [($fff & .) - ($fff & bankswitch_hotspot)]d, " and try again."
          endif

          ; -------------------------------------------------------------------
          ; EFSC identification header immediately after bankswitch code
          ; -------------------------------------------------------------------
          ;
          ; For EFSC 64k SuperChip carts we reserve 16 bytes starting at the
          ; CPU hotspot address ($FFE0) in each bank. The bankswitch stub
          ; is placed so that it ends just before $FFE0; the following 16 bytes
          ; at $FFE0-$FFEF contain:
          ;
          ;   "EFSC", 0, "BRPocock", 0, $25, $00
          ;
          ; Because the bankswitch hardware only cares about accesses to the
          ; hotspot address, not the data value, this identification header
          ; does not interfere with bankswitching. Emulators/multicarts can
          ; use it to detect EFSC ROMs and associate metadata.
          ;

          ; Use current_bank (0-based, 0-15) set by batariBASIC to calculate bank base
          ; Bank base = current_bank * $1000 (Bank 0=$0000, Bank 1=$1000, etc.)
          ; Note: batariBASIC sets ORG before including this file, so we work within that context
          ifnconst current_bank
          echo "ERROR: current_bank not defined! BankSwitching.s requires current_bank to be set."
          err
          endif

          ; batariBASIC has already set ORG to the bankswitch code location
          ; We just need to set RORG and place the EFSC header
          ; Do NOT set ORG here - batariBASIC handles all ORG positioning
          RORG bankswitch_hotspot
EFSC_Header:
          byte "EFSC",0
          byte "BRPocock",0
          byte $25,$00

          ; Reset code at $fff0 - batariBASIC should set ORG before this section
          ; We only set RORG for CPU address space
          RORG $fff0
Reset:
          lda #14
          sta bankswitch_hotspot ; switch to bank 14
          jmp MainLoop

          ; Reset vectors are handled by batariBASIC after including this file
          ; batariBASIC sets ORG $XFFC and places .word (start_bankN & $ffff) vectors
          ; We cannot set ORG here because file position may have advanced to next bank
          ; causing "Origin Reverse-indexed" errors

          ; CPU address space check: should end at exactly $10000
          ; After reset vectors at $fffc-$ffff, we should be at $10000
          IF . != $10000
          echo "ERROR: BankSwitching.s CPU address overflow! Ends at ", ., " but should be $10000"
          err
          endif
