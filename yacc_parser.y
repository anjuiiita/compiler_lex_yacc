
%{

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>
#define MAX 100
#define MAXCHILD 10

int yylex();
extern int yylineno;
extern char* yytext;
extern FILE *yyin, *yyout;
char *filename;

char indent[100]="";
char* none = "none";
char* type="TYPE";
char *constt="CONST";

void yyerror (const char *mesg);
int success = 1;
#define YYDEBUG 1
#define STR(VAR) (#VAR)
char **stmt;
int lineno = 0;

char *global[100];
int global_itr = 0;
int inside_func = 0;
int inside_param = 0;
struct function {
	char *name;
	char *local_var[100];
	char *param[100];
	int local_itr;
	int param_itr;
};
struct function *cur_func;
struct function *func_list[100];
int func_list_itr = 0;
struct function *proto_list[100];
int proto_itr = 0;
char *global_struct[100];
int global_struct_itr = 0;

struct treeNode{
    struct treeNode *child[MAXCHILD];
	char* lborder;
	char* rborder;
    char* nodeType;
    char* string;
    char* value;
    char* dataType;
    int lineNo;
    int Nchildren;
};
void printVariables(struct treeNode* node){
	if (!inside_func && strcmp(node->nodeType, "struct_spec") == 0 && strcmp(node->string, none) != 0) {
		global_struct[global_struct_itr++] = node->string;
	}
    if (!inside_func && strcmp(node->nodeType, "stmt_declarator") == 0 && strcmp(node->string, none) != 0) {
		global[global_itr++] = node->string;
	}
	//printf("%d %s\n", inside_func, node->nodeType);
	if (!inside_func && strcmp(node->nodeType, "func_declarator") == 0 && strcmp(node->string, none) != 0) {
		global[global_itr++] = node->string;
	}
	if (!inside_func && strcmp(node->nodeType, "function_definition") == 0) {
		inside_func = 1;
	}
	
	if (inside_func && strcmp(node->nodeType, "func_declarator") == 0) {

		if (strcmp(node->lborder, "(") == 0) {
			inside_param = 1;
		}
		if (inside_param) {
			if (cur_func && strcmp(cur_func->name, none) != 0) {
				func_list[func_list_itr++] = cur_func;
			}
			cur_func = malloc(sizeof(struct function));
			cur_func->name = node->string;
		}
	}
	if (inside_func && inside_param && strcmp(node->nodeType, "stmt_declarator") == 0) {
		if (cur_func && strcmp(node->string, none) != 0) {
			cur_func->param[cur_func->param_itr++] = node->string;
		}
	}
	if (inside_func && strcmp(node->nodeType, "function_stmts") == 0) {
		inside_param = 0;
	}
	if (inside_func && !inside_param && strcmp(node->nodeType, "stmt_declarator") == 0) {
		if (cur_func && strcmp(node->string, none) != 0) {
			cur_func->local_var[cur_func->local_itr++] = node->string;
		}
	}
	if (inside_func && strcmp(node->lborder, "return") == 0) {
		if (cur_func) {
			func_list[func_list_itr++] = cur_func;
			inside_func = 0;
			cur_func = NULL;
		}
	}
	if (inside_func && strcmp(node->lborder, "proto_end") == 0) {
		if (cur_func) {
			proto_list[proto_itr++] = cur_func;
			inside_func = 0;
			cur_func = NULL;
		}
	}

	//printf("%s 			%s			%s			%s\n", node->nodeType, node->string, node->lborder, node->rborder);
    int i;
    if (node->Nchildren > 0){
        for (i = 0;i < node->Nchildren; i++){
            printVariables(node->child[i]);
        }
    }
}

struct treeNode * newnode(char*lborder, char *rborder, int lineNo, char* nodeType, char* string, char* value, char* dataType, int Nchildren, ...){
    struct treeNode * node = (struct treeNode*) malloc(sizeof(struct treeNode));
	node->lborder = lborder;
	node->rborder = rborder;
    node->nodeType = nodeType;
    node->string = string;
    node->value = value;
    node->dataType = dataType;
    node->lineNo = lineNo;
    node->Nchildren = Nchildren;
    va_list ap;
    int i;
    va_start(ap, Nchildren);
    for (i=0;i<Nchildren;i++){
        node->child[i]=va_arg(ap, struct treeNode *);
    }
    va_end(ap);
    return node;
}



%}

