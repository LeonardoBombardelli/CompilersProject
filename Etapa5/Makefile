etapa5: parser.y scanner.l main.c src/*.cpp
	if [ -d build ]; then rm -r build; fi
	mkdir build
	bison -v -d parser.y -b build/parser
	flex -o build/lex.yy.c scanner.l
	g++ -g -ggdb3 build/*.c src/*.cpp main.c -o etapa5 -lfl

clean:
	rm -rf build etapa5

redo: clean etapa5