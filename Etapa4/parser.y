%{
    #include <cstdio>
    #include <map>
    #include "AST.hpp"
    #include "Scope.hpp"

    extern "C" int yylex();

    extern int yylineno;
    extern void *arvore;
    int yylex(void);
    Node* last_command_of_chain(Node* n);
    void yyerror (char const *s);


    char* auxScopeName = NULL;
    char* auxLiteral = (char*) malloc(sizeof(char)*500);

    std::map<char*, SymbolTableEntry*> *tempVarMap = new std::map<char*, SymbolTableEntry*>;    // reusable map of vars
    std::list<FuncArgument *> *tempFuncArgList = new std::list<FuncArgument *>;                 // reusable list of function arguments
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
    %empty { DestroyStack(); $$ = NULL; free(auxLiteral); }


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
            DestroySymbolTableEntry(scopeStack->back()->symbolTable[auxLiteral]);

        scopeStack->back()->symbolTable[auxLiteral] = ste;
    } |
    TK_LIT_FLOAT  {
        $$ = create_node_literal($1, NODE_TYPE_FLOAT); 

        // set auxLiteral to be the lexeme
        memset(auxLiteral, 0, 500);
        sprintf(auxLiteral, "%f", $1->tokenValue.float);

        SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_FLOAT, $1->line_number, TABLE_NATURE_LIT, NULL, 0);

        if (SymbolIsInSymbolTable(auxLiteral, scopeStack->back()))
            DestroySymbolTableEntry(scopeStack->back()->symbolTable[auxLiteral]);

        scopeStack->back()->symbolTable[auxLiteral] = ste;
    } |
    TK_LIT_FALSE  {
        $$ = create_node_literal($1, NODE_TYPE_BOOL);  

        // set auxLiteral to be the lexeme
        memset(auxLiteral, 0, 500);
        sprintf(auxLiteral, "false");

        SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_BOOL, $1->line_number, TABLE_NATURE_LIT, NULL, 0);

        if (SymbolIsInSymbolTable(auxLiteral, scopeStack->back()))
            DestroySymbolTableEntry(scopeStack->back()->symbolTable[auxLiteral]);

        scopeStack->back()->symbolTable[auxLiteral] = ste;
    } |
    TK_LIT_TRUE   {
        $$ = create_node_literal($1, NODE_TYPE_BOOL);  

        // set auxLiteral to be the lexeme
        memset(auxLiteral, 0, 500);
        sprintf(auxLiteral, "true");

        SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_BOOL, $1->line_number, TABLE_NATURE_LIT, NULL, 0);

        if (SymbolIsInSymbolTable(auxLiteral, scopeStack->back()))
            DestroySymbolTableEntry(scopeStack->back()->symbolTable[auxLiteral]);

        scopeStack->back()->symbolTable[auxLiteral] = ste;
    } |
    TK_LIT_CHAR   {
        $$ = create_node_literal($1, NODE_TYPE_CHAR);  

        // set auxLiteral to be the lexeme
        memset(auxLiteral, 0, 500);
        sprintf(auxLiteral, "\'%c\'", $1->tokenValue.character);

        SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_CHAR, $1->line_number, TABLE_NATURE_LIT, NULL, 0);

        if (SymbolIsInSymbolTable(auxLiteral, scopeStack->back()))
            DestroySymbolTableEntry(scopeStack->back()->symbolTable[auxLiteral]);

        scopeStack->back()->symbolTable[auxLiteral] = ste;
    } |
    TK_LIT_STRING {
        $$ = create_node_literal($1, NODE_TYPE_STRING);

        // set auxLiteral to be the lexeme
        memset(auxLiteral, 0, 500);
        sprintf(auxLiteral, "\"%s\"", $1->tokenValue.string);

        SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_STRING, $1->line_number, TABLE_NATURE_LIT, NULL, 0);

        if (SymbolIsInSymbolTable(auxLiteral, scopeStack->back()))
            DestroySymbolTableEntry(scopeStack->back()->symbolTable[auxLiteral]);

        scopeStack->back()->symbolTable[auxLiteral] = ste;
    };