%union {
	char *ident;
	struct treeNode * func_def;
}


%token PLUS MINUS STAR SLASH SEMI LPAR RPAR DOT QUEST LBRACE RBRACE LBRACKET RBRACKET
%token COLON MOD TILDE PIPE AMP BANG DPIPE DAMP ASSIGN PLUSASSIGN MINUSASSIGN STARASSIGN SLASHASSIGN 
%token INCR DECR EQUALS NEQUAL GT GE LT LE TYPE CONST STRUCT FOR WHILE DO IF ELSE BREAK CONTINUE RETURN 
%token INTCONST REALCONST STRCONST CHARCONST ERROR DIRECTIVES 
%token SWITCH CASE DEFAULT SIZEOF HEADER DEFINE
%token <ident> IDENT 

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
%start atree

%type <ident>  INTCONST REALCONST STRCONST CHARCONST 
%type <ident> PLUSASSIGN MINUSASSIGN STARASSIGN SLASHASSIGN ASSIGN assignment_operator
%type <ident> AMP BANG STAR PLUS MINUS TILDE unary_operator
%type <ident> CONTINUE BREAK RETURN CONST TYPE
%type <func_def> program  program_unit_list function_definition stmt_specs func_declarator jump_stat variables
%type <func_def> type_spec id_list param_list param_decl stmt_declarator paranthesis_decl 
%type <func_def> conditional_exp logical_or_exp logical_and_exp inclusive_or_exp and_exp equality_exp relational_exp 
%type <func_def> addition_exp mult_exp cast_exp unary_exp variable_exp argument_exp_list assignment_exp 
%type <func_def> initializer initializer_list   stmt program_unit

%type <func_def> stmt_list struct_spec struct_stmt_list init_declarator_list init_declarator type_spec_list 
%type <func_def> struct_decl struct_declarator_list type_name stat function_stmts stat_list selection_stat loop_stat exp_stat 
%type <func_def> exp  
%%
atree						:program 									{printVariables($1);}
program						: program_unit_list							{$$=$1;}
							;
program_unit_list			: program_unit 								{$$=$1;}
							| program_unit_list program_unit       		{$$=newnode(none, none, yylineno, "program", none, none, none, 2, $1, $2);}
							;

program_unit				: function_definition						{$$=$1;}
							| stmt										{$$=$1;}
							;
function_definition			: stmt_specs func_declarator function_stmts			{$$=newnode(none, none, yylineno, "function_definition", none, none, none, 3, $1, $2, $3);}
							| stmt_specs func_declarator	    			{$$=newnode(none, none, yylineno, "function_definition", none, none, none, 2, $1, $2);}
							| SEMI											{$$=newnode("proto_end", none, yylineno, "function_definition", none, none, none, 0);}
							;
stmt						: stmt_specs init_declarator_list SEMI 		{$$=newnode(none, none, yylineno, "stmt", none, none, none, 2, $1, $2);}
							| stmt_specs SEMI							{$$=newnode(none, none, yylineno, "stmt", none, none, none, 1, $1);}
							;
stmt_list					: stmt 									{$$=$1;}			
							| stmt_list stmt						{$$=newnode(none, none, yylineno, "stat_list", none, none, none, 2, $1, $2);}	
							;
stmt_specs					: type_spec stmt_specs					{$$=newnode(none, none, yylineno, "stmt_specs", none, none, none, 2, $1, $2);}
							| type_spec 							{$$=newnode(none, none, yylineno, "stmt_specs", none, none, none, 1, $1);}
							| CONST stmt_specs 						{$$=newnode(none, none, yylineno, "stmt_specs", none, none, constt, 1, $2);}
							| CONST 								{$$=newnode(none, none, yylineno, "stmt_specs", none, none, none, 0);}	
							;
