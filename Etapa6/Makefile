#   C-like Language Compiler's project Makefile
#   
#   Utilization example:
#       make <TARGET> ["DEBUG=true"]
#   
#   @param TARGET
#       Can be any of the following:
#       all - builds the project (DEFAULT TARGET)
#       clean - cleans up binary and byproducts of the compilation
#       redo - cleans up and then builds
#   
#   @param "DEBUG=true"
#       When present, the build will happen in debug mode.
#   
#   @authors
#       Artur Waquil Campana
#       Leonardo Boaventura Bombardelli

FLEXLIB := -lfl

OUT_DIR := build
SRC_DIR := src

TARGET_EXE := etapa6

DEBUG :=
DEBUGF := $(if $(DEBUG),-g -ggdb3)

all: parser.y scanner.l main.c $(SRC_DIR)/*.cpp
	mkdir $(OUT_DIR)
	bison -v -d parser.y -b $(OUT_DIR)/parser
	flex -o $(OUT_DIR)/lex.yy.c scanner.l
	g++ $(DEBUGF) $(OUT_DIR)/*.c $(SRC_DIR)/*.cpp main.c -o $(TARGET_EXE) $(FLEXLIB)

clean:
	rm -rf $(OUT_DIR) $(TARGET_EXE)

redo: clean all