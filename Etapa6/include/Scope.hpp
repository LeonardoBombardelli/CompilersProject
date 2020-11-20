#ifndef SCOPE_H
#define SCOPE_H

#include <cstring>
#include <cstdlib>
#include "lexicalvalue.hpp"
#include "errors.hpp"
#include "AST.hpp"

#include <map>
#include <list>

typedef enum
{
    TABLE_NATURE_LIT    ,
    TABLE_NATURE_VAR    ,
    TABLE_NATURE_VEC    ,
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
    int desloc;

} SymbolTableEntry;


typedef struct scope
{
    std::map<std::string, SymbolTableEntry *> *symbolTable;
    char* scopeName;
    int currentDesloc;

} Scope;

// Global stack

extern std::list<Scope *> *scopeStack;

// Create all structs

Scope* CreateNewScope(char* scopeName, int desloc);
SymbolTableEntry* CreateSymbolTableEntry(SymbolType symbolType, int line, TableEntryNature entryNature, 
                                        std::list<FuncArgument *> *funcArguments, int vectorSize, int desloc);
FuncArgument* CreateFuncArgument(char* argName, SymbolType type);


// Deletes all structs

void DestroyScope(Scope *scope);
void DestroySymbolTableEntry(SymbolTableEntry *symbolTableEntry);
void DestroyFuncArgument(FuncArgument *funcArgument);

// Stack management

void CreateStack();
void DestroyStack();


// Auxiliary functions

bool SymbolIsInSymbolTable(char *symbol, Scope *scope);
SymbolTableEntry* GetFirstOccurrence(char *symbol);


// aux
SymbolType LiteralTypeToSymbolType(LiteralType type);
SymbolType IntToSymbolType(int type);
SymbolType NodeTypeToSymbolType(NodeType type);
NodeType SymbolTypeToNodeType(SymbolType type);
bool ImplicitConversionPossible(SymbolType symbolType, SymbolType symbolType2);
int SizeFromSymbolType(SymbolType type);

#endif