type_spec					: TYPE							{$$=newnode(none, none, yylineno, "type_spec", none, none, type, 0);}			
							| struct_spec					{$$=newnode(none, none, yylineno, "type_spec", none, none, none, 1, $1);}
							;
struct_spec					: STRUCT IDENT LBRACE struct_stmt_list RBRACE		{$$=newnode(none, none, yylineno, "struct_spec", $2, none, none, 1, $4);}
							| STRUCT LBRACE struct_stmt_list RBRACE				{$$=newnode(none, none, yylineno, "struct_spec", none, none, none, 1, $3);}
							| STRUCT IDENT										{$$=newnode(none, none, yylineno, "struct_spec", $2, none, none, 0);}
							;
struct_stmt_list			: struct_decl											{$$=$1;}
							| struct_stmt_list struct_decl							{$$=newnode(none, none, yylineno, "struct_stmt_list", none, none, none, 2, $1, $2);}
							;
init_declarator_list		: init_declarator										{$$=$1;}
							| init_declarator_list COMMA init_declarator   			{$$=newnode(none, none, yylineno, "init_declarator_list", none, none, none, 2, $1, $3);}
							;
init_declarator				: stmt_declarator									{$$=$1;}
							| stmt_declarator ASSIGN initializer				{$$=newnode(none, none, yylineno, "init_declarator", none, none, none, 2, $1, $3);}
							;
struct_decl					: type_spec_list struct_declarator_list SEMI     	{$$=newnode(none, none, yylineno, "struct_decl", none, none, none, 2, $1, $2);}
							;
type_spec_list				: type_spec type_spec_list							{$$=newnode(none, none, yylineno, "type_spec_list", none, none, none, 2, $1, $2);}
							| type_spec											{$$=newnode(none, none, yylineno, "type_spec_list", none, none, none, 1, $1);}	
							| CONST type_spec_list								{$$=newnode(none, none, yylineno, "type_spec_list", none, none, none, 1, $2);}
							| CONST												{$$=newnode(none, none, yylineno, "type_spec_list", none, none, constt, 0);}
							;
struct_declarator_list		: stmt_declarator									{$$=newnode(none, none, yylineno, "struct_declarator_list", none, none, none, 1, $1);}
							| struct_declarator_list COMMA stmt_declarator		{$$=newnode(none, none, yylineno, "struct_declarator_list", none, none, none, 2, $1, $3);}
							;
func_declarator				: IDENT													{$$ = newnode(none, none, yylineno, "func_declarator", $1, none, none, 0);}
							//| func_declarator LBRACKET conditional_exp RBRACKET		{$$ = newnode("[", "]", yylineno,"func_declarator", none, none, none, 2, $1, $3);}					
							//| func_declarator LBRACKET RBRACKET			{$$ = newnode("[", "]", yylineno,"func_declarator", none, none, none, 1, $1);}					
							| func_declarator LPAR param_list RPAR 		{$$ = newnode("(", ")", yylineno,"func_declarator", none, none, none, 2, $1, $3);}								
							| func_declarator LPAR id_list RPAR 		{$$ = newnode("(", ")", yylineno,"func_declarator", none, none, none, 2, $1, $3);}							
							| func_declarator LPAR RPAR 				{$$ = newnode("(", ")", yylineno,"func_declarator", none, none, none, 1, $1);}								
							;
stmt_declarator				: IDENT													{$$ = newnode(none, none, yylineno,"stmt_declarator", $1, none, none, 0);}		
							| stmt_declarator LBRACKET conditional_exp RBRACKET		{$$ = newnode("[", "]", yylineno,"stmt_declarator", none, none, none, 2, $1, $3);}		
							| stmt_declarator LBRACKET RBRACKET						{$$ = newnode("[", "]", yylineno,"stmt_declarator", none, none, none, 1, $1);}		
							;
