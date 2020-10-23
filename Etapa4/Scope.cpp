#include "Scope.hpp"

std::list<Scope *> *scopeStack;

// Create all structs

Scope* CreateNewScope(char* scopeName)
{
    Scope *scope = (Scope *)malloc(sizeof(Scope));
    scope->scopeName = scopeName;
    scope->symbolTable = std::map<char *, SymbolTableEntry *>();
     
    return scope;
}

SymbolTableEntry* CreateSymbolTableEntry(SymbolType symbolType, int line, TableEntryNature entryNature, std::list<FuncArgument *> *funcArguments, int vectorSize)
{
    SymbolTableEntry *symbolTableEntry = (SymbolTableEntry *)malloc(sizeof(SymbolTableEntry));

    symbolTableEntry->line = line;
    symbolTableEntry->vectorSize = vectorSize;          // if not a vector, vectorSize == 0
    symbolTableEntry->funcArguments = funcArguments;    // if not a function, funcArguments = NULL
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

    if(entryNature == TABLE_NATURE_VEC) symbolTableEntry->size *= vectorSize;

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
    std::map<char *, SymbolTableEntry *>::iterator it;

    for(it = scope->symbolTable.begin(); it != scope->symbolTable.end(); ++it)
    {
        free(it->first);
        DestroySymbolTableEntry(it->second);
    }

    scope->symbolTable.clear();
    free(scope->scopeName);

    free(scope);
    return;
}

void DestroySymbolTableEntry(SymbolTableEntry *symbolTableEntry)
{

    if(symbolTableEntry->funcArguments != NULL)
    {    
        while(!symbolTableEntry->funcArguments->empty())
        {
            DestroyFuncArgument(symbolTableEntry->funcArguments->back());
            symbolTableEntry->funcArguments->pop_back();
        }
    }
    free(symbolTableEntry);
    return;
}

void DestroyFuncArgument(FuncArgument *funcArgument)
{
    free(funcArgument->argName);
    free(funcArgument);
    return;
}

// Stack management

void CreateStack()
{
    scopeStack = new std::list<Scope *>;
}

void DestroyStack()
{
    while(!scopeStack->empty())
    {
        DestroyScope(scopeStack->back());
        scopeStack->pop_back();
    }
}


// Auxiliary functions

bool SymbolIsInSymbolTable(char *symbol, Scope *scope)
{
    std::map<char *, SymbolTableEntry *>::iterator it;

    it = scope->symbolTable.find(symbol);
    return(it != scope->symbolTable.end());
}

SymbolTableEntry* GetFirstOccourence(char *symbol)
{
    bool found = false;
    SymbolTableEntry* entryToReturn = NULL;
    std::list<Scope *>::iterator it = scopeStack->end();
    
    while(it != scopeStack->begin() || found)
    {
        if(SymbolIsInSymbolTable(symbol, *it))
        {
            entryToReturn = (*it)->symbolTable[symbol];
            found = true;
        }
    }

    return entryToReturn;
}

SymbolType LiteralTypeToSymbolType(LiteralType type)
{
    switch(type)
    {
        case LITERAL_TYPE_INTEGER: return SYMBOL_TYPE_INTEGER;
        case LITERAL_TYPE_FLOAT:   return SYMBOL_TYPE_FLOAT;
        case LITERAL_TYPE_CHAR:    return SYMBOL_TYPE_CHAR;
        case LITERAL_TYPE_BOOL:    return SYMBOL_TYPE_BOOL;
        case LITERAL_TYPE_STRING:  return SYMBOL_TYPE_STRING;
        default:                   return SYMBOL_TYPE_INDEF;
    }
}

SymbolType IntToSymbolType(int type)
{
    switch(type)
    {
        case 1:     return SYMBOL_TYPE_INTEGER;
        case 2:     return SYMBOL_TYPE_FLOAT;
        case 3:     return SYMBOL_TYPE_CHAR;
        case 4:     return SYMBOL_TYPE_BOOL;
        case 5:     return SYMBOL_TYPE_STRING;
        default:    return SYMBOL_TYPE_INDEF;
    }
}

SymbolType NodeTypeToSymbolType(NodeType type)
{
    switch(type)
    {
        case NODE_TYPE_INT:     return SYMBOL_TYPE_INTEGER;
        case NODE_TYPE_FLOAT:   return SYMBOL_TYPE_FLOAT;
        case NODE_TYPE_CHAR:    return SYMBOL_TYPE_CHAR;
        case NODE_TYPE_BOOL:    return SYMBOL_TYPE_BOOL;
        case NODE_TYPE_STRING:  return SYMBOL_TYPE_STRING;
        default:                return SYMBOL_TYPE_INDEF;
    }
}