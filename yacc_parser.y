
%{

#include <stdio.h>
#include <stdlib.h>

int yylex();
extern int yylval;
extern int yylineno;
extern char* yytext;
extern FILE *yyin, *yyout;
char *filename;

void yyerror (const char *mesg);
int success = 1;
#define YYDEBUG 1
char **sym
%}

%token PLUS MINUS STAR SLASH SEMI LPAR RPAR LBRACKET RBRACKET LBRACE RBRACE DOT QUEST COLON MOD TILDE PIPE AMP BANG DPIPE DAMP ASSIGN PLUSASSIGN MINUSASSIGN STARASSIGN SLASHASSIGN INCR DECR EQUALS NEQUAL GT GE LT LE TYPE CONST STRUCT FOR WHILE DO IF ELSE BREAK CONTINUE RETURN IDENT INTCONST REALCONST STRCONST CHARCONST ERROR DIRECTIVES 


%token SWITCH CASE DEFAULT SIZEOF
%token HEADER DEFINE


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

%%
program						: HEADER program                               
							| DEFINE primary_exp program                	
							| program_unit_list							
							;
program_unit_list			: program_unit 									
							| program_unit_list program_unit       
							;
program_unit				: function_definition
							| function_proto
							| stmt
							;
function_definition			: stmt_specs func_declarator compound_stat			
							| func_declarator compound_stat						
							;
function_proto				: stmt_specs func_declarator SEMI    				{printf("function_proto\n");}
							;
stmt						: stmt_specs init_declarator_list SEMI 				{printf("type_spec %s\n", yytext);}			
							| stmt_specs SEMI									{printf("type_spec %s\n", yytext);}			
							;
stmt_list					: stmt 												
							| stmt_list stmt									
							;
stmt_specs					: type_spec stmt_specs								
							| type_spec 										
							| CONST stmt_specs 									
							| CONST 											
							;
type_spec					: TYPE										{printf("%s\n", yytext);}		
							| struct_spec							    {printf("%s\n", yytext);}
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
struct_decl					: spec_qualifier_list struct_declarator_list SEMI     
							;
spec_qualifier_list			: type_spec spec_qualifier_list
							| type_spec
							| CONST spec_qualifier_list
							| CONST
							;
struct_declarator_list		: struct_declarator
							| struct_declarator_list COMMA struct_declarator
							;
struct_declarator			: stmt_declarator
							| stmt_declarator COLON conditional_exp
							| COLON conditional_exp
							;
func_declarator				: IDENT				   				
							| LPAR func_declarator RPAR						
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
							| stmt_specs direct_abstract_declarator
							| stmt_specs
							;
id_list						: IDENT					
							| id_list COMMA IDENT	
							;
initializer					: assignment_exp
							| LBRACE initializer_list RBRACE
							| LBRACE initializer_list COMMA RBRACE
							;
initializer_list			: initializer					
							| initializer_list COMMA initializer    
							;
type_name					: spec_qualifier_list direct_abstract_declarator
							| spec_qualifier_list
							;
direct_abstract_declarator	: LPAR direct_abstract_declarator RPAR
							| direct_abstract_declarator LBRACKET conditional_exp RBRACKET
							| LBRACKET conditional_exp RBRACKET
							| direct_abstract_declarator LBRACKET RBRACKET
							| LBRACKET RBRACKET
							| direct_abstract_declarator LPAR param_list RPAR     
							| LPAR param_list RPAR					
							| direct_abstract_declarator LPAR RPAR
							| LPAR RPAR
							;
stat						: labeled_stat 									      	
							| exp_stat 											  	
							| compound_stat 									  	
							| selection_stat  									  
							| iteration_stat
							| jump_stat
							;
labeled_stat				: IDENT COLON stat
							| CASE conditional_exp COLON stat
							| DEFAULT COLON stat
							;
exp_stat					: exp SEMI      {printf("%s\n", yytext);}
							| SEMI			{printf("%s\n", yytext);}
							;
compound_stat				: LBRACE stmt_list stat_list RBRACE   	  
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
iteration_stat				: WHILE LPAR exp RPAR stat
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
							| RETURN exp SEMI			  {printf("%s\n", yytext);}
							| RETURN SEMI                 {printf("%s\n", yytext);}
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
relational_exp				: additive_exp
							| relational_exp LT additive_exp
							| relational_exp GT additive_exp
							| relational_exp LE additive_exp
							| relational_exp GE additive_exp
							;
additive_exp				: mult_exp
							| additive_exp PLUS mult_exp
							| additive_exp MINUS mult_exp
							;
mult_exp					: cast_exp
							| mult_exp STAR cast_exp
							| mult_exp SLASH cast_exp
							| mult_exp MOD cast_exp
							;
cast_exp					: unary_exp
							| LPAR type_name RPAR cast_exp
							;
unary_exp					: postfix_exp
							| INCR unary_exp
							| DECR unary_exp
							| unary_operator cast_exp
							| SIZEOF unary_exp
							| SIZEOF LPAR type_name RPAR
							;
unary_operator				: AMP | STAR | PLUS | MINUS | TILDE | BANG 				
							;
postfix_exp					: primary_exp 										
							| postfix_exp LBRACKET exp RBRACKET  
							| postfix_exp LPAR argument_exp_list RPAR 
							| postfix_exp LPAR RPAR 
							| postfix_exp DOT IDENT 
							| postfix_exp INCR   
							| postfix_exp DECR  
							;
argument_exp_list			: assignment_exp
							| argument_exp_list COMMA assignment_exp
							;
primary_exp					: IDENT 						
							| values 												
							| STRCONST 												
							| LPAR exp RPAR					
							;
values						: INTCONST     
							| REALCONST
							| CHARCONST
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
		printf("its happening\n");
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
