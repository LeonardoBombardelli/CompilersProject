%{
    #include "stdio.h"
    #include "definitions.h"

extern int yylineno;
int yylex(void);
void yyerror (char const *s);
%}

%define parse.lac full
%define parse.error detailed

%union 
{
    ValorLexico* valor_lexico;
    Node* node;
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

%type<node> programa
%type<node> program_list

%type<node> maybe_vector
%type<node> var
%type<node> type
%type<node> literal

%type<node> func_definition
%type<node> func_header
%type<node> func_header_list
%type<node> func_header_list_iterator
%type<node> simple_command
%type<node> command_block
%type<node> sequence_simple_command
%type<node> local_var_declaration
%type<node> local_var_atribution
%type<node> attribution_command
%type<node> io_command
%type<node> call_func_command
%type<node> func_parameters_list
%type<node> shift_command
%type<node> shift_operators
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
%type<node> unary_op
%type<node> operand

%%
programa: program_list;
program_list: global_var program_list | func_definition program_list | %empty;


maybe_const: %empty | TK_PR_CONST;
maybe_static: %empty | TK_PR_STATIC;
maybe_vector: %empty | '[' expression ']';

var: TK_IDENTIFICADOR '[' TK_LIT_INT ']' | TK_IDENTIFICADOR;
type: TK_PR_INT | TK_PR_FLOAT | TK_PR_CHAR | TK_PR_BOOL | TK_PR_STRING;
literal: TK_LIT_INT | TK_LIT_FLOAT | TK_LIT_FALSE | TK_LIT_TRUE | TK_LIT_CHAR | TK_LIT_STRING;

global_var: maybe_static type global_var_list ';';
global_var_list: var ',' global_var_list | var;


func_definition: func_header command_block;

func_header: maybe_static type TK_IDENTIFICADOR '(' func_header_list ')';
func_header_list: %empty | maybe_const type TK_IDENTIFICADOR func_header_list_iterator;
func_header_list_iterator: ',' maybe_const type TK_IDENTIFICADOR func_header_list_iterator | %empty;

simple_command: command_block | local_var_declaration | attribution_command | io_command | call_func_command | shift_command | return_command | flux_control_command;

command_block: '{' sequence_simple_command '}';
sequence_simple_command: simple_command ';' sequence_simple_command | %empty;

local_var_declaration: maybe_static maybe_const type TK_IDENTIFICADOR local_var_atribution;
local_var_atribution: %empty | TK_OC_LE literal | TK_OC_LE TK_IDENTIFICADOR;

attribution_command: TK_IDENTIFICADOR maybe_vector '=' expression;

io_command: TK_PR_INPUT TK_IDENTIFICADOR | TK_PR_OUTPUT TK_IDENTIFICADOR | TK_PR_OUTPUT literal;

call_func_command: TK_IDENTIFICADOR '(' func_parameters_list ')' | TK_IDENTIFICADOR '(' ')';
func_parameters_list: expression | func_parameters_list ',' expression;

shift_command: TK_IDENTIFICADOR maybe_vector shift_operators TK_LIT_INT;
shift_operators: TK_OC_SL | TK_OC_SR;

return_command: TK_PR_RETURN expression | TK_PR_BREAK | TK_PR_CONTINUE ;

flux_control_command: conditional_flux_control | for_flux_control | while_flux_control;

conditional_flux_control: TK_PR_IF '(' expression ')' command_block maybe_else;
maybe_else: TK_PR_ELSE command_block | %empty;

for_flux_control: TK_PR_FOR '(' attribution_command ':' expression ':' attribution_command ')' command_block;
while_flux_control: TK_PR_WHILE '(' expression ')' TK_PR_DO command_block;

expression: exp_log_or '?' expression ':' expression | exp_log_or;
exp_log_or: exp_log_or TK_OC_OR exp_log_and | exp_log_and;
exp_log_and: exp_log_and TK_OC_AND exp_bit_or | exp_bit_or;
exp_bit_or: exp_bit_or '|' exp_bit_and | exp_bit_and;
exp_bit_and: exp_bit_and '&' exp_relat_1 | exp_relat_1;
exp_relat_1: exp_relat_1 TK_OC_EQ exp_relat_2 | exp_relat_1 TK_OC_NE exp_relat_2 | exp_relat_2;
exp_relat_2: exp_relat_2 TK_OC_LE exp_sum | exp_relat_2 TK_OC_GE exp_sum | exp_relat_2 '<' exp_sum | exp_relat_2 '>' exp_sum | exp_sum;
exp_sum: exp_sum '+' exp_mult | exp_sum '-' exp_mult | exp_mult;
exp_mult: exp_mult '*' exp_pow | exp_mult '/' exp_pow | exp_mult '%' exp_pow | exp_pow;
exp_pow: exp_pow '^' unary_exp | unary_exp;

unary_exp: unary_op unary_exp | operand;
unary_op: '+' | '-' | '!' | '&' | '*' | '?' | '#'; 
operand: TK_IDENTIFICADOR maybe_vector | literal | call_func_command | '(' expression ')';

%%
// Referencia para precedencia e associatividade dos operadores nas expressoes: https://en.cppreference.com/w/cpp/language/operator_precedence


void yyerror (char const *s) {
    printf("[ERROR, LINE %d] %s.\n", yylineno, s);
}
