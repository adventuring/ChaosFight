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
ALL_SOURCES = $(shell find Source -name \*.bas)

# Default target
.PHONY: all clean emu game help doc
all: game doc

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

# Build game
Dist/$(GAME).NTSC.a26 Dist/$(GAME).NTSC.sym Dist/$(GAME).NTSC.lst: $(ALL_SOURCES)
	mkdir -p Dist $(GENERATED_DIR)
	cpp -P -I. Source/Platform/NTSC.bas > $(GENERATED_DIR)/$(GAME).NTSC.bas
	bin/preprocess < $(GENERATED_DIR)/$(GAME).NTSC.bas | bin/2600basic -i Tools/batariBASIC -r Tools/batariBASIC/includes/variable_redefs.h > $(GENERATED_DIR)/bB.s
	cp $(GENERATED_DIR)/bB.s bB.asm
	bin/postprocess -i Tools/batariBASIC < bB.asm > $(GENERATED_DIR)/$(GAME).s
	bin/dasm $(GENERATED_DIR)/$(GAME).s -ITools/batariBASIC/includes -f3 -lDist/$(GAME).NTSC.lst -sDist/$(GAME).NTSC.sym -oDist/$(GAME).NTSC.a26
	rm -f $(GENERATED_DIR)/bB.s bB.asm $(GENERATED_DIR)/$(GAME).s

Dist/$(GAME).PAL.a26 Dist/$(GAME).PAL.sym Dist/$(GAME).PAL.lst: $(ALL_SOURCES)
	mkdir -p Dist $(GENERATED_DIR)
	cpp -P -I. Source/Platform/PAL.bas > $(GENERATED_DIR)/$(GAME).PAL.bas
	bin/preprocess < $(GENERATED_DIR)/$(GAME).PAL.bas | bin/2600basic -i Tools/batariBASIC -r Tools/batariBASIC/includes/variable_redefs.h > $(GENERATED_DIR)/bB_PAL.s
	cp $(GENERATED_DIR)/bB_PAL.s bB.asm
	bin/postprocess -i Tools/batariBASIC < bB.asm > $(GENERATED_DIR)/$(GAME)_PAL.s
	bin/dasm $(GENERATED_DIR)/$(GAME)_PAL.s -ITools/batariBASIC/includes -f3 -lDist/$(GAME).PAL.lst -sDist/$(GAME).PAL.sym -oDist/$(GAME).PAL.a26
	rm -f $(GENERATED_DIR)/bB_PAL.s bB.asm $(GENERATED_DIR)/$(GAME)_PAL.s

Dist/$(GAME).SECAM.a26 Dist/$(GAME).SECAM.sym Dist/$(GAME).SECAM.lst: $(ALL_SOURCES)
	mkdir -p Dist $(GENERATED_DIR)
	cpp -P -I. Source/Platform/SECAM.bas > $(GENERATED_DIR)/$(GAME).SECAM.bas
	bin/preprocess < $(GENERATED_DIR)/$(GAME).SECAM.bas | bin/2600basic -i Tools/batariBASIC -r Tools/batariBASIC/includes/variable_redefs.h > $(GENERATED_DIR)/bB_SECAM.s
	cp $(GENERATED_DIR)/bB_SECAM.s bB.asm
	bin/postprocess -i Tools/batariBASIC < bB.asm > $(GENERATED_DIR)/$(GAME)_SECAM.s
	bin/dasm $(GENERATED_DIR)/$(GAME)_SECAM.s -ITools/batariBASIC/includes -f3 -lDist/$(GAME).SECAM.lst -sDist/$(GAME).SECAM.sym -oDist/$(GAME).SECAM.a26
	rm -f $(GENERATED_DIR)/bB_SECAM.s bB.asm $(GENERATED_DIR)/$(GAME)_SECAM.s

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