param_list					: param_decl											{$$=$1;}
							| param_list COMMA param_decl							{$$ = newnode(none, none, yylineno,"param_list", none, none, none, 2, $1, $3);}		
							;
param_decl					: stmt_specs stmt_declarator					{$$ = newnode(none, none, yylineno,"param_decl", none, none, none, 2, $1, $2);}		
							| stmt_specs paranthesis_decl					{$$ = newnode(none, none, yylineno,"param_decl", none, none, none, 2, $1, $2);}
							| stmt_specs									{$$ = newnode(none, none, yylineno,"param_decl", none, none, none, 1, $1);}		
							;
id_list						: IDENT								{$$ = newnode(none, none, yylineno,"id_list", $1, none, none, 0);}													
							| id_list COMMA IDENT				{$$ = newnode(none, none, yylineno,"id_list", $3, none, none, 1, $1);}									
							;
initializer					: assignment_exp											{$$=$1;}
							| LBRACE initializer_list RBRACE							{$$=newnode("{", "}", yylineno, "initializer", none, none, none, 1, $2);}
							| LBRACE initializer_list COMMA RBRACE						{$$=newnode("{", "}", yylineno, "initializer", none, none, none, 1, $2);}
							;
initializer_list			: initializer												{$$=$1;}
							| initializer_list COMMA initializer    					{$$=newnode(none, none, yylineno, "initializer_list", none, none, none, 2, $1, $3);}
							;
type_name					: type_spec_list paranthesis_decl							{$$=newnode(none, none, yylineno, "type_name", none, none, none, 2, $1, $2);}
							| type_spec_list											{$$=$1;}
							;
paranthesis_decl			: LPAR paranthesis_decl RPAR								{$$=newnode("(", ")", yylineno, "paranthesis_decl", none, none, none, 1, $2);}
							| paranthesis_decl LBRACKET conditional_exp RBRACKET		{$$=newnode("[", "]", yylineno, "paranthesis_decl", none, none, none, 2, $1, $3);}
							| LBRACKET conditional_exp RBRACKET							{$$=newnode("[", "]", yylineno, "paranthesis_decl", none, none, none, 1, $2);}
							| paranthesis_decl LBRACKET RBRACKET						{$$=newnode("[", "]", yylineno, "paranthesis_decl", none, none, none, 1, $1);}
							| LBRACKET RBRACKET											{$$=newnode("[", "]", yylineno, "paranthesis_decl", none, none, none, 0);}
							| paranthesis_decl LPAR param_list RPAR     				{$$=newnode("(", ")", yylineno, "paranthesis_decl", none, none, none, 2, $1, $3);}
							| LPAR param_list RPAR										{$$=newnode("(", ")", yylineno, "paranthesis_decl", none, none, none, 1, $2);}
							| paranthesis_decl LPAR RPAR								{$$=newnode("(", ")", yylineno, "paranthesis_decl", none, none, none, 1, $1);}
							| LPAR RPAR													{$$=newnode("(", ")", yylineno, "paranthesis_decl", none, none, none, 0);}
							;
stat						: function_stmts									{$$=$1;}			
							| exp_stat											{$$=$1;}			
							| selection_stat									{$$=$1;}			
							| loop_stat											{$$=$1;}			
							| jump_stat											{$$=$1;}			
							;
function_stmts				: LBRACE stmt_list stat_list RBRACE   	  			{$$=newnode("{", "}", yylineno, "function_stmts", none, none, none, 2, $2, $3);}
							| LBRACE stat_list RBRACE							{$$=newnode("{", "}", yylineno, "function_stmts", none, none, none, 1, $2);}
							| LBRACE stmt_list	RBRACE							{$$=newnode("{", "}", yylineno, "function_stmts", none, none, none, 1, $2);}
							| LBRACE RBRACE										{$$=newnode("{", "}", yylineno, "function_stmts", none, none, none, 0);}
							;
