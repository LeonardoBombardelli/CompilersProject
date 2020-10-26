%{
    #include <cstdio>
    #include <map>
    #include "../include/AST.hpp"
    #include "../include/Scope.hpp"

    extern "C" int yylex();

    extern int yylineno;
    extern void *arvore;
    int yylex(void);
    void yyerror (char const *s);

    void throw_error(int err_code, int line, char* identifier, TableEntryNature nature);
    NodeType InferTypePlus(NodeType t1, NodeType t2, int line);
    NodeType InferTypeTernary(NodeType t1, NodeType t2, int line);
    NodeType InferTypeEqNeq(NodeType t1, NodeType t2, int line);
    NodeType InferType(NodeType t1, NodeType t2, int line);
    Node* last_command_of_chain(Node* n);

    char* auxScopeName = NULL;
    SymbolType auxCurrentFuncType = SYMBOL_TYPE_INDEF;
    char* auxLiteral = (char*) malloc(500);
    int auxCurrentFuncLine = 0;

    int stringConcatSize = 0;

    std::map<ValorLexico*, SymbolType> *auxInitTypeMap = new std::map<ValorLexico*, SymbolType>; // aux map to check type when initializing vars on declaration

    std::map<std::string, SymbolTableEntry*> *tempVarMap = new std::map<std::string, SymbolTableEntry*>;     // reusable map of vars
    std::list<FuncArgument *> *tempFuncArgList = new std::list<FuncArgument *>;                  // reusable list of function arguments
%}

%union 
{
    struct valorLexico* valor_lexico;
    struct node* node;
    int symbol_type; /* int later converted to SymbolType */
}

%token<valor_lexico> TK_PR_INT
%token<valor_lexico> TK_PR_FLOAT
%token<valor_lexico> TK_PR_BOOL
%token<valor_lexico> TK_PR_CHAR
%token<valor_lexico> TK_PR_STRING
%token<valor_lexico> TK_PR_IF
%token<valor_lexico> TK_PR_THEN
%token<valor_lexico> TK_PR_ELSE
%token<valor_lexico> TK_PR_WHILE
%token<valor_lexico> TK_PR_DO
%token<valor_lexico> TK_PR_INPUT
%token<valor_lexico> TK_PR_OUTPUT
%token<valor_lexico> TK_PR_RETURN
%token<valor_lexico> TK_PR_CONST
%token<valor_lexico> TK_PR_STATIC
%token<valor_lexico> TK_PR_FOREACH
%token<valor_lexico> TK_PR_FOR
%token<valor_lexico> TK_PR_SWITCH
%token<valor_lexico> TK_PR_CASE
%token<valor_lexico> TK_PR_BREAK
%token<valor_lexico> TK_PR_CONTINUE
%token<valor_lexico> TK_PR_CLASS
%token<valor_lexico> TK_PR_PRIVATE
%token<valor_lexico> TK_PR_PUBLIC
%token<valor_lexico> TK_PR_PROTECTED
%token<valor_lexico> TK_PR_END
%token<valor_lexico> TK_PR_DEFAULT
%token<valor_lexico> TK_OC_LE
%token<valor_lexico> TK_OC_GE
%token<valor_lexico> TK_OC_EQ
%token<valor_lexico> TK_OC_NE
%token<valor_lexico> TK_OC_AND
%token<valor_lexico> TK_OC_OR
%token<valor_lexico> TK_OC_SL
%token<valor_lexico> TK_OC_SR
%token<valor_lexico> TK_OC_FORWARD_PIPE
%token<valor_lexico> TK_OC_BASH_PIPE
%token<valor_lexico> TK_LIT_INT
%token<valor_lexico> TK_LIT_FLOAT
%token<valor_lexico> TK_LIT_FALSE
%token<valor_lexico> TK_LIT_TRUE
%token<valor_lexico> TK_LIT_CHAR
%token<valor_lexico> TK_LIT_STRING
%token<valor_lexico> TK_IDENTIFICADOR
%token<valor_lexico> TOKEN_ERRO
%token<valor_lexico> ','
%token<valor_lexico> ';'
%token<valor_lexico> ':'
%token<valor_lexico> '('
%token<valor_lexico> ')'
%token<valor_lexico> '['
%token<valor_lexico> ']'
%token<valor_lexico> '{'
%token<valor_lexico> '}'
%token<valor_lexico> '+'
%token<valor_lexico> '-'
%token<valor_lexico> '|'
%token<valor_lexico> '*'
%token<valor_lexico> '/'
%token<valor_lexico> '<'
%token<valor_lexico> '>'
%token<valor_lexico> '='
%token<valor_lexico> '!'
%token<valor_lexico> '&'
%token<valor_lexico> '%'
%token<valor_lexico> '#'
%token<valor_lexico> '^'
%token<valor_lexico> '.'
%token<valor_lexico> '$'
%token<valor_lexico> '?'

%type<node> programa
%type<node> init_stack
%type<node> destroy_stack
%type<node> program_list
%type<node> maybe_const
%type<node> maybe_static
%type<symbol_type> type
%type<node> literal
%type<node> global_var
%type<node> global_var_declaration
%type<node> global_var_list
%type<node> func_definition
%type<node> func_header
%type<node> func_header_list
%type<node> func_header_list_iterator
%type<node> simple_command
%type<node> command_block
%type<node> real_command_block
%type<node> cmd_block_init_scope
%type<node> cmd_block_destroy_scope
%type<node> sequence_simple_command
%type<node> local_var_declaration
%type<node> local_var_list
%type<node> local_var_list_iterator
%type<node> local_var
%type<node> var_access
%type<node> attribution_command
%type<node> io_command
%type<node> call_func_command
%type<node> func_parameters_list
%type<node> func_parameters_list_iterator
%type<node> shift_command
%type<node> return_command
%type<node> flux_control_command
%type<node> conditional_flux_control
%type<node> maybe_else
%type<node> for_flux_control
%type<node> while_flux_control
%type<node> expression
%type<node> exp_log_or 
%type<node> exp_log_and
%type<node> exp_bit_or 
%type<node> exp_bit_and
%type<node> exp_relat_1
%type<node> exp_relat_2
%type<node> exp_sum
%type<node> exp_mult
%type<node> exp_pow
%type<node> unary_exp
%type<valor_lexico> unary_op
%type<node> operand

