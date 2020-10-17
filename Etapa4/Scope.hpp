#include <cstring>
#include "lexicalvalue.hpp"

#include <map>
#include <list>

typedef enum
{
    TABLE_NATURE_LIT    ,
    TABLE_NATURE_VAR    ,
    TABLE_NATURE_FUNC   

} TableEntryNature;

typedef enum
{
    SYMBOL_TYPE_INTEGER ,
    SYMBOL_TYPE_FLOAT   ,
    SYMBOL_TYPE_CHAR    ,
    SYMBOL_TYPE_BOOL    ,
    SYMBOL_TYPE_STRING  ,
    SYMBOL_TYPE_INDEF

} SymbolType;

typedef struct funcArgument
{
    char* argName;
    SymbolType type;
} FuncArgument;

typedef struct symbolTableEntry
{
    int line;
    TableEntryNature entryNature;
    SymbolType symbolType;
    int size;
    std::list<FuncArgument *> *funcArguments;
    int vectorSize;

} SymbolTableEntry;


typedef struct scope
{
    std::map<char *, SymbolTableEntry *> symbolTable;
    char* scopeName;

} Scope;

// Create all structs

Scope* CreateNewScope(char* scopeName);
SymbolTableEntry* CreateSymbolTableEntry(SymbolType symbolType, int line, TableEntryNature entryNature, std::list<FuncArgument *> *funcArguments, int vectorSize);
FuncArgument* CreateFuncArgument(char* argName, SymbolType type);

// Deletes all structs

void DestroyScope(Scope *scope);
void DestroySymbolTableEntry(SymbolTableEntry *symbolTableEntry);
void DestroyFuncArgument(FuncArgument *funcArgument);

// Access a symbolTableEntry

SymbolTableEntry* GetSymbolTableEntry(Scope *scope, char* symbol);

// Auxiliary functions

bool SymbolIsInSymbolTable(char *symbol, Scope *scope);
