#include "Scope.hpp"


// Create all structs

Scope* CreateNewScope(char* scopeName)
{
    Scope *scope = (Scope *)malloc(sizeof(Scope));
    scope->scopeName = scopeName;
    scope->symbolTable = std::map<char *, SymbolTableEntry *>();
     
    return scope;
}

SymbolTableEntry* CreateSymbolTableEntry(SymbolType symbolType, int line, TableEntryNature entryNature, std::list<FuncArgument> *funcArguments, int vectorSize)
{
    SymbolTableEntry *symbolTableEntry = (SymbolTableEntry *)malloc(sizeof(SymbolTableEntry));

    symbolTableEntry->line = line;
    symbolTableEntry->vectorSize = vectorSize;      // If vectorSize = 0, it's not a vector
    symbolTableEntry->funcArguments = funcArguments;
    symbolTableEntry->entryNature = entryNature;
    symbolTableEntry->symbolType = symbolType;
    
    switch (symbolType)
    {
    case SYMBOL_TYPE_INTEGER:
        symbolTableEntry->size = 4;
        break;
    case SYMBOL_TYPE_FLOAT:
        symbolTableEntry->size = 8;
        break;
    case SYMBOL_TYPE_CHAR:
    case SYMBOL_TYPE_BOOL:
        symbolTableEntry->size = 1;
        break;
    case SYMBOL_TYPE_STRING:
        symbolTableEntry->size = 0;
        break;
    default:
        symbolTableEntry->size = 0;
        break;
    }

    if(vectorSize != 0) symbolTableEntry->size *= vectorSize;

    return symbolTableEntry;
}

FuncArgument* CreateFuncArgument(char* argName, SymbolType type)
{
    FuncArgument *funcArgument = (FuncArgument *)malloc(sizeof(FuncArgument));
    funcArgument->argName = argName;
    funcArgument->type = type;

    return funcArgument;
}

// Deletes all structs

void DestroyScope(Scope *scope)
{
    free(scope->scopeName);
    return;
}

void DestroySymbolTableEntry(SymbolTableEntry *symbolTableEntry)
{
    return;
}

void DestroyFuncArgument(FuncArgument *funcArgument)
{
    return;
}

// Access a symbolTableEntry

SymbolTableEntry* GetSymbolTableEntry(Scope *scope, char* symbol)
{
    return NULL;
}

// Auxiliary functions

bool SymbolIsInSymbolTable(char *symbol, Scope *scope)
{
    std::map<char *, SymbolTableEntry *>::iterator it;

    it = scope->symbolTable.find(symbol);
    return(it != scope->symbolTable.end());
}

