#!/bin/zsh
./etapa5 < schnorr_tst/ijk$1 > temp_iloc
python tst/ilocsim.py -s -t temp_iloc
rm temp_iloc