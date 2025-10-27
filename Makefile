# Tools and directories
BB_DIR = Tools/batariBASIC
BB_MAIN = bin/2600basic
BB_PREPROCESS = bin/preprocess
BB_POSTPROCESS = bin/postprocess
BB_OPTIMIZE = bin/optimize
BB_FILTER = bin/bbfilter
DASM = bin/dasm
STELLA = stella
SOURCE_DIR = .
GENERATED_DIR = Source/Generated
OBJECT_DIR = Object
DIST_DIR = Dist

# Output files
GAME = ChaosFight
ROM = Dist/$(GAME).NTSC.a26

# Assembly files
ALL_SOURCES = $(shell find Source -name \*.bas) $(GENERATED_DIR)/Characters.bas $(GENERATED_DIR)/Playfields.bas

# Default target
.PHONY: all clean emu game help doc characters playfields
all: game doc characters playfields

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

doc: Dist/$(GAME).pdf

# Build character assets
characters: $(GENERATED_DIR)/Characters.bas

# Build playfield assets
playfields: $(GENERATED_DIR)/Playfields.bas

# Convert XCF to PNG for characters
Source/Art/Character-%.png: Source/Art/Character-%.xcf
	gimp -i -b '(let* ((file (car (gimp-file-load RUN-NONINTERACTIVE "$<" "$<"))) (drawable (car (gimp-image-get-active-drawable file)))) (gimp-file-save RUN-NONINTERACTIVE file drawable "$@" "$@") (gimp-image-delete file))' -b '(gimp-quit 0)'

# Convert XCF to PNG for maps
Source/Art/Map-%.png: Source/Art/Map-%.xcf
	gimp -i -b '(let* ((file (car (gimp-file-load RUN-NONINTERACTIVE "$<" "$<"))) (drawable (car (gimp-image-get-active-drawable file)))) (gimp-file-save RUN-NONINTERACTIVE file drawable "$@" "$@") (gimp-image-delete file))' -b '(gimp-quit 0)'

# Convert PNG to batariBASIC character include
$(GENERATED_DIR)/Characters.bas: $(wildcard Source/Art/Character-*.png)
	mkdir -p $(GENERATED_DIR)
	bin/skyline-tool compile-characters $(GENERATED_DIR) $(wildcard Source/Art/Character-*.png)

# Convert PNG to batariBASIC playfield include
$(GENERATED_DIR)/Playfields.bas: $(wildcard Source/Art/Map-*.png)
	mkdir -p $(GENERATED_DIR)
	bin/skyline-tool compile-playfields $(GENERATED_DIR) $(wildcard Source/Art/Map-*.png)

# Build game
Dist/$(GAME).NTSC.a26 Dist/$(GAME).NTSC.sym Dist/$(GAME).NTSC.lst: $(ALL_SOURCES)
	mkdir -p Dist $(GENERATED_DIR)
	cpp -P -I. Source/Platform/NTSC.bas > $(GENERATED_DIR)/$(GAME).NTSC.bas
	bin/preprocess < $(GENERATED_DIR)/$(GAME).NTSC.bas | bin/2600basic -i Tools/batariBASIC -r Tools/batariBASIC/includes/variable_redefs.h > $(GENERATED_DIR)/$(GAME).NTSC.bB.s
	cp $(GENERATED_DIR)/$(GAME).NTSC.bB.s $(GENERATED_DIR)/$(GAME).NTSC.bB.asm
	bin/postprocess -i Tools/batariBASIC < $(GENERATED_DIR)/$(GAME).NTSC.bB.asm > $(GENERATED_DIR)/$(GAME).NTSC.s
	bin/dasm $(GENERATED_DIR)/$(GAME).NTSC.s -ITools/batariBASIC/includes -f3 -lDist/$(GAME).NTSC.lst -sDist/$(GAME).NTSC.sym -oDist/$(GAME).NTSC.a26
	rm -f $(GENERATED_DIR)/$(GAME).NTSC.bB.s $(GENERATED_DIR)/$(GAME).NTSC.bB.asm $(GENERATED_DIR)/$(GAME).NTSC.s

Dist/$(GAME).PAL.a26 Dist/$(GAME).PAL.sym Dist/$(GAME).PAL.lst: $(ALL_SOURCES)
	mkdir -p Dist $(GENERATED_DIR)
	cpp -P -I. Source/Platform/PAL.bas > $(GENERATED_DIR)/$(GAME).PAL.bas
	bin/preprocess < $(GENERATED_DIR)/$(GAME).PAL.bas | bin/2600basic -i Tools/batariBASIC -r Tools/batariBASIC/includes/variable_redefs.h > $(GENERATED_DIR)/$(GAME).PAL.bB.s
	cp $(GENERATED_DIR)/$(GAME).PAL.bB.s $(GENERATED_DIR)/$(GAME).PAL.bB.asm
	bin/postprocess -i Tools/batariBASIC < $(GENERATED_DIR)/$(GAME).PAL.bB.asm > $(GENERATED_DIR)/$(GAME).PAL.s
	bin/dasm $(GENERATED_DIR)/$(GAME).PAL.s -ITools/batariBASIC/includes -f3 -lDist/$(GAME).PAL.lst -sDist/$(GAME).PAL.sym -oDist/$(GAME).PAL.a26
	rm -f $(GENERATED_DIR)/$(GAME).PAL.bB.s $(GENERATED_DIR)/$(GAME).PAL.bB.asm $(GENERATED_DIR)/$(GAME).PAL.s

Dist/$(GAME).SECAM.a26 Dist/$(GAME).SECAM.sym Dist/$(GAME).SECAM.lst: $(ALL_SOURCES)
	mkdir -p Dist $(GENERATED_DIR)
	cpp -P -I. Source/Platform/SECAM.bas > $(GENERATED_DIR)/$(GAME).SECAM.bas
	bin/preprocess < $(GENERATED_DIR)/$(GAME).SECAM.bas | bin/2600basic -i Tools/batariBASIC -r Tools/batariBASIC/includes/variable_redefs.h > $(GENERATED_DIR)/$(GAME).SECAM.bB.s
	cp $(GENERATED_DIR)/$(GAME).SECAM.bB.s $(GENERATED_DIR)/$(GAME).SECAM.bB.asm
	bin/postprocess -i Tools/batariBASIC < $(GENERATED_DIR)/$(GAME).SECAM.bB.asm > $(GENERATED_DIR)/$(GAME).SECAM.s
	bin/dasm $(GENERATED_DIR)/$(GAME).SECAM.s -ITools/batariBASIC/includes -f3 -lDist/$(GAME).SECAM.lst -sDist/$(GAME).SECAM.sym -oDist/$(GAME).SECAM.a26
	rm -f $(GENERATED_DIR)/$(GAME).SECAM.bB.s $(GENERATED_DIR)/$(GAME).SECAM.bB.asm $(GENERATED_DIR)/$(GAME).SECAM.s

# Run emulator
emu: $(ROM)
	$(STELLA) $(ROM)

# Clean all generated files
clean:
	rm -rf Dist/*.a26
	rm -rf Object/*
	rm -f $(GENERATED_DIR)/*.s
	rm -f bB.s *.bin *.lst *.sym *.map

# Help target
help:
	@echo "Available targets:"
	@echo "  all     - Build game (default)"
	@echo "  game    - Build game"
	@echo "  clean   - Remove all generated files"
	@echo "  emu     - Build and run in Stella emulator"
	@echo "  help    - Show this help message"
	@echo ""
	@echo "Distributable files in Dist/"

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

