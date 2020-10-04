etapa3: parser.y scanner.l main.c AST.c
	bison -v -d parser.y 
	flex -o lex.yy.c scanner.l
	gcc -c lex.yy.c parser.tab.c AST.c
	gcc lex.yy.c parser.tab.c AST.c main.c -o etapa3 -lfl

clean:
	rm -f *.tab.c *.tab.h *.yy.c *.o *.output etapa2
