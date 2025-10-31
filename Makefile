# Default target
all: sprites game doc characters playfields fonts music

# Test target
test: SkylineTool/skyline-tool.asd
	@echo "Running SkylineTool fiveam tests..."
	cd SkylineTool && sbcl --script tests/run-tests.lisp || (echo "Tests failed!" && exit 1)

# Precious intermediate files
.PRECIOUS: %.s %.png %.midi

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
READYDATE = 20251028
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
ROM = Dist/$(GAME).NTSC.a26

# Assembly files
ALL_SOURCES = $(shell find Source -name \*.bas)

# Moved to top of file
.PHONY: all clean emu game help doc characters playfields fonts sprites nowready ready

# Build game
game: \
	Dist/$(GAME).NTSC.a26 \
	Dist/$(GAME).PAL.a26 \
	Dist/$(GAME).SECAM.a26 \
	Dist/$(GAME).NTSC.sym \
	Dist/$(GAME).PAL.sym \
	Dist/$(GAME).SECAM.sym \
	Dist/$(GAME).NTSC.lst \
	Dist/$(GAME).PAL.lst \
	Dist/$(GAME).SECAM.lst \
	Dist/$(GAME).NTSC.pro \
	Dist/$(GAME).PAL.pro \
	Dist/$(GAME).SECAM.pro

doc: Dist/$(GAME).pdf Dist/$(GAME).html

# Character sprite sheet names (16 characters)
CHARACTER_NAMES = Bernie Curler Dragonet EXOPilot FatTony Megax Harpy KnightGuy Frooty Nefertem NinjishGuy PorkChop RadishGoblin RoboTito Ursulo VegDog

# TV architectures
TV_ARCHS = NTSC PAL SECAM

# Screen names (32×32 playfield screens)
SCREEN_NAMES = AtariAge Interworldly ChaosFight

# Font names
FONT_NAMES = Numbers

# Music names (MuseScore files)
MUSIC_NAMES = AtariToday Interworldly Title Victory GameOver

# Build character assets  
characters: $(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas)

# Build playfield assets (game levels + title screens)
playfields: $(foreach screen,$(SCREEN_NAMES),$(foreach arch,$(TV_ARCHS),Source/Generated/Playfield.$(screen).$(arch).bas))

# Build font assets (fonts are universal, not region-specific)
fonts: $(foreach font,$(FONT_NAMES),Source/Generated/$(font).bas)

# Build music assets
music: $(foreach song,$(MUSIC_NAMES),$(foreach arch,$(TV_ARCHS),Source/Generated/Song.$(song).$(arch).bas))

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
		~/Software/MuseScore*.AppImage --export-to $@ $<; \
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
Source/Generated/Song.%.NTSC.bas: Source/Songs/%.midi bin/skyline-tool
	@echo "Converting music $< to $@ for NTSC..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-midi "$<" "batariBASIC" "60" "$@"

# Convert MIDI to batariBASIC music data for PAL (50Hz)
Source/Generated/Song.%.PAL.bas: Source/Songs/%.midi bin/skyline-tool
	@echo "Converting music $< to $@ for PAL..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-midi "$<" "batariBASIC" "50" "$@"

# Convert MIDI to batariBASIC music data for SECAM (50Hz)
Source/Generated/Song.%.SECAM.bas: Source/Songs/%.midi bin/skyline-tool
	@echo "Converting music $< to $@ for SECAM..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-midi "$<" "batariBASIC" "50" "$@"



# Generate list of character sprite files
CHARACTER_XCF = $(foreach char,$(CHARACTER_NAMES),Source/Art/$(char).xcf)
CHARACTER_PNG = $(foreach char,$(CHARACTER_NAMES),Source/Art/$(char).png)
CHARACTER_BAS = $(foreach char,$(CHARACTER_NAMES),Source/Generated/Art.$(char).bas)

# Convert XCF to PNG for sprites (characters and special sprites)
%.png: %.xcf $(READYFILE)
	@echo "Converting $< to $@..."
	mkdir -p Source/Art
	$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'

# Character sprites are compiled using compile-chaos-character
# Special sprites (QuestionMark, CPU, No) are hard-coded in Source/Data/SpecialSprites.bas

