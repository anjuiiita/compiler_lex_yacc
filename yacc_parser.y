
%{

#include <stdio.h>
#include <stdlib.h>
#define MAX 100

int yylex();
extern int yylineno;
extern char* yytext;
extern FILE *yyin, *yyout;
char *filename;

void yyerror (const char *mesg);
int success = 1;
#define YYDEBUG 1
char **stmt;
int lineno = 0;
%}

%union {
	char *ident;
	char* func_def;
	char * exp;
}


%token PLUS MINUS STAR SLASH SEMI LPAR RPAR DOT QUEST LBRACE RBRACE LBRACKET RBRACKET
%token COLON MOD TILDE PIPE AMP BANG DPIPE DAMP ASSIGN PLUSASSIGN MINUSASSIGN STARASSIGN SLASHASSIGN 
%token INCR DECR EQUALS NEQUAL GT GE LT LE TYPE CONST STRUCT FOR WHILE DO IF ELSE BREAK CONTINUE RETURN 
%token INTCONST REALCONST STRCONST CHARCONST ERROR DIRECTIVES 
%token SWITCH CASE DEFAULT SIZEOF HEADER DEFINE
%token <ident> IDENT 
//%type <ident> variables
//%type <exp> variable_exp

%left LPAR RPAR LBRACKET RBRACKET LBRACE RBRACE
%left PLUS MINUS MOD
%left STAR SLASH
%left EQUALS NEQUAL
%left GT GE LT LE
%left AMP PIPE BANG TILDE UMINUS DECR INCR
%left DAMP DPIPE
%left COMMA	

%right ASSIGN PLUSASSIGN MINUSASSIGN STARASSIGN SLASHASSIGN
%right QUEST COLON 

%nonassoc "then"
%nonassoc ELSE
%start program

//%type <func_def> function_definition stmt_specs func_declarator function_stmts type_spec id_list param_list param_decl stmt_declarator paranthesis_decl conditional_exp logical_or_exp logical_and_exp inclusive_or_exp and_exp equality_exp relational_exp addition_exp mult_exp cast_exp unary_exp variable_exp variables argument_exp_list assignment_exp initializer initializer_list

%%
program						: HEADER program                               
							| DEFINE variables program                	
							| program_unit_list							
							;
program_unit_list			: program_unit 									
							| program_unit_list program_unit       
							;
program_unit				: function_definition						
							| function_proto
							| stmt
							;
function_definition			: stmt_specs func_declarator function_stmts			
							;
function_proto				: stmt_specs func_declarator SEMI    				
							;
stmt						: stmt_specs init_declarator_list SEMI 				
							| stmt_specs SEMI									
							;
stmt_list					: stmt 												
							| stmt_list stmt									
							;
stmt_specs					: type_spec stmt_specs					
							| type_spec 									
							| CONST stmt_specs 								
							| CONST 										
							;
type_spec					: TYPE										
							| struct_spec			
							;
struct_spec					: STRUCT IDENT LBRACE struct_stmt_list RBRACE		
							| STRUCT LBRACE struct_stmt_list RBRACE				
							| STRUCT IDENT										
							;
struct_stmt_list			: struct_decl											
							| struct_stmt_list struct_decl							
							;
init_declarator_list		: init_declarator										
							| init_declarator_list COMMA init_declarator   			
							;
init_declarator				: stmt_declarator										
							| stmt_declarator ASSIGN initializer					
							;
struct_decl					: type_spec_list struct_declarator_list SEMI     
							;
type_spec_list				: type_spec type_spec_list							
							| type_spec												
							| CONST type_spec_list								
							| CONST													
							;
struct_declarator_list		: func_declarator										
							| struct_declarator_list COMMA func_declarator	
							;
func_declarator				: IDENT	
							| func_declarator LBRACKET conditional_exp RBRACKET							
							| func_declarator LBRACKET RBRACKET			
							| func_declarator LPAR param_list RPAR 					
							| func_declarator LPAR id_list RPAR 					
							| func_declarator LPAR RPAR 							
							;
stmt_declarator				: IDENT													
							| stmt_declarator LBRACKET conditional_exp RBRACKET		
							| stmt_declarator LBRACKET RBRACKET						
							;
param_list					: param_decl											
							| param_list COMMA param_decl							
							;
param_decl					: stmt_specs stmt_declarator							
							| stmt_specs paranthesis_decl					
							| stmt_specs											
							;
id_list						: IDENT													
							| id_list COMMA IDENT									
							;
initializer					: assignment_exp										
							| LBRACE initializer_list RBRACE						{ printf("initializer %s\n", yytext);}
							| LBRACE initializer_list COMMA RBRACE					{ printf("initializer %s\n", yytext);}
							;
initializer_list			: initializer											
							| initializer_list COMMA initializer    				
							;
type_name					: type_spec_list paranthesis_decl		
							| type_spec_list									
							;
