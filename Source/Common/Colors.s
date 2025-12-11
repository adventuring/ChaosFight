;; Colors.s - Color definitions for different TV standards
;; Uses TVStandard (NTSC=0, PAL=1, SECAM=2) with enumerated constants
;; Only one TV standard's colors are included based on TVStandard
;; Note: TVStandard is set by platform files (NTSC.s, PAL.s, SECAM.s) before Preamble.s

;; Include NTSC colors if TVStandard == 0 (NTSC)
.if TVStandard == 0
.include "Source/Platform/ColorsNTSC.s"
.fi

;; Include PAL colors if TVStandard == 1 (PAL)
.if TVStandard == 1
.include "Source/Platform/ColorsPAL.s"
.fi

;; SECAM color definitions if TVStandard == 2 (SECAM)
.if TVStandard == 2
;; SECAM color functions - 8 colors: RGB, CMY, KW (luminance selects black vs chroma)
;; Precompute luminance mappings

;; Grey / White mapping
_SECAM_COL_Grey_L0 = 0
_SECAM_COL_Grey_L2 = 7
_SECAM_COL_Grey_L4 = 7
_SECAM_COL_Grey_L6 = 7
_SECAM_COL_Grey_L8 = 7
_SECAM_COL_Grey_L10 = 7
_SECAM_COL_Grey_L12 = 7
_SECAM_COL_Grey_L14 = 7

;; Primary chroma mappings
_SECAM_COL_Red_L0 = 0
_SECAM_COL_Red_L2 = 1
_SECAM_COL_Red_L4 = 1
_SECAM_COL_Red_L6 = 1
_SECAM_COL_Red_L8 = 1
_SECAM_COL_Red_L10 = 1
_SECAM_COL_Red_L12 = 1
_SECAM_COL_Red_L14 = 1

_SECAM_COL_Green_L0 = 0
_SECAM_COL_Green_L2 = 2
_SECAM_COL_Green_L4 = 2
_SECAM_COL_Green_L6 = 2
_SECAM_COL_Green_L8 = 2
_SECAM_COL_Green_L10 = 2
_SECAM_COL_Green_L12 = 2
_SECAM_COL_Green_L14 = 2

_SECAM_COL_Blue_L0 = 0
_SECAM_COL_Blue_L2 = 3
_SECAM_COL_Blue_L4 = 3
_SECAM_COL_Blue_L6 = 3
_SECAM_COL_Blue_L8 = 3
_SECAM_COL_Blue_L10 = 3
_SECAM_COL_Blue_L12 = 3
_SECAM_COL_Blue_L14 = 3

;; Secondary chroma mappings
_SECAM_COL_Cyan_L0 = 0
_SECAM_COL_Cyan_L2 = 4
_SECAM_COL_Cyan_L4 = 4
_SECAM_COL_Cyan_L6 = 4
_SECAM_COL_Cyan_L8 = 4
_SECAM_COL_Cyan_L10 = 4
_SECAM_COL_Cyan_L12 = 4
_SECAM_COL_Cyan_L14 = 4

_SECAM_COL_Magenta_L0 = 0
_SECAM_COL_Magenta_L2 = 5
_SECAM_COL_Magenta_L4 = 5
_SECAM_COL_Magenta_L6 = 5
_SECAM_COL_Magenta_L8 = 5
_SECAM_COL_Magenta_L10 = 5
_SECAM_COL_Magenta_L12 = 5
_SECAM_COL_Magenta_L14 = 5

_SECAM_COL_Yellow_L0 = 0
_SECAM_COL_Yellow_L2 = 6
_SECAM_COL_Yellow_L4 = 6
_SECAM_COL_Yellow_L6 = 6
_SECAM_COL_Yellow_L8 = 6
_SECAM_COL_Yellow_L10 = 6
_SECAM_COL_Yellow_L12 = 6
_SECAM_COL_Yellow_L14 = 6
.fi
