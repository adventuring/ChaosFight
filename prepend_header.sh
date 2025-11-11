#!/bin/bash
# Prepend the multisprite header to the postprocess output
printf "processor 6507\ninclude \"vcs.h\"\ninclude \"macro.h\"\ninclude \"multisprite.h\"\ninclude \"superchip.h\"\ninclude \"2600basic_variable_redefs.h\"\n"
printf "ifconst bankswitch\n"
printf "  if bankswitch == 64\n"
printf "     ORG \$1000\n"
printf "     RORG \$1000\n"
printf "  endif\n"
printf "else\n"
printf "   ORG \$F000\n"
printf "endif\n"
printf "repeat 256\n"
printf ".byte \$ff\n"
printf "repend\n"
cat
