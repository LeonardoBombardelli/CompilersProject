etapa2: scanner.l main.c
	bison -d parser.y 
	flex -o lex.yy.c scanner.l
	gcc -c lex.yy.c parser.tab.c
	gcc lex.yy.c parser.tab.c main.c -o etapa2 -lfl

clean:
	rm -f *.tab.c *.tab.h *.yy.c *.o etapa2

# temp option to allow debugging of lexical analyser
lexical: scanner.l ../Etapa1/main.c
	cp scanner.l tmpscanner.l
	sed -i -e "s/parser.tab.h/..\/Etapa1\/tokens.h/" tmpscanner.l
	flex -o lex.yy.c tmpscanner.l
	gcc ../Etapa1/main.c lex.yy.c -o lexical -lfl

cleanlexical:
	rm -f tmpscanner.l lexical
