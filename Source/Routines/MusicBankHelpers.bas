          rem ChaosFight - Source/Routines/MusicBankHelpers.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem SONGS BANK HELPER FUNCTIONS
          rem =================================================================
          rem These functions access song data tables and streams in Bank 16
          rem =================================================================
          
          #include "Source/Data/SongPointers.bas"
          
          rem Lookup song pointer from tables
          rem Input: temp1 = song ID (0-28)
          rem Output: SongPointerL, SongPointerH = pointer to Song_Voice0 stream
LoadSongPointer
          dim LSP_songID = temp1
          rem Bounds check: 29 songs (0-28)
          if LSP_songID > 28 then let SongPointerH = 0 : return
          rem Use array access to lookup pointer
          let SongPointerL = SongPointersL[LSP_songID]
          let SongPointerH = SongPointersH[LSP_songID]
          return
          
          rem Lookup Voice 1 song pointer from tables
          rem Input: temp1 = song ID (0-28)
          rem Output: SongPointerL, SongPointerH = pointer to Song_Voice1 stream
LoadSongVoice1Pointer
          dim LSV1P_songID = temp1
          rem Bounds check: 29 songs (0-28)
          if LSV1P_songID > 28 then let SongPointerH = 0 : return
          rem Use array access to lookup Voice 1 pointer directly
          let SongPointerL = SongPointersSecondL[LSV1P_songID]
          let SongPointerH = SongPointersSecondH[LSV1P_songID]
          return
          
          rem Load next note from Voice 0 stream using assembly for pointer access
          rem Input: MusicVoice0PointerL/H points to current note in Song_Voice0 stream
          rem Output: Updates TIA registers, advances pointer, sets MusicVoice0Frame
LoadMusicNote0
          dim LMN0_audcv = temp2
          dim LMN0_audf = temp3
          dim LMN0_duration = temp4
          dim LMN0_delay = temp5
          dim LMN0_audc = temp6
          dim LMN0_audv = temp7
          asm
          ; Load 4 bytes from stream[pointer]
          ldy #0
          lda (MusicVoice0PointerL),y  ; Load AUDCV
          sta temp2
          iny
          lda (MusicVoice0PointerL),y  ; Load AUDF
          sta temp3
          iny
          lda (MusicVoice0PointerL),y  ; Load Duration
          sta temp4
          iny
          lda (MusicVoice0PointerL),y  ; Load Delay
          sta temp5
          end
          
          rem Check for end of track (Duration = 0)
          if LMN0_duration = 0 then LoadMusicNote0EndOfTrack
          
          rem Extract AUDC (upper 4 bits) and AUDV (lower 4 bits) from AUDCV
          LMN0_audc = LMN0_audcv & %11110000
          LMN0_audc = LMN0_audc / 16
          LMN0_audv = LMN0_audcv & %00001111
          
          rem Store target AUDV and total frames for envelope calculation
          let MusicVoice0TargetAUDV = LMN0_audv
          let MusicVoice0TotalFrames = LMN0_duration + LMN0_delay
          
          rem Write to TIA registers (will be adjusted by envelope in UpdateMusicVoice0)
          AUDC0 = LMN0_audc
          AUDF0 = LMN0_audf
          AUDV0 = LMN0_audv
          
          rem Set frame counter = Duration + Delay
          let MusicVoice0Frame = LMN0_duration + LMN0_delay
          
          rem Advance pointer by 4 bytes (16-bit addition)
          rem Reuse temp2 (LMN0_audcv no longer needed) for pointer calculation
          let temp2 = MusicVoice0PointerL
          let MusicVoice0PointerL = temp2 + 4
          if MusicVoice0PointerL < temp2 then let MusicVoice0PointerH = MusicVoice0PointerH + 1
          
          return
          
LoadMusicNote0EndOfTrack
          rem End of track reached - check if Chaotica (26) for looping
          if CurrentSongID_R = 26 then LoadMusicNote0LoopChaotica
          
          rem Not Chaotica - stop playback
          let MusicVoice0PointerH = 0
          AUDV0 = 0
          return
          
