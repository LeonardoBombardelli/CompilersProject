./etapa3 < $1 > saida.txt
python conv_dot.py saida.txt tree.dot
dot tree.dot -Tpng -o tree.png
rm saida.txt tree.dot