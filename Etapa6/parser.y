%{
    #include <cstdio>
    #include <map>
    #include "../include/AST.hpp"
    #include "../include/Scope.hpp"
    #include "../include/ILOC.hpp"

    extern "C" int yylex();

    extern int yylineno;
    extern void *arvore;
    int yylex(void);
    void yyerror (char const *s);

    /* Aux function to print error message and exit execution with error */
    void throw_error(int err_code, int line, char* identifier, TableEntryNature nature);

    /* Aux functions to do type inference for nodes and throw errors if needed */
    NodeType InferTypePlus    (NodeType t1, NodeType t2, int line);
    NodeType InferTypeTernary (NodeType t1, NodeType t2, int line);
    NodeType InferTypeEqNeq   (NodeType t1, NodeType t2, int line);
    NodeType InferType        (NodeType t1, NodeType t2, int line);

    /* Aux function to find last sequenceNode of tree */
    Node* last_command_of_chain(Node* n);

    /* Just an empty string to be passed by value */
    std::string nullstr = std::string();

    char* auxLiteral              = (char*) malloc(500); // Save literals in string format. Used when creating node_literals
    char* auxScopeName            = NULL;                // Save current function's name. Used when creating new scopes
    SymbolType auxCurrentFuncType = SYMBOL_TYPE_INDEF;   // Save current function's return type. Used when verifying return command
    int auxCurrentFuncLine        = 0;                   // Save current func's decl. line. Used when creating STEs for function's args
    int stringConcatSize          = 0;                   // Used to calculate the final size when concating strings
    int localVarListSize          = 0;                   // Used to calculate offset in relation to rsp

    std::string *mainFuncLabel = new std::string;

    /* Aux map to help complete ILOC instructions in local var declarations with init  */
    std::map<std::string, std::string*> *auxLocalVarDecDesloc = new std::map<std::string, std::string*>;

    /* Aux map to check type when initializing vars on declaration */
    std::map<ValorLexico*, SymbolType> *auxInitTypeMap = new std::map<ValorLexico*, SymbolType>;

    /* Aux list of vars, used to gather all variables declared in the same command.
       Instead of using a map we now use a list of pairs in order to keep the order of pushbacks */
    std::list<std::pair<std::string, SymbolTableEntry*>> *tempVarList = new std::list<std::pair<std::string, SymbolTableEntry*>>;
    
    /* Aux list of function arguments, used both in func declaration (to gather 
       all formal parameters) and in func call (to gather all real parameters)  */
    std::list<FuncArgument *> *tempFuncArgList = new std::list<FuncArgument *>;

    /* Aux map to store all function's labels */
    std::map<std::string, std::string*> *auxFuncLabelMap = new std::map<std::string, std::string*>;
%}

%union 
{
    /* A grammar symbol can be of one of the following types: */

    /* Lexical value is the type of all terminals and some nonterminals (currently only 'unary_op') */
    struct valorLexico* valor_lexico;

    /* Node is the atomic structure of the AST */
    struct node* node;

    /* The nonterminal 'type' uses this to propagate type info in declarations. 
       Here we use an int which is later converted to SymbolType                */
    int symbol_type;

    /* The following fields are used solely to differentiate between grammar symbols in
       cases where the rules (if made separate) would be almost but not completely the same */
    int input_or_output;     /* Used in nonterminal 'io_command'    */
    int shift_left_or_right; /* Used in nonterminal 'shift_command' */
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
%type<valor_lexico> real_literal
%type<node> global_var
%type<valor_lexico> global_var_maybe_vector
%type<node> global_var_declaration
%type<node> global_var_list
%type<node> func_definition
%type<node> func_header
%type<node> func_header_list
%type<node> func_header_list_iterator
%type<node> func_header_parameter
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
%type<node> var_access_attr
%type<node> attribution_command
%type<node> io_command
%type<input_or_output> input_or_output
%type<node> call_func_command
%type<node> func_parameters_list
%type<node> func_parameters_list_iterator
%type<node> shift_command
%type<shift_left_or_right> shift_operator
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
    init_stack program_list destroy_stack {

        std::string rsp  = std::string("rsp");
        std::string rfp  = std::string("rfp");
        std::string rbss = std::string("rbss");

        std::string newRegister = createRegisterDirect();
        int codeSize = $2->code->size() + 9;

        $2->code->push_front(IlocCode(HALT, NULL, NULL, NULL));
        $2->code->push_front(IlocCode(JUMPI, mainFuncLabel, NULL, NULL));               // add instruction to jump to function main
        $2->code->push_front(IlocCode(STOREAI, rsp, std::string("8"), rfp));            // save rfp
        $2->code->push_front(IlocCode(STOREAI, rsp, std::string("4"), rsp));            // save rsp
        $2->code->push_front(IlocCode(STOREAI, rsp, std::string("0"), newRegister));
        $2->code->push_front(IlocCode(LOADI, std::string("8"), nullstr, newRegister));  // save return address (halt)

        $2->code->push_front(IlocCode(LOADI, std::to_string(codeSize), nullstr, rbss)); // define starting points to data segment ...
        $2->code->push_front(IlocCode(LOADI, std::string("1024"), nullstr, rsp));       // ... stack pointer ...
        $2->code->push_front(IlocCode(LOADI, std::string("1024"), nullstr, rfp));       // ... and frame pointer

        $$ = $2; arvore = $$;
    };
program_list: 
    global_var_declaration program_list   { $$ = $2; /* ignore global vars in AST */    } |
    func_definition program_list          { 
        $1->sequenceNode = $2; 
        $$ = $1; 
        if($2 != NULL) for(IlocCode c: *($2->code)) $$->code->push_back(c);             // 
    } |
    %empty                                { $$ = NULL;                                  };

init_stack:
    %empty {

        // initialize global stack of scopes (which contain the symbol tables)
        CreateStack();

        // initialize global counters used to generate the ILOC labels and registers
        labelIndex = 0;
        registerIndex = 0;
        
        $$ = NULL;
    }

destroy_stack:
    %empty {
    
        // deallocate all aux structures used during construction of the AST
        DestroyStack(); 
        free(auxLiteral); 
        free(auxScopeName);
        delete auxInitTypeMap;
        delete tempVarList;
        delete tempFuncArgList;

        *mainFuncLabel = std::string(*(*auxFuncLabelMap)[std::string("main")]);
        for (std::pair<std::string, std::string*> item : *auxFuncLabelMap) delete item.second;
        delete auxFuncLabelMap;
        
        // for (std::pair<std::string, std::string*> item : *auxLocalVarDecDesloc) delete item.second;
        delete auxLocalVarDecDesloc;
        
        $$ = NULL;
    }


maybe_const: 
    %empty        { $$ = NULL; /* ignore (for now?) the 'const' and 'static' syntactic structures */ } |
    TK_PR_CONST   { $$ = NULL;                                                                       };
maybe_static: 
    %empty        { $$ = NULL;                                                                       } |
    TK_PR_STATIC  { $$ = NULL;                                                                       };

type:
    TK_PR_INT     { $$ = 1; /* int later converted to SymbolType */ } |
    TK_PR_FLOAT   { $$ = 2;                                         } |
    TK_PR_CHAR    { $$ = 3;                                         } |
    TK_PR_BOOL    { $$ = 4;                                         } |
    TK_PR_STRING  { $$ = 5;                                         };
literal:
    real_literal {
        struct valorLexico* lexval = $1;
        SymbolType symbolType  = LiteralTypeToSymbolType(lexval->literalType);
        NodeType nodeType  = SymbolTypeToNodeType(symbolType);
        
        $$ = create_node_literal(lexval, nodeType);

        // set auxLiteral to be the lexeme
        memset(auxLiteral, 0, 500);
        switch (symbolType)
        {
        case SYMBOL_TYPE_INTEGER: sprintf(auxLiteral, "%d",     lexval->tokenValue.integer          ); break;
        case SYMBOL_TYPE_FLOAT:   sprintf(auxLiteral, "%f",     lexval->tokenValue.floating         ); break;
        case SYMBOL_TYPE_CHAR:    sprintf(auxLiteral, "\'%c\'", lexval->tokenValue.character        ); break;
        case SYMBOL_TYPE_STRING:  sprintf(auxLiteral, "\"%s\"", lexval->tokenValue.string           ); break;
        case SYMBOL_TYPE_BOOL:    sprintf(auxLiteral, lexval->tokenValue.boolean ? "true" : "false" ); break;
        default:                  break;
        }

        SymbolTableEntry* ste = CreateSymbolTableEntry(symbolType, lexval->line_number, TABLE_NATURE_LIT, NULL, 0, 0);
        
        // keep only one (the last) STE for each literal in each symbol table
        if (SymbolIsInSymbolTable(auxLiteral, scopeStack->back()))
            DestroySymbolTableEntry((*scopeStack->back()->symbolTable)[std::string(auxLiteral)]);

        // insert STE in current scope's symbol table
        (*scopeStack->back()->symbolTable)[std::string(auxLiteral)] = ste;

        // only create ILOC code if literal is an integer
        if (symbolType == SYMBOL_TYPE_INTEGER)
        {
            std::string *newRegister = createRegister();
            delete $$->local;
            $$->local = newRegister;
            $$->code->push_back(IlocCode(LOADI, std::string(auxLiteral), nullstr, *newRegister));
        }

    }
real_literal: 
    TK_LIT_INT    { $$ = $1; } |
    TK_LIT_FLOAT  { $$ = $1; } |
    TK_LIT_FALSE  { $$ = $1; } |
    TK_LIT_TRUE   { $$ = $1; } |
    TK_LIT_CHAR   { $$ = $1; } |
    TK_LIT_STRING { $$ = $1; };

global_var: 
    TK_IDENTIFICADOR global_var_maybe_vector {

        // define nature and vec_size if var is or is not a vector
        TableEntryNature nature = ($2 == NULL) ? TABLE_NATURE_VAR : TABLE_NATURE_VEC;
        int vec_size            = ($2 == NULL) ? 0 : $2->tokenValue.integer;

        // throw error if var already in symbol table
        if (SymbolIsInSymbolTable($1->tokenValue.string, scopeStack->back()))
            throw_error(ERR_DECLARED, $1->line_number, $1->tokenValue.string, nature);
        
        // add new var to temp var list (to be included later in symbol table)
        SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_INDEF, $1->line_number, nature, NULL, vec_size, 0);
        char* id = $1->tokenValue.string;
        tempVarList->push_back(std::make_pair(std::string(id), ste));

        // ignore global vars in AST
        $$ = NULL; 
        FreeValorLexico($1);
        if ($2 != NULL) FreeValorLexico($2);
    };
