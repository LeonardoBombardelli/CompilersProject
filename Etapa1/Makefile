etapa1: scanner.l main.c
	flex -o lex.yy.c scanner.l
	gcc main.c lex.yy.c -o etapa1 -lfl

clean:
	rm -f lex.yy.c etapa1