global_var: 
    TK_IDENTIFICADOR {
        SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_INDEF, $1->line_number, TABLE_NATURE_VAR, NULL, 0);
        (*tempVarMap)[$1->tokenValue.string] = ste;
        $$ = NULL; 
        FreeValorLexico($1);
    } |
    TK_IDENTIFICADOR '[' TK_LIT_INT ']' {
        SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_INDEF, $1->line_number, TABLE_NATURE_VEC, NULL, $3->tokenValue.integer);
        (*tempVarMap)[$1->tokenValue.string] = ste;
        $$ = NULL; 
        FreeValorLexico($1); FreeValorLexico($2); FreeValorLexico($3); FreeValorLexico($4);
    };
global_var_declaration: 
    maybe_static type global_var_list ';' {

        // set type to all vars of list, and insert them in table
        std::map<char*, SymbolTableEntry*>::iterator it;
        for(it = tempVarMap->begin(); it != tempVarMap->end(); ++it)
        {
            it->second->symbolType = IntToSymbolType($2);
            scopeStack->back()->symbolTable[it->first] = it->second;
        }

        // free temp var map
        tempVarMap = new std::map<char*, SymbolTableEntry*>;

        $$ = NULL; 
        FreeValorLexico($4); 
    };
global_var_list: 
    global_var ',' global_var_list        { $$ = NULL; FreeValorLexico($2); } |
    global_var                            { $$ = NULL; };


func_definition:
    func_header command_block {
        // TODO: is it right????
        // remove function scope from stack
        scopeStack->pop_back();

        $1->n_function_declaration.firstCommand = $2;
        $$ = $1;
    };

func_header:
    maybe_static type TK_IDENTIFICADOR '(' func_header_list ')' {

        // create entry and add it to scope
        SymbolTableEntry* ste = CreateSymbolTableEntry(IntToSymbolType($2), $3->line_number, TABLE_NATURE_FUNC, tempFuncArgList, 0);
        scopeStack->back()->symbolTable[$3->tokenValue.string] = ste;

        // free temp func arg list
        tempFuncArgList = new std::list<FuncArgument *>;

        // update aux var with new scope name
        auxScopeName = strdup($3->tokenValue.string);

        $$ = create_node_function_declaration($3, NULL);
        FreeValorLexico($4); FreeValorLexico($6);
    };
func_header_list:
    %empty                                                          { $$ = NULL; } |
    maybe_const type TK_IDENTIFICADOR func_header_list_iterator     {

        // create funcargument and add it to global list
        FuncArgument* fa = CreateFuncArgument($3->tokenValue.string, IntToSymbolType($2));
        tempFuncArgList->push_back(fa);

        $$ = NULL;
        FreeValorLexico($3);
    };
func_header_list_iterator: 
    %empty                                                          { $$ = NULL; } |
    ',' maybe_const type TK_IDENTIFICADOR func_header_list_iterator {

        // create funcargument and add it to global list
        FuncArgument* fa = CreateFuncArgument($4->tokenValue.string, IntToSymbolType($3));
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
        /* create new scope and push it to scopeStack */
        Scope* newScope = CreateNewScope(auxScopeName);
        scopeStack.push_back(newScope);
    }

