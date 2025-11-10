          rem ChaosFight - Source/Data/PlayerColors.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Player color tables for indexed lookup (P1..P4)
          rem Bright (luminance 12) and dim (luminance 6)
          data PlayerColors12
          ColIndigo(12), ColRed(12), ColYellow(12), ColTurquoise(12)
end
#ifdef TV_SECAM
          data PlayerColors8
          ColMagenta(8), ColMagenta(8), ColMagenta(8), ColMagenta(8)
end
#else
          data PlayerColors6
          ColIndigo(6), ColRed(6), ColYellow(6), ColTurquoise(6)
end
#endif


