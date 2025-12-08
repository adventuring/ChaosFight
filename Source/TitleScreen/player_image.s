

;;;;*** the height of this mini-kernel.
bmp_player_window = 10

 ;;*** how many scanlines per pixel. 
bmp_player_kernellines = 1

 ;;*** the height of each player.
bmp_player0_height = 10
bmp_player1_height = 10

 ;;*** NUSIZ0 value. If you want to change it in a variable
 ;;*** instead, dim on in bB called "bmp_player0_nusiz"
          .if ! bmp_player0_nusiz
bmp_player0_nusiz:
          .fi
          .byte 0

 ;;*** NUSIZ1 value. If you want to change it in a variable
 ;;*** instead, dim on in bB called "bmp_player1_nusiz"
          .if ! bmp_player1_nusiz
bmp_player1_nusiz:
          .fi
          .byte 0

 ;;*** REFP0 value. If you want to change it in a variable
 ;;*** instead, dim on in bB called "bmp_player0_refp"
          .if ! bmp_player0_refp
bmp_player0_refp:
          .fi
          .byte 3

 ;;*** REFP1 value. If you want to change it in a variable
 ;;*** instead, dim on in bB called "bmp_player1_refp"
          .if ! bmp_player1_refp
bmp_player1_refp:
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
