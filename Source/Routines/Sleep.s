; Sleep macro for ChaosFight
; Provides cycle-accurate delays

          MAC SLEEP
          .CYCLES SET {1}
          IF .CYCLES < 2
          ECHO "MACRO ERROR: 'SLEEP': Duration must be > 1"
          ERR
          ENDIF
          IF .CYCLES & 1
          nop 0
          .CYCLES SET .CYCLES - 3
          ELSE
          .CYCLES SET .CYCLES - 2
          ENDIF
          REPEAT .CYCLES / 2
          nop
          REPEND
          ENDM
