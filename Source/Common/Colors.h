#ifndef COLORS_H
#define COLORS_H

/* Color macro functions for different TV standards
   NTSC: 16 colors (4-bit hue + 4-bit luminance)
   PAL: 16 colors (4-bit hue + 4-bit luminance) - some different from NTSC
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
#define ColGrey(lum) 0  /* Black for now */
#define ColYellow(lum) 6
#define ColBrown(lum) 6  /* -> Yellow */
#define ColOrange(lum) 6  /* -> Yellow */
#define ColRed(lum) 1
#define ColMagenta(lum) 5
#define ColPurple(lum) 5  /* -> Magenta */
#define ColIndigo(lum) 3  /* -> Blue */
#define ColBlue(lum) 3
#define ColTurquoise(lum) 4  /* -> Cyan */
#define ColCyan(lum) 4
#define ColTeal(lum) 4  /* -> Cyan */
#define ColSeafoam(lum) 4  /* -> Cyan */
#define ColGreen(lum) 2
#define ColSpringGreen(lum) 2  /* -> Green */
#define ColGold(lum) 6  /* -> Yellow */

#else
/* Default to NTSC */
#include "Source/Platform/ColorsNTSC.h"
#endif

#endif