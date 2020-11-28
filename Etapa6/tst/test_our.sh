#!/bin/zsh
./etapa6 < tst/our_tests/testing.ling > tst/our_tests/testing_our.s
gcc tst/our_tests/testing_our.s -o tst/our_tests/testing
./tst/our_tests/testing
echo $?