%%
programa: 
    init_stack program_list destroy_stack { $$ = $2; arvore = $$; };
program_list: 
    global_var_declaration program_list   { $$ = $2; /* ignore global vars in AST */    } |
    func_definition program_list          { $1->sequenceNode = $2; $$ = $1;             } |
    %empty                                { $$ = NULL;                                  };

init_stack:
    %empty { CreateStack(); $$ = NULL; }

destroy_stack:
    %empty { DestroyStack(); 
    free(auxLiteral); 
    free(auxScopeName);
    delete auxInitTypeMap;
    delete tempVarMap;
    delete tempFuncArgList;
    
    $$ = NULL; }


maybe_const: 
    %empty        { $$ = NULL; } |
    TK_PR_CONST   { $$ = NULL; };
maybe_static: 
    %empty        { $$ = NULL; } |
    TK_PR_STATIC  { $$ = NULL; };

type:
    TK_PR_INT     { $$ = 1; /* int later converted to SymbolType */ } |
    TK_PR_FLOAT   { $$ = 2;                                         } |
    TK_PR_CHAR    { $$ = 3;                                         } |
    TK_PR_BOOL    { $$ = 4;                                         } |
    TK_PR_STRING  { $$ = 5;                                         };
literal: 
    TK_LIT_INT    {
        $$ = create_node_literal($1, NODE_TYPE_INT);

        // set auxLiteral to be the lexeme
        memset(auxLiteral, 0, 500);
        sprintf(auxLiteral, "%d", $1->tokenValue.integer);

        SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_INTEGER, $1->line_number, TABLE_NATURE_LIT, NULL, 0);

        if (SymbolIsInSymbolTable(auxLiteral, scopeStack->back()))
            DestroySymbolTableEntry((*scopeStack->back()->symbolTable)[std::string(auxLiteral)]);

        (*scopeStack->back()->symbolTable)[std::string(auxLiteral)] = ste;
    } |
    TK_LIT_FLOAT  {
        $$ = create_node_literal($1, NODE_TYPE_FLOAT); 

        // set auxLiteral to be the lexeme
        memset(auxLiteral, 0, 500);
        sprintf(auxLiteral, "%f", $1->tokenValue.floating);

        SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_FLOAT, $1->line_number, TABLE_NATURE_LIT, NULL, 0);

        if (SymbolIsInSymbolTable(auxLiteral, scopeStack->back()))
            DestroySymbolTableEntry((*scopeStack->back()->symbolTable)[std::string(auxLiteral)]);

        (*scopeStack->back()->symbolTable)[std::string(auxLiteral)] = ste;
    } |
    TK_LIT_FALSE  {
        $$ = create_node_literal($1, NODE_TYPE_BOOL);  

        // set auxLiteral to be the lexeme
        memset(auxLiteral, 0, 500);
        sprintf(auxLiteral, "false");

        SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_BOOL, $1->line_number, TABLE_NATURE_LIT, NULL, 0);

        if (SymbolIsInSymbolTable(auxLiteral, scopeStack->back()))
            DestroySymbolTableEntry((*scopeStack->back()->symbolTable)[std::string(auxLiteral)]);

        (*scopeStack->back()->symbolTable)[std::string(auxLiteral)] = ste;
    } |
    TK_LIT_TRUE   {
        $$ = create_node_literal($1, NODE_TYPE_BOOL);  

        // set auxLiteral to be the lexeme
        memset(auxLiteral, 0, 500);
        sprintf(auxLiteral, "true");

        SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_BOOL, $1->line_number, TABLE_NATURE_LIT, NULL, 0);

        if (SymbolIsInSymbolTable(auxLiteral, scopeStack->back()))
            DestroySymbolTableEntry((*scopeStack->back()->symbolTable)[std::string(auxLiteral)]);

        (*scopeStack->back()->symbolTable)[std::string(auxLiteral)] = ste;
    } |
    TK_LIT_CHAR   {
        $$ = create_node_literal($1, NODE_TYPE_CHAR);  

        // set auxLiteral to be the lexeme
        memset(auxLiteral, 0, 500);
        sprintf(auxLiteral, "\'%c\'", $1->tokenValue.character);

        SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_CHAR, $1->line_number, TABLE_NATURE_LIT, NULL, 0);

        if (SymbolIsInSymbolTable(auxLiteral, scopeStack->back()))
            DestroySymbolTableEntry((*scopeStack->back()->symbolTable)[std::string(auxLiteral)]);

        (*scopeStack->back()->symbolTable)[std::string(auxLiteral)] = ste;
    } |
    TK_LIT_STRING {
        $$ = create_node_literal($1, NODE_TYPE_STRING);

        // set auxLiteral to be the lexeme
        memset(auxLiteral, 0, 500);
        sprintf(auxLiteral, "\"%s\"", $1->tokenValue.string);

        SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_STRING, $1->line_number, TABLE_NATURE_LIT, NULL, 0);

        if (SymbolIsInSymbolTable(auxLiteral, scopeStack->back()))
            DestroySymbolTableEntry((*scopeStack->back()->symbolTable)[std::string(auxLiteral)]);

        (*scopeStack->back()->symbolTable)[std::string(auxLiteral)] = ste;
    };

