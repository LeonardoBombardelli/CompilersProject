#include "../include/Scope.hpp"

std::list<Scope *> *scopeStack;

// Create all structs

Scope* CreateNewScope(char* scopeName, int desloc)
{
    Scope *scope = (Scope *)malloc(sizeof(Scope));
    scope->scopeName = scopeName;
    scope->symbolTable = new std::map<std::string, SymbolTableEntry *>;
    scope->currentDesloc = desloc;
     
    return scope;
}

SymbolTableEntry* CreateSymbolTableEntry(SymbolType symbolType, int line, TableEntryNature entryNature, 
                                        std::list<FuncArgument *> *funcArguments, int vectorSize, int desloc)
{
    SymbolTableEntry *symbolTableEntry = (SymbolTableEntry *)malloc(sizeof(SymbolTableEntry));

    symbolTableEntry->line = line;
    symbolTableEntry->vectorSize = vectorSize;          // if not a vector, vectorSize == 0
    symbolTableEntry->funcArguments = funcArguments;    // if not a function, funcArguments = NULL
    symbolTableEntry->entryNature = entryNature;
    symbolTableEntry->size = SizeFromSymbolType(symbolType);
    symbolTableEntry->symbolType = symbolType;
    symbolTableEntry->desloc = desloc;
    
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
    std::map<std::string, SymbolTableEntry *>::iterator it;

    for(it = scope->symbolTable->begin(); it != scope->symbolTable->end(); ++it)
    {
        DestroySymbolTableEntry(it->second);
    }

    scope->symbolTable->clear();
    delete scope->symbolTable;

    if(scope->scopeName != NULL)
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
        delete symbolTableEntry->funcArguments;
    }
    free(symbolTableEntry);
    return;
}

void DestroyFuncArgument(FuncArgument *funcArgument)
{
    if (funcArgument->argName != NULL) free(funcArgument->argName);
    free(funcArgument);
    return;
}

// Stack management

void CreateStack()
{
    scopeStack = new std::list<Scope *>;
    scopeStack->push_back(CreateNewScope(NULL, 0));
}

void DestroyStack()
{
    while(!scopeStack->empty())
    {
        DestroyScope(scopeStack->back());
        scopeStack->pop_back();
    }
    delete scopeStack;
}


// Auxiliary functions

bool SymbolIsInSymbolTable(char *symbol, Scope *scope)
{
    std::map<std::string, SymbolTableEntry *>::iterator it = scope->symbolTable->begin();

    while(it != scope->symbolTable->end())
    {
        if(std::string(symbol) == it->first)
            return true;
        ++it;
    }

    return false;
}

SymbolTableEntry* GetFirstOccurrence(char *symbol)
{
    bool found = false;
    SymbolTableEntry* entryToReturn = NULL;
    std::list<Scope *>::reverse_iterator it = scopeStack->rbegin();
    
    while(it != scopeStack->rend() && !found)
    {
        if(SymbolIsInSymbolTable(symbol, *it))
        {
            entryToReturn = (*(*it)->symbolTable)[std::string(symbol)];
            found = true;
        }
        ++it;
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

NodeType SymbolTypeToNodeType(SymbolType type)
{
    switch(type)
    {
        case SYMBOL_TYPE_INTEGER: return NODE_TYPE_INT;
        case SYMBOL_TYPE_FLOAT:   return NODE_TYPE_FLOAT;
        case SYMBOL_TYPE_CHAR:    return NODE_TYPE_CHAR;
        case SYMBOL_TYPE_BOOL:    return NODE_TYPE_BOOL;
        case SYMBOL_TYPE_STRING:  return NODE_TYPE_STRING;
        default:                  return NODE_TYPE_INDEF;
    }
}

bool ImplicitConversionPossible(SymbolType symbolType, SymbolType symbolType2)
{
    switch (symbolType)
    {
    case SYMBOL_TYPE_INTEGER:
    case SYMBOL_TYPE_FLOAT:
    case SYMBOL_TYPE_BOOL:
        if(symbolType2 == SYMBOL_TYPE_INTEGER || 
        symbolType2 == SYMBOL_TYPE_FLOAT ||
        symbolType2 == SYMBOL_TYPE_BOOL)
            return true;

        else return false;
        break;
    case SYMBOL_TYPE_CHAR:
        if(symbolType2 == SYMBOL_TYPE_CHAR) return true;
        else return false;
    
    case SYMBOL_TYPE_STRING:
        if(symbolType2 == SYMBOL_TYPE_STRING) return true;
        else return false;

    default:
        return false;
        break;
    }
}

int SizeFromSymbolType(SymbolType type)
{
    switch (type)
    {
    case SYMBOL_TYPE_INTEGER:   return 4;
    case SYMBOL_TYPE_FLOAT:     return 8;
    case SYMBOL_TYPE_CHAR:      return 1;
    case SYMBOL_TYPE_BOOL:      return 1;
    case SYMBOL_TYPE_STRING:    return -1;
    default:                    return 0;
    }
}