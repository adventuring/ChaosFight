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
/* SECAM color macro functions - 8 colors: RGB, CMY, KW
   0=Black, 1=Red, 2=Green, 3=Blue, 4=Cyan, 5=Magenta, 6=Yellow, 7=White */
/* SECAM luminance mapping: lum=0 -> black (0) for ALL colors, lum>0 -> respective color, ColGrey(2+) -> white (7) */
#define ColGrey(lum) ((lum) == 0 ? 0 : ((lum) >= 2 ? 7 : 0))  /* lum=0 -> black, lum>=2 -> white */
#define ColGray(lum) ColGrey(lum)  /* ColGray and ColGrey are synonyms */
#define ColYellow(lum) ((lum) == 0 ? 0 : 6)  /* lum=0 -> black, lum>0 -> yellow */
#define ColBrown(lum) ((lum) == 0 ? 0 : 6)  /* lum=0 -> black, lum>0 -> yellow */
#define ColOrange(lum) ((lum) == 0 ? 0 : 6)  /* lum=0 -> black, lum>0 -> yellow */
#define ColRed(lum) ((lum) == 0 ? 0 : 1)  /* lum=0 -> black, lum>0 -> red */
#define ColMagenta(lum) ((lum) == 0 ? 0 : 5)  /* lum=0 -> black, lum>0 -> magenta */
#define ColPurple(lum) ((lum) == 0 ? 0 : 5)  /* lum=0 -> black, lum>0 -> magenta */
#define ColViolet(lum) ((lum) == 0 ? 0 : 5)  /* lum=0 -> black, lum>0 -> magenta (synonym of Purple) */
#define ColIndigo(lum) ((lum) == 0 ? 0 : 3)  /* lum=0 -> black, lum>0 -> blue */
#define ColBlue(lum) ((lum) == 0 ? 0 : 3)  /* lum=0 -> black, lum>0 -> blue */
#define ColTurquoise(lum) ((lum) == 0 ? 0 : 4)  /* lum=0 -> black, lum>0 -> cyan */
#define ColCyan(lum) ((lum) == 0 ? 0 : 4)  /* lum=0 -> black, lum>0 -> cyan */
#define ColTeal(lum) ((lum) == 0 ? 0 : 4)  /* lum=0 -> black, lum>0 -> cyan */
#define ColSeafoam(lum) ((lum) == 0 ? 0 : 4)  /* lum=0 -> black, lum>0 -> cyan */
#define ColGreen(lum) ((lum) == 0 ? 0 : 2)  /* lum=0 -> black, lum>0 -> green */
#define ColLime(lum) ((lum) == 0 ? 0 : 2)  /* lum=0 -> black, lum>0 -> green (synonym of Green) */
#define ColSpringGreen(lum) ((lum) == 0 ? 0 : 2)  /* lum=0 -> black, lum>0 -> green */
#define ColGold(lum) ((lum) == 0 ? 0 : 6)  /* lum=0 -> black, lum>0 -> yellow */

#else
/* Default to NTSC */
#include "Source/Platform/ColorsNTSC.h"
#endif

#endif