stat_list					: stat     									{$$=newnode(none, none, yylineno, "stat_list", none, none, none, 1, $1);}	
							| stat_list stat  							{$$=newnode(none, none, yylineno, "stat_list", none, none, none, 2, $1, $2);}	
							;
selection_stat				: IF LPAR exp RPAR stat 									%prec "then"		{$$=newnode(none, none, yylineno, "selection_stat", none, none, none, 2, $3, $5);}
							| IF LPAR exp RPAR stat ELSE stat												{$$=newnode(none, none, yylineno, "selection_stat", none, none, none, 3, $3, $5, $7);}
							;
loop_stat					: WHILE LPAR exp RPAR stat								{$$=newnode(none, none, yylineno, "loop_stat", none, none, none, 2, $3, $5);}
							| DO stat WHILE LPAR exp RPAR SEMI						{$$=newnode(none, none, yylineno, "loop_stat", none, none, none, 2, $2, $5);}
							| FOR LPAR exp SEMI exp SEMI exp RPAR stat				{$$=newnode(none, none, yylineno, "loop_stat", none, none, none, 4, $3, $5, $7, $9);}
							| FOR LPAR exp SEMI exp SEMI RPAR stat					{$$=newnode(none, none, yylineno, "loop_stat", none, none, none, 3, $3, $5, $8);}
							| FOR LPAR exp SEMI SEMI exp RPAR stat					{$$=newnode(none, none, yylineno, "loop_stat", none, none, none, 3, $3, $6, $8);}
							| FOR LPAR exp SEMI SEMI RPAR stat						{$$=newnode(none, none, yylineno, "loop_stat", none, none, none, 2, $3, $7);}
							| FOR LPAR SEMI exp SEMI exp RPAR stat					{$$=newnode(none, none, yylineno, "loop_stat", none, none, none, 3, $4, $6, $8);}
							| FOR LPAR SEMI exp SEMI RPAR stat						{$$=newnode(none, none, yylineno, "loop_stat", none, none, none, 2, $4, $7);}
							| FOR LPAR SEMI SEMI exp RPAR stat						{$$=newnode(none, none, yylineno, "loop_stat", none, none, none, 2, $5, $7);}
							| FOR LPAR SEMI SEMI RPAR stat							{$$=newnode(none, none, yylineno, "loop_stat", none, none, none, 1, $6);}
							;
jump_stat					: CONTINUE SEMI										{$$=newnode(none, none, yylineno, "jump_stat", none, none, none, 0);}
							| BREAK SEMI										{$$=newnode(none, none, yylineno, "jump_stat", none, none, none, 0);}				
							| RETURN exp SEMI			  						{$$=newnode("return", none, yylineno, "jump_stat", none, none, none, 1, $2);}				
							| RETURN SEMI                 						{$$=newnode("return", none, yylineno, "jump_stat", none, none, none, 0);}				
							;
exp_stat					: exp SEMI      									{$$=newnode(none, none, yylineno, "exp_stat", none, none, none, 1, $1);}
							| SEMI												{$$=newnode("exp_stat", none, yylineno, "exp_stat", none, none, none, 0);}
							;
exp							: assignment_exp									{$$=newnode(none, none, yylineno, "exp", none, none, none, 1, $1);}										
							| exp COMMA assignment_exp 							{$$=newnode(none, none, yylineno, "exp", none, none, none, 2, $1, $3);}				
							;
assignment_exp				: conditional_exp									{$$=newnode(none, none, yylineno, "assignment_exp", none, none, none, 1, $1);}				
							| unary_exp assignment_operator assignment_exp		{$$=newnode(none, none, yylineno, "assignment_exp", none, none, none, 2, $1, $3);}				
							;
assignment_operator			: PLUSASSIGN						{$$=$1;}				
							| MINUSASSIGN						{$$=$1;}				
							| STARASSIGN						{$$=$1;}				
							| SLASHASSIGN						{$$=$1;}				
							| ASSIGN							{$$=$1;}				
							;
