%{
    #include "stdio.h"

extern int yylineno;
int yylex(void);
void yyerror (char const *s);
%}

%define parse.lac full
%define parse.error detailed

%token TK_PR_INT
%token TK_PR_FLOAT
%token TK_PR_BOOL
%token TK_PR_CHAR
%token TK_PR_STRING
%token TK_PR_IF
%token TK_PR_THEN
%token TK_PR_ELSE
%token TK_PR_WHILE
%token TK_PR_DO
%token TK_PR_INPUT
%token TK_PR_OUTPUT
%token TK_PR_RETURN
%token TK_PR_CONST
%token TK_PR_STATIC
%token TK_PR_FOREACH
%token TK_PR_FOR
%token TK_PR_SWITCH
%token TK_PR_CASE
%token TK_PR_BREAK
%token TK_PR_CONTINUE
%token TK_PR_CLASS
%token TK_PR_PRIVATE
%token TK_PR_PUBLIC
%token TK_PR_PROTECTED
%token TK_PR_END
%token TK_PR_DEFAULT
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE
%token TK_OC_AND
%token TK_OC_OR
%token TK_OC_SL
%token TK_OC_SR
%token TK_OC_FORWARD_PIPE
%token TK_OC_BASH_PIPE
%token TK_LIT_INT
%token TK_LIT_FLOAT
%token TK_LIT_FALSE
%token TK_LIT_TRUE
%token TK_LIT_CHAR
%token TK_LIT_STRING
%token TK_IDENTIFICADOR
%token TOKEN_ERRO


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

io_command: TK_PR_INPUT TK_IDENTIFICADOR | TK_PR_OUTPUT id_or_literal;
id_or_literal: TK_IDENTIFICADOR | literal;

call_func_command: TK_IDENTIFICADOR '(' func_parameters_list ')' | TK_IDENTIFICADOR '(' ')';
func_parameters_list: expression | func_parameters_list ',' expression;

shift_command: TK_IDENTIFICADOR maybe_vector shift_operators TK_LIT_INT;
shift_operators: TK_OC_SL | TK_OC_SR;

return_command: TK_PR_RETURN expression | TK_PR_BREAK | TK_PR_CONTINUE ;

flux_control_command: conditional_flux_control | for_flux_control | while_flux_control;

conditional_flux_control: TK_PR_IF '(' expression ')' command_block maybe_else;
maybe_else: TK_PR_ELSE command_block | %empty;

for_flux_control: TK_PR_FOR '(' attribution_command ':' expression ':' attribution_command ')' command_block ';';
while_flux_control: TK_PR_WHILE '(' expression ')' TK_PR_DO command_block ';';

expression: expression TK_OC_OR exp_log_or | exp_log_or;
exp_log_or: exp_log_or TK_OC_AND exp_log_and | exp_log_and;
exp_log_and: exp_log_and '|' exp_bit_or | exp_bit_or;
exp_bit_or: exp_bit_or '&' exp_bit_and | exp_bit_and;
exp_bit_and: exp_bit_and TK_OC_EQ exp_relat | exp_bit_and TK_OC_NE exp_relat | exp_relat;
exp_relat: exp_relat TK_OC_LE exp_sum | exp_relat TK_OC_GE exp_sum | exp_relat '<' exp_sum | exp_relat '>' exp_sum | exp_sum;
exp_sum: exp_sum '+' exp_mult | exp_sum '-' exp_mult | exp_mult;
exp_mult: exp_mult '*' exp_pow | exp_mult '/' exp_pow | exp_mult '%' exp_pow | exp_pow;
exp_pow: exp_pow '^' unary_exp | unary_exp;

unary_exp: unary_op unary_exp | operand;
unary_op: '+' | '-' | '!' | '&' | '*' | '?' | '#'; 
operand: TK_IDENTIFICADOR maybe_vector | literal | call_func_command | '(' expression ')';

%%

void yyerror (char const *s) {
    printf("[ERROR, LINE %d] %s.\n", yylineno, s);
}
