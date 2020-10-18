etapa4: parser.y scanner.l main.c AST.cpp Scope.cpp
	bison -v -d parser.y 
	flex -o lex.yy.c scanner.l
	g++ -c lex.yy.c parser.tab.c AST.cpp Scope.cpp
	g++ lex.yy.c parser.tab.c AST.cpp Scope.cpp main.c -o etapa4 -lfl

clean:
	rm -f *.tab.c *.tab.h *.yy.c *.o *.output etapa4
