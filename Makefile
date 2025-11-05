# Default target
all: game doc

# Test target
test: SkylineTool/skyline-tool.asd
	@echo "Running SkylineTool fiveam tests..."
	cd SkylineTool && sbcl --script tests/run-tests.lisp || (echo "Tests failed!" && exit 1)

# Precious intermediate files
.PRECIOUS: %.s %.png %.midi Object/bB.%.s Source/Generated/$(GAME).%.preprocessed.bas

# Don't delete PNG files automatically - they are intermediate but should be preserved
# between builds if XCF hasn't changed
.SECONDARY: $(CHARACTER_PNG) $(foreach bitmap,$(BITMAP_NAMES),Source/Art/$(bitmap).png)

# Tools and directories
BB_DIR = Tools/batariBASIC
BB_MAIN = bin/2600basic
BB_PREPROCESS = bin/preprocess
BB_POSTPROCESS = bin/postprocess
BB_OPTIMIZE = bin/optimize
DASM = bin/dasm
BB_FILTER = bin/bbfilter
POSTINC = $(abspath Tools/batariBASIC)
DASM = bin/dasm
STELLA = stella
# -i taken out for now from gimp
GIMP = gimp --batch-interpreter plug-in-script-fu-eval -c --no-shm

# Ready system
READYDATE = 20251104
READYFILE = .#ready.$(READYDATE)

# SkylineTool build rules
SkylineTool/zx7mini/zx7mini.c:
	git submodule update --init --recursive

bin/zx7mini:	SkylineTool/zx7mini/zx7mini.c
	$(CC) SkylineTool/zx7mini/zx7mini.c -o bin/zx7mini
	chmod +x bin/zx7mini

skyline-tool:	bin/skyline-tool

SkylineTool/skyline-tool.asd:
	git submodule update --init --recursive