global_var_maybe_vector:
    %empty             { $$ = NULL;                                         } |
    '[' TK_LIT_INT ']' { $$ = $2; FreeValorLexico($1); FreeValorLexico($3); };
global_var_declaration: 
    maybe_static type global_var_list ';' {

        Scope* scopeStackTop = scopeStack->back();
        SymbolType type = IntToSymbolType($2);

        // set type to all vars of list, and insert them in table
        for (std::pair<std::string, SymbolTableEntry*> item : *tempVarList)
        {
            SymbolTableEntry* ste = item.second;

            ste->symbolType = type;

            // update STE size
            int size = SizeFromSymbolType(type);
            if(ste->entryNature == TABLE_NATURE_VEC) size *= ste->vectorSize;
            ste->size = size;

            // update offset info
            ste->desloc = scopeStackTop->currentDesloc;
            scopeStackTop->currentDesloc += size;

            (*scopeStackTop->symbolTable)[item.first] = ste;
        }

        // free temp var list
        delete tempVarList;
        tempVarList = new std::list<std::pair<std::string, SymbolTableEntry*>>;

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

        /* intermediate code generation */

        std::string rsp  = std::string("rsp");
        std::string rfp  = std::string("rfp");
        std::string rbss = std::string("rbss");

        char* funcName = $1->n_function_declaration.identifier->tokenValue.string;
        SymbolTableEntry* ste = GetFirstOccurrence(funcName);
        int num_params = ste->funcArguments->size();

        std::string *funcLabel = createLabel();
        (*auxFuncLabelMap)[std::string(funcName)] = funcLabel;

        int incr_rsp = 16+4*num_params;

        $$->code->push_back(IlocCode(*funcLabel, NOP, nullstr, nullstr, nullstr));  // instruction with func's label
        $$->code->push_back(IlocCode(I2I, rsp, nullstr, rfp));                      // copy rsp to rfp
        $$->code->push_back(IlocCode(ADDI, rsp, std::to_string(incr_rsp), rsp));    // update rsp
        if($2 != NULL) for (IlocCode c : *($2->code)) $$->code->push_back(c);       // copy command block's code

        // implicit return

        std::string regReturnAddress = createRegisterDirect();
        std::string regRestoreRsp    = createRegisterDirect();
        std::string regRestoreRfp    = createRegisterDirect();

        $$->code->push_back(IlocCode(LOADAI, rfp, std::string("0"), regReturnAddress));
        $$->code->push_back(IlocCode(LOADAI, rfp, std::string("4"), regRestoreRsp));
        $$->code->push_back(IlocCode(LOADAI, rfp, std::string("8"), regRestoreRfp));
        $$->code->push_back(IlocCode(I2I, regRestoreRsp , nullstr, rsp));
        $$->code->push_back(IlocCode(I2I, regRestoreRfp , nullstr, rfp));
        $$->code->push_back(IlocCode(JUMP, regReturnAddress , nullstr, nullstr));
    };

func_header:
    maybe_static type TK_IDENTIFICADOR '(' func_header_list ')' {

        char* id = $3->tokenValue.string;

        // throw error if function already in symbol table
        if (SymbolIsInSymbolTable(id, scopeStack->back()))
            throw_error(ERR_DECLARED, $3->line_number, id, TABLE_NATURE_FUNC);

        // make a deep copy of func args list
        std::list<FuncArgument*> *deepCopy = new std::list<FuncArgument*>;
        for (FuncArgument* arg : *tempFuncArgList) deepCopy->push_back(arg);

        // add function to symbol table
        SymbolTableEntry* ste = CreateSymbolTableEntry(IntToSymbolType($2), $3->line_number, TABLE_NATURE_FUNC, deepCopy, 0, 0);
        (*scopeStack->back()->symbolTable)[std::string(id)] = ste;

        // update aux vars with new scope name, current function's type and current function's line
        if(auxScopeName != NULL) free(auxScopeName);
        auxScopeName = strdup(id);
        auxCurrentFuncType = IntToSymbolType($2);
        auxCurrentFuncLine = $3->line_number;

        $$ = create_node_function_declaration($3, NULL);
        FreeValorLexico($4); FreeValorLexico($6);
    };
func_header_list:
    %empty                                              { $$ = NULL; } |
    func_header_parameter func_header_list_iterator     { $$ = NULL; };
func_header_list_iterator: 
    %empty                                              { $$ = NULL;                      } |
    ',' func_header_parameter func_header_list_iterator { $$ = NULL; FreeValorLexico($1); };
func_header_parameter:
    maybe_const type TK_IDENTIFICADOR {

        // create funcargument and add it to global list
        char* id = strdup($3->tokenValue.string);
        FuncArgument* fa = CreateFuncArgument(id, IntToSymbolType($2));
        tempFuncArgList->push_back(fa);

        $$ = NULL;
        FreeValorLexico($3);
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
        /* create new scope with current function's name and desloc, and push it to scopeStack.
           when it's a new function, start offset at 16 (after return addr, rsp, rfp and return value) */
        int desloc = scopeStack->back()->scopeName == NULL ? 16 : scopeStack->back()->currentDesloc;
        Scope* newScope = CreateNewScope(strdup(auxScopeName), desloc);
        scopeStack->push_back(newScope);

        // add formal parameters to function's scope. update symbol table offset (desloc) accordingly
        for (FuncArgument* arg : *tempFuncArgList)
        {
            SymbolTableEntry* ste = CreateSymbolTableEntry(arg->type, auxCurrentFuncLine, TABLE_NATURE_VAR, NULL, 0, scopeStack->back()->currentDesloc);
            scopeStack->back()->currentDesloc += SizeFromSymbolType(arg->type);
            (*scopeStack->back()->symbolTable)[std::string(arg->argName)] = ste;
        }

        // free temp func arg list
        delete tempFuncArgList;
        tempFuncArgList = new std::list<FuncArgument *>;

    }

