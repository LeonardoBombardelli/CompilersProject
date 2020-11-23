./etapa6 < tst/testing.c > tst/testing.s
gcc tst/testing.s -o tst/testing
./tst/testing
echo $?