global_var: 
    TK_IDENTIFICADOR {
        // add var to symbol table if not already there
        if (!SymbolIsInSymbolTable($1->tokenValue.string, scopeStack->back()))
        {
            SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_INDEF, $1->line_number, TABLE_NATURE_VAR, NULL, 0);
            char* id = $1->tokenValue.string;
            (*tempVarMap)[std::string(id)] = ste;
        }
        else throw_error(ERR_DECLARED, $1->line_number, $1->tokenValue.string, TABLE_NATURE_VAR);

        // ignore global vars in AST
        $$ = NULL; 
        FreeValorLexico($1);
        // TODO: shall we keep freeing the lexical value? We're using it now to add the variable to the symbol table
    } |
    TK_IDENTIFICADOR '[' TK_LIT_INT ']' {
        // add var to symbol table if not already there
        if (!SymbolIsInSymbolTable($1->tokenValue.string, scopeStack->back()))
        {
            SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_INDEF, $1->line_number, TABLE_NATURE_VEC, NULL, $3->tokenValue.integer);
            char* id = $1->tokenValue.string;
            (*tempVarMap)[std::string(id)] = ste;
        }
        else throw_error(ERR_DECLARED, $1->line_number, $1->tokenValue.string, TABLE_NATURE_VAR);

        // ignore global vars in AST
        $$ = NULL; 
        FreeValorLexico($1); FreeValorLexico($2); FreeValorLexico($3); FreeValorLexico($4);
        // TODO: shall we keep freeing the lexical value? We're using it now to add the variable to the symbol table
    };
global_var_declaration: 
    maybe_static type global_var_list ';' {

        // set type to all vars of list, and insert them in table
        std::map<std::string, SymbolTableEntry*>::iterator it;
        for(it = tempVarMap->begin(); it != tempVarMap->end(); ++it)
        {
            it->second->symbolType = IntToSymbolType($2);
            (*scopeStack->back()->symbolTable)[it->first] = it->second;
        }

        // free temp var map
        delete tempVarMap;
        tempVarMap = new std::map<std::string, SymbolTableEntry*>;

        $$ = NULL; 
        FreeValorLexico($4); 
    };
global_var_list: 
    global_var ',' global_var_list        { $$ = NULL; FreeValorLexico($2); } |
    global_var                            { $$ = NULL; };


func_definition:
    func_header command_block {
        $1->n_function_declaration.firstCommand = $2;
        $$ = $1;
    };

func_header:
    maybe_static type TK_IDENTIFICADOR '(' func_header_list ')' {

        // add function to symbol table if not already there
        if (!SymbolIsInSymbolTable($3->tokenValue.string, scopeStack->back()))
        {
            std::list<FuncArgument*> *deepCopy = new std::list<FuncArgument*>;
            std::list<FuncArgument*>::iterator it = tempFuncArgList->begin();

            while(it != tempFuncArgList->end())
            {
                deepCopy->push_back(*it);
                ++it;
            }

            // create entry and add it to scope
            SymbolTableEntry* ste = CreateSymbolTableEntry(IntToSymbolType($2), $3->line_number, TABLE_NATURE_FUNC, deepCopy, 0);
            char* id = $3->tokenValue.string;
            (*scopeStack->back()->symbolTable)[std::string(id)] = ste;
        }
        else throw_error(ERR_DECLARED, $3->line_number, $3->tokenValue.string, TABLE_NATURE_FUNC);

        // update aux vars with new scope name, current function's type and current function's line
        if(auxScopeName != NULL) free(auxScopeName);
        auxScopeName = strdup($3->tokenValue.string);
        auxCurrentFuncType = IntToSymbolType($2);
        auxCurrentFuncLine = $3->line_number;

        $$ = create_node_function_declaration($3, NULL);
        FreeValorLexico($4); FreeValorLexico($6);
    };
func_header_list:
    %empty                                                          { $$ = NULL; } |
    maybe_const type TK_IDENTIFICADOR func_header_list_iterator     {

        // create funcargument and add it to global list
        char* id = strdup($3->tokenValue.string);
        FuncArgument* fa = CreateFuncArgument(id, IntToSymbolType($2));
        tempFuncArgList->push_back(fa);

        $$ = NULL;
        FreeValorLexico($3);
    };
func_header_list_iterator: 
    %empty                                                          { $$ = NULL; } |
    ',' maybe_const type TK_IDENTIFICADOR func_header_list_iterator {

        // create funcargument and add it to global list
        char* id = strdup($4->tokenValue.string);
        FuncArgument* fa = CreateFuncArgument(id, IntToSymbolType($3));
        tempFuncArgList->push_back(fa);

        $$ = NULL;
        FreeValorLexico($1); FreeValorLexico($4);
    };

simple_command: 
    command_block         { $$ = $1;                     } |
    local_var_declaration { $$ = $1;                     } |
    attribution_command   { $$ = $1;                     } |
    io_command            { $$ = $1;                     } |
    call_func_command     { $$ = $1;                     } |
    shift_command         { $$ = $1;                     } |
    return_command        { $$ = $1;                     } |
    TK_PR_BREAK           { $$ = create_node_break();    } |
    TK_PR_CONTINUE        { $$ = create_node_continue(); } |
    flux_control_command  { $$ = $1;                     };

command_block: 
    cmd_block_init_scope real_command_block cmd_block_destroy_scope { $$ = $2; }

cmd_block_init_scope:
    %empty {
        /* create new scope with current function's name and push it to scopeStack */
        Scope* newScope = CreateNewScope(strdup(auxScopeName));
        scopeStack->push_back(newScope);

        // add formal parameters to function's scope
        if (!tempFuncArgList->empty())
        {
            std::list<FuncArgument *>::iterator it = tempFuncArgList->begin();

            while (it != tempFuncArgList->end())
            {
                SymbolTableEntry* ste = CreateSymbolTableEntry((*it)->type, auxCurrentFuncLine, TABLE_NATURE_VAR, NULL, 0);
                (*scopeStack->back()->symbolTable)[std::string((*it)->argName)] = ste;
                ++it;
            }
        }

        // free temp func arg list
        delete tempFuncArgList;
        tempFuncArgList = new std::list<FuncArgument *>;

    }

cmd_block_destroy_scope:
    %empty {
        /* pop current scope from scopeStack and free its memory */
        Scope* currentScope = scopeStack->back();
        DestroyScope(currentScope);
        scopeStack->pop_back();
    }

real_command_block:
    '{' sequence_simple_command '}' { $$ = $2; FreeValorLexico($1); FreeValorLexico($3); };
sequence_simple_command: 
    %empty { $$ = NULL; } |
    simple_command ';' sequence_simple_command  { 
        if ($1 != NULL)
        {
            last_command_of_chain($1)->sequenceNode = $3;
            $$ = $1;
        }
        else
        {
            $$ = $3;
        }
        FreeValorLexico($2);
    };

