./etapa6 < tst/testing.c > testing.s
gcc testing.s -o testing
./testing
echo $?