bin/skyline-tool:	bin/buildapp bin/zx7mini \
	SkylineTool/skyline-tool.asd \
	$(shell ls SkylineTool/*.lisp SkylineTool/src/*.lisp)
	mkdir -p bin
	@echo "Note: This may take a while if you don't have some common Quicklisp \
libraries already compiled. On subsequent runs, though, it'll be much quicker." >&2
	bin/buildapp --output bin/skyline-tool \
		--load SkylineTool/setup.lisp \
		--load-system skyline-tool \
		--entry skyline-tool::command

bin/buildapp:
	sbcl --load SkylineTool/prepare-system.lisp --eval '(cl-user::quit)'

# Output files
GAME = ChaosFight
GAMEYEAR = 25
ROM = Dist/$(GAME)$(GAMEYEAR).NTSC.a26

# Assembly files (exclude preprocessed, generated files, and reference files)
ALL_SOURCES = $(shell find Source -name \*.bas -not -path "Source/Generated/*" -not -path "Source/Reference/*")

.PHONY: all clean emu game help doc characters fonts sprites nowready ready bitmaps music sounds

# Build game
game: \
	$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas) \
	Dist/$(GAME)$(GAMEYEAR).NTSC.a26 \
	Dist/$(GAME)$(GAMEYEAR).PAL.a26 \
	Dist/$(GAME)$(GAMEYEAR).SECAM.a26 \
	Dist/$(GAME)$(GAMEYEAR).NTSC.sym \
	Dist/$(GAME)$(GAMEYEAR).PAL.sym \
	Dist/$(GAME)$(GAMEYEAR).SECAM.sym \
	Dist/$(GAME)$(GAMEYEAR).NTSC.lst \
	Dist/$(GAME)$(GAMEYEAR).PAL.lst \
	Dist/$(GAME)$(GAMEYEAR).SECAM.lst \
	Dist/$(GAME)$(GAMEYEAR).NTSC.pro \
	Dist/$(GAME)$(GAMEYEAR).PAL.pro \
	Dist/$(GAME)$(GAMEYEAR).SECAM.pro

doc: Dist/$(GAME)$(GAMEYEAR).pdf Dist/$(GAME)$(GAMEYEAR).html

# Character sprite sheet names (32 characters: 16 main + 16 future)
CHARACTER_NAMES = \
	Bernie Curler DragonOfStorms ZoeRyen FatTony Megax Harpy KnightGuy \
	Frooty Nefertem NinjishGuy PorkChop RadishGoblin RoboTito Ursulo Shamone \
	Character16 Character17 Character18 Character19 Character20 Character21 Character22 Character23 \
	Character24 Character25 Character26 Character27 Character28 Character29 Character30 MethHound

# TV architectures
TV_ARCHS = NTSC PAL SECAM

# Bitmap names (48×42 bitmaps for titlescreen kernel)
BITMAP_NAMES = AtariAge AtariAgeText BRP ChaosFight

# Font names
FONT_NAMES = Numbers

# Music names (MuseScore files)
MUSIC_NAMES = AtariToday Interworldly Chaotica

# Game-based character theme songs (unique songs only - no duplicates)
# Character-to-song mapping is defined in Source/Data/CharacterThemeSongIndices.bas
# Character 0-15 mappings: Bernie→Bernie, Curler→OCascadia, DragonOfStorms→Revontuli, ZoeRyen→EXO,
#   FatTony→Grizzards, Megax→Grizzards, Harpy→Revontuli, KnightGuy→MagicalFairyForce,
#   Frooty→MagicalFairyForce, Nefertem→Bolero, NinjishGuy→LowRes, PorkChop→MagicalFairyForce,
#   RadishGoblin→Bolero, RoboTito→RoboTito, Ursulo→SongOfTheBear, Shamone→DucksAway
# Character 16: Character16Theme (placeholder)
# Characters 17-30: Character*Theme (placeholders for future characters)
# Character 31 (MethHound): DucksAway (reuses DucksAway from character 15)
GAME_THEME_SONGS = Bernie OCascadia Revontuli EXO Grizzards MagicalFairyForce Bolero LowRes RoboTito SongOfTheBear DucksAway \
	Character16Theme Character17Theme Character18Theme Character19Theme Character20Theme Character21Theme Character22Theme Character23Theme \
	Character24Theme Character25Theme Character26Theme Character27Theme Character28Theme Character29Theme Character30Theme

# Sound effect names (MIDI files)
SOUND_NAMES = SoundAttackHit SoundGuardBlock SoundJump SoundPlayerEliminated \
	SoundMenuNavigate SoundMenuSelect SoundSpecialMove SoundPowerup \
	SoundLandingSafe SoundLandingDamage

# Build character assets
characters: $(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas)

# Build bitmap assets (48×42 for titlescreen kernel on admin screens)
bitmaps: $(foreach bitmap,$(BITMAP_NAMES),Source/Generated/Art.$(bitmap).s)

# Build font assets (fonts are universal, not region-specific)
fonts: $(foreach font,$(FONT_NAMES),Source/Generated/$(font).bas)

# Build music assets
music: $(foreach song,$(MUSIC_NAMES),$(foreach arch,$(TV_ARCHS),Source/Generated/Song.$(song).$(arch).bas)) \
       $(foreach song,$(GAME_THEME_SONGS),$(foreach arch,$(TV_ARCHS),Source/Generated/Song.$(song).$(arch).bas))

# Build sound effect assets
sounds: $(foreach sound,$(SOUND_NAMES),$(foreach arch,$(TV_ARCHS),Source/Generated/Sound.$(sound).$(arch).bas))

# Convert MuseScore to MIDI
%.midi: %.mscz
	if [ -x ~/Software/MuseScore*.AppImage ]; then \
		~/Software/MuseScore*.AppImage --export-to $@ $<; \
	elif which mscore; then \
		mscore --export-to $@ $<; \
	else \
		flatpak run org.musescore.MuseScore --export-to $@ $<; \
	fi

%.flac: %.mscz
	if [ -x ~/Software/MuseScore*.AppImage ]; then \
		
	elif which mscore; then \
		mscore --export-to $@ $<; \
	else \
		flatpak run org.musescore.MuseScore --export-to $@ $<; \
	fi

%.ogg: %.mscz
	if [ -x ~/Software/MuseScore*.AppImage ]; then \
		~/Software/MuseScore*.AppImage --export-to $@ $<; \
	elif which mscore; then \
		mscore --export-to $@ $<; \
	else \
		flatpak run org.musescore.MuseScore --export-to $@ $<; \
	fi

%.pdf: %.mscz
	if [ -x ~/Software/MuseScore*.AppImage ]; then \
		~/Software/MuseScore*.AppImage --export-to $@ $<; \
	elif which mscore; then \
		mscore --export-to $@ $<; \
	else \
		flatpak run org.musescore.MuseScore --export-to $@ $<; \
	fi

# Convert MIDI to batariBASIC music data for NTSC (60Hz)
# MIDI files are generated from MSCZ via %.midi: %.mscz pattern rule
# Explicitly depend on MSCZ to ensure proper build ordering in parallel builds
Source/Generated/Song.%.NTSC.bas: Source/Songs/%.midi Source/Songs/%.mscz bin/skyline-tool
	@echo "Converting music $< to $@ for NTSC..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-midi "$<" "batariBASIC" "60" "$@"

# Special rule: Title song is generated from Chaotica source files
Source/Generated/Song.Title.NTSC.bas: Source/Songs/Chaotica.midi Source/Songs/Chaotica.mscz bin/skyline-tool
	@echo "Converting Chaotica music $< to Song.Title $@ for NTSC..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-midi "$<" "batariBASIC" "60" "$@"

Source/Generated/Song.Title.PAL.bas: Source/Songs/Chaotica.midi Source/Songs/Chaotica.mscz bin/skyline-tool
	@echo "Converting Chaotica music $< to Song.Title $@ for PAL..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-midi "$<" "batariBASIC" "50" "$@"

# SECAM music files are not generated - SECAM build uses PAL music files via conditional includes

# Convert MIDI to batariBASIC music data for PAL (50Hz)
# MIDI files are generated from MSCZ via %.midi: %.mscz pattern rule
# Explicitly depend on MSCZ to ensure proper build ordering in parallel builds
Source/Generated/Song.%.PAL.bas: Source/Songs/%.midi Source/Songs/%.mscz bin/skyline-tool
	@echo "Converting music $< to $@ for PAL..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-midi "$<" "batariBASIC" "50" "$@"

# SECAM music files are not generated - SECAM build uses PAL music files via conditional includes

# Sound effect files use Sound. prefix instead of Song. prefix
# Convert MIDI to batariBASIC sound data for NTSC (60Hz)
# MIDI files are generated from MSCZ via %.midi: %.mscz pattern rule
# Explicitly depend on MSCZ to ensure proper build ordering in parallel builds
Source/Generated/Sound.%.NTSC.bas: Source/Songs/%.midi Source/Songs/%.mscz bin/skyline-tool
	@echo "Converting sound $< to $@ for NTSC..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-midi "$<" "batariBASIC" "60" "$@"

# Convert MIDI to batariBASIC sound data for PAL (50Hz)
# MIDI files are generated from MSCZ via %.midi: %.mscz pattern rule
# Explicitly depend on MSCZ to ensure proper build ordering in parallel builds
Source/Generated/Sound.%.PAL.bas: Source/Songs/%.midi Source/Songs/%.mscz bin/skyline-tool
	@echo "Converting sound $< to $@ for PAL..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-midi "$<" "batariBASIC" "50" "$@"

# SECAM sound files are not generated - SECAM build uses PAL sound files via conditional includes



# Generate list of character sprite files
CHARACTER_XCF = $(foreach char,$(CHARACTER_NAMES),Source/Art/$(char).xcf)
CHARACTER_PNG = $(foreach char,$(CHARACTER_NAMES),Source/Art/$(char).png)
CHARACTER_BAS = $(foreach char,$(CHARACTER_NAMES),Source/Generated/Art.$(char).bas)

# Convert XCF to PNG for sprites (characters and special sprites)
# Make will only regenerate if XCF is newer than PNG (based on file timestamps)
# Touch PNG after generation to ensure it's newer than XCF (handles filesystem precision issues)
%.png: %.xcf
	@echo "Converting $< to $@..."
	@mkdir -p Source/Art
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'
	@touch "$@"

# Character sprites are compiled using compile-chaos-character
# Special sprites (QuestionMark, CPU, No) are hard-coded in Source/Data/SpecialSprites.bas

# Explicit PNG dependencies for character sprites (ensures PNG generation from XCF)
# Use pattern rule to ensure PNG is generated from XCF before .bas compilation
$(foreach char,$(CHARACTER_NAMES),Source/Art/$(char).png): Source/Art/%.png: Source/Art/%.xcf
	@echo "Converting $< to $@..."
	@mkdir -p Source/Art
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'
	@touch "$@"

# Convenience rule: redirect Source/Generated/*.png requests to Source/Art/*.png
$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).png): Source/Generated/%.png: Source/Art/%.png
	@echo "Note: Character PNG files are in Source/Art/, not Source/Generated/"
	@mkdir -p Source/Generated
	@cp "$<" "$@"

# Generate character sprite files from PNG using chaos character compiler
# PNG files are generated from XCF via %.png: %.xcf pattern rule or explicit rules above
# Explicitly depend on both PNG and XCF to ensure proper build ordering
$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas): Source/Generated/%.bas: Source/Art/%.png Source/Art/%.xcf bin/skyline-tool                                      
	@echo "Generating character sprite data for $*..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-chaos-character "$@" "$(filter %.png,$^)"

# Convert Numbers PNG to batariBASIC data using SkylineTool
# PNG files are generated from XCF via %.png: %.xcf pattern rule
# Explicitly depend on XCF to ensure proper build ordering in parallel builds
Source/Generated/Numbers.bas: Source/Art/Numbers.png Source/Art/Numbers.xcf bin/skyline-tool
	@echo "Converting Numbers font $< to $@..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-2600-font-8x16 "$@" "$<"

# Fonts are universal (not TV-specific)
# Source/Generated/Numbers.bas is used directly by FontRendering.bas

# Convert 48×42 PNG to titlescreen kernel assembly format
# Uses compile-batari-48px with titlescreen-kernel-p flag for color-per-line + double-height
# These are bitmaps for the titlescreen kernel minikernels, not playfield data
# PNG files are built from XCF via the %.png: %.xcf pattern rule (line 180)
# Explicit PNG→XCF dependencies ensure XCF→PNG conversion happens first
# These use the pattern rule %.png: %.xcf (line 239) to generate PNGs from XCFs
Source/Art/AtariAge.png: Source/Art/AtariAge.xcf
	@echo "Generating PNG from XCF: $@..."
	@mkdir -p Source/Art
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'
	@touch "$@"

Source/Art/AtariAgeText.png: Source/Art/AtariAgeText.xcf
	@echo "Generating PNG from XCF: $@..."
	@mkdir -p Source/Art
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'
	@touch "$@"

Source/Art/BRP.png: Source/Art/BRP.xcf
	@echo "Generating PNG from XCF: $@..."
	@mkdir -p Source/Art
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'
	@touch "$@"

Source/Art/ChaosFight.png: Source/Art/ChaosFight.xcf
	@echo "Generating PNG from XCF: $@..."
	@mkdir -p Source/Art
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'
	@touch "$@"

Source/Art/Numbers.png: Source/Art/Numbers.xcf
	@echo "Generating PNG from XCF: $@..."
	@mkdir -p Source/Art
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'
	@touch "$@"

# Titlescreen kernel bitmap conversion: PNG → .s (assembly format)
# PNG files are generated from XCF via %.png: %.xcf pattern rule
# Explicitly depend on XCF to ensure proper build ordering in parallel builds
Source/Generated/Art.AtariAge.s: Source/Art/AtariAge.png Source/Art/AtariAge.xcf bin/skyline-tool
	@echo "Converting 48×42 bitmap $< to titlescreen kernel $@..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-batari-48px "$<" "$@" "t" "NTSC"

Source/Generated/Art.AtariAgeText.s: Source/Art/AtariAgeText.png Source/Art/AtariAgeText.xcf bin/skyline-tool
	@echo "Converting 48×42 bitmap $< to titlescreen kernel $@..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-batari-48px "$<" "$@" "t" "NTSC"

Source/Generated/Art.BRP.s: Source/Art/BRP.png Source/Art/BRP.xcf bin/skyline-tool
	@echo "Converting 48×42 bitmap $< to titlescreen kernel $@..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-batari-48px "$<" "$@" "t" "NTSC"

Source/Generated/Art.ChaosFight.s: Source/Art/ChaosFight.png Source/Art/ChaosFight.xcf bin/skyline-tool
	@echo "Converting 48×42 bitmap $< to titlescreen kernel $@..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-batari-48px "$<" "$@" "t" "NTSC"

# Convert XCF to PNG for maps
Source/Art/Map-%.png: Source/Art/Map-%.xcf
	$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'

# Convert PNG font to batariBASIC data
Source/Generated/Font.bas: Source/Art/Font.png
	@echo "Converting font $< to $@ for NTSC..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-8x16-font "$<" > "$@" 

# Build game - accurate dependencies based on actual includes
# CRITICAL: cpp preprocessor processes includes immediately, so all generated files
# that are included via #include directives MUST exist before cpp runs.
# Character files are dependencies of Bank2/3/4/5.bas (defined above).
# Bitmap files are dependencies of Bank1.bas (defined above).
# Numbers font is a dependency of Bank12.bas (defined above).
# Bank15.bas includes Sound.*.bas files, so they must be dependencies here.
Source/Generated/$(GAME).NTSC.bas: Source/Platform/NTSC.bas \
	$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas) \
	Source/Banks/Bank1.bas Source/Banks/Bank2.bas Source/Banks/Bank3.bas Source/Banks/Bank4.bas Source/Banks/Bank5.bas Source/Banks/Bank12.bas \
	Source/Generated/Art.AtariAge.s Source/Generated/Art.AtariAgeText.s Source/Generated/Art.ChaosFight.s Source/Generated/Art.BRP.s \
	$(foreach sound,$(SOUND_NAMES),Source/Generated/Sound.$(sound).NTSC.bas) \
	$(foreach song,$(MUSIC_NAMES),Source/Generated/Song.$(song).NTSC.bas) \
	$(foreach song,$(GAME_THEME_SONGS),Source/Generated/Song.$(song).NTSC.bas)
	mkdir -p Source/Generated
	cpp -P -traditional -I. -DBUILD_YEAR=$(shell date +%Y) -DBUILD_DAY=$(shell date +%j) -DBUILD_DATE_STRING=\"$(shell date +%Y).$(shell date +%j)\" -Wno-trigraphs -Wno-format -Wno-invalid-pp-token $< > $@

Source/Generated/$(GAME).PAL.bas: Source/Platform/PAL.bas \
	$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas) \
	Source/Banks/Bank1.bas Source/Banks/Bank2.bas Source/Banks/Bank3.bas Source/Banks/Bank4.bas Source/Banks/Bank5.bas Source/Banks/Bank12.bas \
	Source/Generated/Art.AtariAge.s Source/Generated/Art.AtariAgeText.s Source/Generated/Art.ChaosFight.s Source/Generated/Art.BRP.s \
	$(foreach sound,$(SOUND_NAMES),Source/Generated/Sound.$(sound).PAL.bas) \
	$(foreach song,$(MUSIC_NAMES),Source/Generated/Song.$(song).PAL.bas) \
	$(foreach song,$(GAME_THEME_SONGS),Source/Generated/Song.$(song).PAL.bas)
	mkdir -p Source/Generated
	cpp -P -traditional -I. -DBUILD_YEAR=$(shell date +%Y) -DBUILD_DAY=$(shell date +%j) -DBUILD_DATE_STRING=\"$(shell date +%Y).$(shell date +%j)\" -Wno-trigraphs -Wno-format -Wno-invalid-pp-token $< > $@

# SECAM build uses PAL music/sound files via conditional includes in Bank15/16.bas
Source/Generated/$(GAME).SECAM.bas: Source/Platform/SECAM.bas \
	$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas) \
	Source/Banks/Bank1.bas Source/Banks/Bank2.bas Source/Banks/Bank3.bas Source/Banks/Bank4.bas Source/Banks/Bank5.bas Source/Banks/Bank12.bas \
	Source/Generated/Art.AtariAge.s Source/Generated/Art.AtariAgeText.s Source/Generated/Art.ChaosFight.s Source/Generated/Art.BRP.s \
	$(foreach sound,$(SOUND_NAMES),Source/Generated/Sound.$(sound).PAL.bas) \
	$(foreach song,$(MUSIC_NAMES),Source/Generated/Song.$(song).PAL.bas) \
	$(foreach song,$(GAME_THEME_SONGS),Source/Generated/Song.$(song).PAL.bas)
	mkdir -p Source/Generated
	cpp -P -traditional -I. -DBUILD_YEAR=$(shell date +%Y) -DBUILD_DAY=$(shell date +%j) -DBUILD_DATE_STRING=\"$(shell date +%Y).$(shell date +%j)\" -Wno-trigraphs -Wno-format -Wno-invalid-pp-token $< > $@

# Bank file dependencies - each bank explicitly depends on the files it includes
Source/Banks/Bank1.bas: Source/Generated/Art.AtariAge.s Source/Generated/Art.AtariAgeText.s Source/Generated/Art.ChaosFight.s Source/Generated/Art.BRP.s

Source/Banks/Bank2.bas: Source/Generated/Bernie.bas Source/Generated/Curler.bas Source/Generated/DragonOfStorms.bas Source/Generated/ZoeRyen.bas Source/Generated/FatTony.bas Source/Generated/Megax.bas Source/Generated/Harpy.bas Source/Generated/KnightGuy.bas

Source/Banks/Bank3.bas: Source/Generated/Frooty.bas Source/Generated/Nefertem.bas Source/Generated/NinjishGuy.bas Source/Generated/PorkChop.bas Source/Generated/RadishGoblin.bas Source/Generated/RoboTito.bas Source/Generated/Ursulo.bas Source/Generated/Shamone.bas

Source/Banks/Bank4.bas: Source/Generated/Character16.bas Source/Generated/Character17.bas Source/Generated/Character18.bas Source/Generated/Character19.bas Source/Generated/Character20.bas Source/Generated/Character21.bas Source/Generated/Character22.bas Source/Generated/Character23.bas

Source/Banks/Bank5.bas: Source/Generated/Character24.bas Source/Generated/Character25.bas Source/Generated/Character26.bas Source/Generated/Character27.bas Source/Generated/Character28.bas Source/Generated/Character29.bas Source/Generated/Character30.bas Source/Generated/MethHound.bas

Source/Banks/Bank12.bas: Source/Generated/Numbers.bas

# Shared dependencies for all TV standards
BUILD_DEPS = $(ALL_SOURCES) \
	Source/Banks/Bank1.bas \
	Source/Banks/Bank2.bas \
	Source/Banks/Bank3.bas \
	Source/Banks/Bank4.bas \
	Source/Banks/Bank5.bas \
	Source/Banks/Bank12.bas \
	Source/Banks/Banks.bas \
	Source/Common/Colors.h \
	Source/Common/Constants.bas \
	Source/Common/Macros.bas \
	Source/Common/Preamble.bas \
	Source/Common/Variables.bas \
	Source/Data/SpecialSprites.bas \
	Source/Routines/ColdStart.bas \
	Source/Routines/ControllerDetection.bas \
	Source/Routines/FallingAnimation.bas \
	Source/Routines/GameLoopInit.bas \
	Source/Routines/GameLoopMain.bas \
	Source/Routines/HealthBarSystem.bas \
	Source/Routines/LevelSelect.bas \
	Source/Routines/MainLoop.bas \
	Source/Routines/MusicSystem.bas \
	Source/Routines/ScreenLayout.bas \
	Source/Routines/SoundSystem.bas \
	Source/Routines/SpriteLoader.bas \
	$(foreach sound,$(SOUND_NAMES),Source/Generated/Sound.$(sound).NTSC.bas) \
	$(foreach sound,$(SOUND_NAMES),Source/Generated/Sound.$(sound).PAL.bas) \
	$(foreach song,$(MUSIC_NAMES),Source/Generated/Song.$(song).NTSC.bas) \
	$(foreach song,$(MUSIC_NAMES),Source/Generated/Song.$(song).PAL.bas) \
	$(foreach song,$(GAME_THEME_SONGS),Source/Generated/Song.$(song).NTSC.bas) \
	$(foreach song,$(GAME_THEME_SONGS),Source/Generated/Song.$(song).PAL.bas)
	# Note: SECAM uses PAL music/sound files via conditional includes in Bank15/16.bas

# Step 1: Preprocess .bas → .preprocessed.bas
# Explicitly depend on character and bitmap PNG files to ensure they are generated
Source/Generated/$(GAME).NTSC.preprocessed.bas: Source/Generated/$(GAME).NTSC.bas $(BUILD_DEPS) \
	$(CHARACTER_PNG) $(foreach bitmap,$(BITMAP_NAMES),Source/Art/$(bitmap).png)
	mkdir -p Source/Generated
	bin/preprocess < $< > $@

Source/Generated/$(GAME).PAL.preprocessed.bas: Source/Generated/$(GAME).PAL.bas $(BUILD_DEPS) \
	$(CHARACTER_PNG) $(foreach bitmap,$(BITMAP_NAMES),Source/Art/$(bitmap).png)
	mkdir -p Source/Generated
	bin/preprocess < $< > $@

Source/Generated/$(GAME).SECAM.preprocessed.bas: Source/Generated/$(GAME).SECAM.bas $(BUILD_DEPS) \
	$(CHARACTER_PNG) $(foreach bitmap,$(BITMAP_NAMES),Source/Art/$(bitmap).png)
	mkdir -p Source/Generated
	bin/preprocess < $< > $@

# Create empty variable redefs file if it doesn't exist (will be populated by batariBASIC)
# batariBASIC expects this file to be named 2600basic_variable_redefs.h
Object/2600basic_variable_redefs.h:
	@mkdir -p Object
	@touch $@

# Step 2: Compile .preprocessed.bas → bB.ARCH.s
Object/bB.NTSC.s: Source/Generated/$(GAME).NTSC.preprocessed.bas Object/2600basic_variable_redefs.h
	mkdir -p Object
	cd Object && timeout 60 ../bin/2600basic -i $(POSTINC) -r 2600basic_variable_redefs.h < ../Source/Generated/$(GAME).NTSC.preprocessed.bas > bB.NTSC.s

Object/bB.PAL.s: Source/Generated/$(GAME).PAL.preprocessed.bas Object/2600basic_variable_redefs.h
	mkdir -p Object
	cd Object && timeout 60 ../bin/2600basic -i $(POSTINC) -r 2600basic_variable_redefs.h < ../Source/Generated/$(GAME).PAL.preprocessed.bas > bB.PAL.s

Object/bB.SECAM.s: Source/Generated/$(GAME).SECAM.preprocessed.bas Object/2600basic_variable_redefs.h
	mkdir -p Object
	cd Object && timeout 60 ../bin/2600basic -i $(POSTINC) -r 2600basic_variable_redefs.h < ../Source/Generated/$(GAME).SECAM.preprocessed.bas > bB.SECAM.s

# Step 3: Postprocess bB.ARCH.s → ARCH.s (final assembly)
# postprocess requires includes.bB to be in the current working directory
# (it's created by 2600basic in Object/), so run postprocess from Object/
# postprocess also needs bB.asm to exist (listed in includes.bB), so create symlink
# Fix ## token pasting: cpp should expand ColGreen(6) → _COL_Green_L6, but if ##
# remains, replace it with _ (e.g., _COL_Green_L##6 → _COL_Green_L6)
Source/Generated/$(GAME).NTSC.s: Object/bB.NTSC.s
	mkdir -p Source/Generated
	cd Object && ln -sf bB.NTSC.s bB.asm && ../bin/postprocess -i ../Tools/batariBASIC < bB.NTSC.s | ../bin/optimize | sed -e 's/\.,-1/.-1/g' -e 's/##\([0-9]\+\)/_\1/g' > ../$@

Source/Generated/$(GAME).PAL.s: Object/bB.PAL.s
	mkdir -p Source/Generated
	cd Object && ln -sf bB.PAL.s bB.asm && ../bin/postprocess -i ../Tools/batariBASIC < bB.PAL.s | ../bin/optimize | sed -e 's/\.,-1/.-1/g' -e 's/##\([0-9]\+\)/_\1/g' > ../$@

Source/Generated/$(GAME).SECAM.s: Object/bB.SECAM.s
	mkdir -p Source/Generated
	cd Object && ln -sf bB.SECAM.s bB.asm && ../bin/postprocess -i ../Tools/batariBASIC < bB.SECAM.s | ../bin/optimize | sed -e 's/\.,-1/.-1/g' -e 's/##\([0-9]\+\)/_\1/g' > ../$@

# Step 4: Assemble ARCH.s → ARCH.a26 + ARCH.lst + ARCH.sym
# ROM build targets depend on generated .s file, which already depends on all generated assets via BUILD_DEPS
# The .s file is the final assembly output that includes all generated assets
Dist/$(GAME)$(GAMEYEAR).NTSC.a26 Dist/$(GAME)$(GAMEYEAR).NTSC.sym Dist/$(GAME)$(GAMEYEAR).NTSC.lst: Source/Generated/$(GAME).NTSC.s Object/2600basic_variable_redefs.h
	mkdir -p Dist Object
	cd Object && ../bin/dasm ../$< -I../Tools/batariBASIC/includes -I. -I../Source -I../Source/Common -f3 -l../Dist/$(GAME)$(GAMEYEAR).NTSC.lst -s../Dist/$(GAME)$(GAMEYEAR).NTSC.sym -o../Dist/$(GAME)$(GAMEYEAR).NTSC.a26

Dist/$(GAME)$(GAMEYEAR).PAL.a26 Dist/$(GAME)$(GAMEYEAR).PAL.sym Dist/$(GAME)$(GAMEYEAR).PAL.lst: Source/Generated/$(GAME).PAL.s Object/2600basic_variable_redefs.h
	mkdir -p Dist Object
	cd Object && ../bin/dasm ../$< -I../Tools/batariBASIC/includes -I. -I../Source -I../Source/Common -f3 -l../Dist/$(GAME)$(GAMEYEAR).PAL.lst -s../Dist/$(GAME)$(GAMEYEAR).PAL.sym -o../Dist/$(GAME)$(GAMEYEAR).PAL.a26

Dist/$(GAME)$(GAMEYEAR).SECAM.a26 Dist/$(GAME)$(GAMEYEAR).SECAM.sym Dist/$(GAME)$(GAMEYEAR).SECAM.lst: Source/Generated/$(GAME).SECAM.s Object/2600basic_variable_redefs.h
	mkdir -p Dist Object
	cd Object && ../bin/dasm ../$< -I../Tools/batariBASIC/includes -I. -I../Source -ISource/Common -f3 -l../Dist/$(GAME)$(GAMEYEAR).SECAM.lst -s../Dist/$(GAME)$(GAMEYEAR).SECAM.lst -o../Dist/$(GAME)$(GAMEYEAR).SECAM.a26

# Run emulator
emu: $(ROM)
	$(STELLA) $(ROM)

# Clean all generated files
clean:
	rm -rf Dist/*
	rm -rf Object/*
	rm -f Source/Generated/*
	rm -f Source/Art/*.png
	rm -f bB.*.s *.bin *.lst *.sym *.map *.pro
	rm -f Source/Generated/$(GAME).*.bas Source/Generated/$(GAME).*.s
	rm -f Source/Generated/$(GAME).*.preprocessed.bas
	rm -f Object/bB.*.s Object/includes.bB
	cd Tools/batariBASIC && git clean --force

# Install GIMP export script
gimp-export:
	@for d in ~/.config/GIMP/*/scripts/; do \
		if [ -d "$$d" ]; then \
			cp Tools/xcf-export.scm "$$d"; \
			echo "Installed xcf-export.scm to $$d"; \
		fi \
	done

# Help target
help:
	@echo "Available targets:"
	@echo "  all          - Build game and documentation (default)"
	@echo "  game         - Build game ROMs for all TV systems"
	@echo "  doc          - Build PDF and HTML manuals"
	@echo "  characters   - Generate character sprite data"
	@echo "  playfields   - Generate playfield/screen data"
	@echo "  fonts        - Generate font data"
	@echo "  clean        - Remove generated ROM files"
	@echo "  emu          - Build and run in Stella emulator"
	@echo "  gimp-export  - Install GIMP export script"
	@echo "  ready        - Setup development environment and dependencies"
	@echo "  nowready     - Check if development environment is ready"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Output files:"
	@echo "  Dist/ChaosFight25.pdf        - Game manual (PDF)"
	@echo "  Dist/ChaosFight25.html       - Game manual (HTML)"
	@echo "  Dist/ChaosFight25.NTSC.a26   - NTSC ROM"
	@echo "  Dist/ChaosFight25.PAL.a26    - PAL ROM"
	@echo "  Dist/ChaosFight25.SECAM.a26  - SECAM ROM"

# Generate Stella .pro files
Dist/$(GAME)$(GAMEYEAR).NTSC.pro: Source/$(GAME).pro Dist/$(GAME)$(GAMEYEAR).NTSC.a26
	sed $< -e s/@@TV@@/NTSC/g \
		-e s/@@MD5@@/$$(md5sum Dist/$(GAME)$(GAMEYEAR).NTSC.a26 | cut -d\  -f1)/g > $@

Dist/$(GAME)$(GAMEYEAR).PAL.pro: Source/$(GAME).pro Dist/$(GAME)$(GAMEYEAR).PAL.a26
	sed $< -e s/@@TV@@/PAL/g \
		-e s/@@MD5@@/$$(md5sum Dist/$(GAME)$(GAMEYEAR).PAL.a26 | cut -d\  -f1)/g > $@

Dist/$(GAME)$(GAMEYEAR).SECAM.pro: Source/$(GAME).pro Dist/$(GAME)$(GAMEYEAR).SECAM.a26
	sed $< -e s/@@TV@@/SECAM/g \
		-e s/@@MD5@@/$$(md5sum Dist/$(GAME)$(GAMEYEAR).SECAM.a26 | cut -d\  -f1)/g > $@

# Documentation generation
# Build PDF in Object/ to contain auxiliary files (.aux, .cp, .cps, .toc)
Dist/$(GAME)$(GAMEYEAR).pdf: Manual/ChaosFight.texi
	mkdir -p Object Dist
	makeinfo --pdf --output=Object/$(GAME)$(GAMEYEAR).pdf $<
	cp Object/$(GAME)$(GAMEYEAR).pdf $@

Dist/$(GAME)$(GAMEYEAR).html: Manual/ChaosFight.texi
	mkdir -p Dist
	makeinfo --html --output=$@ $<

nowready: $(READYFILE)

$(READYFILE):
	$(MAKE) ready

ready: gimp-export bin/skyline-tool
	# Mark ready
	@echo "Development environment ready for ChaosFight build"
	touch $(READYFILE)
