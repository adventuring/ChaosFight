# Default target
all: game doc

# Test target
test: SkylineTool/skyline-tool.asd
	@echo "Running SkylineTool fiveam tests..."
	cd SkylineTool && sbcl --script tests/run-tests.lisp || (echo "Tests failed!" && exit 1)

# Verify calling conventions (stack usage audit)
verify-calls:
	@echo "Auditing calling conventions..."
	@./Tools/audit-calling-conventions

# Precious intermediate files
.PRECIOUS: %.s %.png %.midi

# Don't delete PNG files automatically - they are intermediate but should be preserved
# between builds if XCF hasn't changed
.SECONDARY: $(CHARACTER_PNG) $(foreach bitmap,$(BITMAP_NAMES),Source/Art/$(bitmap).png)

# Tools and directories
64TASS = 64tass
PATH := $(abspath bin):$(PATH)
export PATH
STELLA = stella
# -i taken out for now from gimp
GIMP = gimp --batch-interpreter plug-in-script-fu-eval -c --no-shm

# Common 64tass assembly flags
ASFLAGS = -Wall -Wno-branch-page -C -a --m6502 \
	-I.. -I. -I../Source -I../Source/Common -I../Source/Routines \
	-DBUILD_YEAR=$(shell date +%Y) -DBUILD_DAY=$(shell date +%j) \
	-DBUILD_DATE_STRING=\"$(shell date +%Y).$(shell date +%j)\"

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
# doesn't try to regenerate them with the built-in ".sh →" implicit rule
Tools/batariBASIC/dasm.Linux.x64:
	@:

Tools/batariBASIC/preprocess: Tools/batariBASIC/preprocess.lex
	$(MAKE) -C Tools/batariBASIC preprocess

Tools/batariBASIC/postprocess: Tools/batariBASIC/postprocess.c
	$(MAKE) -C Tools/batariBASIC postprocess

Tools/batariBASIC/optimize: Tools/batariBASIC/optimize.lex
	$(MAKE) -C Tools/batariBASIC optimize

Tools/batariBASIC/bbfilter: Tools/batariBASIC/bbfilter.c
	$(MAKE) -C Tools/batariBASIC bbfilter

bin/preprocess: Tools/batariBASIC/preprocess | bin/
	cp "$<" "$@"
	chmod +x "$@"

bin/postprocess: Tools/batariBASIC/postprocess | bin/
	cp "$<" "$@"
	chmod +x "$@"

bin/optimize: Tools/batariBASIC/optimize | bin/
	cp "$<" "$@"
	chmod +x "$@"

Tools/batariBASIC/2600basic: Tools/batariBASIC/2600bas.c Tools/batariBASIC/statements.c Tools/batariBASIC/keywords.c Tools/batariBASIC/statements.h Tools/batariBASIC/keywords.h
	$(MAKE) -C Tools/batariBASIC 2600basic

bin/2600basic: Tools/batariBASIC/2600basic | bin/
	cp "$<" "$@"
	chmod +x "$@"

bin/bbfilter: Tools/batariBASIC/bbfilter | bin/
	cp "$<" "$@"
	chmod +x "$@"

