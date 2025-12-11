
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
          lda temp1
          cmp # 0
          bne CheckPlayer1Character
          ;; let temp2 = playerCharacter[0]         
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

          ;; let temp2 = playerCharacter[1]         
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

          ;; let temp2 = playerCharacter[2]         
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

          ;; let temp2 = playerCharacter[3]         
          lda # 3
          asl
          tax
          lda playerCharacter,x
          sta temp2
LookupThemeSong:


          ;; Look up full song ID from mapping table (table contains
          ;; song ID consta

          ;; let temp1 = CharacterThemeSongIndices[temp2]         
          lda temp2
          asl
          tax
          lda CharacterThemeSongIndices,x
          sta temp1

          ;; Start winner’s character theme song
          ;; Cross-bank call to StartMusic in bank 15
          lda # >(AfterStartMusicWinner-1)
          pha
          lda # <(AfterStartMusicWinner-1)
          pha
          lda # >(StartMusic-1)
          pha
          lda # <(StartMusic-1)
          pha
                    ldx # 14
          jmp BS_jsr
AfterStartMusicWinner:


          jsr BS_return

.pend

