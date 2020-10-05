%{
    #include "stdio.h"
    #include "AST.h"

extern int yylineno;
extern void *arvore;
int yylex(void);
Node* last_command_of_chain(Node* n);
void yyerror (char const *s);
%}

%define parse.lac full
%define parse.error detailed

%union 
{
    struct valorLexico* valor_lexico;
    struct node* node;
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
%type<node> program_list
%type<node> maybe_const
%type<node> maybe_static
%type<node> type
%type<node> literal
%type<node> global_var
%type<node> global_var_declaration
%type<node> global_var_list
%type<node> func_definition
%type<valor_lexico> func_header
%type<node> func_header_list
%type<node> func_header_list_iterator
%type<node> simple_command
%type<node> command_block
%type<node> sequence_simple_command
%type<node> local_var_declaration
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
    program_list { $$ = $1; arvore = $$; };
program_list: 
    global_var_declaration program_list   { $$ = $2; /* ignore global vars */ } |
    func_definition program_list          { $1->sequenceNode = $2; $$ = $1; } |
    %empty                                { $$ = NULL; };


maybe_const: 
    %empty        { $$ = NULL; } |
    TK_PR_CONST   { $$ = NULL; };
maybe_static: 
    %empty        { $$ = NULL; } |
    TK_PR_STATIC  { $$ = NULL; };

type:
    TK_PR_INT     { $$ = NULL; /* ignore types */ } |
    TK_PR_FLOAT   { $$ = NULL;                    } |
    TK_PR_CHAR    { $$ = NULL;                    } |
    TK_PR_BOOL    { $$ = NULL;                    } |
    TK_PR_STRING  { $$ = NULL;                    };
literal: 
    TK_LIT_INT    { $$ = create_node_literal($1); } |
    TK_LIT_FLOAT  { $$ = create_node_literal($1); } |
    TK_LIT_FALSE  { $$ = create_node_literal($1); } |
    TK_LIT_TRUE   { $$ = create_node_literal($1); } |
    TK_LIT_CHAR   { $$ = create_node_literal($1); } |
    TK_LIT_STRING { $$ = create_node_literal($1); };

global_var: 
    TK_IDENTIFICADOR '[' TK_LIT_INT ']'   { $$ = NULL; /* ignore global vars */ } |
    TK_IDENTIFICADOR                      { $$ = NULL;                          };
global_var_declaration: 
    maybe_static type global_var_list ';' { $$ = NULL; };
global_var_list: 
    global_var ',' global_var_list        { $$ = NULL; } |
    global_var                            { $$ = NULL; };


func_definition:
    func_header command_block { create_node_function_declaration($2, $1); };

func_header:
    maybe_static type TK_IDENTIFICADOR '(' func_header_list ')' { $$ = $3; /* ignore all but function name */ };
func_header_list:
    %empty                                                          { $$ = NULL; } |
    maybe_const type TK_IDENTIFICADOR func_header_list_iterator     { $$ = NULL; };
func_header_list_iterator: 
    ',' maybe_const type TK_IDENTIFICADOR func_header_list_iterator { $$ = NULL; } |
    %empty                                                          { $$ = NULL; };

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
    '{' sequence_simple_command '}' { $$ = $2; };
sequence_simple_command: 
    simple_command ';' sequence_simple_command  { last_command_of_chain($1)->sequenceNode = $3; $$ = $1; } |
    %empty                                      { $$ = NULL; };

local_var_declaration: 
    maybe_static maybe_const type TK_IDENTIFICADOR { $$ = NULL; } |
    maybe_static maybe_const type TK_IDENTIFICADOR TK_OC_LE literal {
        $$ = create_node_var_attr(create_node_var_access($4, NULL), $6);
    } |
    maybe_static maybe_const type TK_IDENTIFICADOR TK_OC_LE TK_IDENTIFICADOR {
        $$ = create_node_var_attr(create_node_var_access($4, NULL), create_node_literal($6));
    };

var_access:
    TK_IDENTIFICADOR                    { $$ = create_node_var_access($1, NULL); } | 
    TK_IDENTIFICADOR '[' expression ']' { $$ = create_node_var_access($1, $3);   };

attribution_command:
    var_access '=' expression { $$ = create_node_var_attr($1, $3); };

io_command: 
    TK_PR_INPUT TK_IDENTIFICADOR    { $$ = create_node_input($2);  } | 
    TK_PR_OUTPUT TK_IDENTIFICADOR   { $$ = create_node_output_lex($2); } | 
    TK_PR_OUTPUT literal            { $$ = create_node_output_nod($2); } ;

call_func_command:
    TK_IDENTIFICADOR '(' func_parameters_list ')' { $$ = create_node_function_call($1, $3);   } | 
    TK_IDENTIFICADOR '(' ')'                      { $$ = create_node_function_call($1, NULL); };
func_parameters_list: 
    expression                           { $$ = $1; } | 
    func_parameters_list ',' expression  { $1->sequenceNode = $3; $$ = $1; };

shift_command:
    var_access TK_OC_SL TK_LIT_INT { $$ = create_node_shift_left($1, create_node_literal($3));  } |
    var_access TK_OC_SR TK_LIT_INT { $$ = create_node_shift_right($1, create_node_literal($3)); };

return_command:
    TK_PR_RETURN expression { $$ = create_node_return($2); };

flux_control_command: 
    conditional_flux_control { $$ = $1; } | 
    for_flux_control         { $$ = $1; } | 
    while_flux_control       { $$ = $1; };

conditional_flux_control: 
    TK_PR_IF '(' expression ')' command_block maybe_else { $$ = create_node_if($3, $5, $6); };
maybe_else: 
    TK_PR_ELSE command_block { $$ = $2;   } | 
    %empty                   { $$ = NULL; };

for_flux_control: 
    TK_PR_FOR '(' attribution_command ':' expression ':' attribution_command ')' command_block { $$ = create_node_for_loop($3, $5, $7, $9); };
while_flux_control:
    TK_PR_WHILE '(' expression ')' TK_PR_DO command_block { $$ = create_node_while_loop($3, $6); };

expression: 
    exp_log_or '?' expression ':' expression    { $$ = create_node_ternary_operation($1, $3, $5); } | 
    exp_log_or                                  { $$ = $1; };
exp_log_or: 
    exp_log_or TK_OC_OR exp_log_and             { $$ = create_node_binary_operation($2, $1, $3); } | 
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
    unary_op unary_exp  { $$ = create_node_unary_operation($1, $2); } | 
    operand             { $$ = $1; };
unary_op: 
    '+' { $$ = $1; } | 
    '-' { $$ = $1; } | 
    '!' { $$ = $1; } | 
    '&' { $$ = $1; } | 
    '*' { $$ = $1; } | 
    '?' { $$ = $1; } | 
    '#' { $$ = $1; }; 
operand:
    var_access         { $$ = $1; } | 
    literal            { $$ = $1; } | 
    call_func_command  { $$ = $1; } | 
    '(' expression ')' { $$ = $2; };

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