cmd_block_destroy_scope:
    %empty {
        Scope* currentScope = scopeStack->back();

        int desloc = currentScope->currentDesloc;

        /* pop current scope from scopeStack and free its memory */
        DestroyScope(currentScope);
        scopeStack->pop_back();

        if(scopeStack->back()->scopeName != NULL) scopeStack->back()->currentDesloc = desloc;
    }

real_command_block:
    '{' sequence_simple_command '}' { $$ = $2; FreeValorLexico($1); FreeValorLexico($3); };
sequence_simple_command: 
    %empty { $$ = NULL; } |
    simple_command ';' sequence_simple_command  { 
        if ($1 == NULL) $$ = $3;
        else
        {
            last_command_of_chain($1)->sequenceNode = $3;
            $$ = $1;
            if($3 != NULL) for(IlocCode c: *($3->code)) $$->code->push_back(c);
        }
        FreeValorLexico($2);
    };

local_var_declaration:
    maybe_static maybe_const type local_var_list {

        // check if all inits obey the declared type
        for (std::pair<ValorLexico*, SymbolType> item : *auxInitTypeMap)
        {
            if (!ImplicitConversionPossible(item.second, IntToSymbolType($3)))
                throw_error(ERR_WRONG_TYPE, item.first->line_number, item.first->tokenValue.string, TABLE_NATURE_VAR);
        }

        Scope* scopeStackTop = scopeStack->back();

        // set type to all vars of list, and insert them in table
        for (std::pair<std::string, SymbolTableEntry*> item : *tempVarList)
        {
            SymbolTableEntry* ste = item.second;
            SymbolType type = IntToSymbolType($3);
            ste->symbolType = type;

            // update STE size
            int size = SizeFromSymbolType(type);
            if(ste->entryNature == TABLE_NATURE_VEC) size *= ste->vectorSize;
            ste->size = size;

            // update offset info
            ste->desloc = scopeStackTop->currentDesloc;
            scopeStackTop->currentDesloc += size;

            (*scopeStack->back()->symbolTable)[item.first] = ste;
        }

        for (std::pair<std::string, std::string*> item : *auxLocalVarDecDesloc)
        {
            std::string desloc = std::to_string((*scopeStack->back()->symbolTable)[item.first]->desloc);
            *(item.second) = desloc;
        }

        $$ = $4;
        
        std::string rsp = std::string("rsp");
        $$->code->push_front(IlocCode(ADDI, rsp, std::to_string(localVarListSize), rsp));

        // free temp var list and aux init type map
        delete tempVarList;
        tempVarList = new std::list<std::pair<std::string, SymbolTableEntry*>>;
        delete auxInitTypeMap;
        auxInitTypeMap = new std::map<ValorLexico*, SymbolType>;
        localVarListSize = 0;

    };

local_var_list:
    local_var local_var_list_iterator {
        localVarListSize += 4;
        $1->sequenceNode = $2;
        if ($2 != NULL) for (IlocCode c : *($2->code)) $1->code->push_back(c);
        $$ = $1;
    };
local_var_list_iterator:
    %empty               { $$ = NULL;                    } |
    ',' local_var_list   { $$ = $2; FreeValorLexico($1); } ;

local_var: 
    TK_IDENTIFICADOR {

        char* id = $1->tokenValue.string;
        
        // throw error if var already in symbol table
        if (SymbolIsInSymbolTable(id, scopeStack->back()))
            throw_error(ERR_DECLARED, $1->line_number, id, TABLE_NATURE_VAR);
            
        // add new var to temp var list (to be included later in symbol table)
        SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_INDEF, $1->line_number, TABLE_NATURE_VAR, NULL, 0, 0);
        tempVarList->push_back(std::make_pair(std::string(id), ste));

        // ignore unititialized var in AST
        $$ = CreateGenericNode(NODE_INDEF);
        FreeValorLexico($1);
    } |
    TK_IDENTIFICADOR TK_OC_LE literal {

        char* id = $1->tokenValue.string;

        // throw error if var already in symbol table
        if (SymbolIsInSymbolTable(id, scopeStack->back()))
            throw_error(ERR_DECLARED, $1->line_number, id, TABLE_NATURE_VAR);

        SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_INDEF, $1->line_number, TABLE_NATURE_VAR, NULL, 0, 0);
        
        // if literal is of type string, update ste's size accordingly
        if ($3->nodeType == NODE_TYPE_STRING)
            ste->size = (int) strlen($3->n_literal.literal->tokenValue.string);

        // add new var to temp var list (to be included later in symbol table)
        tempVarList->push_back(std::make_pair(std::string(id), ste));

        // add entry in aux map to check type of initialized vars
        (*auxInitTypeMap)[$1] = NodeTypeToSymbolType($3->nodeType);

        // add var_init node to AST
        $$ = create_node_var_init(create_node_var_access($1, $3->nodeType), $3);
        FreeValorLexico($2);

        /* intermediate code generation */

        for (IlocCode c : *($3->code)) $$->code->push_back(c);
        std::string *temp1 = new std::string; *temp1 = std::string("rfp");
        std::string *temp2 = new std::string;
        std::string *temp3 = new std::string; *temp3 = std::string(*($3->local));
        $$->code->push_back(IlocCode(STOREAI, temp1, temp2, temp3));

        // save the place where we'll later write the var's offset in relation to rfp
        (*auxLocalVarDecDesloc)[std::string(id)] = temp2;

    } |
    TK_IDENTIFICADOR TK_OC_LE TK_IDENTIFICADOR {

        char* id = $1->tokenValue.string;
        char* s3_name = $3->tokenValue.string;
        int s3_line = $3->line_number;

        // add var to symbol table if not already there
        if (SymbolIsInSymbolTable(id, scopeStack->back()))
            throw_error(ERR_DECLARED, $1->line_number, id, TABLE_NATURE_VAR);

        SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_INDEF, $1->line_number, TABLE_NATURE_VAR, NULL, 0, 0);
        
        SymbolTableEntry* ste2 = GetFirstOccurrence(s3_name);
        // if var s3_name doesn't exist, throw ERR_UNDECLARED
        if (ste2 == NULL) throw_error(ERR_UNDECLARED, s3_line, s3_name, TABLE_NATURE_VAR);
        // if s3_name is a function or a vector, throw ERR_FUNCTION or ERR_VECTOR
        if (ste2->entryNature == TABLE_NATURE_FUNC) throw_error(ERR_FUNCTION, s3_line, s3_name, TABLE_NATURE_FUNC);
        if (ste2->entryNature == TABLE_NATURE_VEC) throw_error(ERR_VECTOR, s3_line, s3_name, TABLE_NATURE_VEC);

        // if $3 is of type string, update ste's size accordingly
        if (ste2->symbolType == SYMBOL_TYPE_STRING) ste->size = ste2->size;

        // add new var to temp var list (to be included later in symbol table)
        tempVarList->push_back(std::make_pair(std::string(id), ste));

        // add entry in aux map to check type of initialized vars
        (*auxInitTypeMap)[$1] = ste2->symbolType;
        
        // add var_init node to AST
        $$ = create_node_var_init(create_node_var_access($1, SymbolTypeToNodeType(ste2->symbolType)),
                                    create_node_var_access($3, SymbolTypeToNodeType(ste2->symbolType)));
        FreeValorLexico($2);

        /* intermediate code generation */

        // select correct base register
        bool var_is_global = IsVarGlobal(s3_name);
        std::string baseReg = var_is_global ? "rbss" : "rfp";

        // load s3's value in newRegister
        std::string *temp1 = new std::string; *temp1 = std::string(baseReg);
        std::string *temp2 = new std::string; *temp2 = std::to_string(ste2->desloc);
        std::string *newRegister = createRegister();
        $$->code->push_back(IlocCode(LOADAI, temp1, temp2, newRegister));

        // store newRegister's value in var's address
        std::string *temp3 = new std::string; *temp3 = std::string("rfp");
        std::string *temp4 = new std::string;
        $$->code->push_back(IlocCode(STOREAI, temp3, temp4, newRegister));

        // save the place where we'll later write the var's offset in relation to rfp
        (*auxLocalVarDecDesloc)[std::string(id)] = temp4;

    };