# Generate character sprite files from PNG using chaos character compiler
# Explicit rules for each character ensure proper PNG dependency tracking
$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas): Source/Generated/%.bas: Source/Art/%.png bin/skyline-tool
	@echo "Generating character sprite data for $*..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-chaos-character "$@" "$<"

# Convert Numbers PNG to batariBASIC data using SkylineTool
Source/Generated/Numbers.bas: Source/Art/Numbers.png bin/skyline-tool
	@echo "Converting Numbers font $< to $@..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-2600-font-8x16 "$@" "$<"

# Convert PNG screen to batariBASIC playfield data for NTSC
Source/Generated/Playfield.%.NTSC.bas: Source/Art/%.png bin/skyline-tool
	@echo "Converting playfield screen $< to $@ for NTSC..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-2600-playfield "$@" "$<" "NTSC"

# Convert PNG screen to batariBASIC playfield data for PAL
Source/Generated/Playfield.%.PAL.bas: Source/Art/%.png bin/skyline-tool
	@echo "Converting playfield screen $< to $@ for PAL..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-2600-playfield "$@" "$<" "PAL"

# Convert PNG screen to batariBASIC playfield data for SECAM
Source/Generated/Playfield.%.SECAM.bas: Source/Art/%.png bin/skyline-tool
	@echo "Converting playfield screen $< to $@ for SECAM..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-2600-playfield "$@" "$<" "SECAM"

# Convert XCF to PNG for maps
Source/Art/Map-%.png: Source/Art/Map-%.xcf
	$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'

# Convert PNG to batariBASIC playfield include
# Commented out - no Map-*.png files exist, and command should be compile-2600-playfield (singular)
# Source/Generated/Playfields.bas: $(wildcard Source/Art/Map-*.png)
# 	mkdir -p Source/Generated
# 	bin/skyline-tool compile-2600-playfield "Source/Generated/Playfields.bas" "Source/Art/Map-Arena1.png"

# Convert PNG font to batariBASIC data
Source/Generated/Font.bas: Source/Art/Font.png
	@echo "Converting font $< to $@ for NTSC..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-8x16-font "$<" > "$@" 

# Build game - accurate dependencies based on actual includes
Source/Generated/$(GAME).NTSC.bas: Source/Platform/NTSC.bas $(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas)
	mkdir -p Source/Generated
	cpp -P -I. -DBUILD_DATE=$(shell date +%Y.%j) $< > $@

Source/Generated/$(GAME).PAL.bas: Source/Platform/PAL.bas $(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas)
	mkdir -p Source/Generated
	cpp -P -I. -DBUILD_DATE=$(shell date +%Y.%j) $< > $@

Source/Generated/$(GAME).SECAM.bas: Source/Platform/SECAM.bas $(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas)
	mkdir -p Source/Generated
	cpp -P -I. -DBUILD_DATE=$(shell date +%Y.%j) $< > $@

Dist/$(GAME).NTSC.a26 Dist/$(GAME).NTSC.sym Dist/$(GAME).NTSC.lst: \
    Source/Generated/$(GAME).NTSC.bas \
	$(ALL_SOURCES) \
	$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas) \
	Source/Banks/Bank1.bas \
	Source/Banks/Banks.bas \
	Source/Common/Colors.h \
	Source/Common/Constants.bas \
	Source/Common/Macros.bas \
	Source/Common/Preamble.bas \
	Source/Common/Variables.bas \
	Source/Data/SpecialSprites.bas \
	Source/Routines/CharacterArt.s \
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
	Source/Routines/VisualEffects.bas \
	$(foreach screen,$(SCREEN_NAMES),Source/Generated/Playfield.$(screen).NTSC.bas) \
	Source/Generated/Numbers.bas
	mkdir -p Dist Source/Generated Object
	bin/preprocess < Source/Generated/$(GAME).NTSC.bas > Source/Generated/$(GAME).NTSC.preprocessed.bas
	cd Object && ../bin/2600basic -i $(POSTINC) -r ../Source/Common/variable_redefs.h < ../Source/Generated/$(GAME).NTSC.preprocessed.bas > bB.asm
	cd Object && ../bin/postprocess -i $(POSTINC) < bB.asm | ../bin/optimize > ../Source/Generated/$(GAME).NTSC.body.s
	cpp -P -DTV_STANDARD=NTSC Source/Common/AssemblyWrapper.template.s > Source/Generated/$(GAME).NTSC.s
	bin/dasm Source/Generated/$(GAME).NTSC.s -ITools/batariBASIC/includes -ISource -ISource/Common -f3 -lDist/$(GAME).NTSC.lst -sDist/$(GAME).NTSC.sym -oDist/$(GAME).NTSC.a26
	rm -f Source/Generated/$(GAME).NTSC.preprocessed.bas
	rm -f Object/bB.asm Object/includes.bB