conditional_exp				: logical_or_exp									{$$=newnode(none, none, yylineno, "conditional_exp", none, none, none, 1, $1);}			
							| logical_or_exp QUEST exp COLON conditional_exp	{$$=newnode(none, none, yylineno, "conditional_exp", none, none, none, 3, $1, $3, $5);}			
							;	
logical_or_exp				: logical_and_exp							{$$=newnode(none, none, yylineno, "logical_or_exp", none, none, none, 1, $1);}			
							| logical_or_exp DPIPE logical_and_exp		{$$=newnode(none, none, yylineno, "logical_or_exp", none, none, "|", 2, $1, $3);}			
							;
logical_and_exp				: inclusive_or_exp							{$$=newnode(none, none, yylineno, "logical_and_exp", none, none, none, 1, $1);}	
							| logical_and_exp DAMP inclusive_or_exp		{$$=newnode(none, none, yylineno, "logical_and_exp", none, none, "&", 2, $1, $3);}			
							;
inclusive_or_exp			: and_exp								{$$=newnode(none, none, yylineno, "inclusive_or_exp", none, none, none, 1, $1);}				
							| inclusive_or_exp PIPE and_exp			{$$=newnode(none, none, yylineno, "inclusive_or_exp", none, none, "||", 2, $1, $3);}				
							;
							;
and_exp						: equality_exp							{$$=newnode(none, none, yylineno, "and_exp", none, none, none, 1, $1);}			
							| and_exp AMP equality_exp				{$$=newnode(none, none, yylineno, "and_exp", none, none, "&&", 2, $1, $3);}				
							;
equality_exp				: relational_exp						{$$=newnode(none, none, yylineno, "equality_exp", none, none, none, 1, $1);}			
							| equality_exp EQUALS relational_exp	{$$=newnode(none, none, yylineno, "equality_exp", none, none, "==", 2, $1, $3);}			
							| equality_exp NEQUAL relational_exp	{$$=newnode(none, none, yylineno, "equality_exp", none, none, "!=", 2, $1, $3);}			
							;
relational_exp				: addition_exp							{$$=newnode(none, none, yylineno, "relational_exp", none, none, none, 1, $1);}		
							| relational_exp LT addition_exp		{$$=newnode(none, none, yylineno, "relational_exp", none, none, "<", 2, $1, $3);}			
							| relational_exp GT addition_exp		{$$=newnode(none, none, yylineno, "relational_exp", none, none, ">", 2, $1, $3);}			
							| relational_exp LE addition_exp		{$$=newnode(none, none, yylineno, "relational_exp", none, none, "<=", 2, $1, $3);}			
							| relational_exp GE addition_exp		{$$=newnode(none, none, yylineno, "relational_exp", none, none, ">=", 2, $1, $3);}			
							;
addition_exp				: mult_exp								{$$=newnode(none, none, yylineno, "addition_exp", none, none, none, 1, $1);}			
							| addition_exp PLUS mult_exp			{$$=newnode(none, none, yylineno, "addition_exp", none, none, "+", 2, $1, $3);}					
							| addition_exp MINUS mult_exp			{$$=newnode(none, none, yylineno, "addition_exp", none, none, "-", 2, $1, $3);}					
							;
mult_exp					: cast_exp								{$$=newnode(none, none, yylineno, "mult_exp", none, none, none, 1, $1);}			
							| mult_exp STAR cast_exp				{$$=newnode(none, none, yylineno, "mult_exp", none, none, "*", 2, $1, $3);}			
							| mult_exp SLASH cast_exp				{$$=newnode(none, none, yylineno, "mult_exp", none, none, "/", 2, $1, $3);}			
							| mult_exp MOD cast_exp					{$$=newnode(none, none, yylineno, "mult_exp", none, none, "%", 2, $1, $3);}			
							;	
cast_exp					: unary_exp								{$$=newnode(none, none, yylineno, "cast_exp", none, none, none, 1, $1);}			
							| LPAR type_name RPAR cast_exp			{$$=newnode(none, none, yylineno, "cast_exp", none, none, none, 2, $2, $4);}				
							;
