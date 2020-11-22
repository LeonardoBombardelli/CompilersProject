#!/bin/zsh
./etapa6 < tst/schnorr_tst_e5/ijk$1 > temp_iloc
python tst/ilocsim.py -s -t temp_iloc
rm temp_iloc