Dist/$(GAME).PAL.a26 Dist/$(GAME).PAL.sym Dist/$(GAME).PAL.lst: \
    Source/Generated/$(GAME).PAL.bas \
	$(ALL_SOURCES) \
	$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas) \
	Source/Banks/Bank1.bas \
	Source/Banks/Banks.bas \
	Source/Common/Colors.h \
	Source/Common/Constants.bas \
	Source/Common/Macros.bas \
	Source/Common/Preamble.bas \
	Source/Common/Variables.bas \
	Source/Data/SpecialSprites.bas \
	Source/Routines/CharacterArt.s \
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
	Source/Routines/VisualEffects.bas \
	$(foreach screen,$(SCREEN_NAMES),Source/Generated/Playfield.$(screen).PAL.bas) \
	Source/Generated/Numbers.bas
	mkdir -p Dist Source/Generated Object
	bin/preprocess < Source/Generated/$(GAME).PAL.bas > Source/Generated/$(GAME).PAL.preprocessed.bas
	cd Object && ../bin/2600basic -i $(POSTINC) -r ../Source/Common/variable_redefs.h < ../Source/Generated/$(GAME).PAL.preprocessed.bas > bB.asm
	cd Object && ../bin/postprocess -i $(POSTINC) < bB.asm | ../bin/optimize > ../Source/Generated/$(GAME).PAL.body.s
	cpp -P -DTV_STANDARD=PAL Source/Common/AssemblyWrapper.template.s > Source/Generated/$(GAME).PAL.s
	bin/dasm Source/Generated/$(GAME).PAL.s -ITools/batariBASIC/includes -ISource -ISource/Common -f3 -lDist/$(GAME).PAL.lst -sDist/$(GAME).PAL.sym -oDist/$(GAME).PAL.a26
	rm -f Source/Generated/$(GAME).PAL.preprocessed.bas
	rm -f Object/bB.asm Object/includes.bB

Dist/$(GAME).SECAM.a26 Dist/$(GAME).SECAM.sym Dist/$(GAME).SECAM.lst: \
    Source/Generated/$(GAME).SECAM.bas \
	$(ALL_SOURCES) \
	$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas) \
	$(foreach screen,$(SCREEN_NAMES),Source/Generated/Playfield.$(screen).SECAM.bas) \
	Source/Banks/Bank1.bas \
	Source/Banks/Banks.bas \
	Source/Common/AssemblyConfig.s \
	Source/Common/AssemblyConfig.SECAM.s \
	Source/Common/AssemblyFooter.s \
	Source/Common/AssemblyWrapper.template.s \
	Source/Common/Colors.h \
	Source/Common/Constants.bas \
	Source/Common/Macros.bas \
	Source/Common/Preamble.bas \
	Source/Common/Variables.bas \
	Source/Data/SpecialSprites.bas \
	Source/Routines/CharacterArt.s \
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
	Source/Routines/VisualEffects.bas \
	$(foreach screen,$(SCREEN_NAMES),Source/Generated/Playfield.$(screen).SECAM.bas) \
	Source/Generated/Numbers.bas
	mkdir -p Dist Source/Generated Object
	bin/preprocess < Source/Generated/$(GAME).SECAM.bas > Source/Generated/$(GAME).SECAM.preprocessed.bas
	cd Object && ../bin/2600basic -i $(POSTINC) -r ../Source/Common/variable_redefs.h < ../Source/Generated/$(GAME).SECAM.preprocessed.bas > bB.asm
	cd Object && ../bin/postprocess -i $(POSTINC) < bB.asm | ../bin/optimize > ../Source/Generated/$(GAME).SECAM.body.s
	cpp -P -DTV_STANDARD=SECAM Source/Common/AssemblyWrapper.template.s > Source/Generated/$(GAME).SECAM.s
	bin/dasm Source/Generated/$(GAME).SECAM.s -ITools/batariBASIC/includes -ISource -ISource/Common -f3 -lDist/$(GAME).SECAM.lst -sDist/$(GAME).SECAM.sym -oDist/$(GAME).SECAM.a26
	rm -f Source/Generated/$(GAME).SECAM.preprocessed.bas
	rm -f Object/bB.asm Object/includes.bB