var_access:
    TK_IDENTIFICADOR {
    
        char* id = $1->tokenValue.string;
        SymbolTableEntry* ste = GetFirstOccurrence(id);
        int line = $1->line_number;

        // check if var was declared
        if (ste == NULL) throw_error(ERR_UNDECLARED, line, id, TABLE_NATURE_VAR);
        // check if symbol's nature is not function or vector
        if (ste->entryNature == TABLE_NATURE_FUNC) throw_error(ERR_FUNCTION, line, id, TABLE_NATURE_FUNC);
        if (ste->entryNature == TABLE_NATURE_VEC) throw_error(ERR_VECTOR, line, id, TABLE_NATURE_VEC);

        // add var_access node to AST
        $$ = create_node_var_access($1, SymbolTypeToNodeType(ste->symbolType));

        /* intermediate code generation */

        // select correct base register
        bool var_is_global = IsVarGlobal(id);
        std::string baseReg = var_is_global ? "rbss" : "rfp";

        std::string *newRegister = createRegister();
        delete $$->local;
        $$->local = newRegister;
        $$->code->push_back(IlocCode(LOADAI, std::string(baseReg), std::to_string(ste->desloc), *newRegister));

    } | 
    TK_IDENTIFICADOR '[' expression ']' {
        char* id = $1->tokenValue.string;
        SymbolTableEntry* ste = GetFirstOccurrence(id);
        int line = $1->line_number;

        // check if var was declared
        if (ste == NULL) throw_error(ERR_UNDECLARED, line, id, TABLE_NATURE_VEC);
        // check if symbol's nature is not function or vector
        if (ste->entryNature == TABLE_NATURE_FUNC) throw_error(ERR_FUNCTION, line, id, TABLE_NATURE_FUNC);
        if (ste->entryNature == TABLE_NATURE_VAR) throw_error(ERR_VARIABLE, line, id, TABLE_NATURE_VAR);

        // check if expression is not of type string or char
        NodeType exp_type = $3->nodeType;
        if (exp_type == NODE_TYPE_STRING) throw_error(ERR_STRING_TO_X, line, id, TABLE_NATURE_VEC);
        if (exp_type == NODE_TYPE_CHAR) throw_error(ERR_CHAR_TO_X, line, id, TABLE_NATURE_VEC);

        // add vector_access node to AST
        NodeType nt = SymbolTypeToNodeType(ste->symbolType);
        $$ = create_node_vector_access(create_node_var_access($1, nt), $3, nt);
        FreeValorLexico($2); FreeValorLexico($4);

        /* we'll only need to create intermediate code here if vectors 
           are included back in the language in the next phases */

    };

var_access_attr:
    TK_IDENTIFICADOR {
    
        char* id = $1->tokenValue.string;
        SymbolTableEntry* ste = GetFirstOccurrence(id);
        int line = $1->line_number;

        // check if var was declared
        if (ste == NULL) throw_error(ERR_UNDECLARED, line, id, TABLE_NATURE_VAR);
        // check if symbol's nature is not function or vector
        if (ste->entryNature == TABLE_NATURE_FUNC) throw_error(ERR_FUNCTION, line, id, TABLE_NATURE_FUNC);
        if (ste->entryNature == TABLE_NATURE_VEC) throw_error(ERR_VECTOR, line, id, TABLE_NATURE_VEC);

        // add var_access node to AST
        $$ = create_node_var_access($1, SymbolTypeToNodeType(ste->symbolType));
    } |

    TK_IDENTIFICADOR '[' expression ']' {
        char* id = $1->tokenValue.string;
        SymbolTableEntry* ste = GetFirstOccurrence(id);
        int line = $1->line_number;

        // check if var was declared
        if (ste == NULL) throw_error(ERR_UNDECLARED, line, id, TABLE_NATURE_VEC);
        // check if symbol's nature is not function or vector
        if (ste->entryNature == TABLE_NATURE_FUNC) throw_error(ERR_FUNCTION, line, id, TABLE_NATURE_FUNC);
        if (ste->entryNature == TABLE_NATURE_VAR) throw_error(ERR_VARIABLE, line, id, TABLE_NATURE_VAR);

        // check if expression is not of type string or char
        NodeType exp_type = $3->nodeType;
        if (exp_type == NODE_TYPE_STRING) throw_error(ERR_STRING_TO_X, line, id, TABLE_NATURE_VEC);
        if (exp_type == NODE_TYPE_CHAR) throw_error(ERR_CHAR_TO_X, line, id, TABLE_NATURE_VEC);

        // add vector_access node to AST
        NodeType nt = SymbolTypeToNodeType(ste->symbolType);
        $$ = create_node_vector_access(create_node_var_access($1, nt), $3, nt);
        FreeValorLexico($2); FreeValorLexico($4);

        /* we'll only need to create intermediate code here if vectors 
           are included back in the language in the next phases */

    };

attribution_command:
    var_access_attr '=' expression {

        int line = $2->line_number;

        if ($1->nodeCategory == NODE_VAR_ACCESS)
        {
            char* id = $1->n_var_access.identifier->tokenValue.string;
            SymbolTableEntry* ste = GetFirstOccurrence(id);

            // check if expression and var/vector have compatible types
            if ( !ImplicitConversionPossible(ste->symbolType, NodeTypeToSymbolType($3->nodeType)) )
                throw_error(ERR_WRONG_TYPE, line, id, TABLE_NATURE_VAR);

            // if var is of type string, do size checks
            if(ste->symbolType == SYMBOL_TYPE_STRING)
            {
                NodeCategory nodeCat = $3->nodeCategory;
                if(nodeCat == NODE_LITERAL)
                {
                    int literalSize = strlen($3->n_literal.literal->tokenValue.string);
                    if(ste->size == -1) ste->size = literalSize;
                    else if(ste->size < literalSize) throw_error(ERR_STRING_SIZE, line, id, TABLE_NATURE_VAR);
                }
            
                if(nodeCat == NODE_VAR_ACCESS)
                {
                    SymbolTableEntry* ste2 = GetFirstOccurrence($3->n_var_access.identifier->tokenValue.string);
                    if(ste->size == -1) ste->size = ste2->size;
                    else if(ste->size < ste2->size) throw_error(ERR_STRING_SIZE, line, id, TABLE_NATURE_VAR);
                }

                if(nodeCat == NODE_BINARY_OPERATION)
                {
                    if(ste->size == -1) ste->size = stringConcatSize;
                    else if (ste->size < stringConcatSize) throw_error(ERR_STRING_SIZE, line, id, TABLE_NATURE_VAR);

                    stringConcatSize = 0;
                }
            }

            $$ = create_node_var_attr($1, $3);
            FreeValorLexico($2);

            /* intermediate code generation */

            // select correct base register
            bool var_is_global = IsVarGlobal(id);
            std::string baseReg = var_is_global ? "rbss" : "rfp";

            for (IlocCode c : *($3->code)) $$->code->push_back(c);
            std::string expLocal = std::string(*($3->local));
            $$->code->push_back(IlocCode(STOREAI, std::string(baseReg), std::to_string(ste->desloc), expLocal));

        }
        else if ($1->nodeCategory == NODE_VECTOR_ACCESS)
        {
            char* id = $1->n_vector_access.var->n_var_access.identifier->tokenValue.string;
            SymbolTableEntry* ste = GetFirstOccurrence(id);

            // check if expression and var/vector have compatible types
            if ( !ImplicitConversionPossible(ste->symbolType, NodeTypeToSymbolType($3->nodeType)) )
                throw_error(ERR_WRONG_TYPE, line, id, TABLE_NATURE_VEC);
                
            $$ = create_node_var_attr($1, $3);
            FreeValorLexico($2);

            /* we'll only need to create intermediate code here if vectors 
               are included back in the language in the next phases */

        }

    };

