./etapa3 < $1 > saida.txt
python tst/conv_dot.py saida.txt tree.dot
dot tree.dot -Tpng -o tree.png
rm saida.txt tree.dot