paranthesis_decl			: LPAR paranthesis_decl RPAR					
							| paranthesis_decl LBRACKET conditional_exp RBRACKET
							| LBRACKET conditional_exp RBRACKET						
							| paranthesis_decl LBRACKET RBRACKET			
							| LBRACKET RBRACKET										
							| paranthesis_decl LPAR param_list RPAR     	
							| LPAR param_list RPAR									
							| paranthesis_decl LPAR RPAR					
							| LPAR RPAR												
							;
stat						: function_stmts	
							| exp_stat
							| selection_stat
							| loop_stat									
							| jump_stat												
							;
function_stmts				: LBRACE stmt_list stat_list RBRACE   	  			
							| LBRACE stat_list RBRACE							
							| LBRACE stmt_list	RBRACE							
							| LBRACE RBRACE										
							;
stat_list					: stat     												
							| stat_list stat  										
							;
selection_stat				: IF LPAR exp RPAR stat 									%prec "then"
							| IF LPAR exp RPAR stat ELSE stat
							;
loop_stat					: WHILE LPAR exp RPAR stat								
							| DO stat WHILE LPAR exp RPAR SEMI						
							| FOR LPAR exp SEMI exp SEMI exp RPAR stat				
							| FOR LPAR exp SEMI exp SEMI RPAR stat					
							| FOR LPAR exp SEMI SEMI exp RPAR stat					
							| FOR LPAR exp SEMI SEMI RPAR stat						
							| FOR LPAR SEMI exp SEMI exp RPAR stat					
							| FOR LPAR SEMI exp SEMI RPAR stat						
							| FOR LPAR SEMI SEMI exp RPAR stat						
							| FOR LPAR SEMI SEMI RPAR stat							
							;
jump_stat					: CONTINUE SEMI
							| BREAK SEMI
							| RETURN exp SEMI			  							
							| RETURN SEMI                 							
							;
exp_stat					: exp SEMI      										
							| SEMI													
							;
exp							: assignment_exp										
							| exp COMMA assignment_exp 								
							;
assignment_exp				: conditional_exp									
							| unary_exp assignment_operator assignment_exp		
							;
assignment_operator			: PLUSASSIGN										
							| MINUSASSIGN										
							| STARASSIGN										
							| SLASHASSIGN										
							| ASSIGN											
							;
conditional_exp				: logical_or_exp									
							| logical_or_exp QUEST exp COLON conditional_exp	
							;	
logical_or_exp				: logical_and_exp									
							| logical_or_exp DPIPE logical_and_exp				
							;
logical_and_exp				: inclusive_or_exp									
							| logical_and_exp DAMP inclusive_or_exp				
							;
inclusive_or_exp			: and_exp											
							| inclusive_or_exp PIPE and_exp						
							;
							;
and_exp						: equality_exp										
							| and_exp AMP equality_exp							
							;
equality_exp				: relational_exp									
							| equality_exp EQUALS relational_exp			
							| equality_exp NEQUAL relational_exp			
							;
relational_exp				: addition_exp									
							| relational_exp LT addition_exp				
							| relational_exp GT addition_exp				
							| relational_exp LE addition_exp				
							| relational_exp GE addition_exp				
							;
addition_exp				: mult_exp										
							| addition_exp PLUS mult_exp					
							| addition_exp MINUS mult_exp					
							;
mult_exp					: cast_exp											
							| mult_exp STAR cast_exp							
							| mult_exp SLASH cast_exp							
							| mult_exp MOD cast_exp								
							;	
cast_exp					: unary_exp											
							| LPAR type_name RPAR cast_exp						
							;
unary_exp					: variable_exp										
							| INCR unary_exp									
							| DECR unary_exp	
							| unary_operator cast_exp						
							| SIZEOF unary_exp									
							| SIZEOF LPAR type_name RPAR						
							;
unary_operator				: AMP | STAR | PLUS | MINUS | TILDE | BANG
							;
variable_exp				: variables 										//{$$ = <ident>;}
							| variable_exp LBRACKET exp RBRACKET  				//{$$ = strcat(<exp>, $2, $3, $4);}
							| variable_exp LPAR argument_exp_list RPAR 			
							| variable_exp LPAR RPAR 							
							| variable_exp DOT IDENT 							
							| variable_exp INCR   								
							| variable_exp DECR  								
							;
argument_exp_list			: assignment_exp									
							| argument_exp_list COMMA assignment_exp			
							;
variables					: IDENT 							//{$$=<ident>;}
							| INTCONST     						//{$$=<ident>;}		
							| REALCONST							//{$$=<ident>;}		
							| CHARCONST							//{$$=<ident>;}
							| STRCONST							//{$$=<ident>;}
							| LPAR exp RPAR					    //{$$=strcat($1, $2, $3);}		
							;
%%

int initialize_parser(char * filename) {
    //yydebug = 1;
    FILE *f = fopen( filename, "r" );
    if ( !f ) {
        printf("Error: Opening include file: %s\n", filename);
        perror(filename);
    } else {
        yyin = f;
        yyparse();
    }
	if (success) {
		printf("There are no errors. Syntactically, %s is correct.\n", filename);
	}
    return 0;
}

void yyerror(const char* mesg)
{
    printf("Error near %s line %d text %s \n\t%s\n", filename, yylineno, yytext, mesg);
	success = 0;
}
