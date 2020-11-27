./etapa6 < tst/our_tests/testing.ling > tst/our_tests/testing.s
gcc tst/our_tests/testing.s -o tst/our_tests/testing
./tst/our_tests/testing
echo $?