io_command: 
    input_or_output TK_IDENTIFICADOR {

        char* id = $2->tokenValue.string;
        SymbolTableEntry* ste = GetFirstOccurrence(id);
        int line = $2->line_number;

        // check if var was declared and is not a function or a vector
        if (ste == NULL) throw_error(ERR_UNDECLARED, line, id, TABLE_NATURE_VAR);
        if (ste->entryNature == TABLE_NATURE_FUNC) throw_error(ERR_FUNCTION, line, id, TABLE_NATURE_FUNC);
        if (ste->entryNature == TABLE_NATURE_VEC) throw_error(ERR_VECTOR, line, id, TABLE_NATURE_VEC);

        // check if id is of type int or float
        if (ste->symbolType != SYMBOL_TYPE_INTEGER && ste->symbolType != SYMBOL_TYPE_FLOAT)
            throw_error(ERR_WRONG_PAR_INPUT, line, id, TABLE_NATURE_VAR);

        // create right node for input or output
        if ($1 == 0) $$ = create_node_input(create_node_var_access($2, SymbolTypeToNodeType(ste->symbolType)));
        else $$ = create_node_output(create_node_var_access($2, SymbolTypeToNodeType(ste->symbolType)));
    } | 
    TK_PR_OUTPUT literal {
        int line = $2->n_literal.literal->line_number;

        // check if literal is of type int or float
        if ($2->nodeType != NODE_TYPE_INT && $2->nodeType != NODE_TYPE_FLOAT)
            throw_error(ERR_WRONG_PAR_OUTPUT, line, NULL, TABLE_NATURE_VAR);

        $$ = create_node_output($2);
    } ;
input_or_output:
    TK_PR_INPUT  { $$ = 0; } |
    TK_PR_OUTPUT { $$ = 1; };

call_func_command:
    TK_IDENTIFICADOR '(' func_parameters_list ')' {

        char* id = $1->tokenValue.string;
        SymbolTableEntry* ste = GetFirstOccurrence(id);
        int line = $1->line_number;

        // check if function was declared and is not a var or a vector
        if (ste == NULL) throw_error(ERR_UNDECLARED, line, id, TABLE_NATURE_FUNC);
        if (ste->entryNature == TABLE_NATURE_VAR) throw_error(ERR_VARIABLE, line, id, TABLE_NATURE_VAR);
        if (ste->entryNature == TABLE_NATURE_VEC) throw_error(ERR_VECTOR, line, id, TABLE_NATURE_VEC);

        // if function is called with arguments
        if ($3 != NULL)
        {
            if (tempFuncArgList->size() > ste->funcArguments->size()) throw_error(ERR_EXCESS_ARGS, line, id, TABLE_NATURE_FUNC);
            if (tempFuncArgList->size() < ste->funcArguments->size()) throw_error(ERR_MISSING_ARGS, line, id, TABLE_NATURE_FUNC);

            // iterate through both lists comparing each argument's type
            std::list<FuncArgument*>::iterator it_formal_args = ste->funcArguments->begin();
            std::list<FuncArgument*>::iterator it_real_args = tempFuncArgList->begin();
            while (it_formal_args != ste->funcArguments->end() && it_real_args != tempFuncArgList->end())
            {
                if ( !ImplicitConversionPossible((*it_formal_args)->type, (*it_real_args)->type) )
                    throw_error(ERR_WRONG_TYPE_ARGS, line, id, TABLE_NATURE_FUNC);

                DestroyFuncArgument(*it_real_args);   
                ++it_formal_args; ++it_real_args;
            }

            // free temp function argument list
            delete tempFuncArgList;
            tempFuncArgList = new std::list<FuncArgument*>;
        }
        // throw error if function is called without arguments but has formal params
        else if (ste->funcArguments != NULL && !ste->funcArguments->empty())
            throw_error(ERR_MISSING_ARGS, line, id, TABLE_NATURE_FUNC);

        // get nodeType from function return type
        NodeType nt = SymbolTypeToNodeType(ste->symbolType);

        $$ = create_node_function_call($1, $3, nt);
        FreeValorLexico($2); FreeValorLexico($4);

        /* intermediate code generation */
        
        std::string rfp = std::string("rfp");
        std::string rsp = std::string("rsp");
        std::string rpc = std::string("rpc");

        std::string newRegister = createRegisterDirect();

        int param_address = 12;         // start stacking params in rsp+16 (skip an addr to store return value)
        Node* param = $3;

        while (param != NULL)
        {
            param_address += 4;
            for (IlocCode c : *(param->code)) $$->code->push_back(c);                           // copy param's code
            std::string str_param_address = std::to_string(param_address);
            std::string str_param_reg     = std::string(*(param->local));
            $$->code->push_back(IlocCode(STOREAI, rsp, str_param_address, str_param_reg));      // stack param in rsp+param_address
            param = param->sequenceNode;
        }

        // compute number of instructions to jump over (to jump right after the JUMP instruction)
        $$->code->push_back(IlocCode(ADDI, rpc, std::string("5"), newRegister));
        
        $$->code->push_back(IlocCode(STOREAI, rsp, std::string("0"), newRegister));             // save return address
        $$->code->push_back(IlocCode(STOREAI, rsp, std::string("4"), rsp));                     // save rsp
        $$->code->push_back(IlocCode(STOREAI, rsp, std::string("8"), rfp));                     // save rfp

        std::string *calledFuncLabel = (*auxFuncLabelMap)[std::string(id)];
        $$->code->push_back(IlocCode(JUMPI, *calledFuncLabel, nullstr, nullstr));               // jump to called function

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
    var_access shift_operator TK_LIT_INT {

        // check if shift number greater than 16
        if ($3->tokenValue.integer > 16)
            throw_error(ERR_WRONG_PAR_SHIFT, $3->line_number, NULL, TABLE_NATURE_LIT);

        // create right node for shift left or right
        if ($2 == 0) $$ = create_node_shift_left($1, create_node_literal($3, NODE_TYPE_INT));
        else $$ = create_node_shift_right($1, create_node_literal($3, NODE_TYPE_INT));

    };
shift_operator:
    TK_OC_SL { $$ = 0; FreeValorLexico($1); } |
    TK_OC_SR { $$ = 1; FreeValorLexico($1); };

return_command:
    TK_PR_RETURN expression { 

        // check if expression has type different than current function's
        if ( !ImplicitConversionPossible( NodeTypeToSymbolType($2->nodeType), auxCurrentFuncType) )
            throw_error(ERR_WRONG_PAR_RETURN, $1->line_number, auxScopeName, TABLE_NATURE_FUNC);

        $$ = create_node_return($2); 

        /* intermediate code generation */

        for (IlocCode c : *($2->code)) $$->code->push_back(c);              // copy expression's code

        std::string rsp  = std::string("rsp");
        std::string rfp  = std::string("rfp");
        std::string rbss = std::string("rbss");

        std::string newRegister1 = createRegisterDirect();
        std::string newRegister2 = createRegisterDirect();
        std::string newRegister3 = createRegisterDirect();

        std::string expLocal = std::string(*($2->local));
        $$->code->push_back(IlocCode(STOREAI, rfp, std::string("12"), expLocal));        // save return value
        $$->code->push_back(IlocCode(LOADAI, rfp, std::string("0"), newRegister1));
        $$->code->push_back(IlocCode(LOADAI, rfp, std::string("4"), newRegister2));
        $$->code->push_back(IlocCode(LOADAI, rfp, std::string("8"), newRegister3));
        $$->code->push_back(IlocCode(I2I, newRegister2 , nullstr, rsp));
        $$->code->push_back(IlocCode(I2I, newRegister3 , nullstr, rfp));
        $$->code->push_back(IlocCode(JUMP, newRegister1 , nullstr, nullstr));

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
            int line = $1->line_number;
            if(st == SYMBOL_TYPE_CHAR) throw_error(ERR_CHAR_TO_X, line, NULL, TABLE_NATURE_VEC);
            if(st == SYMBOL_TYPE_STRING) throw_error(ERR_STRING_TO_X, line, NULL, TABLE_NATURE_VEC);
        }

        $$ = create_node_if($3, $5, $6); 
        FreeValorLexico($2); FreeValorLexico($4); 

        /* intermediate code generation */
        
        Node* exp = $3;
        Node* s1 = $5;
        Node* maybe_else = $6;

        std::string *x = createLabel();
        std::string *y = createLabel();
        std::string *z;
        if (maybe_else != NULL) z = createLabel();
        
        // mend the patches in exp's tl with x and fl with y
        for (std::string* s : *(exp->tl)) *s = *x;
        for (std::string* s : *(exp->fl)) *s = *y;

        // resulting code has first exp's code, then label "x", then second one's code
        for (IlocCode c : *(exp->code)) $$->code->push_back(c);
        
        $$->code->push_back(IlocCode(x, NOP, NULL, NULL, NULL));
        if(s1 != NULL) for (IlocCode c : *(s1->code)) $$->code->push_back(c);
        if (maybe_else != NULL) $$->code->push_back(IlocCode(JUMPI, *z, nullstr, nullstr));
        $$->code->push_back(IlocCode(y, NOP, NULL, NULL, NULL));
        
        if (maybe_else != NULL)
        {
            for (IlocCode c : *(maybe_else->code)) $$->code->push_back(c);
            $$->code->push_back(IlocCode(*z, NOP, nullstr, nullstr, nullstr));
        }

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
            int line = $1->line_number;
            if (st == SYMBOL_TYPE_CHAR) throw_error(ERR_CHAR_TO_X, line, NULL, TABLE_NATURE_VEC);
            if (st == SYMBOL_TYPE_STRING) throw_error(ERR_STRING_TO_X, line, NULL, TABLE_NATURE_VEC);
        }

        $$ = create_node_for_loop($3, $5, $7, $9);
        FreeValorLexico($2); FreeValorLexico($4); FreeValorLexico($6); FreeValorLexico($8);

        /* intermediate code generation */
        
        Node* s1 = $3;
        Node* exp = $5;
        Node* s2 = $7;
        Node* s3 = $9;

        std::string *x = createLabel();
        std::string *y = createLabel();
        std::string *z = createLabel();
        
        // mend the patches in exp's tl with x and fl with y
        for (std::string* s : *(exp->tl)) *s = *x;
        for (std::string* s : *(exp->fl)) *s = *y;

        // define node's resulting ILOC code
        for (IlocCode c : *(s1->code)) $$->code->push_back(c);                     // S1.code
        $$->code->push_back(IlocCode(*z, NOP, nullstr, nullstr, nullstr));         // z: nop
        for (IlocCode c : *(exp->code)) $$->code->push_back(c);                    // B.code
        $$->code->push_back(IlocCode(x, NOP, NULL, NULL, NULL));                   // x: nop
        if(s3 != NULL) for (IlocCode c : *(s3->code)) $$->code->push_back(c);      // S3.code
        for (IlocCode c : *(s2->code)) $$->code->push_back(c);                     // S2.code
        $$->code->push_back(IlocCode(JUMPI, *z, nullstr, nullstr));                // jump z
        $$->code->push_back(IlocCode(y, NOP, NULL, NULL, NULL));                   // y: nop

    };
