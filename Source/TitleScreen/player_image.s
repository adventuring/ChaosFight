

;;;;*** the height of this mini-kernel.
bmpPlayerWindow = 10

 ;;*** how many scanlines per pixel. 
bmpPlayerKernellines = 1

 ;;*** the height of each player.
bmpPlayer0Height = 10
bmpPlayer1Height = 10

 ;;*** NUSIZ0 value. If you want to change it in a variable
 ;;*** instead, dim on in bB called "bmpPlayer0Nusiz"
          .if ! bmpPlayer0Nusiz
bmpPlayer0Nusiz:
          .fi
          .byte 0

 ;;*** NUSIZ1 value. If you want to change it in a variable
 ;;*** instead, dim on in bB called "bmpPlayer1Nusiz"
          .if ! bmpPlayer1Nusiz
bmpPlayer1Nusiz:
          .fi
          .byte 0

 ;;*** REFP0 value. If you want to change it in a variable
 ;;*** instead, dim on in bB called "bmpPlayer0Refp"
          .if ! bmpPlayer0Refp
bmpPlayer0Refp:
          .fi
          .byte 3

 ;;*** REFP1 value. If you want to change it in a variable
 ;;*** instead, dim on in bB called "bmpPlayer1Refp"
          .if ! bmpPlayer1Refp
bmpPlayer1Refp:
          .fi
          .byte 3

 ;;*** the bitmap data for player0
bmp_player0:
          .byte %11111111
          .byte %11000011
          .byte %10011001
          .byte %10111101
          .byte %10111101
          .byte %10111101
          .byte %10111101
          .byte %10011001
          .byte %11000011
          .byte %11111111

 ;;*** the color data for player0
bmp_color_player0:
          .byte $86 
          .byte $86 
          .byte $86 
          .byte $86 
          .byte $86 
          .byte $86 
          .byte $86 
          .byte $86 
          .byte $86 
          .byte $86 

 ;;*** the bitmap data for player1
bmp_player1:
          .byte %11111111
          .byte %11000011
          .byte %11100111
          .byte %11100111
          .byte %11100111
          .byte %11100111
          .byte %11100111
          .byte %11100111
          .byte %11000111
          .byte %11111111

 ;;*** the color data for player1
bmp_color_player1:
          .byte $FA
          .byte $FA
          .byte $FA
          .byte $FA
          .byte $FA
          .byte $FA
          .byte $FA
          .byte $FA
          .byte $FA
          .byte $FA
