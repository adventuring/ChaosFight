# Default target
all: game doc

# Test target
test: SkylineTool/skyline-tool.asd
	@echo "Running SkylineTool fiveam tests..."
	cd SkylineTool && sbcl --script tests/run-tests.lisp || (echo "Tests failed!" && exit 1)

# Precious intermediate files
.PRECIOUS: %.s %.png %.midi %.bas

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
PATH := $(abspath bin):$(PATH)
export PATH
STELLA = stella
# -i taken out for now from gimp
GIMP = gimp --batch-interpreter plug-in-script-fu-eval -c --no-shm

# Ready system
READYDATE = 20251104
READYFILE = .#ready.$(READYDATE)

# SkylineTool build rules
SkylineTool/zx7mini/zx7mini.c:
	git submodule update --init --recursive

bin/zx7mini:	SkylineTool/zx7mini/zx7mini.c | bin/
	$(CC) SkylineTool/zx7mini/zx7mini.c -o bin/zx7mini
	chmod +x bin/zx7mini

# batariBASIC tool links
# Explicitly mark upstream tool binaries as fixed files so GNU make
# doesn’t try to regenerate them with the built-in “.sh →” implicit rule
Tools/batariBASIC/2600basic \
Tools/batariBASIC/preprocess \
Tools/batariBASIC/postprocess \
Tools/batariBASIC/optimize \
Tools/batariBASIC/bbfilter \
Tools/batariBASIC/dasm.Linux.x64:
	@:

bin/preprocess: Tools/batariBASIC/preprocess | bin/
	ln -sf "$(abspath $<)" "$@"

bin/postprocess: Tools/batariBASIC/postprocess | bin/
	ln -sf "$(abspath $<)" "$@"

bin/optimize: Tools/batariBASIC/optimize | bin/
	ln -sf "$(abspath $<)" "$@"

bin/2600basic: Tools/batariBASIC/2600basic | bin/
	ln -sf "$(abspath $<)" "$@"

bin/bbfilter: Tools/batariBASIC/bbfilter | bin/
	ln -sf "$(abspath $<)" "$@"

bin/dasm: Tools/batariBASIC/dasm.Linux.x64 | bin/
	ln -sf "$(abspath $<)" "$@"

skyline-tool:	bin/skyline-tool

SkylineTool/skyline-tool.asd:
	git submodule update --init --recursive

