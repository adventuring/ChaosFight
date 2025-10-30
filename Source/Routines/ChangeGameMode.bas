          rem ChaosFight - Source/Routines/ChangeGameMode.bas
          rem Calls the appropriate Begin* routine for the current GameMode

ChangeGameMode
          if GameMode = ModePublisherPrelude then gosub BeginPublisherPrelude : return
          if GameMode = ModeAuthorPrelude then gosub BeginAuthorPrelude : return
          if GameMode = ModeTitle then gosub BeginTitleScreen : return
          if GameMode = ModeCharacterSelect then gosub BeginCharacterSelect : return
          if GameMode = ModeFallingAnimation then gosub BeginFallingAnimation : return
          if GameMode = ModeGame then gosub BeginGameLoop : return
          if GameMode = ModeWinner then return
          return