cmd_block_destroy_scope:
    %empty {
        /* pop current scope from scopeStack and free its memory */
        Scope* currentScope = scopeStack.back();
        DestroyScope(currentScope);
        scopeStack.pop_back();
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

        // set type to all vars of list, and insert them in table
        std::map<char*, SymbolTableEntry*>::iterator it;
        for(it = tempVarMap->begin(); it != tempVarMap->end(); ++it)
        {
            it->second->symbolType = IntToSymbolType($3);
            scopeStack->back()->symbolTable[it->first] = it->second;
        }

        // free temp var map
        tempVarMap = new std::map<char*, SymbolTableEntry*>;

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
        SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_INDEF, $1->line_number, TABLE_NATURE_VAR, NULL, 0);
        (*tempVarMap)[$1->tokenValue.string] = ste;
        $$ = NULL;
        FreeValorLexico($1);
    } |
    TK_IDENTIFICADOR TK_OC_LE literal {
        /* TODO: deal with vars of type string (need to update their size) */
        SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_INDEF, $1->line_number, TABLE_NATURE_VAR, NULL, 0);
        (*tempVarMap)[$1->tokenValue.string] = ste;
        $$ = create_node_var_init(create_node_var_access($1), $3);
        FreeValorLexico($2);
    } |
    TK_IDENTIFICADOR TK_OC_LE TK_IDENTIFICADOR {
        /* TODO: deal with vars of type string (need to update their size) */
        SymbolTableEntry* ste = CreateSymbolTableEntry(SYMBOL_TYPE_INDEF, $1->line_number, TABLE_NATURE_VAR, NULL, 0);
        (*tempVarMap)[$1->tokenValue.string] = ste;
        $$ = create_node_var_init(create_node_var_access($1), create_node_literal($3));
        FreeValorLexico($2);
    };

var_access:
    TK_IDENTIFICADOR                    { $$ = create_node_var_access($1); } | 
    TK_IDENTIFICADOR '[' expression ']' { $$ = create_node_vector_access(create_node_var_access($1), $3); FreeValorLexico($2); FreeValorLexico($4); };

attribution_command:
    var_access '=' expression { $$ = create_node_var_attr($1, $3); FreeValorLexico($2); };

io_command: 
    TK_PR_INPUT TK_IDENTIFICADOR    { $$ = create_node_input(create_node_var_access($2));  } | 
    TK_PR_OUTPUT TK_IDENTIFICADOR   { $$ = create_node_output(create_node_var_access($2)); } | 
    TK_PR_OUTPUT literal            { $$ = create_node_output($2); } ;

call_func_command:
    TK_IDENTIFICADOR '(' func_parameters_list ')' { /* take nodeType from symbol table */ $$ = create_node_function_call($1, $3); FreeValorLexico($2); FreeValorLexico($4);   } | 
    TK_IDENTIFICADOR '(' ')'                      { /* take nodeType from symbol table */ $$ = create_node_function_call($1, NULL); FreeValorLexico($2); FreeValorLexico($3); };
func_parameters_list: 
    expression                           { $$ = $1; } | 
    func_parameters_list ',' expression  { last_command_of_chain($1)->sequenceNode = $3; $$ = $1; FreeValorLexico($2); };

shift_command:
    var_access TK_OC_SL TK_LIT_INT { $$ = create_node_shift_left($1, create_node_literal($3));  FreeValorLexico($2); } |
    var_access TK_OC_SR TK_LIT_INT { $$ = create_node_shift_right($1, create_node_literal($3)); FreeValorLexico($2); };

return_command:
    TK_PR_RETURN expression { $$ = create_node_return($2); };

flux_control_command: 
    conditional_flux_control { $$ = $1; } | 
    for_flux_control         { $$ = $1; } | 
    while_flux_control       { $$ = $1; };

conditional_flux_control: 
    TK_PR_IF '(' expression ')' command_block maybe_else { $$ = create_node_if($3, $5, $6); FreeValorLexico($2); FreeValorLexico($4); };
maybe_else: 
    TK_PR_ELSE command_block { $$ = $2;   } | 
    %empty                   { $$ = NULL; };

for_flux_control: 
    TK_PR_FOR '(' attribution_command ':' expression ':' attribution_command ')' command_block {
        $$ = create_node_for_loop($3, $5, $7, $9);
        FreeValorLexico($2); FreeValorLexico($4); FreeValorLexico($6); FreeValorLexico($8);
    };
