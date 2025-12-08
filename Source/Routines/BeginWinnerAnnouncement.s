
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
          ;; lda ScreenPfRows (duplicate)
          ;; sta pfrows (duplicate)

          ;; Background: black (COLUBK starts black, no need to set)

          ;; Initialize display rank (starts at 0, may be updated by
          ;; DisplayWinScreen if implemented)
          ;; lda # 0 (duplicate)
          ;; sta displayRank_W (duplicate)

          ;; Get winner’s character index
          ;; lda winnerPlayerIndex_R (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda temp1 (duplicate)
          cmp # 0
          bne skip_3841
                    ;; let temp2 = playerCharacter[0]         
          ;; lda 0 (duplicate)
          asl
          tax
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp2 (duplicate)
skip_3841:


          ;; lda temp1 (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bne skip_7445 (duplicate)
                    ;; let temp2 = playerCharacter[1]         
          ;; lda 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp2 (duplicate)
skip_7445:


          ;; lda temp1 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_6650 (duplicate)
                    ;; let temp2 = playerCharacter[2]         
          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp2 (duplicate)
skip_6650:


          ;; lda temp1 (duplicate)
          ;; cmp # 3 (duplicate)
          ;; bne skip_3547 (duplicate)
                    ;; let temp2 = playerCharacter[3]         
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp2 (duplicate)
skip_3547:


          ;; Look up full song ID from mapping table (table contains
          ;; song ID consta

                    ;; let temp1 = CharacterThemeSongIndices[temp2]         
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterThemeSongIndices,x (duplicate)
          ;; sta temp1 (duplicate)

          ;; Start winner’s character theme song
          ;; Cross-bank call to StartMusic in bank 15
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(StartMusic-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(StartMusic-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 14
          jmp BS_jsr
return_point:


          jsr BS_return

.pend