while_flux_control:
    TK_PR_WHILE '(' expression ')' TK_PR_DO command_block {

        SymbolType st = NodeTypeToSymbolType($3->nodeType);

        // if expression is not of type compatible with bool, throw error
        if ( !ImplicitConversionPossible(st, SYMBOL_TYPE_BOOL))
        {
            int line = $1->line_number;
            if(st == SYMBOL_TYPE_CHAR) throw_error(ERR_CHAR_TO_X, line, NULL, TABLE_NATURE_VEC);
            if(st == SYMBOL_TYPE_STRING) throw_error(ERR_STRING_TO_X, line, NULL, TABLE_NATURE_VEC);
        }

        $$ = create_node_while_loop($3, $6);
        FreeValorLexico($2); FreeValorLexico($4);

        /* intermediate code generation */
        
        Node* exp = $3;
        Node* s1 = $6;

        std::string *x = createLabel();
        std::string *y = createLabel();
        std::string *z = createLabel();

        // mend the patches in exp's tl with x and fl with y
        for (std::string* s : *(exp->tl)) *s = *x;
        for (std::string* s : *(exp->fl)) *s = *y;

        // define node's resulting ILOC code
        $$->code->push_back(IlocCode(*z, NOP, nullstr, nullstr, nullstr));          // z: nop
        for (IlocCode c : *(exp->code)) $$->code->push_back(c);                     // B.code
        $$->code->push_back(IlocCode(x, NOP, NULL, NULL, NULL));                    // x: nop
        if(s1 != NULL) for (IlocCode c : *(s1->code)) $$->code->push_back(c);       // S1.code
        $$->code->push_back(IlocCode(JUMPI, *z, nullstr, nullstr));                 // jump z
        $$->code->push_back(IlocCode(y, NOP, NULL, NULL, NULL));                    // y: nop

    };

expression: 
    exp_log_or '?' expression ':' expression    {

        int line = $2->line_number;
        NodeType nt = $1->nodeType;

        // check if first expression is not string or char
        if (nt == NODE_TYPE_STRING) throw_error(ERR_STRING_TO_X, line, NULL, TABLE_NATURE_VAR);
        if (nt == NODE_TYPE_CHAR) throw_error(ERR_CHAR_TO_X, line, NULL, TABLE_NATURE_VAR);

        $$ = create_node_ternary_operation($1, $3, $5, InferTypeTernary($3->nodeType, $5->nodeType, line));
        FreeValorLexico($2); FreeValorLexico($4);

        /* intermediate code generation */
        
        Node* exp1 = $1;
        Node* exp2 = $3;
        Node* exp3 = $5;

        delete $$->local;
        $$->local = createRegister();

        std::string *x = createLabel();
        std::string *y = createLabel();
        std::string *z = createLabel();

        // mend the patches in exp's tl with x and fl with y
        for (std::string* s : *(exp1->tl)) *s = *x;
        for (std::string* s : *(exp1->fl)) *s = *y;

        // resulting code has first exp's code, then label "x", then second one's code
        for (IlocCode c : *(exp1->code)) $$->code->push_back(c);
        
        $$->code->push_back(IlocCode(x, NOP, NULL, NULL, NULL));
        for (IlocCode c : *(exp2->code)) $$->code->push_back(c);
        $$->code->push_back(IlocCode(I2I, std::string(*(exp2->local)), nullstr, std::string(*($$->local))));
        $$->code->push_back(IlocCode(JUMPI, z, NULL, NULL));

        $$->code->push_back(IlocCode(y, NOP, NULL, NULL, NULL));
        for (IlocCode c : *(exp3->code)) $$->code->push_back(c);
        $$->code->push_back(IlocCode(I2I, std::string(*(exp3->local)), nullstr, std::string(*($$->local))));
        $$->code->push_back(IlocCode(z, NOP, NULL, NULL, NULL));

    } | 
    exp_log_or                                  { $$ = $1; };
exp_log_or: 
    exp_log_or TK_OC_OR exp_log_and {
        $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number));

        /* intermediate code generation */
        
        std::string *x = createLabel();
        
        // make a deep copy of the tl and fl lists
        std::list<std::string*> *b1tl = new std::list<std::string*>; for (std::string* s : *($1->tl)) b1tl->push_back(s);
        std::list<std::string*> *b1fl = new std::list<std::string*>; for (std::string* s : *($1->fl)) b1tl->push_back(s);
        std::list<std::string*> *b2tl = new std::list<std::string*>; for (std::string* s : *($3->tl)) b1tl->push_back(s);
        std::list<std::string*> *b2fl = new std::list<std::string*>; for (std::string* s : *($3->fl)) b1tl->push_back(s);

        // mend the patches in first exp's fl
        for (std::string* s : *b1fl) *s = *x;

        // propagate the other lists
        $$->fl = b2fl;
        $$->tl = b1tl;
        for (std::string* s : *b2tl) $$->fl->push_back(s);

        // resulting code has first exp's code, then label "x", then second one's code
        for (IlocCode c : *($1->code)) $$->code->push_back(c);
        $$->code->push_back(IlocCode(x, NOP, NULL, NULL, NULL));
        for (IlocCode c : *($3->code)) $$->code->push_back(c);

    } | 
    exp_log_and                                 { $$ = $1; };
