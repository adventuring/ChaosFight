#ifndef COLORS_H
#define COLORS_H

// Color macro functions for different TV standards
// NTSC: 16 colors (4-bit hue + 4-bit luminance)
// PAL: 16 colors (4-bit hue + 4-bit luminance) - some different from NTSC
// SECAM: 8 colors (3-bit hue only, no luminance)

#ifdef TV_NTSC
// NTSC color macro functions
#define ColGrey(lum) ($00 | (lum))
#define ColYellow(lum) ($10 | (lum))
#define ColBrown(lum) ($20 | (lum))
#define ColOrange(lum) ($30 | (lum))
#define ColRed(lum) ($40 | (lum))
#define ColMagenta(lum) ($50 | (lum))
#define ColPurple(lum) ($60 | (lum))
#define ColIndigo(lum) ($70 | (lum))
#define ColBlue(lum) ($80 | (lum))
#define ColTurquoise(lum) ($90 | (lum))
#define ColCyan(lum) ($a0 | (lum))
#define ColTeal(lum) ($b0 | (lum))
#define ColSeafoam(lum) ($c0 | (lum))
#define ColGreen(lum) ($d0 | (lum))
#define ColSpringGreen(lum) ($e0 | (lum))
#define ColGold(lum) ($f0 | (lum))

#elif defined(TV_PAL)
// PAL color macro functions - same as NTSC for now
#define ColGrey(lum) ($00 | (lum))
#define ColYellow(lum) ($10 | (lum))
#define ColBrown(lum) ($20 | (lum))
#define ColOrange(lum) ($30 | (lum))
#define ColRed(lum) ($40 | (lum))
#define ColMagenta(lum) ($50 | (lum))
#define ColPurple(lum) ($60 | (lum))
#define ColIndigo(lum) ($70 | (lum))
#define ColBlue(lum) ($80 | (lum))
#define ColTurquoise(lum) ($90 | (lum))
#define ColCyan(lum) ($a0 | (lum))
#define ColTeal(lum) ($b0 | (lum))
#define ColSeafoam(lum) ($c0 | (lum))
#define ColGreen(lum) ($d0 | (lum))
#define ColSpringGreen(lum) ($e0 | (lum))
#define ColGold(lum) ($f0 | (lum))

#elif defined(TV_SECAM)
// SECAM color macro functions - 8 colors: RGB, CMY, KW
// 0=Black, 1=Red, 2=Green, 3=Blue, 4=Cyan, 5=Magenta, 6=Yellow, 7=White
#define ColGrey(lum) 0  // Black for now
#define ColYellow(lum) 6
#define ColBrown(lum) 6  // -> Yellow
#define ColOrange(lum) 6  // -> Yellow
#define ColRed(lum) 1
#define ColMagenta(lum) 5
#define ColPurple(lum) 5  // -> Magenta
#define ColIndigo(lum) 3  // -> Blue
#define ColBlue(lum) 3
#define ColTurquoise(lum) 4  // -> Cyan
#define ColCyan(lum) 4
#define ColTeal(lum) 4  // -> Cyan
#define ColSeafoam(lum) 4  // -> Cyan
#define ColGreen(lum) 2
#define ColSpringGreen(lum) 2  // -> Green
#define ColGold(lum) 6  // -> Yellow

#else
// Default to NTSC
#define ColGrey(lum) ($00 | (lum))
#define ColYellow(lum) ($10 | (lum))
#define ColBrown(lum) ($20 | (lum))
#define ColOrange(lum) ($30 | (lum))
#define ColRed(lum) ($40 | (lum))
#define ColMagenta(lum) ($50 | (lum))
#define ColPurple(lum) ($60 | (lum))
#define ColIndigo(lum) ($70 | (lum))
#define ColBlue(lum) ($80 | (lum))
#define ColTurquoise(lum) ($90 | (lum))
#define ColCyan(lum) ($a0 | (lum))
#define ColTeal(lum) ($b0 | (lum))
#define ColSeafoam(lum) ($c0 | (lum))
#define ColGreen(lum) ($d0 | (lum))
#define ColSpringGreen(lum) ($e0 | (lum))
#define ColGold(lum) ($f0 | (lum))
#endif

#endif