local_var_declaration:
    maybe_static maybe_const type local_var_list {

        // check if all inits obey the declared type
        std::map<ValorLexico*, SymbolType>::iterator it2;
        for(it2 = auxInitTypeMap->begin(); it2 != auxInitTypeMap->end(); ++it2)
        {
            if (!ImplicitConversionPossible(it2->second, IntToSymbolType($3)))
                throw_error(ERR_WRONG_TYPE, it2->first->line_number, it2->first->tokenValue.string, TABLE_NATURE_VAR);
        }

        // set type to all vars of list, and insert them in table
        std::map<std::string, SymbolTableEntry*>::iterator it;
        for(it = tempVarMap->begin(); it != tempVarMap->end(); ++it)
        {
            it->second->symbolType = IntToSymbolType($3);

            switch (it->second->symbolType)
            {
            case SYMBOL_TYPE_INTEGER:
                it->second->size = 4;
                break;
            case SYMBOL_TYPE_FLOAT:
                it->second->size = 8;
                break;
            case SYMBOL_TYPE_CHAR:
            case SYMBOL_TYPE_BOOL:
                it->second->size = 1;
                break;
            case SYMBOL_TYPE_STRING:
                it->second->size = -1;
                break;
            default:
                it->second->size = 0;
                break;
            }

            (*scopeStack->back()->symbolTable)[it->first] = it->second;
        }

        // free temp var map and aux init type map
        delete tempVarMap;
        tempVarMap = new std::map<std::string, SymbolTableEntry*>;
        delete auxInitTypeMap;
        auxInitTypeMap = new std::map<ValorLexico*, SymbolType>;

        $$ = $4;
    };

local_var_list:
    local_var local_var_list_iterator {
        if ($1 != NULL)
        {
            $1->sequenceNode = $2;
            $$ = $1;
        }
        else
        {
            $$ = $2;
        }
    };

local_var_list_iterator:
    %empty                                  { $$ = NULL; } |
    ',' local_var local_var_list_iterator   { 
        if ($2 != NULL)
        {
            $2->sequenceNode = $3;
            $$ = $2;
        }
        else
        {
            $$ = $3;
        }
        FreeValorLexico($1);
    } ;

local_var: 
    TK_IDENTIFICADOR {
        // add var to symbol table if not already there
        if (!SymbolIsInSymbolTable($1->tokenValue.string, scopeStack->back()))
        {
            SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_INDEF, $1->line_number, TABLE_NATURE_VAR, NULL, 0);
            char* id = $1->tokenValue.string;
            (*tempVarMap)[std::string(id)] = ste;
        }
        else throw_error(ERR_DECLARED, $1->line_number, $1->tokenValue.string, TABLE_NATURE_VAR);

        // ignore unititialized var in AST
        $$ = NULL;
        FreeValorLexico($1);
    } |
    TK_IDENTIFICADOR TK_OC_LE literal {
        // add var to symbol table if not already there
        if (!SymbolIsInSymbolTable($1->tokenValue.string, scopeStack->back()))
        {
            SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_INDEF, $1->line_number, TABLE_NATURE_VAR, NULL, 0);
            
            // if literal is of type string, update ste's size accordingly
            if ($3->nodeType == NODE_TYPE_STRING)
                ste->size = (int) strlen($3->n_literal.literal->tokenValue.string);

            // add entry in aux map to check type of initialized vars
            (*auxInitTypeMap)[$1] = NodeTypeToSymbolType($3->nodeType);

            char* id = $1->tokenValue.string;
            (*tempVarMap)[std::string(id)] = ste;
        }
        else throw_error(ERR_DECLARED, $1->line_number, $1->tokenValue.string, TABLE_NATURE_VAR);

        // add var_init node to AST
        $$ = create_node_var_init(create_node_var_access($1, $3->nodeType), $3);
        FreeValorLexico($2);
    } |
    TK_IDENTIFICADOR TK_OC_LE TK_IDENTIFICADOR {
        // add var to symbol table if not already there
        if (!SymbolIsInSymbolTable($1->tokenValue.string, scopeStack->back()))
        {
            SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_INDEF, $1->line_number, TABLE_NATURE_VAR, NULL, 0);
            
            char* s3_name = $3->tokenValue.string;

            SymbolTableEntry* ste2 = GetFirstOccurrence(s3_name);
            // if var s3_name doesn't exist, throw ERR_UNDECLARED
            if (ste2 == NULL) 
                throw_error(ERR_UNDECLARED, $3->line_number, s3_name, TABLE_NATURE_VAR);
            // if s3_name is a function or a vector, throw ERR_FUNCTION or ERR_VECTOR
            if (ste2->entryNature == TABLE_NATURE_FUNC)
                throw_error(ERR_FUNCTION, $3->line_number, s3_name, TABLE_NATURE_FUNC);
            if (ste2->entryNature == TABLE_NATURE_VEC)
                throw_error(ERR_VECTOR, $3->line_number, s3_name, TABLE_NATURE_VEC);

            // if $3 is of type string, update ste's size accordingly
            if (ste2->symbolType == SYMBOL_TYPE_STRING)
                ste->size = ste2->size;

            // add entry in aux map to check type of initialized vars
            (*auxInitTypeMap)[$1] = ste2->symbolType;
            
            char* id = $1->tokenValue.string;
            (*tempVarMap)[std::string(id)] = ste;

            // add var_init node to AST
            $$ = create_node_var_init(create_node_var_access($1, SymbolTypeToNodeType(ste2->symbolType)),
                                      create_node_var_access($3, SymbolTypeToNodeType(ste2->symbolType)));
            FreeValorLexico($2);
        }
        else throw_error(ERR_DECLARED, $1->line_number, $1->tokenValue.string, TABLE_NATURE_VAR);

    };