exp_log_and: 
    exp_log_and TK_OC_AND exp_bit_or {
        $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number));

        /* intermediate code generation */
        
        std::string *x = createLabel();
        
        // make a deep copy of the tl and fl lists
        std::list<std::string*> *b1tl = new std::list<std::string*>; for (std::string* s : *($1->tl)) b1tl->push_back(s);
        std::list<std::string*> *b1fl = new std::list<std::string*>; for (std::string* s : *($1->fl)) b1tl->push_back(s);
        std::list<std::string*> *b2tl = new std::list<std::string*>; for (std::string* s : *($3->tl)) b1tl->push_back(s);
        std::list<std::string*> *b2fl = new std::list<std::string*>; for (std::string* s : *($3->fl)) b1tl->push_back(s);

        // mend the patches in first exp's fl
        for (std::string* s : *b1tl) *s = *x;

        // propagate the other lists
        $$->tl = b2tl;
        $$->fl = b1fl;
        for (std::string* s : *b2fl) $$->fl->push_back(s);

        // resulting code has first exp's code, then label "x", then second one's code
        for (IlocCode c : *($1->code)) $$->code->push_back(c);
        $$->code->push_back(IlocCode(x, NOP, NULL, NULL, NULL));
        for (IlocCode c : *($3->code)) $$->code->push_back(c);

    } | 
    exp_bit_or                                  { $$ = $1; };
exp_bit_or: 
    exp_bit_or '|' exp_bit_and                  { $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number)); } | 
    exp_bit_and                                 { $$ = $1; };
exp_bit_and: 
    exp_bit_and '&' exp_relat_1                 { $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number)); } | 
    exp_relat_1                                 { $$ = $1; };
exp_relat_1: 
    exp_relat_1 TK_OC_EQ exp_relat_2    { 
        $$ = create_node_binary_operation($2, $1, $3, InferTypeEqNeq($1->nodeType, $3->nodeType, $2->line_number)); 

        /* intermediate code generation */
        
        // create new register name to save the result
        std::string *newRegister = createRegister();
        delete $$->local;
        $$->local = newRegister;

        // resulting code has first exp's code, then second one's code, then EQ instruction
        for (IlocCode c : *($1->code)) $$->code->push_back(c);
        for (IlocCode c : *($3->code)) $$->code->push_back(c);

        std::string exp1local = std::string(*($1->local));
        std::string exp2local = std::string(*($3->local));

        std::string *flPatch = new std::string;
        std::string *tlPatch = new std::string;

        $$->code->push_back(IlocCode(CMP_EQ, exp1local, exp2local, *newRegister));
        std::string *newRegister2 = new std::string; *newRegister2 = std::string(*newRegister);
        $$->code->push_back(IlocCode(CBR, newRegister2, tlPatch, flPatch));

        // patch for future mend
        $$->tl->push_back(tlPatch);
        $$->fl->push_back(flPatch);

        } | 
    exp_relat_1 TK_OC_NE exp_relat_2 { 
        $$ = create_node_binary_operation($2, $1, $3, InferTypeEqNeq($1->nodeType, $3->nodeType, $2->line_number)); 

        /* intermediate code generation */
        
        // create new register name to save the result
        std::string *newRegister = createRegister();
        delete $$->local;
        $$->local = newRegister;

        // resulting code has first exp's code, then second one's code, then EQ instruction
        for (IlocCode c : *($1->code)) $$->code->push_back(c);
        for (IlocCode c : *($3->code)) $$->code->push_back(c);

        std::string exp1local = std::string(*($1->local));
        std::string exp2local = std::string(*($3->local));

        std::string *flPatch = new std::string;
        std::string *tlPatch = new std::string;

        $$->code->push_back(IlocCode(CMP_NE, exp1local, exp2local, *newRegister));
        std::string *newRegister2 = new std::string; *newRegister2 = std::string(*newRegister);
        $$->code->push_back(IlocCode(CBR, newRegister2, tlPatch, flPatch));

        // patch for future mend
        $$->tl->push_back(tlPatch);
        $$->fl->push_back(flPatch);

        } | 
    exp_relat_2                                 { $$ = $1; };
exp_relat_2: 
    exp_relat_2 TK_OC_LE exp_sum {
        $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number));

        /* intermediate code generation */
        
        // create new register name to save the result
        std::string *newRegister = createRegister();
        delete $$->local;
        $$->local = newRegister;

        // resulting code has first exp's code, then second one's code, then EQ instruction
        for (IlocCode c : *($1->code)) $$->code->push_back(c);
        for (IlocCode c : *($3->code)) $$->code->push_back(c);

        std::string exp1local = std::string(*($1->local));
        std::string exp2local = std::string(*($3->local));

        std::string *flPatch = new std::string;
        std::string *tlPatch = new std::string;

        $$->code->push_back(IlocCode(CMP_LE, exp1local, exp2local, *newRegister));
        std::string *newRegister2 = new std::string; *newRegister2 = std::string(*newRegister);
        $$->code->push_back(IlocCode(CBR, newRegister2, tlPatch, flPatch));

        // patch for future mend
        $$->tl->push_back(tlPatch);
        $$->fl->push_back(flPatch);

    } | 
    exp_relat_2 TK_OC_GE exp_sum {
        $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number));

        /* intermediate code generation */
        
        // create new register name to save the result
        std::string *newRegister = createRegister();
        delete $$->local;
        $$->local = newRegister;

        // resulting code has first exp's code, then second one's code, then EQ instruction
        for (IlocCode c : *($1->code)) $$->code->push_back(c);
        for (IlocCode c : *($3->code)) $$->code->push_back(c);

        std::string exp1local = std::string(*($1->local));
        std::string exp2local = std::string(*($3->local));

        std::string *flPatch = new std::string;
        std::string *tlPatch = new std::string;

        $$->code->push_back(IlocCode(CMP_GE, exp1local, exp2local, *newRegister));
        std::string *newRegister2 = new std::string; *newRegister2 = std::string(*newRegister);
        $$->code->push_back(IlocCode(CBR, newRegister2, tlPatch, flPatch));

        // patch for future mend
        $$->tl->push_back(tlPatch);
        $$->fl->push_back(flPatch);

    } | 
    exp_relat_2 '<' exp_sum {
        $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number));

        /* intermediate code generation */
        
        // create new register name to save the result
        std::string *newRegister = createRegister();
        delete $$->local;
        $$->local = newRegister;

        // resulting code has first exp's code, then second one's code, then EQ instruction
        for (IlocCode c : *($1->code)) $$->code->push_back(c);
        for (IlocCode c : *($3->code)) $$->code->push_back(c);

        std::string exp1local = std::string(*($1->local));
        std::string exp2local = std::string(*($3->local));

        std::string *flPatch = new std::string;
        std::string *tlPatch = new std::string;

        $$->code->push_back(IlocCode(CMP_LT, exp1local, exp2local, *newRegister));
        std::string *newRegister2 = new std::string; *newRegister2 = std::string(*newRegister);
        $$->code->push_back(IlocCode(CBR, newRegister2, tlPatch, flPatch));

        // patch for future mend
        $$->tl->push_back(tlPatch);
        $$->fl->push_back(flPatch);

    } | 
    exp_relat_2 '>' exp_sum {
        $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number));

        /* intermediate code generation */
        
        // create new register name to save the result
        std::string *newRegister = createRegister();
        delete $$->local;
        $$->local = newRegister;

        // resulting code has first exp's code, then second one's code, then EQ instruction
        for (IlocCode c : *($1->code)) $$->code->push_back(c);
        for (IlocCode c : *($3->code)) $$->code->push_back(c);

        std::string exp1local = std::string(*($1->local));
        std::string exp2local = std::string(*($3->local));

        std::string *flPatch = new std::string;
        std::string *tlPatch = new std::string;

        $$->code->push_back(IlocCode(CMP_GT, exp1local, exp2local, *newRegister));
        std::string *newRegister2 = new std::string; *newRegister2 = std::string(*newRegister);
        $$->code->push_back(IlocCode(CBR, newRegister2, tlPatch, flPatch));

        // patch for future mend
        $$->tl->push_back(tlPatch);
        $$->fl->push_back(flPatch);

    } | 
    exp_sum                                     { $$ = $1; };