LoadMusicNote0LoopChaotica
          rem Chaotica loops - reset to start
          let MusicVoice0PointerL = MusicVoice0StartPointerL
          let MusicVoice0PointerH = MusicVoice0StartPointerH
          rem Tail call to reload first note
          rem tail call
          goto LoadMusicNote0
          
          rem Extract AUDC (upper 4 bits) and AUDV (lower 4 bits) from AUDCV
          LMN0_audc = LMN0_audcv & %11110000
          LMN0_audc = LMN0_audc / 16
          LMN0_audv = LMN0_audcv & %00001111
          
          rem Store target AUDV and total frames for envelope calculation
          let MusicVoice0TargetAUDV = LMN0_audv
          let MusicVoice0TotalFrames = LMN0_duration + LMN0_delay
          
          rem Write to TIA registers (will be adjusted by envelope in UpdateMusicVoice0)
          AUDC0 = LMN0_audc
          AUDF0 = LMN0_audf
          AUDV0 = LMN0_audv
          
          rem Set frame counter = Duration + Delay
          let MusicVoice0Frame = LMN0_duration + LMN0_delay
          
          rem Advance pointer by 4 bytes (16-bit addition)
          rem Reuse temp2 (LMN0_audcv no longer needed) for pointer calculation
          let temp2 = MusicVoice0PointerL
          let MusicVoice0PointerL = temp2 + 4
          if MusicVoice0PointerL < temp2 then let MusicVoice0PointerH = MusicVoice0PointerH + 1
          
          return
          
          rem Load next note from Voice 1 stream
LoadMusicNote1
          dim LMN1_audcv = temp2
          dim LMN1_audf = temp3
          dim LMN1_duration = temp4
          dim LMN1_delay = temp5
          dim LMN1_audc = temp6
          dim LMN1_audv = temp7
          asm
          ; Load 4 bytes from stream[pointer]
          ldy #0
          lda (MusicVoice1PointerL),y  ; Load AUDCV
          sta temp2
          iny
          lda (MusicVoice1PointerL),y  ; Load AUDF
          sta temp3
          iny
          lda (MusicVoice1PointerL),y  ; Load Duration
          sta temp4
          iny
          lda (MusicVoice1PointerL),y  ; Load Delay
          sta temp5
          end
          
          rem Check for end of track (Duration = 0)
          if LMN1_duration = 0 then LoadMusicNote1EndOfTrack
          
          rem Extract AUDC and AUDV
          LMN1_audc = LMN1_audcv & %11110000
          LMN1_audc = LMN1_audc / 16
          LMN1_audv = LMN1_audcv & %00001111
          
          rem Store target AUDV and total frames for envelope calculation
          let MusicVoice1TargetAUDV = LMN1_audv
          let MusicVoice1TotalFrames = LMN1_duration + LMN1_delay
          
          rem Write to TIA registers (will be adjusted by envelope in UpdateMusicVoice1)
          AUDC1 = LMN1_audc
          AUDF1 = LMN1_audf
          AUDV1 = LMN1_audv
          
          rem Set frame counter = Duration + Delay
          let MusicVoice1Frame = LMN1_duration + LMN1_delay
          
          rem Advance pointer by 4 bytes
          rem Reuse temp2 (LMN1_audcv no longer needed) for pointer calculation
          let temp2 = MusicVoice1PointerL
          let MusicVoice1PointerL = temp2 + 4
          if MusicVoice1PointerL < temp2 then let MusicVoice1PointerH = MusicVoice1PointerH + 1
          
          return
          
LoadMusicNote1EndOfTrack
          rem End of track reached - check if Chaotica (26) for looping
          if CurrentSongID_R = 26 then LoadMusicNote1LoopChaotica
          
          rem Not Chaotica - stop playback
          let MusicVoice1PointerH = 0
          AUDV1 = 0
          return
          
LoadMusicNote1LoopChaotica
          rem Chaotica loops - reset to start
          let MusicVoice1PointerL = MusicVoice1StartPointerL
          let MusicVoice1PointerH = MusicVoice1StartPointerH
          rem Tail call to reload first note
          rem tail call
          goto LoadMusicNote1
          
          rem Extract AUDC and AUDV
          LMN1_audc = LMN1_audcv & %11110000
          LMN1_audc = LMN1_audc / 16
          LMN1_audv = LMN1_audcv & %00001111
          
          rem Store target AUDV and total frames for envelope calculation
          let MusicVoice1TargetAUDV = LMN1_audv
          let MusicVoice1TotalFrames = LMN1_duration + LMN1_delay
          
          rem Write to TIA registers (will be adjusted by envelope in UpdateMusicVoice1)
          AUDC1 = LMN1_audc
          AUDF1 = LMN1_audf
          AUDV1 = LMN1_audv
          
          rem Set frame counter = Duration + Delay
          let MusicVoice1Frame = LMN1_duration + LMN1_delay
          
          rem Advance pointer by 4 bytes
          rem Reuse temp2 (LMN1_audcv no longer needed) for pointer calculation
          let temp2 = MusicVoice1PointerL
          let MusicVoice1PointerL = temp2 + 4
          if MusicVoice1PointerL < temp2 then let MusicVoice1PointerH = MusicVoice1PointerH + 1
          
          return
