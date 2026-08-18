#!/bin/bash
echo \"Building AELION...\"

mkdir -p build
cd build

echo \"Compiling core...\"
gcc ../src/core/usp/usp.c -c
gcc ../src/core/bus/bus.c -c
gcc ../src/core/registry/registry.c -c
gcc ../src/core/security/security.c -c
gcc ../src/core/common/sentence.c -c
gcc ../src/core/common/utils.c -c

echo \"Compiling engines...\"
gcc ../src/engines/justice/justice.c -c
gcc ../src/engines/recall/recall.c -c
gcc ../src/engines/emotional/emotional.c -c
gcc ../src/engines/home/home.c -c
gcc ../src/engines/community/community.c -c
gcc ../src/engines/governance/governance.c -c
gcc ../src/engines/mining/mining.c -c

echo \"Build complete.\"
