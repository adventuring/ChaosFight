#ifndef COLORS_H
#define COLORS_H

/* Color macro functions for different TV standards
   NTSC: 128 colors (4-bit hue + 3-bit luminance)
   PAL: 128 colors (4-bit hue + 3-bit luminance) - some different from NTSC
   SECAM: 8 colors (3-bit hue only, no luminance) */

#ifdef TV_NTSC
/* NTSC color macro functions - pre-calculated hex values using token pasting */
/* Color definitions embedded in platform-specific file */
#include "Source/Platform/ColorsNTSC.h"

#elif defined(TV_PAL)
/* PAL color macro functions - platform-specific palette */
/* Color definitions embedded in platform-specific file */
#include "Source/Platform/ColorsPAL.h"

#elif defined(TV_SECAM)
/* SECAM color macro functions - 8 colors: RGB, CMY, KW (luminance selects black vs chroma) */
/* Precompute luminance mappings to keep generated BASIC free of ternary operators */

/* Helper macros for token pasting */
#define _SECAM_COL_CONCAT(prefix, lum) prefix##lum
#define _SECAM_COL(prefix, lum) _SECAM_COL_CONCAT(prefix, lum)

/* Grey / White mapping */
#define _SECAM_COL_Grey_L0 0
#define _SECAM_COL_Grey_L2 7
#define _SECAM_COL_Grey_L4 7
#define _SECAM_COL_Grey_L6 7
#define _SECAM_COL_Grey_L8 7
#define _SECAM_COL_Grey_L10 7
#define _SECAM_COL_Grey_L12 7
#define _SECAM_COL_Grey_L14 7

/* Primary chroma mappings */
#define _SECAM_COL_Red_L0 0
#define _SECAM_COL_Red_L2 1
#define _SECAM_COL_Red_L4 1
#define _SECAM_COL_Red_L6 1
#define _SECAM_COL_Red_L8 1
#define _SECAM_COL_Red_L10 1
#define _SECAM_COL_Red_L12 1
#define _SECAM_COL_Red_L14 1

#define _SECAM_COL_Green_L0 0
#define _SECAM_COL_Green_L2 2
#define _SECAM_COL_Green_L4 2
#define _SECAM_COL_Green_L6 2
#define _SECAM_COL_Green_L8 2
#define _SECAM_COL_Green_L10 2
#define _SECAM_COL_Green_L12 2
#define _SECAM_COL_Green_L14 2

#define _SECAM_COL_Blue_L0 0
#define _SECAM_COL_Blue_L2 3
#define _SECAM_COL_Blue_L4 3
#define _SECAM_COL_Blue_L6 3
#define _SECAM_COL_Blue_L8 3
#define _SECAM_COL_Blue_L10 3
#define _SECAM_COL_Blue_L12 3
#define _SECAM_COL_Blue_L14 3

/* Secondary chroma mappings */
#define _SECAM_COL_Cyan_L0 0
#define _SECAM_COL_Cyan_L2 4
#define _SECAM_COL_Cyan_L4 4
#define _SECAM_COL_Cyan_L6 4
#define _SECAM_COL_Cyan_L8 4
#define _SECAM_COL_Cyan_L10 4
#define _SECAM_COL_Cyan_L12 4
#define _SECAM_COL_Cyan_L14 4

#define _SECAM_COL_Magenta_L0 0
#define _SECAM_COL_Magenta_L2 5
#define _SECAM_COL_Magenta_L4 5
#define _SECAM_COL_Magenta_L6 5
#define _SECAM_COL_Magenta_L8 5
#define _SECAM_COL_Magenta_L10 5
#define _SECAM_COL_Magenta_L12 5
#define _SECAM_COL_Magenta_L14 5

#define _SECAM_COL_Yellow_L0 0
#define _SECAM_COL_Yellow_L2 6
#define _SECAM_COL_Yellow_L4 6
#define _SECAM_COL_Yellow_L6 6
#define _SECAM_COL_Yellow_L8 6
#define _SECAM_COL_Yellow_L10 6
#define _SECAM_COL_Yellow_L12 6
#define _SECAM_COL_Yellow_L14 6

/* SECAM color selection macros */
#define ColGrey(lum) _SECAM_COL(_SECAM_COL_Grey_L, lum)
#define ColGray(lum) ColGrey(lum)

#define ColRed(lum) _SECAM_COL(_SECAM_COL_Red_L, lum)

#define ColGreen(lum) _SECAM_COL(_SECAM_COL_Green_L, lum)
#define ColLime(lum) ColGreen(lum)
#define ColSpringGreen(lum) ColGreen(lum)
#define ColSpinach(lum) ColGreen(lum)

#define ColBlue(lum) _SECAM_COL(_SECAM_COL_Blue_L, lum)
#define ColIndigo(lum) ColBlue(lum)

#define ColCyan(lum) _SECAM_COL(_SECAM_COL_Cyan_L, lum)
#define ColTurquoise(lum) ColCyan(lum)
#define ColTeal(lum) ColCyan(lum)
#define ColSeafoam(lum) ColCyan(lum)
#define ColStonewash(lum) ColCyan(lum)

#define ColMagenta(lum) _SECAM_COL(_SECAM_COL_Magenta_L, lum)
#define ColPurple(lum) ColMagenta(lum)
#define ColViolet(lum) ColMagenta(lum)

#define ColYellow(lum) _SECAM_COL(_SECAM_COL_Yellow_L, lum)
#define ColBrown(lum) ColYellow(lum)
#define ColOrange(lum) ColYellow(lum)
#define ColGold(lum) ColYellow(lum)
#define ColAlgae(lum) ColGreen(lum)

#else
/* Default to NTSC */
#include "Source/Platform/ColorsNTSC.h"
#endif

#endif