var_access:
    TK_IDENTIFICADOR {
    
        char* id = $1->tokenValue.string;
        SymbolTableEntry* ste = GetFirstOccurrence(id);

        // check if var was declared
        if (ste == NULL)
            throw_error(ERR_UNDECLARED, $1->line_number, id, TABLE_NATURE_VAR);
        // check if symbol's nature is not function or vector
        if (ste->entryNature == TABLE_NATURE_FUNC)
            throw_error(ERR_FUNCTION, $1->line_number, id, TABLE_NATURE_FUNC);
        if (ste->entryNature == TABLE_NATURE_VEC)
            throw_error(ERR_VECTOR, $1->line_number, id, TABLE_NATURE_VEC);

        $$ = create_node_var_access($1, SymbolTypeToNodeType(ste->symbolType));
    } | 
    TK_IDENTIFICADOR '[' expression ']' {

        char* id = $1->tokenValue.string;
        SymbolTableEntry* ste = GetFirstOccurrence(id);

        // check if var was declared
        if (ste == NULL)
            throw_error(ERR_UNDECLARED, $1->line_number, id, TABLE_NATURE_VEC);
        // check if symbol's nature is not function or vector
        if (ste->entryNature == TABLE_NATURE_FUNC)
            throw_error(ERR_FUNCTION, $1->line_number, id, TABLE_NATURE_FUNC);
        if (ste->entryNature == TABLE_NATURE_VAR)
            throw_error(ERR_VARIABLE, $1->line_number, id, TABLE_NATURE_VAR);

        // check if expression is not of type string or char
        if ($3->nodeType == NODE_TYPE_STRING)
            throw_error(ERR_STRING_TO_X, $1->line_number, id, TABLE_NATURE_VEC);
        if ($3->nodeType == NODE_TYPE_CHAR)
            throw_error(ERR_CHAR_TO_X, $1->line_number, id, TABLE_NATURE_VEC);

        NodeType nt = SymbolTypeToNodeType(ste->symbolType);
        $$ = create_node_vector_access(create_node_var_access($1, nt), $3, nt);
        FreeValorLexico($2); FreeValorLexico($4);
    };

attribution_command:
    var_access '=' expression {

        if ($1->nodeCategory == NODE_VAR_ACCESS)
        {
            char* id = $1->n_var_access.identifier->tokenValue.string;
            SymbolTableEntry* ste = GetFirstOccurrence(id);

            // check if expression and var/vector have compatible types
            if ( !ImplicitConversionPossible(ste->symbolType, NodeTypeToSymbolType($3->nodeType)) )
                throw_error(ERR_WRONG_TYPE, $2->line_number, id, TABLE_NATURE_VAR);

            if(ste->symbolType == SYMBOL_TYPE_STRING)
            {
                if($3->nodeCategory == NODE_LITERAL)
                {
                    int literalSize = strlen($3->n_literal.literal->tokenValue.string);
                    if(ste->size == -1) ste->size = literalSize;
                    else if(ste->size < literalSize) throw_error(ERR_STRING_SIZE, $2->line_number, id, TABLE_NATURE_VAR);
                }
            
                if($3->nodeCategory == NODE_VAR_ACCESS)
                {
                    SymbolTableEntry* ste2 = GetFirstOccurrence($3->n_var_access.identifier->tokenValue.string);
                    if(ste->size == -1) ste->size = ste2->size;
                    else if(ste->size < ste2->size) throw_error(ERR_STRING_SIZE, $2->line_number, id, TABLE_NATURE_VAR);
                }

                if($3->nodeCategory == NODE_BINARY_OPERATION)
                {
                    if(ste->size == -1) ste->size = stringConcatSize;
                    else if (ste->size < stringConcatSize) throw_error(ERR_STRING_SIZE, $2->line_number, id, TABLE_NATURE_VAR);

                    stringConcatSize = 0;
                }
            }
        }
        else if ($1->nodeCategory == NODE_VECTOR_ACCESS)
        {
            char* id = $1->n_vector_access.var->n_var_access.identifier->tokenValue.string;
            SymbolTableEntry* ste = GetFirstOccurrence(id);

            // check if expression and var/vector have compatible types
            if ( !ImplicitConversionPossible(ste->symbolType, NodeTypeToSymbolType($3->nodeType)) )
                throw_error(ERR_WRONG_TYPE, $2->line_number, id, TABLE_NATURE_VEC);
        }

        $$ = create_node_var_attr($1, $3);
        FreeValorLexico($2);
    };

io_command: 
    TK_PR_INPUT TK_IDENTIFICADOR {

        char* id = $2->tokenValue.string;
        SymbolTableEntry* ste = GetFirstOccurrence(id);

        // check if var was declared
        if (ste == NULL)
            throw_error(ERR_UNDECLARED, $1->line_number, id, TABLE_NATURE_VAR);
        // check if symbol's nature is not function or vector
        if (ste->entryNature == TABLE_NATURE_FUNC)
            throw_error(ERR_FUNCTION, $1->line_number, id, TABLE_NATURE_FUNC);
        if (ste->entryNature == TABLE_NATURE_VEC)
            throw_error(ERR_VECTOR, $1->line_number, id, TABLE_NATURE_VEC);

        // check if id is of type int or float
        if (ste->symbolType != SYMBOL_TYPE_INTEGER && ste->symbolType != SYMBOL_TYPE_FLOAT)
            throw_error(ERR_WRONG_PAR_INPUT, $1->line_number, id, TABLE_NATURE_VAR);

        $$ = create_node_input(create_node_var_access($2, SymbolTypeToNodeType(ste->symbolType)));
    } | 
    TK_PR_OUTPUT TK_IDENTIFICADOR {

        char* id = $2->tokenValue.string;
        SymbolTableEntry* ste = GetFirstOccurrence(id);

        // check if var was declared
        if (ste == NULL)
            throw_error(ERR_UNDECLARED, $1->line_number, id, TABLE_NATURE_VAR);
        // check if symbol's nature is not function or vector
        if (ste->entryNature == TABLE_NATURE_FUNC)
            throw_error(ERR_FUNCTION, $1->line_number, id, TABLE_NATURE_FUNC);
        if (ste->entryNature == TABLE_NATURE_VEC)
            throw_error(ERR_VECTOR, $1->line_number, id, TABLE_NATURE_VEC);

        // check if id is of type int or float
        if (ste->symbolType != SYMBOL_TYPE_INTEGER && ste->symbolType != SYMBOL_TYPE_FLOAT)
            throw_error(ERR_WRONG_PAR_OUTPUT, $1->line_number, id, TABLE_NATURE_VAR);

        $$ = create_node_output(create_node_var_access($2, SymbolTypeToNodeType(ste->symbolType)));
    } | 
    TK_PR_OUTPUT literal {

        // check if id is of type int or float
        if ($2->nodeType != NODE_TYPE_INT && $2->nodeType != NODE_TYPE_FLOAT)
            throw_error(ERR_WRONG_PAR_OUTPUT, $1->line_number, NULL, TABLE_NATURE_VAR);

        $$ = create_node_output($2);
    } ;