# DASM: build from the local Tools/dasm sources so we get our patched diagnostics
Tools/dasm/bin/dasm: $(wildcard Tools/dasm/src/*.c) $(wildcard Tools/dasm/src/*.h)
	$(MAKE) -C Tools/dasm

bin/dasm: Tools/dasm/bin/dasm | bin/
	cp "$<" "$@"
	chmod +x "$@"

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
GAMEYEAR = 26
ROM = Dist/$(GAME)$(GAMEYEAR).NTSC.a26
PROJECT_JSON = Project.json
PROJECT_VERSION := $(shell jq '.Version' $(PROJECT_JSON))
ifeq ($(strip $(PROJECT_VERSION)),)
$(error Version field missing in $(PROJECT_JSON))
endif
RELEASE_TAG = v$(PROJECT_VERSION)

# Assembly files (exclude preprocessed, generated files, and reference files)
ALL_SOURCES = $(shell find Source -name \*.s -not -path "Source/Generated/*" -not -path "Source/Reference/*")

.PHONY: all clean emu game help doc nowready ready web

# Directory targets for order-only prerequisites (prevents race conditions in parallel builds)
bin/:
	mkdir -p $@

Source/Generated/:
	mkdir -p $@

Source/TitleScreen/:
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
	$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).s) \
	Dist/$(GAME)$(GAMEYEAR).NTSC.a26 \
	Dist/$(GAME)$(GAMEYEAR).NTSC.sym \
	Dist/$(GAME)$(GAMEYEAR).NTSC.lst \
	Dist/$(GAME)$(GAMEYEAR).NTSC.pro

MANUAL_PDF = Dist/$(GAME)$(GAMEYEAR).pdf
MANUAL_HTML = Dist/$(GAME)$(GAMEYEAR).html

doc: $(MANUAL_PDF) $(MANUAL_HTML) WWW/26/manual/index.html | Object/

# Copy manual HTML to WWW directory for local viewing
WWW/26/manual/index.html: $(MANUAL_HTML) | WWW/26/manual/
	@echo "Copying manual HTML to WWW directory..."
	@rm -rf WWW/26/manual/*
	@cp -r $(MANUAL_HTML)/* WWW/26/manual/
	@echo "Manual HTML copied to WWW/26/manual/"

# Create WWW/26/manual/ directory if it doesn't exist
WWW/26/manual/:
	@mkdir -p WWW/26/manual

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
WEB_DOWNLOADS = $(WEB_REMOTE)/26/downloads/
WEB_MANUAL = $(WEB_REMOTE)/26/manual/

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
# Bank allocation: Bernie/OCascadia/Revontuli/EXO sit in Bank 14, the rest live in Bank 0
GAME_THEME_SONGS = Bernie OCascadia Revontuli EXO Grizzards MagicalFairyForce Bolero LowRes RoboTito SongOfTheBear DucksAway \
	Character16Theme Character17Theme Character18Theme Character19Theme Character20Theme Character21Theme Character22Theme Character23Theme \
	Character24Theme Character25Theme Character26Theme Character27Theme Character28Theme Character29Theme Character30Theme

# Sound effect names (MIDI files)
SOUND_NAMES = SoundAttackHit SoundGuardBlock SoundJump SoundPlayerEliminated \
	SoundMenuNavigate SoundMenuSelect SoundSpecialMove SoundPowerup \
	SoundLandingSafe SoundLandingDamage


# Convert MuseScore to MIDI
%.midi: %.mscz
		mscore --export-to $@ $<; \

%.flac: %.mscz
		mscore --export-to $@ $<; \

%.ogg: %.mscz
		mscore --export-to $@ $<; \

%.pdf: %.mscz
		mscore --export-to $@ $<; \

# Convert MIDI to 64tass assembly music data for NTSC (60Hz)
# MIDI files are generated from MSCZ via %.midi: %.mscz pattern rule
# Explicitly depend on MSCZ to ensure proper build ordering in parallel builds
# Note: SkylineTool now generates 64tass assembly directly (.s files)
Source/Generated/Song.%.NTSC.s: Source/Songs/%.midi Source/Songs/%.mscz bin/skyline-tool | Source/Generated/
	@echo "Converting music $< to $@ for NTSC..."
	bin/skyline-tool compile-midi "$<" "64tass" "60" "$@"

# Special rule: Title song is generated from Chaotica source files
Source/Generated/Song.Title.NTSC.s: Source/Songs/Chaotica.midi Source/Songs/Chaotica.mscz bin/skyline-tool | Source/Generated/
	@echo "Converting Chaotica music $< to Song.Title $@ for NTSC..."
	bin/skyline-tool compile-midi "$<" "64tass" "60" "$@"

Source/Generated/Song.Title.PAL.s: Source/Songs/Chaotica.midi Source/Songs/Chaotica.mscz bin/skyline-tool | Source/Generated/
	@echo "Converting Chaotica music $< to Song.Title $@ for PAL..."
	bin/skyline-tool compile-midi "$<" "64tass" "50" "$@"

# SECAM music files are not generated - SECAM build uses PAL music files via conditional includes

# Convert MIDI to 64tass assembly music data for PAL (50Hz)
# MIDI files are generated from MSCZ via %.midi: %.mscz pattern rule
# Explicitly depend on MSCZ to ensure proper build ordering in parallel builds
Source/Generated/Song.%.PAL.s: Source/Songs/%.midi Source/Songs/%.mscz bin/skyline-tool | Source/Generated/
	@echo "Converting music $< to $@ for PAL..."
	bin/skyline-tool compile-midi "$<" "64tass" "50" "$@"

# SECAM music files are not generated - SECAM build uses PAL music files via conditional includes

# Sound effect files use Sound. prefix instead of Song. prefix
# Convert MIDI to 64tass assembly sound data for NTSC (60Hz)
# MIDI files are generated from MSCZ via %.midi: %.mscz pattern rule
# Explicitly depend on MSCZ to ensure proper build ordering in parallel builds
Source/Generated/Sound.%.NTSC.s: Source/Songs/%.midi Source/Songs/%.mscz bin/skyline-tool | Source/Generated/
	@echo "Converting sound $< to $@ for NTSC..."
	bin/skyline-tool compile-midi "$<" "64tass" "60" "$@"

# Convert MIDI to 64tass assembly sound data for PAL (50Hz)
# MIDI files are generated from MSCZ via %.midi: %.mscz pattern rule
# Explicitly depend on MSCZ to ensure proper build ordering in parallel builds
Source/Generated/Sound.%.PAL.s: Source/Songs/%.midi Source/Songs/%.mscz bin/skyline-tool | Source/Generated/
	@echo "Converting sound $< to $@ for PAL..."
	bin/skyline-tool compile-midi "$<" "64tass" "50" "$@"

# SECAM sound files are not generated - SECAM build uses PAL sound files via conditional includes



# Generate list of character sprite files
CHARACTER_XCF = $(foreach char,$(CHARACTER_NAMES),Source/Art/$(char).xcf)
CHARACTER_PNG = $(foreach char,$(CHARACTER_NAMES),Source/Art/$(char).png)

# Convert XCF to PNG for sprites (characters and special sprites)
# Make will only regenerate if XCF is newer than PNG (based on file timestamps)
%.png: %.xcf | Source/Art/
	@echo "Converting $< to $@..."
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'

# Character sprites are compiled using compile-chaos-character
# Special sprites (QuestionMark, CPU, No) are hard-coded in individual files

# Explicit PNG dependencies for character sprites (ensures PNG generation from XCF)
# Use pattern rule to ensure PNG is generated from XCF before .s compilation
$(foreach char,$(CHARACTER_NAMES),Source/Art/$(char).png): Source/Art/%.png: Source/Art/%.xcf | Source/Art/
	@echo "Converting $< to $@..."
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'

# Generate character sprite files from PNG using chaos character compiler
# PNG files are generated from XCF via %.png: %.xcf pattern rule or explicit rules above
# Explicitly depend on both PNG and XCF to ensure proper build ordering in parallel builds
# Note: SkylineTool now generates 64tass assembly directly (.s files)
$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).s): Source/Generated/%.s: Source/Art/%.png Source/Art/%.xcf bin/skyline-tool | Source/Generated/
	@echo "Generating character sprite data for $*..."
	bin/skyline-tool compile-chaos-character "$@" "$(filter %.png,$^)"

# Convert Numbers PNG to 64tass assembly data using SkylineTool
# PNG files are generated from XCF via %.png: %.xcf pattern rule
# Explicitly depend on XCF to ensure proper build ordering in parallel builds
Source/Generated/Numbers.s: Source/Art/Numbers.png Source/Art/Numbers.xcf bin/skyline-tool | Source/Generated/
	@echo "Converting Numbers font $< to $@..."
	bin/skyline-tool compile-2600-font-8x16 "$@" "$<"

# Fonts are universal (not TV-specific)
# Source/Generated/Numbers.s is used directly by SetPlayerGlyph.s

# Convert 48×42 PNG to titlescreen kernel assembly format
# Uses compile-batari-48px with titlescreen-kernel-p flag for color-per-line + double-height
# These are bitmaps for the titlescreen kernel minikernels, not playfield data
# PNG files are built from XCF via the %.png: %.xcf pattern rule (line 180)
# Explicit PNG→XCF dependencies ensure XCF→PNG conversion happens first
# These use the pattern rule %.png: %.xcf (line 239) to generate PNGs from XCFs
Source/Art/AtariAge.png: Source/Art/AtariAge.xcf | Source/Art/
	@echo "Generating PNG from XCF: $@..."
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'

Source/Art/AtariAgeText.png: Source/Art/AtariAgeText.xcf | Source/Art/
	@echo "Generating PNG from XCF: $@..."
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'

Source/Art/BRP.png: Source/Art/BRP.xcf | Source/Art/
	@echo "Generating PNG from XCF: $@..."
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'

Source/Art/ChaosFight.png: Source/Art/ChaosFight.xcf | Source/Art/
	@echo "Generating PNG from XCF: $@..."
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'

Source/Art/Numbers.png: Source/Art/Numbers.xcf | Source/Art/
	@echo "Generating PNG from XCF: $@..."
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'

# Titlescreen kernel bitmap conversion: PNG → .s (assembly format)
# PNG files are generated from XCF via %.png: %.xcf pattern rule
# Explicitly depend on XCF to ensure proper build ordering in parallel builds
# SkylineTool generates both .s and .colors.s files in one call
Source/Generated/Art.AtariAge.s Source/Generated/Art.AtariAge.colors.s: Source/Art/AtariAge.png Source/Art/AtariAge.xcf bin/skyline-tool | Source/Generated/
	@echo "Converting 48×42 bitmap $< to titlescreen kernel $@..."
	bin/skyline-tool compile-batari-48px "$<" "Source/Generated/Art.AtariAge.s" "t" "NTSC"

Source/Generated/Art.AtariAgeText.s Source/Generated/Art.AtariAgeText.colors.s: Source/Art/AtariAgeText.png Source/Art/AtariAgeText.xcf bin/skyline-tool | Source/Generated/
	@echo "Converting 48×42 bitmap $< to titlescreen kernel $@..."
	bin/skyline-tool compile-batari-48px "$<" "Source/Generated/Art.AtariAgeText.s" "t" "NTSC"

Source/Generated/Art.Author.s Source/Generated/Art.Author.colors.s: Source/Art/BRP.png Source/Art/BRP.xcf bin/skyline-tool | Source/Generated/
	@echo "Converting 48×42 bitmap $< to titlescreen kernel $@..."
	bin/skyline-tool compile-batari-48px "$<" "Source/Generated/Art.Author.s" "t" "NTSC"

Source/Generated/Art.ChaosFight.s Source/Generated/Art.ChaosFight.colors.s: Source/Art/ChaosFight.png Source/Art/ChaosFight.xcf bin/skyline-tool | Source/Generated/
	@echo "Converting 48×42 bitmap $< to titlescreen kernel $@..."
	bin/skyline-tool compile-batari-48px "$<" "Source/Generated/Art.ChaosFight.s" "t" "NTSC"

# Generate titlescreen kernel image files from Art.*.s and Art.*.colors.s files
# These are used by the titlescreen kernel minikernels
Source/TitleScreen/48x2_1_image.s: Source/Generated/Art.AtariAge.s Source/Generated/Art.AtariAge.colors.s Tools/generate-48x2-image.sh | Source/TitleScreen/
	@echo "Generating titlescreen image file $@ from $<..."
	Tools/generate-48x2-image.sh "Source/Generated/Art.AtariAge.s" "Source/Generated/Art.AtariAge.colors.s" "$@" "1"

Source/TitleScreen/48x2_2_image.s: Source/Generated/Art.AtariAgeText.s Source/Generated/Art.AtariAgeText.colors.s Tools/generate-48x2-image.sh | Source/TitleScreen/
	@echo "Generating titlescreen image file $@ from $<..."
	Tools/generate-48x2-image.sh "Source/Generated/Art.AtariAgeText.s" "Source/Generated/Art.AtariAgeText.colors.s" "$@" "2"

Source/TitleScreen/48x2_3_image.s: Source/Generated/Art.ChaosFight.s Source/Generated/Art.ChaosFight.colors.s Tools/generate-48x2-image.sh | Source/TitleScreen/
	@echo "Generating titlescreen image file $@ from $<..."
	Tools/generate-48x2-image.sh "Source/Generated/Art.ChaosFight.s" "Source/Generated/Art.ChaosFight.colors.s" "$@" "3"

Source/TitleScreen/48x2_4_image.s: Source/Generated/Art.Author.s Source/Generated/Art.Author.colors.s Tools/generate-48x2-image.sh | Source/TitleScreen/
	@echo "Generating titlescreen image file $@ from $<..."
	Tools/generate-48x2-image.sh "Source/Generated/Art.Author.s" "Source/Generated/Art.Author.colors.s" "$@" "4"

# Color files are generated automatically when bitmap files are generated
# Combine all titlescreen color tables, PF1, PF2, and background into a single file at $f500
# Bitmap data is at $f100, $f200, $f300, $f400 (page-aligned)
# All other data (colors, PF1, PF2, background) starts at $f500
Source/TitleScreen/titlescreen_colors.s: \
	Source/Generated/Art.AtariAge.colors.s \
	Source/Generated/Art.AtariAgeText.colors.s \
	Source/Generated/Art.Author.colors.s \
	Source/Generated/Art.ChaosFight.colors.s | Source/TitleScreen/
	@echo "Creating combined titlescreen colors file $@ at \$$f500..."
	@echo ";;; Chaos Fight - $@" > "$@"
	@echo ";;; This is a generated file, do not edit." >> "$@"
	@echo ";;; Color tables, PF1, PF2, and background for all titlescreen bitmaps" >> "$@"
	@echo ";;; Combined at \$$f500 (after bitmap data at \$$f100-\$$f400)" >> "$@"
	@echo "" >> "$@"
	@echo "   rorg \$$f500" >> "$@"
	@echo "" >> "$@"
	@echo ";;; Include color tables, PF1, PF2, and background for all titlescreen bitmaps" >> "$@"
	@echo "          .include \"Source/Generated/Art.AtariAge.colors.s\"" >> "$@"
	@echo "          .include \"Source/Generated/Art.AtariAgeText.colors.s\"" >> "$@"
	@echo "          .include \"Source/Generated/Art.ChaosFight.colors.s\"" >> "$@"
	@echo "          .include \"Source/Generated/Art.Author.colors.s\"" >> "$@"

# Convert XCF to PNG for maps
Source/Art/Map-%.png: Source/Art/Map-%.xcf | Source/Art/
	$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'

# Convert PNG font to 64tass assembly data
Source/Generated/Font.s: Source/Art/Font.png bin/skyline-tool | Source/Generated/
	@echo "Converting font $< to $@..."
	bin/skyline-tool compile-8x16-font "$<" > "$@" 

# Generate final assembly file from platform entry point (64tass format)
# All source files are already in .s format and use .include directives
Source/Generated/$(GAME)$(GAMEYEAR).NTSC.s: Source/Platform/NTSC.s \
	$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).s) \
	Source/Banks/Bank0.s Source/Banks/Bank1.s Source/Banks/Bank2.s Source/Banks/Bank3.s Source/Banks/Bank4.s Source/Banks/Bank11.s Source/Banks/Bank15.s \
	Source/Generated/Numbers.s \
	Source/Generated/Art.AtariAge.s Source/Generated/Art.AtariAgeText.s Source/Generated/Art.ChaosFight.s Source/Generated/Art.Author.s \
	Source/TitleScreen/titlescreen_colors.s \
	$(foreach sound,$(SOUND_NAMES),Source/Generated/Sound.$(sound).NTSC.s) \
	$(foreach song,$(MUSIC_NAMES),Source/Generated/Song.$(song).NTSC.s) \
	$(foreach song,$(GAME_THEME_SONGS),Source/Generated/Song.$(song).NTSC.s) \
	$(foreach bitmap,$(BITMAP_NAMES),Source/Art/$(bitmap).png) | Source/Generated/
	@echo "Generating final assembly file from NTSC platform entry point..."
	cp $< $@

# Generate final assembly file from PAL platform entry point (64tass format)
Source/Generated/$(GAME)$(GAMEYEAR).PAL.s: Source/Platform/PAL.s \
	$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).s) \
	Source/Banks/Bank0.s Source/Banks/Bank1.s Source/Banks/Bank2.s Source/Banks/Bank3.s Source/Banks/Bank4.s Source/Banks/Bank11.s Source/Banks/Bank15.s \
	Source/Generated/Numbers.s \
	Source/Generated/Art.AtariAge.s Source/Generated/Art.AtariAgeText.s Source/Generated/Art.ChaosFight.s Source/Generated/Art.Author.s \
	Source/TitleScreen/titlescreen_colors.s \
	$(foreach sound,$(SOUND_NAMES),Source/Generated/Sound.$(sound).PAL.s) \
	$(foreach song,$(MUSIC_NAMES),Source/Generated/Song.$(song).PAL.s) \
	$(foreach song,$(GAME_THEME_SONGS),Source/Generated/Song.$(song).PAL.s) \
	$(foreach bitmap,$(BITMAP_NAMES),Source/Art/$(bitmap).png) | Source/Generated/
	@echo "Generating final assembly file from PAL platform entry point..."
	cp $< $@

# Generate final assembly file from SECAM platform entry point (64tass format)
# SECAM build uses PAL music/sound files via conditional includes
Source/Generated/$(GAME)$(GAMEYEAR).SECAM.s: Source/Platform/SECAM.s \
	$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).s) \
	Source/Banks/Bank0.s Source/Banks/Bank1.s Source/Banks/Bank2.s Source/Banks/Bank3.s Source/Banks/Bank4.s Source/Banks/Bank11.s Source/Banks/Bank15.s \
	Source/Generated/Numbers.s \
	Source/Generated/Art.AtariAge.s Source/Generated/Art.AtariAgeText.s Source/Generated/Art.ChaosFight.s Source/Generated/Art.Author.s \
	Source/TitleScreen/titlescreen_colors.s \
	$(foreach sound,$(SOUND_NAMES),Source/Generated/Sound.$(sound).PAL.s) \
	$(foreach song,$(MUSIC_NAMES),Source/Generated/Song.$(song).PAL.s) \
	$(foreach song,$(GAME_THEME_SONGS),Source/Generated/Song.$(song).PAL.s) \
	$(foreach bitmap,$(BITMAP_NAMES),Source/Art/$(bitmap).png) | Source/Generated/
	@echo "Generating final assembly file from SECAM platform entry point..."
	cp $< $@


# Bank file dependencies - each bank explicitly depends on the files it includes
Source/Banks/Bank0.s:

Source/Banks/Bank1.s: Source/Generated/Bernie.s Source/Generated/Curler.s Source/Generated/DragonOfStorms.s Source/Generated/ZoeRyen.s Source/Generated/FatTony.s Source/Generated/Megax.s Source/Generated/Harpy.s Source/Generated/KnightGuy.s

Source/Banks/Bank2.s: Source/Generated/Frooty.s Source/Generated/Nefertem.s Source/Generated/NinjishGuy.s Source/Generated/PorkChop.s Source/Generated/RadishGoblin.s Source/Generated/RoboTito.s Source/Generated/Ursulo.s Source/Generated/Shamone.s

Source/Banks/Bank3.s: Source/Generated/Character16.s Source/Generated/Character17.s Source/Generated/Character18.s Source/Generated/Character19.s Source/Generated/Character20.s Source/Generated/Character21.s Source/Generated/Character22.s Source/Generated/Character23.s

Source/Banks/Bank4.s: Source/Generated/Character24.s Source/Generated/Character25.s Source/Generated/Character26.s Source/Generated/Character27.s Source/Generated/Character28.s Source/Generated/Character29.s Source/Generated/Character30.s Source/Generated/MethHound.s

Source/Banks/Bank11.s:

Source/Banks/Bank15.s: Source/Generated/Numbers.s

# Shared dependencies for all TV standards
BUILD_DEPS = $(ALL_SOURCES)  \
	Source/Banks/Bank0.bas \
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
	Source/Routines/BernieAttack.bas \
	Source/Routines/HarpyAttack.bas \
	Source/Routines/UrsuloAttack.bas \
	Source/Routines/ShamoneAttack.bas \
	Source/Routines/CharacterAttacksDispatch.bas \
	Source/Routines/CharacterControlsDown.bas \
	Source/Routines/CharacterControlsJump.bas \
	Source/Routines/CharacterSelectMain.bas \
	Source/Routines/CharacterSelectRender.bas \
	Source/Routines/CheckRoboTitoStretchMissileCollisions.bas \
	Source/Routines/ColdStart.bas \
	Source/Routines/Combat.bas \
	Source/Routines/ConsoleDetection.bas \
	Source/Routines/ConsoleHandling.bas \
	Source/Routines/ControllerDetection.bas \
	Source/Routines/SetPlayerGlyph.bas \
	Source/Routines/DisplayWinScreen.bas \
	Source/Routines/FallDamage.bas \
	Source/Routines/FallingAnimation.bas \
	Source/Routines/GameLoopInit.bas \
	Source/Routines/GameLoopMain.bas \
	Source/Routines/ApplyGuardColor.bas \
	Source/Routines/RestoreNormalPlayerColor.bas \
	Source/Routines/CheckGuardCooldown.bas \
	Source/Routines/StartGuard.bas \
	Source/Routines/UpdateGuardTimers.bas \
	Source/Routines/UpdateSingleGuardTimer.bas \
	Source/Routines/HealthBarSystem.bas \
	Source/Routines/MainLoop.bas \
	Source/Routines/MissileCollision.bas \
	Source/Routines/MissileSystem.bas \
	Source/Routines/UpdatePlayerMovement.bas \
	Source/Routines/UpdatePlayerMovementSingle.bas \
	Source/Routines/SetPlayerVelocity.bas \
	Source/Routines/SetPlayerPosition.bas \
	Source/Routines/GetPlayerPosition.bas \
	Source/Routines/GetPlayerVelocity.bas \
	Source/Routines/MovementApplyGravity.bas \
	Source/Routines/AddVelocitySubpixelY.bas \
	Source/Routines/ApplyFriction.bas \
	Source/Routines/CheckPlayerCollision.bas \
	Source/Routines/ConstrainToScreen.bas \
	Source/Routines/InitializeMovementSystem.bas \
	Source/Routines/MusicBankHelpers15.bas \
	Source/Routines/MusicBankHelpers.bas \
	Source/Routines/MusicSystem.bas \
	Source/Routines/PerformGenericAttack.bas \
	Source/Routines/PlayerCollisionResolution.bas \
	Source/Routines/CheckAllPlayerEliminations.bas \
	Source/Routines/CheckPlayerElimination.bas \
	Source/Routines/CountRemainingPlayers.bas \
	Source/Routines/DeactivatePlayerMissiles.bas \
	Source/Routines/FindLastEliminated.bas \
	Source/Routines/FindWinner.bas \
	Source/Routines/IsPlayerAlive.bas \
	Source/Routines/IsPlayerEliminated.bas \
	Source/Routines/TriggerEliminationEffects.bas \
	Source/Routines/UpdatePlayers34ActiveFlag.bas \
	Source/Routines/PlayerInput.bas \
	Source/Routines/PlayerLockedHelpers.bas \
	Source/Routines/PlayerPhysicsGravity.bas \
	Source/Routines/SetSpritePositions.bas \
	Source/Routines/SetPlayerSprites.bas \
	Source/Routines/DisplayHealth.bas \
	Source/Routines/PublisherPrelude.bas \
	Source/Routines/SetGameScreenLayout.bas \
	Source/Routines/LoadSoundPointer.bas \
	Source/Routines/LoadSoundNote.bas \
	Source/Routines/LoadSoundNote1.bas \
	Source/Routines/PlaySoundEffect.bas \
	Source/Routines/UpdateSoundEffect.bas \
	Source/Routines/UpdateSoundEffectVoice0.bas \
	Source/Routines/UpdateSoundEffectVoice1.bas \
	Source/Routines/StopSoundEffects.bas \
	Source/Routines/SpriteLoader.bas \
	Source/Routines/SpriteLoaderCharacterArt.bas \
	Source/Routines/InitializeSpritePointers.bas \
	Source/Routines/TitleCharacterParade.bas \
	Source/Routines/TitleScreenMain.bas \
	Source/Routines/TitleScreenRender.bas \
	Source/Routines/TitlescreenWindowControl.bas \
	Source/Routines/WinnerAnnouncement.bas \
	$(foreach sound,$(SOUND_NAMES),Source/Generated/Sound.$(sound).NTSC.s) \
	$(foreach sound,$(SOUND_NAMES),Source/Generated/Sound.$(sound).PAL.s) \
	$(foreach song,$(MUSIC_NAMES),Source/Generated/Song.$(song).NTSC.s) \
	$(foreach song,$(MUSIC_NAMES),Source/Generated/Song.$(song).PAL.s) \
	$(foreach song,$(GAME_THEME_SONGS),Source/Generated/Song.$(song).NTSC.s) \
	$(foreach song,$(GAME_THEME_SONGS),Source/Generated/Song.$(song).PAL.s)\
# Explicitly depend on character and bitmap PNG files to ensure they are generated
# Combined .s files are generated from batariBASIC assembly output
# The conversion script converts DASM syntax to 64tass syntax 

# Assemble combined .s file → ARCH.a26 + ARCH.lst + ARCH.sym
# Using 64tass directly on the assembly file with build-time defines
Dist/$(GAME)$(GAMEYEAR).NTSC.a26 Dist/$(GAME)$(GAMEYEAR).NTSC.sym Dist/$(GAME)$(GAMEYEAR).NTSC.lst: Source/Generated/$(GAME)$(GAMEYEAR).NTSC.s | Dist/ Object/
	cd Object && $(64TASS) $(ASFLAGS) -o ../Dist/$(GAME)$(GAMEYEAR).NTSC.a26 -L ../Dist/$(GAME)$(GAMEYEAR).NTSC.lst -l ../Dist/$(GAME)$(GAMEYEAR).NTSC.sym ../$<

Dist/$(GAME)$(GAMEYEAR).PAL.a26 Dist/$(GAME)$(GAMEYEAR).PAL.sym Dist/$(GAME)$(GAMEYEAR).PAL.lst: Source/Generated/$(GAME)$(GAMEYEAR).PAL.s | Dist/ Object/
	cd Object && $(64TASS) $(ASFLAGS) -o ../Dist/$(GAME)$(GAMEYEAR).PAL.a26 -L ../Dist/$(GAME)$(GAMEYEAR).PAL.lst -l ../Dist/$(GAME)$(GAMEYEAR).PAL.sym ../$<

Dist/$(GAME)$(GAMEYEAR).SECAM.a26 Dist/$(GAME)$(GAMEYEAR).SECAM.sym Dist/$(GAME)$(GAMEYEAR).SECAM.lst: Source/Generated/$(GAME)$(GAMEYEAR).SECAM.s | Dist/ Object/
	cd Object && $(64TASS) $(ASFLAGS) -o ../Dist/$(GAME)$(GAMEYEAR).SECAM.a26 -L ../Dist/$(GAME)$(GAMEYEAR).SECAM.lst -l ../Dist/$(GAME)$(GAMEYEAR).SECAM.sym ../$<

# Run emulator
emu: $(ROM) Dist/$(GAME)$(GAMEYEAR).NTSC.pro
	$(STELLA) -debug $(ROM)

play: $(ROM) Dist/$(GAME)$(GAMEYEAR).NTSC.pro
	$(STELLA) $(ROM)

# Clean all generated files
clean:
	rm -rf Dist Object Source/Generated
	rm -f Source/Art/*.png
	rm -f Source/Songs/*.pdf
	rm -f Source/Songs/*.midi
	rm -f $(GAME)*.aux $(GAME)*.cp $(GAME)*.cps $(GAME)*.toc $(GAME)*.log
	git submodule foreach git clean --force
	rm -f bin/buildapp bin/skyline-tool bin/zx7mini

quickclean:
	rm -rf Dist Object
	rm -f Source/Generated/$(GAME)$(GAMEYEAR)*.s
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
	@echo "  Dist/ChaosFight26.pdf        - Game manual (PDF)"
	@echo "  Dist/ChaosFight26.html       - Game manual (HTML)"
	@echo "  Dist/ChaosFight26.NTSC.a26   - NTSC ROM"
	@echo "  Dist/ChaosFight26.PAL.a26    - PAL ROM"
	@echo "  Dist/ChaosFight26.SECAM.a26  - SECAM ROM"

# Generate Stella .pro files
Dist/$(GAME)$(GAMEYEAR).NTSC.pro: Source/$(GAME)$(GAMEYEAR).pro Dist/$(GAME)$(GAMEYEAR).NTSC.a26 | Dist/
	sed $< -e s/@@TV@@/NTSC/g \
		-e s/@@MD5@@/$$(md5sum Dist/$(GAME)$(GAMEYEAR).NTSC.a26 | cut -d\  -f1)/g > $@

Dist/$(GAME)$(GAMEYEAR).PAL.pro: Source/$(GAME)$(GAMEYEAR).pro Dist/$(GAME)$(GAMEYEAR).PAL.a26 | Dist/
	sed $< -e s/@@TV@@/PAL/g \
		-e s/@@MD5@@/$$(md5sum Dist/$(GAME)$(GAMEYEAR).PAL.a26 | cut -d\  -f1)/g > $@

Dist/$(GAME)$(GAMEYEAR).SECAM.pro: Source/$(GAME)$(GAMEYEAR).pro Dist/$(GAME)$(GAMEYEAR).SECAM.a26 | Dist/
	sed $< -e s/@@TV@@/SECAM/g \
		-e s/@@MD5@@/$$(md5sum Dist/$(GAME)$(GAMEYEAR).SECAM.a26 | cut -d\  -f1)/g > $@

Dist/$(GAME)$(GAMEYEAR).%.$(RELEASE_TAG).zip: Dist/$(GAME)$(GAMEYEAR).%.a26 Dist/$(GAME)$(GAMEYEAR).%.pro $(MANUAL_PDF) | Dist/
	@echo "Packaging $* release $(RELEASE_TAG)..."
	rm -f $@
	zip -j $@ $^

web: doc $(ZIP_ARCHIVES) $(MANUAL_HTML) $(MANUAL_PDF)
	@echo "Deploying website to $(WEB_REMOTE)..."
	ssh interworldly.com 'mkdir -p interworldly.com/games/ChaosFight/26/downloads interworldly.com/games/ChaosFight/26/manual'
	rsync -av WWW/ $(WEB_REMOTE)/
	rsync -av $(MANUAL_HTML) $(WEB_MANUAL)
	rsync -av $(MANUAL_PDF) $(WEB_DOWNLOADS)
	rsync -av $(ZIP_ARCHIVES) $(WEB_DOWNLOADS)

# Documentation generation
# Build PDF in Object/ to contain auxiliary files (.aux, .cp, .cps, .toc)
Dist/$(GAME)$(GAMEYEAR).pdf: Manual/ChaosFight.texi | Object/ Dist/
	cd Object && makeinfo --pdf --output=$(GAME)$(GAMEYEAR).pdf ../$<
	cp Object/$(GAME)$(GAMEYEAR).pdf $@

Dist/$(GAME)$(GAMEYEAR).html: Manual/ChaosFight.texi Manual/texinfo.css | Dist/
	makeinfo --html --css-include=Manual/texinfo.css --output=$@ $<

nowready: $(READYFILE)

$(READYFILE):
	$(MAKE) ready

ready: gimp-export bin/skyline-tool
	# Mark ready
	@echo "Development environment ready for ChaosFight build"
	touch $(READYFILE)
