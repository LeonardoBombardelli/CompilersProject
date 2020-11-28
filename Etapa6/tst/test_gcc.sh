#!/bin/zsh
gcc -fno-asynchronous-unwind-tables -x c -S tst/our_tests/testing.ling -o tst/our_tests/testing_gcc.s
gcc tst/our_tests/testing_gcc.s -o tst/our_tests/testing
./tst/our_tests/testing
echo $?