call_func_command:
    TK_IDENTIFICADOR '(' func_parameters_list ')' {

        char* id = $1->tokenValue.string;
        SymbolTableEntry* ste = GetFirstOccurrence(id);

        if (ste == NULL)
            throw_error(ERR_UNDECLARED, $1->line_number, id, TABLE_NATURE_FUNC);

        if (ste->entryNature == TABLE_NATURE_VAR)
            throw_error(ERR_VARIABLE, $1->line_number, id, TABLE_NATURE_VAR);

        if (ste->entryNature == TABLE_NATURE_VEC)
            throw_error(ERR_VECTOR, $1->line_number, id, TABLE_NATURE_VEC);

        // if function is called with arguments
        if ($3 != NULL)
        {
            if (tempFuncArgList->size() > ste->funcArguments->size())
                throw_error(ERR_EXCESS_ARGS, $1->line_number, id, TABLE_NATURE_FUNC);

            if (tempFuncArgList->size() < ste->funcArguments->size())
                throw_error(ERR_MISSING_ARGS, $1->line_number, id, TABLE_NATURE_FUNC);

            // iterate through both lists comparing each argument's type
            std::list<FuncArgument*>::iterator it_formal_args = ste->funcArguments->begin();
            std::list<FuncArgument*>::iterator it_real_args = tempFuncArgList->begin();
            while (it_formal_args != ste->funcArguments->end() && it_real_args != tempFuncArgList->end())
            {
                if ( !ImplicitConversionPossible((*it_formal_args)->type, (*it_real_args)->type) )
                    throw_error(ERR_WRONG_TYPE_ARGS, $1->line_number, id, TABLE_NATURE_FUNC);

                DestroyFuncArgument(*it_real_args);   
                ++it_formal_args; ++it_real_args;
            }

            // free temp function argument list
            delete tempFuncArgList;
            tempFuncArgList = new std::list<FuncArgument*>;
        }
        // if function is called without arguments, check if it has formal params
        else if (ste->funcArguments != NULL) if(!ste->funcArguments->empty())
            throw_error(ERR_MISSING_ARGS, $1->line_number, id, TABLE_NATURE_FUNC);

        // get nodeType from function return type
        $$ = create_node_function_call($1, $3, SymbolTypeToNodeType(ste->symbolType));
        FreeValorLexico($2); FreeValorLexico($4);
    };
func_parameters_list: 
    %empty                                   { $$ = NULL; } |
    expression func_parameters_list_iterator {

        // add parameter to temp list
        FuncArgument* fa = CreateFuncArgument(NULL, NodeTypeToSymbolType($1->nodeType));
        tempFuncArgList->push_back(fa);

        $1->sequenceNode = $2;
        $$ = $1;
    };
func_parameters_list_iterator:
    %empty                                       { $$ = NULL; } |
    ',' expression func_parameters_list_iterator {

        // add parameter to temp list
        FuncArgument* fa = CreateFuncArgument(NULL, NodeTypeToSymbolType($2->nodeType));
        tempFuncArgList->push_back(fa);

        $2->sequenceNode = $3;
        $$ = $2;
        FreeValorLexico($1);
    };

shift_command:
    var_access TK_OC_SL TK_LIT_INT {

        // check if shift number greater than 16
        if ($3->tokenValue.integer > 16)
            throw_error(ERR_WRONG_PAR_SHIFT, $2->line_number, NULL, TABLE_NATURE_LIT);

        $$ = create_node_shift_left($1, create_node_literal($3, NODE_TYPE_INT));
        FreeValorLexico($2);
    } |
    var_access TK_OC_SR TK_LIT_INT {

        // check if shift number greater than 16
        if ($3->tokenValue.integer > 16)
            throw_error(ERR_WRONG_PAR_SHIFT, $2->line_number, NULL, TABLE_NATURE_LIT);

        $$ = create_node_shift_right($1, create_node_literal($3, NODE_TYPE_INT));
        FreeValorLexico($2);
    };

return_command:
    TK_PR_RETURN expression { 

        // check if expression has type different than current function's
        if ( !ImplicitConversionPossible( NodeTypeToSymbolType($2->nodeType), auxCurrentFuncType) )
            throw_error(ERR_WRONG_PAR_RETURN, $1->line_number, auxScopeName, TABLE_NATURE_FUNC);

        $$ = create_node_return($2); 
    
    };

flux_control_command: 
    conditional_flux_control { $$ = $1; } | 
    for_flux_control         { $$ = $1; } | 
    while_flux_control       { $$ = $1; };

conditional_flux_control: 
    TK_PR_IF '(' expression ')' command_block maybe_else { 
        
        SymbolType st = NodeTypeToSymbolType($3->nodeType);

        // if expression is not of type compatible with bool, throw error
        if( !ImplicitConversionPossible(st, SYMBOL_TYPE_BOOL))
        {
            if(st == SYMBOL_TYPE_CHAR)
                throw_error(ERR_CHAR_TO_X, $1->line_number, NULL, TABLE_NATURE_VEC);
            if(st == SYMBOL_TYPE_STRING)
                throw_error(ERR_STRING_TO_X, $1->line_number, NULL, TABLE_NATURE_VEC);
        }

        $$ = create_node_if($3, $5, $6); 
        FreeValorLexico($2); FreeValorLexico($4); 
        };
