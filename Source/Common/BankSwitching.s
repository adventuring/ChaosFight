          ; CRITICAL: Ensure ORG is set for bankswitch code placement
          ; batariBASIC sets ORG before include, but DASM may need it here too
          ; Define as constants (SET allows redefinition per bank, EQU does not)
BS_return SET .
          ; OPTIMIZATION: Don’t save A/X - target routine is returning, so its A/X don’t matter
          ; Original caller’s A/X are already saved on stack from BS_jsr call
          tsx
          lda 2,x ; get encoded high byte of return address from stack (no A/X save, so offset is 2)
          tay ; save encoded byte for restoration
          lsr
          lsr
          lsr
          lsr ; bank now in low nibble
          pha ; save bank number temporarily
          tya ; get saved encoded byte
          ora #$F0 ; restore to $Fx format
          sta 2,x ; store restored address back to stack (X still has stack pointer)
          pla ; restore bank number
          tax ; bank number (0-F) now in X, already 0-based from batariBASIC
BS_jsr SET .
          nop $ffe0,x ; bankswitch_hotspot + X where X is 0-based bank number
          ; No need to restore A/X - caller doesn’t use A/X after cross-bank call returns
          ; Stack now has return address at top, rts will return to original caller
          rts
          ; Pad to 24 bytes total (20 bytes code + 4 bytes padding)
          nop
          nop
          nop
          nop

          ; EFSC 64k bankswitch hotspot is $FFE0 (not $FFF8 like other schemes)
          ifnconst bankswitch_hotspot
bankswitch_hotspot = $FFE0
          endif
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
          ; CRITICAL: EFSC header must be at $FFE0-$FFEF, not at bankswitch_hotspot ($FFF8)
          RORG $FFE0
EFSC_Header EQU .
          byte "EFSC",0
          byte "BRPocock",0
          byte $25,current_bank

          ; Reset code at $fff0 - must be identical in every bank
          ; CRITICAL: Set ORG to Bank N’s reset code location before setting RORG
          ; Calculate file offset: (current_bank * $1000) | $0FF0
          ; This ensures reset code is in Bank N’s file space, not Bank N+1’s
          ; File offset will be different for each bank, but CPU address ($fff0) is the same
          ORG ((current_bank * $1000) | $0FF0)
          RORG $fff0
Reset EQU .
          ; CRITICAL: Switch to Bank 14 (1-based = 13, 0-based index) where startup code (ColdStart) is located
          ; ColdStart is in Bank 14 (1-based) per ColdStart.bas
          ; Bank switching occurs via accessing specific addresses
          ; Bank 1 (0-based index 0) = $FFE0
          ; Bank N (0-based index) = $FFE0 + N
          ; Bank 14 (0-based index 13) = $FFE0 + 13 = $FFED
          ; Use NOP to access the address (triggers hardware bank switch)
          nop $ffed  ; switch to Bank 14 (14, 1-based = 13, 0-based index) where ColdStart is located
          jmp ColdStart

          ; Reset vectors at $fffc-$ffff
          ; $fffc-$fffd: Reset vector
          ; $fffe-$ffff: IRQ/BRK vector
          ; Both point to Reset handler
          ; CRITICAL: Set ORG to Bank N’s reset vector location
          ; Calculate file offset: (current_bank * $1000) | $0FFC
          ; This ensures reset vectors are in Bank N’s file space, not Bank N+1’s
          ORG ((current_bank * $1000) | $0FFC)
          RORG $fffc
          .word Reset
          .word Reset

          ; CPU address space check: should end at exactly $10000
          ; After reset vectors at $fffc-$ffff, we should be at $10000
          IF . != $10000
          echo "ERROR: BankSwitching.s CPU address overflow! Ends at ", ., " but should be $10000"
          err
          endif