exp_sum:
    exp_sum '+' exp_mult {
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

        /* intermediate code generation */

        // create new register name to save the result
        std::string *newRegister = createRegister();
        delete $$->local;
        $$->local = newRegister;

        // resulting code has first exp's code, then second one's code, then ADD instruction
        for (IlocCode c : *($1->code)) $$->code->push_back(c);
        for (IlocCode c : *($3->code)) $$->code->push_back(c);
        std::string exp1local = std::string(*($1->local));
        std::string exp2local = std::string(*($3->local));
        $$->code->push_back(IlocCode(ADD, exp1local, exp2local, *newRegister));

    } | 
    exp_sum '-' exp_mult {
        $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number));

        /* intermediate code generation */

        // create new register name to save the result
        std::string *newRegister = createRegister();
        delete $$->local;
        $$->local = newRegister;

        // resulting code has first exp's code, then second one's code, then SUB instruction
        for (IlocCode c : *($1->code)) $$->code->push_back(c);
        for (IlocCode c : *($3->code)) $$->code->push_back(c);
        std::string exp1local = std::string(*($1->local));
        std::string exp2local = std::string(*($3->local));
        $$->code->push_back(IlocCode(SUB, exp1local, exp2local, *newRegister));

    } | 
    exp_mult { $$ = $1; };
exp_mult: 
    exp_mult '*' exp_pow {
        $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number));

        /* intermediate code generation */

        // create new register name to save the result
        std::string *newRegister = createRegister();
        delete $$->local;
        $$->local = newRegister;

        // resulting code has first exp's code, then second one's code, then MULT instruction
        for (IlocCode c : *($1->code)) $$->code->push_back(c);
        for (IlocCode c : *($3->code)) $$->code->push_back(c);
        std::string exp1local = std::string(*($1->local));
        std::string exp2local = std::string(*($3->local));
        $$->code->push_back(IlocCode(MULT, exp1local, exp2local, *newRegister));

    } | 
    exp_mult '/' exp_pow {
        $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number));

        /* intermediate code generation */

        // create new register name to save the result
        std::string *newRegister = createRegister();
        delete $$->local;
        $$->local = newRegister;

        // resulting code has first exp's code, then second one's code, then DIV instruction
        for (IlocCode c : *($1->code)) $$->code->push_back(c);
        for (IlocCode c : *($3->code)) $$->code->push_back(c);
        std::string exp1local = std::string(*($1->local));
        std::string exp2local = std::string(*($3->local));
        $$->code->push_back(IlocCode(DIV, exp1local, exp2local, *newRegister));

    } | 
    exp_mult '%' exp_pow                        { $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number)); } | 
    exp_pow                                     { $$ = $1; };
exp_pow: 
    exp_pow '^' unary_exp                       { $$ = create_node_binary_operation($2, $1, $3, InferType($1->nodeType, $3->nodeType, $2->line_number)); } | 
    unary_exp                                   { $$ = $1; };

unary_exp: 
    unary_op unary_exp  {
        $$ = create_node_unary_operation($1, $2, InferType($2->nodeType, NODE_TYPE_BOOL, $1->line_number));

        $$->code = $2->code;
        
        // create new register name to save the result
        std::string *newRegister = createRegister();
        delete $$->local;
        $$->local = newRegister;

        std::string newRegister2 = createRegisterDirect();

        if ($1->tokenValue.character == '-')
        {
            $$->code->push_back(IlocCode(LOADI, std::string("-1"), nullstr, newRegister2));
            $$->code->push_back(IlocCode(MULT, *($2->local), newRegister2, *newRegister));
        }

    } | 
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
    call_func_command  { 
        $$ = $1;

        std::string *newRegister = createRegister();
        delete $$->local;
        $$->local = newRegister;
        $$->code->push_back(IlocCode(LOADAI, std::string("rsp"), std::string("12"), *newRegister));
     };

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
        case ERR_UNDECLARED:                    printf("ERR_UNDECLARED: %s \"%s\" has not been declared.\n", nat, identifier); break;
        case ERR_DECLARED:                      printf("ERR_DECLARED: %s \"%s\" cannot be declared. Name has already been used in this scope.\n", nat, identifier); break;
        case ERR_VARIABLE:                      printf("ERR_VARIABLE: Variable \"%s\" has been used as vector or function.\n", identifier); break;
        case ERR_VECTOR:                        printf("ERR_VECTOR: Vector \"%s\" has been used as variable or function.\n", identifier); break;
        case ERR_FUNCTION:                      printf("ERR_FUNCTION: Function \"%s\" has been used as variable or vector.\n", identifier); break;
        case ERR_WRONG_TYPE:                    printf("ERR_WRONG_TYPE: %s \"%s\" cannot be attributed a value of a different type.\n", nat, identifier); break;
        case ERR_STRING_TO_X:
            if (identifier == NULL)           { printf("ERR_STRING_TO_X: String cannot be implicitly converted.\n"); break; }
            else                              { printf("ERR_STRING_TO_X: String \"%s\" cannot be implicitly converted.\n", identifier); break; }
        case ERR_CHAR_TO_X:
            if (identifier == NULL)           { printf("ERR_CHAR_TO_X: Char cannot be implicitly converted.\n"); break; }
            else                              { printf("ERR_CHAR_TO_X: Char \"%s\" cannot be implicitly converted.\n", identifier); break; }
        case ERR_STRING_SIZE:                   printf("ERR_STRING_SIZE: String \"%s\" cannot be attributed a string of different size.\n", identifier); break;
        case ERR_MISSING_ARGS:                  printf("ERR_MISSING_ARGS: Function \"%s\" cannot be called with less arguments than declared.\n", identifier); break;
        case ERR_EXCESS_ARGS:                   printf("ERR_EXCESS_ARGS: Function \"%s\" cannot be called with more arguments than declared.\n", identifier); break;
        case ERR_WRONG_TYPE_ARGS:               printf("ERR_WRONG_TYPE_ARGS: Function \"%s\" is called with arguments of different types than declared.\n", identifier); break;
        case ERR_WRONG_PAR_INPUT:               printf("ERR_WRONG_PAR_INPUT: Input command can only receive an integer or float variable.\n"); break;
        case ERR_WRONG_PAR_OUTPUT:              printf("ERR_WRONG_PAR_OUTPUT: Output command can only receive an integer or float variable/literal.\n"); break;
        case ERR_WRONG_PAR_RETURN:              printf("ERR_WRONG_PAR_RETURN: Cannot return different type than declared for function \"%s\".\n", identifier); break;
        case ERR_WRONG_PAR_SHIFT:               printf("ERR_WRONG_PAR_SHIFT: Shift command can only receive an integer less than 16.\n"); break;
        default:                                printf("Unidentified error.\n"); break;
    }

    exit(err_code);

}

NodeType InferTypePlus(NodeType t1, NodeType t2, int line) {
    if (t1 == NODE_TYPE_STRING && t2 == NODE_TYPE_STRING)
        return NODE_TYPE_STRING;

    return InferType(t1, t2, line);
}

NodeType InferTypeTernary(NodeType t1, NodeType t2, int line) {
    if (t1 == NODE_TYPE_STRING && t2 == NODE_TYPE_STRING)
        return NODE_TYPE_STRING;
    if (t1 == NODE_TYPE_CHAR && t2 == NODE_TYPE_CHAR)
        return NODE_TYPE_CHAR;

    return InferType(t1, t2, line);
}

NodeType InferTypeEqNeq(NodeType t1, NodeType t2, int line) {
    if (t1 == NODE_TYPE_STRING && t2 == NODE_TYPE_STRING)
        return NODE_TYPE_BOOL;
    if (t1 == NODE_TYPE_CHAR && t2 == NODE_TYPE_CHAR)
        return NODE_TYPE_BOOL;

    return InferType(t1, t2, line);
}

NodeType InferType(NodeType t1, NodeType t2, int line) {
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
    // PrintAll((Node*) arvore);
    PrintIlocCode(*((Node*) arvore)->code);
}

void libera (void *arvore) {
    for (IlocCode c : *(((Node *)arvore)->code))
    {
        if(c.label != NULL) delete c.label;
        if(c.firstArg != NULL) delete c.firstArg;
        if(c.secondArg != NULL) delete c.secondArg;
        if(c.thirdArg != NULL) delete c.thirdArg;
    } 

    FreeTree((Node*) arvore);
}