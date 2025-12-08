;; PAL color palette - pre-calculated hex value macros (even luminances only) 
;; Each hue supports 8 luminance levels: 0, 2, 4, 6, 8, 10, 12, 14 
;; Color ordering and nomenclature matches SkylineTool +vcs-pal-palette+ 
;; Verified against SkylineTool/src/graphics.lisp +vcs-pal-palette+ (Issue #601) 
;; PAL color register values differ from NTSC due to different TV standard hue phases 
_COL_Grey_L0 = $00
_COL_Grey_L2 = $02
_COL_Grey_L4 = $04
_COL_Grey_L6 = $06
_COL_Grey_L8 = $08
_COL_Grey_L10 = $0A
_COL_Grey_L12 = $0C
_COL_Grey_L14 = $0E
_COL_Spinach_L0 = $10
_COL_Spinach_L2 = $12
_COL_Spinach_L4 = $14
_COL_Spinach_L6 = $16
_COL_Spinach_L8 = $18
_COL_Spinach_L10 = $1A
_COL_Spinach_L12 = $1C
_COL_Spinach_L14 = $1E
_COL_Gold_L0 = $20
_COL_Gold_L2 = $22
_COL_Gold_L4 = $24
_COL_Gold_L6 = $26
_COL_Gold_L8 = $28
_COL_Gold_L10 = $2A
_COL_Gold_L12 = $2C
_COL_Gold_L14 = $2E
_COL_Orange_L0 = $30
_COL_Orange_L2 = $32
_COL_Orange_L4 = $34
_COL_Orange_L6 = $36
_COL_Orange_L8 = $38
_COL_Orange_L10 = $3A
_COL_Orange_L12 = $3C
_COL_Orange_L14 = $3E
_COL_Red_L0 = $40
_COL_Red_L2 = $42
_COL_Red_L4 = $44
_COL_Red_L6 = $46
_COL_Red_L8 = $48
_COL_Red_L10 = $4A
_COL_Red_L12 = $4C
_COL_Red_L14 = $4E
_COL_Magenta_L0 = $50
_COL_Magenta_L2 = $52
_COL_Magenta_L4 = $54
_COL_Magenta_L6 = $56
_COL_Magenta_L8 = $58
_COL_Magenta_L10 = $5A
_COL_Magenta_L12 = $5C
_COL_Magenta_L14 = $5E
_COL_Violet_L0 = $60
_COL_Violet_L2 = $62
_COL_Violet_L4 = $64
_COL_Violet_L6 = $66
_COL_Violet_L8 = $68
_COL_Violet_L10 = $6A
_COL_Violet_L12 = $6C
_COL_Violet_L14 = $6E
_COL_Purple_L0 = $70
_COL_Purple_L2 = $72
_COL_Purple_L4 = $74
_COL_Purple_L6 = $76
_COL_Purple_L8 = $78
_COL_Purple_L10 = $7A
_COL_Purple_L12 = $7C
_COL_Purple_L14 = $7E
_COL_Indigo_L0 = $80
_COL_Indigo_L2 = $82
_COL_Indigo_L4 = $84
_COL_Indigo_L6 = $86
_COL_Indigo_L8 = $88
_COL_Indigo_L10 = $8A
_COL_Indigo_L12 = $8C
_COL_Indigo_L14 = $8E
_COL_Blue_L0 = $90
_COL_Blue_L2 = $92
_COL_Blue_L4 = $94
_COL_Blue_L6 = $96
_COL_Blue_L8 = $98
_COL_Blue_L10 = $9A
_COL_Blue_L12 = $9C
_COL_Blue_L14 = $9E
_COL_Stonewash_L0 = $A0
_COL_Stonewash_L2 = $A2
_COL_Stonewash_L4 = $A4
_COL_Stonewash_L6 = $A6
_COL_Stonewash_L8 = $A8
_COL_Stonewash_L10 = $AA
_COL_Stonewash_L12 = $AC
_COL_Stonewash_L14 = $AE
_COL_Turquoise_L0 = $B0
_COL_Turquoise_L2 = $B2
_COL_Turquoise_L4 = $B4
_COL_Turquoise_L6 = $B6
_COL_Turquoise_L8 = $B8
_COL_Turquoise_L10 = $BA
_COL_Turquoise_L12 = $BC
_COL_Turquoise_L14 = $BE
_COL_Green_L0 = $C0
_COL_Green_L2 = $C2
_COL_Green_L4 = $C4
_COL_Green_L6 = $C6
_COL_Green_L8 = $C8
_COL_Green_L10 = $CA
_COL_Green_L12 = $CC
_COL_Green_L14 = $CE
_COL_Seafoam_L0 = $D0
_COL_Seafoam_L2 = $D2
_COL_Seafoam_L4 = $D4
_COL_Seafoam_L6 = $D6
_COL_Seafoam_L8 = $D8
_COL_Seafoam_L10 = $DA
_COL_Seafoam_L12 = $DC
_COL_Seafoam_L14 = $DE
_COL_SpringGreen_L0 = $E0
_COL_SpringGreen_L2 = $E2
_COL_SpringGreen_L4 = $E4
_COL_SpringGreen_L6 = $E6
_COL_SpringGreen_L8 = $E8
_COL_SpringGreen_L10 = $EA
_COL_SpringGreen_L12 = $EC
_COL_SpringGreen_L14 = $EE
_COL_Algae_L0 = $F0
_COL_Algae_L2 = $F2
_COL_Algae_L4 = $F4
_COL_Algae_L6 = $F6
_COL_Algae_L8 = $F8
_COL_Algae_L10 = $FA
_COL_Algae_L12 = $FC
_COL_Algae_L14 = $FE

;; CoLu formula: (color | lum) - simplified color calculation
;; Formula: color_value = (hue * 16) | lum
;; Usage: Use constants directly: _COL_Red_L12 instead of CoLu(4, 12)
;; Example: _COL_Red_L12 = (4 * 16) | 12 = $4C
;; Note: All color constants are pre-calculated above for performance

;; Helper macros for token pasting - double expansion required for proper macro parameter expansion 

;; Color function macros using token pasting 

;; Legacy synonyms retained for backwards compatibility 

