;; NTSC color palette - CoLu function system: CoLu(ColHue, lum)
;; Formula: color_value = (hue * 16) | lum
;; Usage: CoLu(ColGold, 12) calculates (15 * 16) | 12 = $FC
;; Note: CoLu calls are pre-processed to hex values before compilation

;; Hue constants (0-15)
;; Forward references are fine - 64tass handles them automatically
;; If included multiple times, duplicate definitions will be caught by 64tass
ColGrey = 0
ColYellow = 1
ColBrown = 2
ColOrange = 3
ColRed = 4
ColMagenta = 5
ColPurple = 6
ColIndigo = 7
ColBlue = 8
ColTurquoise = 9
ColCyan = 10
ColTeal = 11
ColSeafoam = 12
ColGreen = 13
ColSpringGreen = 14
ColGold = 15

;; CoLu function - pre-processed by build system
;; CoLu(ColHue, lum) -> (hue * 16) | lum