maybe_else: 
    TK_PR_ELSE command_block { $$ = $2;   } | 
    %empty                   { $$ = NULL; };

for_flux_control: 
    TK_PR_FOR '(' attribution_command ':' expression ':' attribution_command ')' command_block {

        SymbolType st = NodeTypeToSymbolType($5->nodeType);

        // if expression is not of type compatible with bool, throw error
        if ( !ImplicitConversionPossible(st, SYMBOL_TYPE_BOOL))
        {
            if (st == SYMBOL_TYPE_CHAR)
                throw_error(ERR_CHAR_TO_X, $1->line_number, NULL, TABLE_NATURE_VEC);
            if (st == SYMBOL_TYPE_STRING)
                throw_error(ERR_STRING_TO_X, $1->line_number, NULL, TABLE_NATURE_VEC);
        }

        $$ = create_node_for_loop($3, $5, $7, $9);
        FreeValorLexico($2); FreeValorLexico($4); FreeValorLexico($6); FreeValorLexico($8);
    };
while_flux_control:
    TK_PR_WHILE '(' expression ')' TK_PR_DO command_block {

        SymbolType st = NodeTypeToSymbolType($3->nodeType);

        // if expression is not of type compatible with bool, throw error
        if ( !ImplicitConversionPossible(st, SYMBOL_TYPE_BOOL))
        {
            if(st == SYMBOL_TYPE_CHAR)
                throw_error(ERR_CHAR_TO_X, $1->line_number, NULL, TABLE_NATURE_VEC);
            if(st == SYMBOL_TYPE_STRING)
                throw_error(ERR_STRING_TO_X, $1->line_number, NULL, TABLE_NATURE_VEC);
        }

        $$ = create_node_while_loop($3, $6);
        FreeValorLexico($2); FreeValorLexico($4);
    };

expression: 
    exp_log_or '?' expression ':' expression    {

        // check if first expression is not string or char
        if ($1->nodeType == NODE_TYPE_STRING)
            throw_error(ERR_STRING_TO_X, $2->line_number, NULL, TABLE_NATURE_VAR);
        if ($1->nodeType == NODE_TYPE_CHAR)
            throw_error(ERR_CHAR_TO_X, $2->line_number, NULL, TABLE_NATURE_VAR);

        $$ = create_node_ternary_operation($1, $3, $5, InferTypeTernary($3->nodeType, $5->nodeType, $2->line_number));
        FreeValorLexico($2); FreeValorLexico($4);
    } | 
    exp_log_or                                  { $$ = $1; };
exp_log_or: 
    exp_log_or TK_OC_OR exp_log_and             { $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number)); } | 
    exp_log_and                                 { $$ = $1; };
exp_log_and: 
    exp_log_and TK_OC_AND exp_bit_or            { $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number)); } | 
    exp_bit_or                                  { $$ = $1; };
exp_bit_or: 
    exp_bit_or '|' exp_bit_and                  { $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number)); } | 
    exp_bit_and                                 { $$ = $1; };
exp_bit_and: 
    exp_bit_and '&' exp_relat_1                 { $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number)); } | 
    exp_relat_1                                 { $$ = $1; };
exp_relat_1: 
    exp_relat_1 TK_OC_EQ exp_relat_2            { $$ = create_node_binary_operation($2, $1, $3, InferTypeEqNeq($1->nodeType, $3->nodeType, $2->line_number)); } | 
    exp_relat_1 TK_OC_NE exp_relat_2            { $$ = create_node_binary_operation($2, $1, $3, InferTypeEqNeq($1->nodeType, $3->nodeType, $2->line_number)); } | 
    exp_relat_2                                 { $$ = $1; };
exp_relat_2: 
    exp_relat_2 TK_OC_LE exp_sum                { $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number)); } | 
    exp_relat_2 TK_OC_GE exp_sum                { $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number)); } | 
    exp_relat_2 '<' exp_sum                     { $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number)); } | 
    exp_relat_2 '>' exp_sum                     { $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number)); } | 
    exp_sum                                     { $$ = $1; };
exp_sum:
    exp_sum '+' exp_mult                        {
        NodeType inferredType = InferTypePlus($1->nodeType, $3->nodeType, $2->line_number);

        // add string length to stringConcatSize for every leaf node
        if (inferredType == NODE_TYPE_STRING)
        {
            if ($1->nodeCategory == NODE_LITERAL)
                stringConcatSize += strlen($1->n_literal.literal->tokenValue.string);
            
            if ($1->nodeCategory == NODE_VAR_ACCESS)
                stringConcatSize += GetFirstOccurrence($1->n_var_access.identifier->tokenValue.string)->size;
            
            if ($3->nodeCategory == NODE_LITERAL)
                stringConcatSize += strlen($3->n_literal.literal->tokenValue.string);

            if ($3->nodeCategory == NODE_VAR_ACCESS)
                stringConcatSize += GetFirstOccurrence($3->n_var_access.identifier->tokenValue.string)->size;
        }

        $$ = create_node_binary_operation($2, $1, $3, inferredType);
        } | 
    exp_sum '-' exp_mult                        { $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number)); } | 
    exp_mult                                    { $$ = $1; };
exp_mult: 
    exp_mult '*' exp_pow                        { $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number)); } | 
    exp_mult '/' exp_pow                        { $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number)); } | 
    exp_mult '%' exp_pow                        { $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number)); } | 
    exp_pow                                     { $$ = $1; };
exp_pow: 
    exp_pow '^' unary_exp                       { $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number)); } | 
    unary_exp                                   { $$ = $1; };

unary_exp: 
    unary_op unary_exp  { $$ = create_node_unary_operation($1, $2, InferType($2->nodeType, NODE_TYPE_BOOL, $1->line_number)); } | 
    operand             { $$ = $1; };
unary_op: 
    '+' { $$ = $1; } | 
    '-' { $$ = $1; } | 
    '!' { $$ = $1; 
    /* these unary operations will not be used in the language
    '&' { $$ = $1; } | 
    '*' { $$ = $1; } | 
    '?' { $$ = $1; } | 
    '#' { $$ = $1; }; */
    }; 

