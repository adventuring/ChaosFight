
BeginWinnerAnnouncement .proc

          ;;
          ;; Returns: Far (return otherbank)
          ;; ChaosFight - Source/Routines/BeginWinnerAnnouncement.bas
          ;; Copyright © 2025 Bruce-Robert Pocock.
          ;; BEGIN WINNER ANNOUNCEMENT - Setup Routine
          ;; Setup routine for Winner Announcement mode. Sets initial
          ;; state only.
          ;; Called from ChangeGameMode when transitioning to
          ;; ModeWinner.

          ;; Setup routine for Winner Announcement mode - sets initial
          ;; state only
          ;;
          ;; Input: winnerPlayerIndex (global) = winner player index
          ;; (set by game end logic)
          ;; playerCharacter[] (global array) = player character
          ;; selections
          ;; CharacterThemeSongIndices[] (global array) =
          ;; character theme song mapping
          ;;
          ;; Output: screen layout set, COLUBK set, displayRank initialized,
          ;; music started with winner’s character theme
          ;;
          ;; Mutates: pfrowheight, pfrows (set via
          ;; SetGameScreenLayout),
          ;; COLUBK (TIA register),
          ;; displayRank (set to 0),
          ;; temp1, temp2 (used for character/song lookup)
          ;;
          ;; Called Routines: SetGameScreenLayout (bank7) - sets
          ;; screen layout,
          ;; StartMusic (bank1) - starts winner’s character theme
          ;; song
          ;;
          ;; Constraints: Called from ChangeGameMode when transitioning
          ;; to ModeWinner
          ;; winnerPlayerIndex must be set by game end
          ;; logic (FindWinner.bas)

          ;; Initialize Winner Announcement mode
          ;; winnerPlayerIndex should already be set by game end logic
          ;; (FindWinner.bas)

          ;; Set screen layout (32×8 for character display) - inlined
          lda ScreenPfRowHeight
          sta pfrowheight
          lda ScreenPfRows
          sta pfrows

          ;; Background: black (COLUBK starts black, no need to set)

          ;; Initialize display rank (starts at 0, may be updated by
          ;; DisplayWinScreen if implemented)
          lda # 0
          sta displayRank_W

          ;; Get winner’s character index
          lda winnerPlayerIndex_R
          sta temp1
          bne CheckPlayer1Character
          ;; Set temp2 = playerCharacter[0]
          lda # 0
          asl
          tax
          lda playerCharacter,x
          sta temp2
          jmp LookupThemeSong

CheckPlayer1Character:

          lda temp1
          cmp # 1
          bne CheckPlayer2Character

          ;; Set temp2 = playerCharacter[1]
          lda # 1
          asl
          tax
          lda playerCharacter,x
          sta temp2
          jmp LookupThemeSong

CheckPlayer2Character:

          lda temp1
          cmp # 2
          bne CheckPlayer3Character

          ;; Set temp2 = playerCharacter[2]
          lda # 2
          asl
          tax
          lda playerCharacter,x
          sta temp2
          jmp LookupThemeSong

CheckPlayer3Character:

          lda temp1
          cmp # 3
          bne LookupThemeSong

          ;; Set temp2 = playerCharacter[3]
          lda # 3
          asl
          tax
          lda playerCharacter,x
          sta temp2
LookupThemeSong:


          ;; Look up full song ID from mapping table (table contains
          ;; song ID consta

          ;; Set temp1 = CharacterThemeSongIndices[temp2]
          lda temp2
          asl
          tax
          lda CharacterThemeSongIndices,x
          sta temp1

          ;; Start winner’s character theme song
          ;; Cross-bank call to StartMusic in bank 15
          ;; Return address: ENCODED with caller bank 13 ($d0) for BS_return to decode
          lda # ((>(AfterStartMusicWinner-1)) & $0f) | $d0  ;;; Encode bank 13 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterStartMusicWinner hi (encoded)]
          lda # <(AfterStartMusicWinner-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterStartMusicWinner hi (encoded)] [SP+0: AfterStartMusicWinner lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(StartMusic-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterStartMusicWinner hi (encoded)] [SP+1: AfterStartMusicWinner lo] [SP+0: StartMusic hi (raw)]
          lda # <(StartMusic-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterStartMusicWinner hi (encoded)] [SP+2: AfterStartMusicWinner lo] [SP+1: StartMusic hi (raw)] [SP+0: StartMusic lo]
          ldx # 14
          jmp BS_jsr
AfterStartMusicWinner:


          jmp BS_return

.pend