# Run emulator
emu: $(ROM)
	$(STELLA) $(ROM)

# Clean all generated files
clean:
	rm -rf Dist/*
	rm -rf Object/*
	rm -f Source/Generated/*
	rm -f Source/Art/*.png
	rm -f bB.s *.bin *.lst *.sym *.map *.pro
	rm -f Source/Generated/$(GAME).*.bas Source/Generated/$(GAME).*.s
	rm -f includes.bB
	cd Tools/batariBASIC && git clean --force

# Install GIMP export script
gimp-export:
	@for d in ~/.config/GIMP/*/scripts/; do \
		if [ -d "$$d" ]; then \
			echo "Installing xcf-export.scm to $$d"; \
			cp -f Tools/xcf-export.scm "$$d"; \
		fi; \
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
	@echo "  Dist/ChaosFight-Manual.pdf  - Game manual (PDF)"
	@echo "  Dist/ChaosFight-Manual.html - Game manual (HTML)"
	@echo "  Dist/ChaosFight.NTSC.a26    - NTSC ROM"
	@echo "  Dist/ChaosFight.PAL.a26     - PAL ROM"
	@echo "  Dist/ChaosFight.SECAM.a26   - SECAM ROM"

# Generate Stella .pro files
Dist/$(GAME).NTSC.pro: Source/$(GAME).pro Dist/$(GAME).NTSC.a26
	sed $< -e s/@@TV@@/NTSC/g \
		-e s/@@MD5@@/$$(md5sum Dist/$(GAME).NTSC.a26 | cut -d\  -f1)/g > $@

Dist/$(GAME).PAL.pro: Source/$(GAME).pro Dist/$(GAME).PAL.a26
	sed $< -e s/@@TV@@/PAL/g \
		-e s/@@MD5@@/$$(md5sum Dist/$(GAME).PAL.a26 | cut -d\  -f1)/g > $@

Dist/$(GAME).SECAM.pro: Source/$(GAME).pro Dist/$(GAME).SECAM.a26
	sed $< -e s/@@TV@@/SECAM/g \
		-e s/@@MD5@@/$$(md5sum Dist/$(GAME).SECAM.a26 | cut -d\  -f1)/g > $@

# Generate PDF manual from Texinfo source
Dist/$(GAME).pdf: Manual/$(GAME).texi
	@echo "Building PDF manual..."
	mkdir -p Dist Object
	cd Object && texi2pdf ../Manual/$(GAME).texi
	cp Object/$(GAME).pdf Dist/$(GAME).pdf

# Generate HTML manual from Texinfo source
Dist/$(GAME).html: Manual/$(GAME).texi
	@echo "Building HTML manual..."
	mkdir -p Dist Object
	cd Object && makeinfo --html --no-split --output=../Dist/$(GAME).html ../Manual/$(GAME).texi

# Back-compatibility aliases (optional)
Dist/$(GAME)-Manual.pdf: Dist/$(GAME).pdf
	cp $< $@

Dist/$(GAME)-Manual.html: Dist/$(GAME).html
	cp $< $@

# Ready system - setup development environment
nowready: $(READYFILE)

$(READYFILE):
	$(MAKE) ready

ready: gimp-export bin/skyline-tool
	@echo "Setting up ChaosFight development environment..."
	# Install required system packages (Fedora-based)
	@echo "Checking system dependencies..."
	@which sbcl > /dev/null || echo "MISSING: sbcl (install with: sudo dnf install sbcl)"
	@which gimp > /dev/null || echo "MISSING: gimp (install with: sudo dnf install gimp)"
	@which texi2pdf > /dev/null || echo "MISSING: texlive (install with: sudo dnf install texlive texinfo)"
	@which makeinfo > /dev/null || echo "MISSING: texinfo (install with: sudo dnf install texinfo)"
	# Initialize git submodules for SkylineTool
	git submodule update --init --recursive
	# Mark ready
	@echo "Development environment ready for ChaosFight build"
	touch $(READYFILE)