operand:
    '(' expression ')' { $$ = $2; FreeValorLexico($1); FreeValorLexico($3); } | 
    var_access         { $$ = $1; } | 
    literal            { $$ = $1; } | 
    call_func_command  { $$ = $1; };

%%
// Referencia para precedencia e associatividade dos operadores nas expressoes: https://en.cppreference.com/w/cpp/language/operator_precedence

void throw_error(int err_code, int line, char* identifier, TableEntryNature nature) {

    printf("[ERROR, LINE %d] ", line);

    char* nat = NULL;
    switch(nature) {
        case TABLE_NATURE_VAR:  nat = (char*) "Variable"; break;
        case TABLE_NATURE_VEC:  nat = (char*) "Vector"; break;
        case TABLE_NATURE_FUNC: nat = (char*) "Function"; break;
        default: "";
    }

    switch(err_code) {
        // TODO: maybe write more descriptive messages???
        case ERR_UNDECLARED:        printf("ERR_UNDECLARED: %s %s has not been declared.\n", nat, identifier); break;
        case ERR_DECLARED:          printf("ERR_DECLARED: %s %s cannot be declared. Name has already been used in this scope.\n", nat, identifier); break;
        case ERR_VARIABLE:          printf("ERR_VARIABLE: Variable %s has been used as vector or function.\n", identifier); break;
        case ERR_VECTOR:            printf("ERR_VECTOR: Vector %s has been used as variable or function.\n", identifier); break;
        case ERR_FUNCTION:          printf("ERR_FUNCTION: Function %s has been used as variable or vector.\n", identifier); break;
        case ERR_WRONG_TYPE:        printf("ERR_WRONG_TYPE: %s %s cannot be attributed a value of a different type.\n", nat, identifier); break;
        case ERR_STRING_TO_X:
            if (identifier == NULL) { printf("ERR_STRING_TO_X: String cannot be implicitly converted.\n"); break; }
            else                    { printf("ERR_STRING_TO_X: String %s cannot be implicitly converted.\n", identifier); break; }
        case ERR_CHAR_TO_X:
            if (identifier == NULL) { printf("ERR_CHAR_TO_X: Char cannot be implicitly converted.\n"); break; }
            else                    { printf("ERR_CHAR_TO_X: Char %s cannot be implicitly converted.\n", identifier); break; }
        case ERR_STRING_SIZE:       printf("ERR_STRING_SIZE: String %s cannot be attributed a string of different size.\n", identifier); break;
        case ERR_MISSING_ARGS:      printf("ERR_MISSING_ARGS: Function %s cannot be called with less arguments than declared.\n", identifier); break;
        case ERR_EXCESS_ARGS:       printf("ERR_EXCESS_ARGS: Function %s cannot be called with more arguments than declared.\n", identifier); break;
        case ERR_WRONG_TYPE_ARGS:   printf("ERR_WRONG_TYPE_ARGS: Function %s is called with arguments of different types than declared.\n", identifier); break;
        case ERR_WRONG_PAR_INPUT:   printf("ERR_WRONG_PAR_INPUT: Input command can only receive an integer or float variable.\n"); break;
        case ERR_WRONG_PAR_OUTPUT:  printf("ERR_WRONG_PAR_OUTPUT: Output command can only receive an int/float literals or variables.\n"); break;
        case ERR_WRONG_PAR_RETURN:  printf("ERR_WRONG_PAR_RETURN: Cannot return different type than declared for function %s.\n", identifier); break;
        case ERR_WRONG_PAR_SHIFT:   printf("ERR_WRONG_PAR_SHIFT: Shift command can only receive an integer less than 16.\n"); break;
        default:                    printf("Unidentified error.\n"); break;
    }

    exit(err_code);

}

NodeType InferTypePlus(NodeType t1, NodeType t2, int line)
{
    if (t1 == NODE_TYPE_STRING && t2 == NODE_TYPE_STRING)
        return NODE_TYPE_STRING;

    return InferType(t1, t2, line);
}

NodeType InferTypeTernary(NodeType t1, NodeType t2, int line)
{
    if (t1 == NODE_TYPE_STRING && t2 == NODE_TYPE_STRING)
        return NODE_TYPE_STRING;
    if (t1 == NODE_TYPE_CHAR && t2 == NODE_TYPE_CHAR)
        return NODE_TYPE_CHAR;

    return InferType(t1, t2, line);
}

NodeType InferTypeEqNeq(NodeType t1, NodeType t2, int line)
{
    if (t1 == NODE_TYPE_STRING && t2 == NODE_TYPE_STRING)
        return NODE_TYPE_BOOL;
    if (t1 == NODE_TYPE_CHAR && t2 == NODE_TYPE_CHAR)
        return NODE_TYPE_BOOL;

    return InferType(t1, t2, line);
}

NodeType InferType(NodeType t1, NodeType t2, int line)
{
    // if any of the types is not int/float/bool
    if (t1 == NODE_TYPE_STRING || t2 == NODE_TYPE_STRING)
        throw_error(ERR_STRING_TO_X, line, NULL, TABLE_NATURE_VAR);
    if (t1 == NODE_TYPE_CHAR || t2 == NODE_TYPE_CHAR)
        throw_error(ERR_CHAR_TO_X, line, NULL, TABLE_NATURE_VAR);
    
    if (t1 == NODE_TYPE_FLOAT || t2 == NODE_TYPE_FLOAT)
        return NODE_TYPE_FLOAT;
    if (t1 == NODE_TYPE_INT || t2 == NODE_TYPE_INT)
        return NODE_TYPE_INT;
    else return NODE_TYPE_BOOL;
}

Node* last_command_of_chain(Node* n) {
    Node* temp = n->sequenceNode;
    while (temp != NULL) {
        n = temp;
        temp = temp->sequenceNode;
    }
    return n;
}

void yyerror (char const *s) {
    printf("[ERROR, LINE %d] %s.\n", yylineno, s);
}

void exporta (void *arvore) {
    PrintAll((Node*) arvore);
}

void libera (void *arvore) {
    FreeTree((Node*) arvore);
}