unary_exp					: variable_exp							{$$=newnode(none, none, yylineno, "unary_exp", none, none, none, 1, $1);}			
							| INCR unary_exp						{$$=newnode(none, none, yylineno, "unary_exp", none, none, "++", 1, $2);}			
							| DECR unary_exp						{$$=newnode(none, none, yylineno, "unary_exp", none, none, "--", 1, $2);}			
							| unary_operator cast_exp				{$$=newnode(none, none, yylineno, "unary_exp", none, none, none, 2, $1, $2);}					
							| SIZEOF unary_exp						{$$=newnode(none, none, yylineno, "unary_exp", none, none, none, 1, $2);}			
							| SIZEOF LPAR type_name RPAR			{$$=newnode(none, none, yylineno, "unary_exp", none, none, none, 1, $3);}						
							;
unary_operator				: AMP | STAR | PLUS | MINUS | TILDE | BANG			{$$=$1;}
							;
variable_exp				: variables 										{$$ = newnode(none, none, yylineno, "variable_exp", none, none, none, 1, $1);}
							| variable_exp LBRACKET exp RBRACKET  				{$$ = newnode(none, none, yylineno, "variable_exp", none, none, none, 2, $1, $3);}
							| variable_exp LPAR argument_exp_list RPAR 			{$$ = newnode(none, none, yylineno, "variable_exp", none, none, none, 2, $1, $3);}
							| variable_exp LPAR RPAR 							{$$ = newnode(none, none, yylineno, "variable_exp", none, none, none, 1, $1);}
							| variable_exp DOT IDENT 							{$$ = newnode(none, none, yylineno, "variable_exp", $3, none, none, 1, $1);}
							| variable_exp INCR   								{$$ = newnode(none, none, yylineno, "variable_exp", none, none, "++", 1, $1);}
							| variable_exp DECR  								{$$ = newnode(none, none, yylineno, "variable_exp", none, none, "--", 1, $1);}
							;
argument_exp_list			: assignment_exp							{$$=newnode(none, none, yylineno, "argument_exp_list", none, none, none, 1, $1);}				
							| argument_exp_list COMMA assignment_exp	{$$=newnode(none, none, yylineno, "argument_exp_list", none, none, none, 2, $1, $3);}		
							;
variables					: IDENT 							{$$=newnode(none, none, yylineno, "variables", $1, none, none, 0);}
							| INTCONST     						{$$=newnode(none, none, yylineno, "variables", none, $1, none, 0);}		
							| REALCONST							{$$=newnode(none, none, yylineno, "variables", none, $1, none, 0);}		
							| CHARCONST							{$$=newnode(none, none, yylineno, "variables", none, $1, none, 0);}
							| STRCONST							{$$=newnode(none, none, yylineno, "variables", none, $1, none, 0);}
							| LPAR exp RPAR						{$$=newnode("(", ")", yylineno, "variables", none, none, none, 1, $2);}
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
	int i = 0, j;
	printf("Global struct: \n");
    printf("\t");
    for (i = 0; i < global_struct_itr; i++)
        printf("%s ", global_struct[i]);
    printf("\n");
    printf("Global variables: \n");
    printf("\t");
    for (i = 0; i < global_itr; i++)
        printf("%s ", global[i]);
    printf("\n");
    for (i = 0; i < func_list_itr; i++) {
        struct function *func = func_list[i];
        printf("Function %s\n", func->name);
        printf("\tParameters: ");
        for(int j = 0; j < func->param_itr; j++)
            printf("%s ", func->param[j]);
        printf("\n");
        printf("\tLocal variables: ");
        for(int j = 0; j < func->local_itr; j++)
            printf("%s ", func->local_var[j]);
        printf("\n");
    }
    
    for (i = 0; i < proto_itr; i++) {
        printf("Prototype %s\n", proto_list[i]->name);
        printf("\tParameters: ");
        for (j = 0; j < proto_list[i]->param_itr; j++) {
            printf("%s ", proto_list[i]->param[j]);
        }
        printf("\n");
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