bin/skyline-tool:	bin/buildapp bin/zx7mini \
	SkylineTool/skyline-tool.asd \
	$(shell ls SkylineTool/*.lisp SkylineTool/src/*.lisp) | bin/
	@echo "Note: This may take a while if you don't have some common Quicklisp \
libraries already compiled. On subsequent runs, though, it'll be much quicker." >&2
	bin/buildapp --output bin/skyline-tool \
		--load SkylineTool/setup.lisp \
		--load-system skyline-tool \
		--entry skyline-tool::command

bin/buildapp: SkylineTool/prepare-system.lisp | bin/
	sbcl --load SkylineTool/prepare-system.lisp --eval '(cl-user::quit)'

# Output files
GAME = ChaosFight
GAMEYEAR = 25
ROM = Dist/$(GAME)$(GAMEYEAR).NTSC.a26
PROJECT_JSON = Project.json
PROJECT_VERSION := $(shell jq -r '.Version // empty' $(PROJECT_JSON))
ifeq ($(strip $(PROJECT_VERSION)),)
$(error Version field missing in $(PROJECT_JSON))
endif
RELEASE_TAG = v$(PROJECT_VERSION)

# Assembly files (exclude preprocessed, generated files, and reference files)
ALL_SOURCES = $(shell find Source -name \*.bas -not -path "Source/Generated/*" -not -path "Source/Reference/*")

.PHONY: all clean emu game help doc nowready ready web

# Directory targets for order-only prerequisites (prevents race conditions in parallel builds)
bin/:
	mkdir -p $@

Source/Generated/:
	mkdir -p $@

Source/Art/:
	mkdir -p $@

Object/:
	mkdir -p $@

Object/NTSC/:
	mkdir -p $@

Object/PAL/:
	mkdir -p $@

Object/SECAM/:
	mkdir -p $@

Dist/:
	mkdir -p $@

# Build game
game: \
	$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas) \
	Dist/$(GAME)$(GAMEYEAR).NTSC.a26 \
	Dist/$(GAME)$(GAMEYEAR).NTSC.sym \
	Dist/$(GAME)$(GAMEYEAR).NTSC.lst \
	Dist/$(GAME)$(GAMEYEAR).NTSC.pro

MANUAL_PDF = Dist/$(GAME)$(GAMEYEAR).pdf
MANUAL_HTML = Dist/$(GAME)$(GAMEYEAR).html

doc: $(MANUAL_PDF) $(MANUAL_HTML) | Object/

# Character sprite sheet names (32 characters: 16 main + 16 future)
CHARACTER_NAMES = \
	Bernie Curler DragonOfStorms ZoeRyen FatTony Megax Harpy KnightGuy \
	Frooty Nefertem NinjishGuy PorkChop RadishGoblin RoboTito Ursulo Shamone \
	Character16 Character17 Character18 Character19 Character20 Character21 Character22 Character23 \
	Character24 Character25 Character26 Character27 Character28 Character29 Character30 MethHound

# TV architectures
TV_ARCHS = NTSC PAL SECAM
ZIP_ARCHIVES = $(foreach arch,$(TV_ARCHS),Dist/$(GAME)$(GAMEYEAR).$(arch).$(RELEASE_TAG).zip)
WEB_REMOTE = interworldly.com:interworldly.com/games/ChaosFight
WEB_DOWNLOADS = $(WEB_REMOTE)/25/downloads/
WEB_MANUAL = $(WEB_REMOTE)/25/manual/

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
# Bank allocation: Bernie/OCascadia/Revontuli/EXO sit in Bank 15, the rest live in Bank 1
GAME_THEME_SONGS = Bernie OCascadia Revontuli EXO Grizzards MagicalFairyForce Bolero LowRes RoboTito SongOfTheBear DucksAway \
	Character16Theme Character17Theme Character18Theme Character19Theme Character20Theme Character21Theme Character22Theme Character23Theme \
	Character24Theme Character25Theme Character26Theme Character27Theme Character28Theme Character29Theme Character30Theme

# Sound effect names (MIDI files)
SOUND_NAMES = SoundAttackHit SoundGuardBlock SoundJump SoundPlayerEliminated \
	SoundMenuNavigate SoundMenuSelect SoundSpecialMove SoundPowerup \
	SoundLandingSafe SoundLandingDamage


# Convert MuseScore to MIDI
%.midi: %.mscz
	if [ -x ~/AppImages/MuseScore*.AppImage ]; then \
		~/AppImages/MuseScore*.AppImage --export-to $@ $<; \
	elif which mscore; then \
		mscore --export-to $@ $<; \
	else \
		flatpak run org.musescore.MuseScore --export-to $@ $<; \
	fi

%.flac: %.mscz
	if [ -x ~/AppImages/MuseScore*.AppImage ]; then \
		~/AppImages/MuseScore*.AppImage --export-to $@ $<; \
	elif which mscore; then \
		mscore --export-to $@ $<; \
	else \
		flatpak run org.musescore.MuseScore --export-to $@ $<; \
	fi

%.ogg: %.mscz
	if [ -x ~/AppImages/MuseScore*.AppImage ]; then \
		~/AppImages/MuseScore*.AppImage --export-to $@ $<; \
	elif which mscore; then \
		mscore --export-to $@ $<; \
	else \
		flatpak run org.musescore.MuseScore --export-to $@ $<; \
	fi

%.pdf: %.mscz
	if [ -x ~/AppImages/MuseScore*.AppImage ]; then \
		~/AppImages/MuseScore*.AppImage --export-to $@ $<; \
	elif which mscore; then \
		mscore --export-to $@ $<; \
	else \
		flatpak run org.musescore.MuseScore --export-to $@ $<; \
	fi

# Convert MIDI to batariBASIC music data for NTSC (60Hz)
# MIDI files are generated from MSCZ via %.midi: %.mscz pattern rule
# Explicitly depend on MSCZ to ensure proper build ordering in parallel builds
Source/Generated/Song.%.NTSC.bas: Source/Songs/%.midi Source/Songs/%.mscz bin/skyline-tool | Source/Generated/
	@echo "Converting music $< to $@ for NTSC..."
	bin/skyline-tool compile-midi "$<" "batariBASIC" "60" "$@"

# Special rule: Title song is generated from Chaotica source files
Source/Generated/Song.Title.NTSC.bas: Source/Songs/Chaotica.midi Source/Songs/Chaotica.mscz bin/skyline-tool | Source/Generated/
	@echo "Converting Chaotica music $< to Song.Title $@ for NTSC..."
	bin/skyline-tool compile-midi "$<" "batariBASIC" "60" "$@"

Source/Generated/Song.Title.PAL.bas: Source/Songs/Chaotica.midi Source/Songs/Chaotica.mscz bin/skyline-tool | Source/Generated/
	@echo "Converting Chaotica music $< to Song.Title $@ for PAL..."
	bin/skyline-tool compile-midi "$<" "batariBASIC" "50" "$@"

# SECAM music files are not generated - SECAM build uses PAL music files via conditional includes

# Convert MIDI to batariBASIC music data for PAL (50Hz)
# MIDI files are generated from MSCZ via %.midi: %.mscz pattern rule
# Explicitly depend on MSCZ to ensure proper build ordering in parallel builds
Source/Generated/Song.%.PAL.bas: Source/Songs/%.midi Source/Songs/%.mscz bin/skyline-tool | Source/Generated/
	@echo "Converting music $< to $@ for PAL..."
	bin/skyline-tool compile-midi "$<" "batariBASIC" "50" "$@"

# SECAM music files are not generated - SECAM build uses PAL music files via conditional includes

# Sound effect files use Sound. prefix instead of Song. prefix
# Convert MIDI to batariBASIC sound data for NTSC (60Hz)
# MIDI files are generated from MSCZ via %.midi: %.mscz pattern rule
# Explicitly depend on MSCZ to ensure proper build ordering in parallel builds
Source/Generated/Sound.%.NTSC.bas: Source/Songs/%.midi Source/Songs/%.mscz bin/skyline-tool | Source/Generated/
	@echo "Converting sound $< to $@ for NTSC..."
	bin/skyline-tool compile-midi "$<" "batariBASIC" "60" "$@"

# Convert MIDI to batariBASIC sound data for PAL (50Hz)
# MIDI files are generated from MSCZ via %.midi: %.mscz pattern rule
# Explicitly depend on MSCZ to ensure proper build ordering in parallel builds
Source/Generated/Sound.%.PAL.bas: Source/Songs/%.midi Source/Songs/%.mscz bin/skyline-tool | Source/Generated/
	@echo "Converting sound $< to $@ for PAL..."
	bin/skyline-tool compile-midi "$<" "batariBASIC" "50" "$@"

# SECAM sound files are not generated - SECAM build uses PAL sound files via conditional includes



# Generate list of character sprite files
CHARACTER_XCF = $(foreach char,$(CHARACTER_NAMES),Source/Art/$(char).xcf)
CHARACTER_PNG = $(foreach char,$(CHARACTER_NAMES),Source/Art/$(char).png)
CHARACTER_BAS = $(foreach char,$(CHARACTER_NAMES),Source/Generated/Art.$(char).bas)

# Convert XCF to PNG for sprites (characters and special sprites)
# Make will only regenerate if XCF is newer than PNG (based on file timestamps)
%.png: %.xcf | Source/Art/
	@echo "Converting $< to $@..."
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'
	@test -s "$@" || (rm -f "$@" && echo "Error: GIMP failed to create $@" && exit 1)

# Character sprites are compiled using compile-chaos-character
# Special sprites (QuestionMark, CPU, No) are hard-coded in individual files

# Explicit PNG dependencies for character sprites (ensures PNG generation from XCF)
# Use pattern rule to ensure PNG is generated from XCF before .bas compilation
$(foreach char,$(CHARACTER_NAMES),Source/Art/$(char).png): Source/Art/%.png: Source/Art/%.xcf | Source/Art/
	@echo "Converting $< to $@..."
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'
	@test -s "$@" || (rm -f "$@" && echo "Error: GIMP failed to create $@" && exit 1)

# Generate character sprite files from PNG using chaos character compiler
# PNG files are generated from XCF via %.png: %.xcf pattern rule or explicit rules above
# Explicitly depend on both PNG and XCF to ensure proper build ordering in parallel builds
$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas): Source/Generated/%.bas: Source/Art/%.png Source/Art/%.xcf bin/skyline-tool | Source/Generated/
	@echo "Generating character sprite data for $*..."
	bin/skyline-tool compile-chaos-character "$@" "$(filter %.png,$^)"

# Convert Numbers PNG to batariBASIC data using SkylineTool
# PNG files are generated from XCF via %.png: %.xcf pattern rule
# Explicitly depend on XCF to ensure proper build ordering in parallel builds
Source/Generated/Numbers.bas: Source/Art/Numbers.png Source/Art/Numbers.xcf bin/skyline-tool | Source/Generated/
	@echo "Converting Numbers font $< to $@..."
	bin/skyline-tool compile-2600-font-8x16 "$@" "$<"

# Fonts are universal (not TV-specific)
# Source/Generated/Numbers.bas is used directly by FontRendering.bas

# Convert 48×42 PNG to titlescreen kernel assembly format
# Uses compile-batari-48px with titlescreen-kernel-p flag for color-per-line + double-height
# These are bitmaps for the titlescreen kernel minikernels, not playfield data
# PNG files are built from XCF via the %.png: %.xcf pattern rule (line 180)
# Explicit PNG→XCF dependencies ensure XCF→PNG conversion happens first
# These use the pattern rule %.png: %.xcf (line 239) to generate PNGs from XCFs
Source/Art/AtariAge.png: Source/Art/AtariAge.xcf | Source/Art/
	@echo "Generating PNG from XCF: $@..."
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'
	@test -s "$@" || (rm -f "$@" && echo "Error: GIMP failed to create $@" && exit 1)

Source/Art/AtariAgeText.png: Source/Art/AtariAgeText.xcf | Source/Art/
	@echo "Generating PNG from XCF: $@..."
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'
	@test -s "$@" || (rm -f "$@" && echo "Error: GIMP failed to create $@" && exit 1)

Source/Art/BRP.png: Source/Art/BRP.xcf | Source/Art/
	@echo "Generating PNG from XCF: $@..."
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'
	@test -s "$@" || (rm -f "$@" && echo "Error: GIMP failed to create $@" && exit 1)

Source/Art/ChaosFight.png: Source/Art/ChaosFight.xcf | Source/Art/
	@echo "Generating PNG from XCF: $@..."
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'
	@test -s "$@" || (rm -f "$@" && echo "Error: GIMP failed to create $@" && exit 1)

Source/Art/Numbers.png: Source/Art/Numbers.xcf | Source/Art/
	@echo "Generating PNG from XCF: $@..."
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'
	@test -s "$@" || (rm -f "$@" && echo "Error: GIMP failed to create $@" && exit 1)

# Titlescreen kernel bitmap conversion: PNG → .s (assembly format)
# PNG files are generated from XCF via %.png: %.xcf pattern rule
# Explicitly depend on XCF to ensure proper build ordering in parallel builds
Source/Generated/Art.AtariAge.s: Source/Art/AtariAge.png Source/Art/AtariAge.xcf bin/skyline-tool | Source/Generated/
	@echo "Converting 48×42 bitmap $< to titlescreen kernel $@..."
	bin/skyline-tool compile-batari-48px "$<" "$@" "t" "NTSC"

Source/Generated/Art.AtariAgeText.s: Source/Art/AtariAgeText.png Source/Art/AtariAgeText.xcf bin/skyline-tool | Source/Generated/
	@echo "Converting 48×42 bitmap $< to titlescreen kernel $@..."
	bin/skyline-tool compile-batari-48px "$<" "$@" "t" "NTSC"

Source/Generated/Art.Author.s: Source/Art/BRP.png Source/Art/BRP.xcf bin/skyline-tool | Source/Generated/
	@echo "Converting 48×42 bitmap $< to titlescreen kernel $@..."
	bin/skyline-tool compile-batari-48px "$<" "$@" "t" "NTSC"

Source/Generated/Art.ChaosFight.s: Source/Art/ChaosFight.png Source/Art/ChaosFight.xcf bin/skyline-tool | Source/Generated/
	@echo "Converting 48×42 bitmap $< to titlescreen kernel $@..."
	bin/skyline-tool compile-batari-48px "$<" "$@" "t" "NTSC"

# Convert XCF to PNG for maps
Source/Art/Map-%.png: Source/Art/Map-%.xcf | Source/Art/
	$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'

# Convert PNG font to batariBASIC data
Source/Generated/Font.bas: Source/Art/Font.png | Source/Generated/
	@echo "Converting font $< to $@ for NTSC..."
	bin/skyline-tool compile-8x16-font "$<" > "$@" 

# Build game - accurate dependencies based on actual includes
# CRITICAL: cpp preprocessor processes includes immediately, so all generated files
# that are included via #include directives MUST exist before cpp runs.
# Character files are dependencies of Bank2/3/4/5.bas (defined above).
# Bitmap files are dependencies of Bank1.bas (defined above).
# Numbers font is needed by FontRendering.bas (in Bank14), must exist before cpp runs.
# Bank15.bas includes Sound.*.bas files, so they must be dependencies here.
# Bitmap .s files must exist before cpp runs, so they need PNG dependencies.
Source/Generated/$(GAME)$(GAMEYEAR).NTSC.bas: Source/Platform/NTSC.bas \
	$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas) \
	Source/Banks/Bank1.bas Source/Banks/Bank2.bas Source/Banks/Bank3.bas Source/Banks/Bank4.bas Source/Banks/Bank5.bas Source/Banks/Bank12.bas Source/Banks/Bank16.bas \
	Source/Generated/Numbers.bas \
	Source/Generated/Art.AtariAge.s Source/Generated/Art.AtariAgeText.s Source/Generated/Art.ChaosFight.s Source/Generated/Art.Author.s \
	$(foreach sound,$(SOUND_NAMES),Source/Generated/Sound.$(sound).NTSC.bas) \
	$(foreach song,$(MUSIC_NAMES),Source/Generated/Song.$(song).NTSC.bas) \
	$(foreach song,$(GAME_THEME_SONGS),Source/Generated/Song.$(song).NTSC.bas) \
	$(foreach bitmap,$(BITMAP_NAMES),Source/Art/$(bitmap).png) | Source/Generated/
	cpp -P -I. -ISource -DBUILD_YEAR=$(shell date +%Y) -DBUILD_DAY=$(shell date +%j) -DBUILD_DATE_STRING=\"$(shell date +%Y).$(shell date +%j)\" -Wno-trigraphs -Wno-format $< > $@

Source/Generated/$(GAME)$(GAMEYEAR).PAL.bas: Source/Platform/PAL.bas \
	$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas) \
	Source/Banks/Bank1.bas Source/Banks/Bank2.bas Source/Banks/Bank3.bas Source/Banks/Bank4.bas Source/Banks/Bank5.bas Source/Banks/Bank12.bas Source/Banks/Bank16.bas \
	Source/Generated/Numbers.bas \
	Source/Generated/Art.AtariAge.s Source/Generated/Art.AtariAgeText.s Source/Generated/Art.ChaosFight.s Source/Generated/Art.Author.s \
	$(foreach sound,$(SOUND_NAMES),Source/Generated/Sound.$(sound).PAL.bas) \
	$(foreach song,$(MUSIC_NAMES),Source/Generated/Song.$(song).PAL.bas) \
	$(foreach song,$(GAME_THEME_SONGS),Source/Generated/Song.$(song).PAL.bas) \
	$(foreach bitmap,$(BITMAP_NAMES),Source/Art/$(bitmap).png) | Source/Generated/
	cpp -P -I. -ISource -DBUILD_YEAR=$(shell date +%Y) -DBUILD_DAY=$(shell date +%j) -DBUILD_DATE_STRING=\"$(shell date +%Y).$(shell date +%j)\" -Wno-trigraphs -Wno-format $< > $@

# SECAM build uses PAL music/sound files via conditional includes in Bank15/16.bas
Source/Generated/$(GAME)$(GAMEYEAR).SECAM.bas: Source/Platform/SECAM.bas \
	$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas) \
	Source/Banks/Bank1.bas Source/Banks/Bank2.bas Source/Banks/Bank3.bas Source/Banks/Bank4.bas Source/Banks/Bank5.bas Source/Banks/Bank12.bas Source/Banks/Bank16.bas \
	Source/Generated/Numbers.bas \
	Source/Generated/Art.AtariAge.s Source/Generated/Art.AtariAgeText.s Source/Generated/Art.ChaosFight.s Source/Generated/Art.Author.s \
	$(foreach sound,$(SOUND_NAMES),Source/Generated/Sound.$(sound).PAL.bas) \
	$(foreach song,$(MUSIC_NAMES),Source/Generated/Song.$(song).PAL.bas) \
	$(foreach song,$(GAME_THEME_SONGS),Source/Generated/Song.$(song).PAL.bas) \
	$(foreach bitmap,$(BITMAP_NAMES),Source/Art/$(bitmap).png) | Source/Generated/
	cpp -P -I. -ISource -DBUILD_YEAR=$(shell date +%Y) -DBUILD_DAY=$(shell date +%j) -DBUILD_DATE_STRING=\"$(shell date +%Y).$(shell date +%j)\" -Wno-trigraphs -Wno-format $< > $@

# Bank file dependencies - each bank explicitly depends on the files it includes
Source/Banks/Bank1.bas:

Source/Banks/Bank2.bas: Source/Generated/Bernie.bas Source/Generated/Curler.bas Source/Generated/DragonOfStorms.bas Source/Generated/ZoeRyen.bas Source/Generated/FatTony.bas Source/Generated/Megax.bas Source/Generated/Harpy.bas Source/Generated/KnightGuy.bas

Source/Banks/Bank3.bas: Source/Generated/Frooty.bas Source/Generated/Nefertem.bas Source/Generated/NinjishGuy.bas Source/Generated/PorkChop.bas Source/Generated/RadishGoblin.bas Source/Generated/RoboTito.bas Source/Generated/Ursulo.bas Source/Generated/Shamone.bas

Source/Banks/Bank4.bas: Source/Generated/Character16.bas Source/Generated/Character17.bas Source/Generated/Character18.bas Source/Generated/Character19.bas Source/Generated/Character20.bas Source/Generated/Character21.bas Source/Generated/Character22.bas Source/Generated/Character23.bas

Source/Banks/Bank5.bas: Source/Generated/Character24.bas Source/Generated/Character25.bas Source/Generated/Character26.bas Source/Generated/Character27.bas Source/Generated/Character28.bas Source/Generated/Character29.bas Source/Generated/Character30.bas Source/Generated/MethHound.bas

Source/Banks/Bank16.bas: Source/Generated/Numbers.bas

# Shared dependencies for all TV standards
BUILD_DEPS = $(ALL_SOURCES)  \
	Source/Banks/Bank1.bas \
	Source/Banks/Bank2.bas \
	Source/Banks/Bank3.bas \
	Source/Banks/Bank4.bas \
	Source/Banks/Bank5.bas \
	Source/Banks/Bank6.bas \
	Source/Banks/Bank7.bas \
	Source/Banks/Bank8.bas \
	Source/Banks/Bank9.bas \
	Source/Banks/Bank10.bas \
	Source/Banks/Bank11.bas \
	Source/Banks/Bank12.bas \
	Source/Banks/Bank13.bas \
	Source/Banks/Bank14.bas \
	Source/Banks/Bank15.bas \
	Source/Banks/Bank16.bas \
	Source/Banks/Banks.bas \
	Source/Common/AssemblyConfig.bas \
	Source/Common/CharacterDefinitions.bas \
	Source/Common/Colors.h \
	Source/Common/Constants.bas \
	Source/Common/Enums.bas \
	Source/Common/Macros.bas \
	Source/Common/Preamble.bas \
	Source/Common/Variables.bas \
	Source/Data/Arenas.bas \
	Source/Data/CharacterDataTables.bas \
	Source/Data/CharacterMissileTables.bas \
	Source/Data/CharacterPhysicsTables.bas \
	Source/Data/CPUSprite.bas \
	Source/Data/HealthBarPatterns.bas \
	Source/Data/NoSprite.bas \
	Source/Data/PlayerColors.bas \
	Source/Data/PlayerColorTables.bas \
	Source/Data/QuestionMarkSprite.bas \
	Source/Data/SongPointers1.bas \
	Source/Data/SongPointers2.bas \
	Source/Data/SoundPointers.bas \
	Source/Data/WinnerScreen.bas \
	Source/Platform/NTSC.bas \
	Source/Platform/PAL.bas \
	Source/Platform/SECAM.bas \
	Source/Routines/AnimationSystem.bas \
	Source/Routines/ArenaLoader.bas \
	Source/Routines/ArenaReloadUtils.bas \
	Source/Routines/ArenaSelect.bas \
	Source/Routines/AttractMode.bas \
	Source/Routines/AuthorPrelude.bas \
	Source/Routines/BeginArenaSelect.bas \
	Source/Routines/BeginAttractMode.bas \
	Source/Routines/BeginAuthorPrelude.bas \
	Source/Routines/BeginFallingAnimation.bas \
	Source/Routines/BeginPublisherPrelude.bas \
	Source/Routines/BeginTitleScreen.bas \
	Source/Routines/BeginWinnerAnnouncement.bas \
	Source/Routines/ChangeGameMode.bas \
	Source/Routines/CharacterAttacks.bas \
	Source/Routines/CharacterAttacksDispatch.bas \
	Source/Routines/CharacterControlsDown.bas \
	Source/Routines/CharacterControlsJump.bas \
	Source/Routines/CharacterCycleUtils.bas \
	Source/Routines/CharacterData.bas \
	Source/Routines/CharacterSelectMain.bas \
	Source/Routines/CharacterSelectRender.bas \
	Source/Routines/CheckRoboTitoStretchMissileCollisions.bas \
	Source/Routines/ColdStart.bas \
	Source/Routines/Combat.bas \
	Source/Routines/ConsoleDetection.bas \
	Source/Routines/ConsoleHandling.bas \
	Source/Routines/ControllerDetection.bas \
	Source/Routines/CopyGlyphToPlayer.bas \
	Source/Routines/DisplayWinScreen.bas \
	Source/Routines/FallDamage.bas \
	Source/Routines/FallingAnimation.bas \
	Source/Routines/FontRendering.bas \
	Source/Routines/GameLoopInit.bas \
	Source/Routines/GameLoopMain.bas \
	Source/Routines/GuardEffects.bas \
	Source/Routines/HealthBarSystem.bas \
	Source/Routines/MainLoop.bas \
	Source/Routines/MissileCollision.bas \
	Source/Routines/MissileSystem.bas \
	Source/Routines/MovementSystem.bas \
	Source/Routines/MusicBankHelpers15.bas \
	Source/Routines/MusicBankHelpers.bas \
	Source/Routines/MusicSystem.bas \
	Source/Routines/PerformMeleeAttack.bas \
	Source/Routines/PerformRangedAttack.bas \
	Source/Routines/PlayerCollisionResolution.bas \
	Source/Routines/PlayerElimination.bas \
	Source/Routines/PlayerInput.bas \
	Source/Routines/PlayerLockedHelpers.bas \
	Source/Routines/PlayerPhysics.bas \
	Source/Routines/PlayerPhysicsGravity.bas \
	Source/Routines/PlayerRendering.bas \
	Source/Routines/PublisherPrelude.bas \
	Source/Routines/ScreenLayout.bas \
	Source/Routines/SetPlayerGlyphFromFont.bas \
	Source/Routines/SoundBankHelpers.bas \
	Source/Routines/SoundSystem.bas \
	Source/Routines/SpecialMovement.bas \
	Source/Routines/SpriteLoader.bas \
	Source/Routines/SpriteLoaderCharacterArt.bas \
	Source/Routines/SpritePointerInit.bas \
	Source/Routines/TitleCharacterParade.bas \
	Source/Routines/TitleScreenMain.bas \
	Source/Routines/TitleScreenRender.bas \
	Source/Routines/TitlescreenWindowControl.bas \
	Source/Routines/Unused/CharacterSelect.bas \
	Source/Routines/Unused/CharacterSelectFire.bas \
	Source/Routines/Unused/FrameBudgeting.bas \
	Source/Routines/Unused/Physics.bas \
	Source/Routines/Unused/PlayerPhysicsCollisions.bas \
	Source/Routines/WinnerAnnouncement.bas \
	$(foreach sound,$(SOUND_NAMES),Source/Generated/Sound.$(sound).NTSC.bas) \
	$(foreach sound,$(SOUND_NAMES),Source/Generated/Sound.$(sound).PAL.bas) \
	$(foreach song,$(MUSIC_NAMES),Source/Generated/Song.$(song).NTSC.bas) \
	$(foreach song,$(MUSIC_NAMES),Source/Generated/Song.$(song).PAL.bas) \
	$(foreach song,$(GAME_THEME_SONGS),Source/Generated/Song.$(song).NTSC.bas) \
	$(foreach song,$(GAME_THEME_SONGS),Source/Generated/Song.$(song).PAL.bas)\
# Explicitly depend on character and bitmap PNG files to ensure they are generated
Source/Generated/$(GAME)$(GAMEYEAR).NTSC.preprocessed.bas: Source/Generated/$(GAME)$(GAMEYEAR).NTSC.bas $(BUILD_DEPS) \
	$(CHARACTER_PNG) $(foreach bitmap,$(BITMAP_NAMES),Source/Art/$(bitmap).png) \
	Source/Generated/Numbers.bas bin/preprocess | Source/Generated/
	bin/preprocess < $< > $@

Source/Generated/$(GAME)$(GAMEYEAR).PAL.preprocessed.bas: Source/Generated/$(GAME)$(GAMEYEAR).PAL.bas $(BUILD_DEPS) \
	$(CHARACTER_PNG) $(foreach bitmap,$(BITMAP_NAMES),Source/Art/$(bitmap).png) \
	Source/Generated/Numbers.bas bin/preprocess | Source/Generated/
	bin/preprocess < $< > $@

Source/Generated/$(GAME)$(GAMEYEAR).SECAM.preprocessed.bas: Source/Generated/$(GAME)$(GAMEYEAR).SECAM.bas $(BUILD_DEPS) \
	$(CHARACTER_PNG) $(foreach bitmap,$(BITMAP_NAMES),Source/Art/$(bitmap).png) \
	Source/Generated/Numbers.bas bin/preprocess | Source/Generated/
	bin/preprocess < $< > $@

# Create empty variable redefs file if it doesn't exist (will be populated by batariBASIC)
# batariBASIC expects this file to be named 2600basic_variable_redefs.h
Object/2600basic_variable_redefs.h: | Object/
	@touch $@

# Step 2: Compile .preprocessed.bas → $(GAME)$(GAMEYEAR).bB.ARCH.s
Object/$(GAME)$(GAMEYEAR).bB.NTSC.s: Source/Generated/$(GAME)$(GAMEYEAR).NTSC.preprocessed.bas Object/2600basic_variable_redefs.h bin/skyline-tool bin/2600basic | Object/
	cd Object && > 2600basic_variable_redefs.h && bB=$(POSTINC) timeout 300 ../bin/2600basic -i $(POSTINC) -r 2600basic_variable_redefs.h < ../Source/Generated/$(GAME)$(GAMEYEAR).NTSC.preprocessed.bas > $(GAME)$(GAMEYEAR).bB.NTSC.s

Object/$(GAME)$(GAMEYEAR).bB.PAL.s: Source/Generated/$(GAME)$(GAMEYEAR).PAL.preprocessed.bas Object/2600basic_variable_redefs.h bin/skyline-tool bin/2600basic | Object/
	cd Object && > 2600basic_variable_redefs.h && bB=$(POSTINC) timeout 300 ../bin/2600basic -i $(POSTINC) -r 2600basic_variable_redefs.h < ../Source/Generated/$(GAME)$(GAMEYEAR).PAL.preprocessed.bas > $(GAME)$(GAMEYEAR).bB.PAL.s 2>/dev/null

Object/$(GAME)$(GAMEYEAR).bB.SECAM.s: Source/Generated/$(GAME)$(GAMEYEAR).SECAM.preprocessed.bas Object/2600basic_variable_redefs.h bin/skyline-tool bin/2600basic | Object/
	cd Object && > 2600basic_variable_redefs.h && bB=$(POSTINC) timeout 300 ../bin/2600basic -i $(POSTINC) -r 2600basic_variable_redefs.h < ../Source/Generated/$(GAME)$(GAMEYEAR).SECAM.preprocessed.bas > $(GAME)$(GAMEYEAR).bB.SECAM.s 2>/dev/null

# Step 3: Postprocess $(GAME)$(GAMEYEAR).bB.ARCH.s → ARCH.s (final assembly)
# postprocess requires includes.bB to be in the current working directory
# (it's created by 2600basic in Object/), so run postprocess from Object/
# postprocess also needs $(GAME)$(GAMEYEAR).bB.asm to exist (listed in includes.bB), so create symlink
# Fix ## token pasting: cpp should expand ColGreen(6) → _COL_Green_L6, but if ##
# remains, replace it with _ (e.g., _COL_Green_L##6 → _COL_Green_L6)
Source/Generated/$(GAME)$(GAMEYEAR).NTSC.s: Object/$(GAME)$(GAMEYEAR).bB.NTSC.s bin/postprocess bin/optimize | Source/Generated/ Object/NTSC/
	cd Object/NTSC && ln -sf ../$(GAME)$(GAMEYEAR).bB.NTSC.s bB.asm && ln -sf ../includes.bB includes.bB && ../../bin/postprocess -i ../../Tools/batariBASIC | ../../bin/optimize > ../../$@ && sed -i 's/RORG $$11000/RORG $$1000/g' ../../$@

Source/Generated/$(GAME)$(GAMEYEAR).PAL.s: Object/$(GAME)$(GAMEYEAR).bB.PAL.s bin/postprocess bin/optimize | Source/Generated/ Object/PAL/
	cd Object/PAL && ln -sf ../$(GAME)$(GAMEYEAR).bB.PAL.s bB.asm && ln -sf ../includes.bB includes.bB && ../../bin/postprocess -i ../../Tools/batariBASIC | ../../bin/optimize > ../../$@ 

Source/Generated/$(GAME)$(GAMEYEAR).SECAM.s: Object/$(GAME)$(GAMEYEAR).bB.SECAM.s bin/postprocess bin/optimize | Source/Generated/ Object/SECAM/
	cd Object/SECAM && ln -sf ../$(GAME)$(GAMEYEAR).bB.SECAM.s bB.asm && ln -sf ../includes.bB includes.bB && ../../bin/postprocess -i ../../Tools/batariBASIC | ../../bin/optimize > ../../$@ 

# Step 4: Assemble ARCH.s → ARCH.a26 + ARCH.lst + ARCH.sym
# ROM build targets depend on generated .s file, which already depends on all generated assets via BUILD_DEPS
# The .s file is the final assembly output that includes all generated assets
Dist/$(GAME)$(GAMEYEAR).NTSC.a26 Dist/$(GAME)$(GAMEYEAR).NTSC.sym Dist/$(GAME)$(GAMEYEAR).NTSC.lst: Source/Generated/$(GAME)$(GAMEYEAR).NTSC.s Object/2600basic_variable_redefs.h bin/dasm | Dist/ Object/
	@echo "Fixing include paths in generated assembly for DASM..."
	@sed -i 's|include "Source/Routines/CharacterArtBank|include "CharacterArtBank|g' $<
	cd Object && ../bin/dasm ../$< -I../Tools/batariBASIC/includes -I. -I../Source -I../Source/Common -I../Source/Routines -f3 -l../Dist/$(GAME)$(GAMEYEAR).NTSC.lst -s../Dist/$(GAME)$(GAMEYEAR).NTSC.sym -o../Dist/$(GAME)$(GAMEYEAR).NTSC.a26

Dist/$(GAME)$(GAMEYEAR).PAL.a26 Dist/$(GAME)$(GAMEYEAR).PAL.sym Dist/$(GAME)$(GAMEYEAR).PAL.lst: Source/Generated/$(GAME)$(GAMEYEAR).PAL.s Object/2600basic_variable_redefs.h bin/dasm | Dist/ Object/
	@echo "Fixing include paths in generated assembly for DASM..."
	@sed -i 's|include "Source/Routines/CharacterArtBank|include "CharacterArtBank|g' $<
	cd Object && ../bin/dasm ../$< -I../Tools/batariBASIC/includes -I. -I../Source -I../Source/Common -I../Source/Routines -f3 -l../Dist/$(GAME)$(GAMEYEAR).PAL.lst -s../Dist/$(GAME)$(GAMEYEAR).PAL.sym -o../Dist/$(GAME)$(GAMEYEAR).PAL.a26

Dist/$(GAME)$(GAMEYEAR).SECAM.a26 Dist/$(GAME)$(GAMEYEAR).SECAM.sym Dist/$(GAME)$(GAMEYEAR).SECAM.lst: Source/Generated/$(GAME)$(GAMEYEAR).SECAM.s Object/2600basic_variable_redefs.h bin/dasm | Dist/ Object/
	@echo "Fixing include paths in generated assembly for DASM..."
	@sed -i 's|include "Source/Routines/CharacterArtBank|include "CharacterArtBank|g' $<
	cd Object && ../bin/dasm ../$< -I../Tools/batariBASIC/includes -I. -I../Source -I../Source/Common -I../Source/Routines -f3 -l../Dist/$(GAME)$(GAMEYEAR).SECAM.lst -s../Dist/$(GAME)$(GAMEYEAR).SECAM.lst -o../Dist/$(GAME)$(GAMEYEAR).SECAM.a26

# Run emulator
emu: $(ROM) Dist/$(GAME)$(GAMEYEAR).NTSC.pro
	$(STELLA) $(ROM)

# Clean all generated files
clean:
	rm -rf Dist Object Source/Generated
	rm -f Source/Art/*.png
	rm -f Source/Songs/*.pdf
	rm -f Source/Songs/*.midi
	rm -f $(GAME)*.aux $(GAME)*.cp $(GAME)*.cps $(GAME)*.toc $(GAME)*.log
	git submodule foreach git clean --force
	rm -f bin/2600basic bin/preprocess bin/postprocess bin/optimize \
		bin/bbfilter bin/dasm bin/buildapp bin/skyline-tool bin/zx7mini

quickclean:
	rm -rf Dist Object
	rm -f Source/Generated/$(GAME)$(GAMEYEAR).*.bas
	rm -f Source/Generated/$(GAME)$(GAMEYEAR).*.preprocessed.bas
	rm -f Source/Generated/$(GAME)$(GAMEYEAR).*.s
	rm -f $(GAME)*.aux $(GAME)*.cp $(GAME)*.cps $(GAME)*.toc $(GAME)*.log

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
	@echo "  web          - Build release archives and deploy website assets"
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
Dist/$(GAME)$(GAMEYEAR).NTSC.pro: Source/$(GAME)$(GAMEYEAR).pro Dist/$(GAME)$(GAMEYEAR).NTSC.a26
	sed $< -e s/@@TV@@/NTSC/g \
		-e s/@@MD5@@/$$(md5sum Dist/$(GAME)$(GAMEYEAR).NTSC.a26 | cut -d\  -f1)/g > $@

Dist/$(GAME)$(GAMEYEAR).PAL.pro: Source/$(GAME)$(GAMEYEAR).pro Dist/$(GAME)$(GAMEYEAR).PAL.a26
	sed $< -e s/@@TV@@/PAL/g \
		-e s/@@MD5@@/$$(md5sum Dist/$(GAME)$(GAMEYEAR).PAL.a26 | cut -d\  -f1)/g > $@

Dist/$(GAME)$(GAMEYEAR).SECAM.pro: Source/$(GAME)$(GAMEYEAR).pro Dist/$(GAME)$(GAMEYEAR).SECAM.a26
	sed $< -e s/@@TV@@/SECAM/g \
		-e s/@@MD5@@/$$(md5sum Dist/$(GAME)$(GAMEYEAR).SECAM.a26 | cut -d\  -f1)/g > $@

Dist/$(GAME)$(GAMEYEAR).%.$(RELEASE_TAG).zip: Dist/$(GAME)$(GAMEYEAR).%.a26 Dist/$(GAME)$(GAMEYEAR).%.pro $(MANUAL_PDF) | Dist/
	@echo "Packaging $* release $(RELEASE_TAG)..."
	rm -f $@
	zip -j $@ $^

web: $(ZIP_ARCHIVES) $(MANUAL_HTML) $(MANUAL_PDF)
	@echo "Deploying website to $(WEB_REMOTE)..."
	ssh interworldly.com 'mkdir -p interworldly.com/games/ChaosFight/25/downloads interworldly.com/games/ChaosFight/25/manual'
	rsync -av WWW/ $(WEB_REMOTE)/
	rsync -av $(MANUAL_HTML) $(WEB_MANUAL)
	rsync -av $(MANUAL_PDF) $(WEB_DOWNLOADS)
	rsync -av $(ZIP_ARCHIVES) $(WEB_DOWNLOADS)

# Documentation generation
# Build PDF in Object/ to contain auxiliary files (.aux, .cp, .cps, .toc)
Dist/$(GAME)$(GAMEYEAR).pdf: Manual/ChaosFight.texi | Object/ Dist/
	cd Object && makeinfo --pdf --output=$(GAME)$(GAMEYEAR).pdf ../$<
	cp Object/$(GAME)$(GAMEYEAR).pdf $@

Dist/$(GAME)$(GAMEYEAR).html: Manual/ChaosFight.texi | Dist/
	makeinfo --html --output=$@ $<

nowready: $(READYFILE)

$(READYFILE):
	$(MAKE) ready

ready: gimp-export bin/skyline-tool
	# Mark ready
	@echo "Development environment ready for ChaosFight build"
	touch $(READYFILE)
