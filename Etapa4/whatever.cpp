#include <iostream>
#include <map>
#include "Scope.hpp"

int main ()
{
    char* test = (char*) malloc(sizeof(char *) * 5);

    char* test2 = (char*) malloc(sizeof(char *) * 5);

    Scope *a = CreateNewScope(test);

    a->symbolTable[test2] = CreateSymbolTableEntry(SYMBOL_TYPE_FLOAT, 5, TABLE_NATURE_VAR, NULL, 5);

    DestroyScope(a);
    return 0;
}