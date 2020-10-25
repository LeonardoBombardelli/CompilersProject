etapa4: parser.y scanner.l main.c src/AST.cpp src/Scope.cpp
	if [ -d build ]; then rm -r build; fi
	mkdir build
	bison -v -d parser.y -b build/parser
	flex -o build/lex.yy.c scanner.l
	g++ build/*.c src/*.cpp main.c -o etapa4 -lfl

clean:
	rm -rf build etapa4