while_flux_control:
    TK_PR_WHILE '(' expression ')' TK_PR_DO command_block {
        $$ = create_node_while_loop($3, $6);
         FreeValorLexico($2); FreeValorLexico($4);
    };

expression: 
    exp_log_or '?' expression ':' expression    { $$ = create_node_ternary_operation($1, $3, $5); FreeValorLexico($2); FreeValorLexico($4); } | 
    exp_log_or                                  { $$ = $1; };
exp_log_or: 
    exp_log_or TK_OC_OR exp_log_and             { /* TODO */ $$ = create_node_binary_operation($2, $1, $3); } | 
    exp_log_and                                 { $$ = $1; };
exp_log_and: 
    exp_log_and TK_OC_AND exp_bit_or            { $$ = create_node_binary_operation($2, $1, $3); } | 
    exp_bit_or                                  { $$ = $1; };
exp_bit_or: 
    exp_bit_or '|' exp_bit_and                  { $$ = create_node_binary_operation($2, $1, $3); } | 
    exp_bit_and                                 { $$ = $1; };
exp_bit_and: 
    exp_bit_and '&' exp_relat_1                 { $$ = create_node_binary_operation($2, $1, $3); } | 
    exp_relat_1                                 { $$ = $1; };
exp_relat_1: 
    exp_relat_1 TK_OC_EQ exp_relat_2            { $$ = create_node_binary_operation($2, $1, $3); } | 
    exp_relat_1 TK_OC_NE exp_relat_2            { $$ = create_node_binary_operation($2, $1, $3); } | 
    exp_relat_2                                 { $$ = $1; };
exp_relat_2: 
    exp_relat_2 TK_OC_LE exp_sum                { $$ = create_node_binary_operation($2, $1, $3); } | 
    exp_relat_2 TK_OC_GE exp_sum                { $$ = create_node_binary_operation($2, $1, $3); } | 
    exp_relat_2 '<' exp_sum                     { $$ = create_node_binary_operation($2, $1, $3); } | 
    exp_relat_2 '>' exp_sum                     { $$ = create_node_binary_operation($2, $1, $3); } | 
    exp_sum                                     { $$ = $1; };
exp_sum:
    exp_sum '+' exp_mult                        { $$ = create_node_binary_operation($2, $1, $3); } | 
    exp_sum '-' exp_mult                        { $$ = create_node_binary_operation($2, $1, $3); } | 
    exp_mult                                    { $$ = $1; };
exp_mult: 
    exp_mult '*' exp_pow                        { $$ = create_node_binary_operation($2, $1, $3); } | 
    exp_mult '/' exp_pow                        { $$ = create_node_binary_operation($2, $1, $3); } | 
    exp_mult '%' exp_pow                        { $$ = create_node_binary_operation($2, $1, $3); } | 
    exp_pow                                     { $$ = $1; };
exp_pow: 
    exp_pow '^' unary_exp                       { $$ = create_node_binary_operation($2, $1, $3); } | 
    unary_exp                                   { $$ = $1; };

unary_exp: 
    unary_op unary_exp  { $$ = create_node_unary_operation($1, $2, $2->nodeType); } | 
    operand             { $$ = $1; };
unary_op: 
    '+' { $$ = $1; } | 
    '-' { $$ = $1; } | 
    '!' { $$ = $1; } | 
    '&' { $$ = $1; /* TODO: unused? */ } | 
    '*' { $$ = $1; /* TODO: unused? */ } | 
    '?' { $$ = $1; /* TODO: unused? */ } | 
    '#' { $$ = $1; /* TODO: unused? */ }; 
operand:
    '(' expression ')' { $$ = $2; FreeValorLexico($1); FreeValorLexico($3); } | 
    var_access         { $$ = $1; } | 
    literal            { $$ = $1; } | 
    call_func_command  { $$ = $1; };

%%
// Referencia para precedencia e associatividade dos operadores nas expressoes: https://en.cppreference.com/w/cpp/language/operator_precedence


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