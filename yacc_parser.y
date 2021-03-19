
%{

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>
#include <math.h> 

#define MAX 100
#define MAXCHILD 10

int yylex();
extern int yylineno;
extern char* yytext;
extern FILE *yyin, *yyout;

const char *errormsg;
void yyerror (const char *mesg);

char* none = "none";
char* type= "TYPE";
char *constt= "CONST";

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
	char *type;
	char *dataType;
	char * returnerror;
	char * statements[100];
    int statement_itr;
};
struct function *cur_func;
struct function *func_list[100];
int func_list_itr = 0;
char *global_struct[100];
int global_struct_itr = 0;
int arr = 0;
char *data_type = "none";
int return_data = 0;
char * error_statement[100];
int statement_itr = 0;


struct treeNode{
    struct treeNode *child[MAXCHILD];
	char* lborder;
	char* rborder;
	int lineNo;
    char* nodeType;
    char* string;
    char* value;
    char* dataType;
    int Nchildren;
};

char* checkVariableDatatype(char *value) {
    double temp; 
    int n; 
    char str[100] = ""; 
    double val = 1e-12; 
  
    if (sscanf(value, "%lf", &temp) == 1)  
    { 
        n = (int)temp; // typecast to int. 
        if (fabs(temp - n) / temp > val)  
            return "float";        
        else 
            return "int";         
    } 
    else if (sscanf(value, "%s", str) == 1)      
        return "char";
    else
        return ""; 
}

char* verifyVariable(char * value) {
    for (int i = 0; i < func_list_itr; i++) {
        struct function * cur_func = func_list[i];
        if (strcmp(cur_func->name, value) == 0) {
            return "function";
        }
        for (int i = 0; i < cur_func->local_itr; i++) {
            if (strcmp(cur_func->local_var[i], value) == 0) {
                return "local";
            } 
        }
        for (int i = 0; i < cur_func->param_itr; i++) {
            if (strcmp(cur_func->param[i], value) == 0) {
                return "param";
            } 
        }
        for (int i = 0; i < global_itr; i++) {
            if (strcmp(global[i], value) == 0) {
                return "glabal";
            } 
        }
    }
    return none;
}

void printVariables(struct treeNode* node) {
	if (return_data == 1 && strcmp(node->nodeType, "variables") == 0 && strcmp(node->string, none) != 0) {
		return_data = 0;
        //printf("%s      %s\n", node->string, data_type);
        char * return_dt = checkVariableDatatype(node->string);
        //printf("%s\n", return_dt);
		if (strcmp(data_type, return_dt) != 0) {
            char * str1 = "line ";
            char * str2 = (char*)malloc(2);
            sprintf( str2, "%d", node->lineNo );
            char * str3 = "\n\tReturning ";
            char * str4 = return_dt;
            char * str5 = " in a function of type ";
            char * str6 = data_type;
            int sz1 = strlen(str1);
            int sz2 = strlen(str2);
            int sz3 = strlen(str3);
            int sz4 = strlen(str4);
            int sz5 = strlen(str5);
            int sz6 = strlen(str6);
            char *return_error = (char*)malloc(sz1 + sz2 + sz3 + sz4 + sz5 + sz6);

            memcpy( return_error, str1, sz1 );
            memcpy( return_error + sz1, str2, sz2 );
            memcpy( return_error + sz1 + sz2, str3, sz3 );
            memcpy( return_error + sz1 + sz2 + sz3, str4, sz4 );
            memcpy( return_error + sz1 + sz2 + sz3 + sz4, str5, sz5 );
            memcpy( return_error + sz1 + sz2 + sz3 + sz4 + sz5, str6, sz6 );
			error_statement[statement_itr++] = return_error;
            //printf("%s\n", return_error);
		}
	}

	if (strcmp(node->nodeType, "type_spec") == 0 && strcmp(node->dataType, none) != 0 ) {
		data_type = node->dataType;
	}

	if (!inside_func && strcmp(node->nodeType, "struct_spec") == 0 && strcmp(node->string, none) != 0) {
		global_struct[global_struct_itr++] = node->string;
	}
	if (!inside_func && strcmp(node->nodeType, "stmt_declarator") == 0 && strcmp(node->lborder, none) != 0) {
		arr = 1;
	}
    if (!inside_func && strcmp(node->nodeType, "stmt_declarator") == 0 && strcmp(node->string, none) != 0) {
		int sz1 = strlen(data_type);
        int sz2 = strlen(node->string);
        if (arr) {
			arr = 0;
            char * final_str = (char*)malloc(sz1 + sz2 + 3);
            memcpy(final_str, data_type, sz1);
            memcpy(final_str + sz1, " ", 1);
            memcpy(final_str + sz1 + 1, node->string, sz2);
            memcpy(final_str + sz1 + 1 + sz2, "[]", 2);
			global[global_itr++] = final_str;
		} else {
            char * final_str = (char*)malloc(sz1 + sz2 + 1);
            memcpy(final_str, data_type, sz1);
            memcpy(final_str + sz1, " ", 1);
            memcpy(final_str + 1 + sz1, node->string, sz2);
            global[global_itr++] = final_str;
        }
			
	}
	//printf("%d %s\n", inside_func, node->nodeType);
	if (!inside_func && strcmp(node->nodeType, "func_declarator") == 0 && strcmp(node->string, none) != 0) {
		int sz1 = strlen(data_type);
        int sz2 = strlen(node->string);
        char * final_str = (char*)malloc(sz1 + sz2 + 1);
        memcpy(final_str, data_type, sz1);
        memcpy(final_str + sz1, " ", 1);
        memcpy(final_str + 1 + sz1, node->string, sz2);
        global[global_itr++] = final_str;
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
                if (strcmp(cur_func->dataType, "void") != 0) {
                    char * str1 = "line ";
                    char * str2 = (char*)malloc(2);
                    sprintf( str2, "%d", node->lineNo );
                    char * str3 = "\n\tReturning void in a function of type ";
                    int sz1 = strlen(str1);
                    int sz2 = strlen(str2);
                    int sz3 = strlen(str3);
                    int sz4 = strlen(cur_func->dataType);
                    char *return_error = (char*)malloc(sz1 + sz2 + sz3 + sz4);

                    memcpy( return_error, str1, sz1 );
                    memcpy( return_error + sz1, str2, sz2 );
                    memcpy( return_error + sz1 + sz2, str3, sz3 );
                    memcpy( return_error + sz1 + sz2 + sz3, data_type, sz4 );

                    error_statement[statement_itr++] = return_error;
                }
				func_list[func_list_itr++] = cur_func;
                cur_func = NULL;
                
			}
			cur_func = malloc(sizeof(struct function));
			cur_func->name = node->string;
			cur_func->type = "";
			cur_func->dataType = data_type;
		}
	}
	if (inside_func && inside_param && strcmp(node->nodeType, "stmt_declarator") == 0 && strcmp(node->lborder, none) != 0) {
		arr = 1;
	}

	if (inside_func && inside_param && strcmp(node->nodeType, "stmt_declarator") == 0) {
		if (cur_func && strcmp(node->string, none) != 0) {
			if (arr) {
				arr = 0;
                int sz1 = strlen(data_type);
                int sz2 = strlen(node->string);
                char * final_str = (char*)malloc(sz1 + sz2 + 3);
                memcpy(final_str, data_type, sz1);
                memcpy(final_str + sz1, " ", 1);
                memcpy(final_str + 1 + sz1, node->string, sz2);
                memcpy(final_str + 1 + sz1 + sz2, "[]", 2);
				cur_func->param[cur_func->param_itr++] = final_str;
			} else {
                int sz1 = strlen(data_type);
                int sz2 = strlen(node->string);
                char * final_str = (char*)malloc(sz1 + sz2 + 1);
                memcpy(final_str, data_type, sz1);
                memcpy(final_str + sz1, " ", 1);
                memcpy(final_str + 1 + sz1, node->string, sz2);
				cur_func->param[cur_func->param_itr++] = final_str;
            }
		}
	}
	if (inside_func && strcmp(node->nodeType, "function_stmts") == 0) {
		inside_param = 0;
	}
	if (inside_func && !inside_param && strcmp(node->nodeType, "stmt_declarator") == 0 && strcmp(node->lborder, none) != 0) {
        if (cur_func && strcmp(node->string, none) != 0) {
            if (strcmp(verifyVariable(node->string), none) != 0) {
                char * str1 = "line ";
                char * str2 = (char*)malloc(2);
                sprintf( str2, "%d", node->lineNo );
                char * str3 = "Redeclaration of local variable ";
                char * str4 = node->string;
                int sz1 = strlen(str1);
                int sz2 = strlen(str2);
                int sz3 = strlen(str3);
                int sz4 = strlen(str4);

                char * redecl_stmt = (char*)malloc(sz1 + sz2 + sz3 + sz4);;
                memcpy( redecl_stmt, str1, sz1 );
                memcpy( redecl_stmt + sz1, str2, sz2 );
                memcpy( redecl_stmt + sz1 + sz2, str3, sz3 );
                memcpy( redecl_stmt + sz1 + sz2 + sz3, str4, sz4 );

                error_statement[statement_itr++] = redecl_stmt;
            }
        }
		arr = 1;
	}
    if (inside_func && !inside_param && strcmp(node->nodeType, "stmt_declarator") == 0 && cur_func && strcmp(node->string, none) != 0) {
		if (arr) {
			arr = 0;
            int sz1 = strlen(data_type);
            int sz2 = strlen(node->string);
            char * final_str = (char*)malloc(sz1 + sz2 + 3);
            memcpy(final_str, data_type, sz1);
            memcpy(final_str + sz1, " ", 1);
            memcpy(final_str + 1 + sz1, node->string, sz2);
            memcpy(final_str + 1 + sz1 + sz2, "[]", 2);
            cur_func->local_var[cur_func->local_itr++] = final_str;
        } else {
            int sz1 = strlen(data_type);
            int sz2 = strlen(node->string);
            char * final_str = (char*)malloc(sz1 + sz2 + 1);
            memcpy(final_str, data_type, sz1);
            memcpy(final_str + sz1, " ", 1);
            memcpy(final_str + 1 + sz1, node->string, sz2);
            cur_func->local_var[cur_func->local_itr++] = final_str;
        }
	}
	if (inside_func && !inside_param  && strcmp(node->string, none) != 0) {
		printf("%s\n", node->string);
        if(strcmp(node->lborder, none) != 0) {
            printf("%s\n", node->lborder);
            
        }
        if (strcmp(node->string, "=") == 0) {
            for (int i = 0; i < node->Nchildren; i++) {
                if (strcmp(node->child[i]->string, none) != 0 && strcmp(verifyVariable(node->child[i]->string), none) == 0) {
                    char * str1 = "line ";
                    char * str2 = (char*)malloc(2);
                    sprintf( str2, "%d", node->lineNo );
                    char * str3 = "\n\tUndeclared identifier: ";
                    char * str4 = node->child[i]->string;
                    int sz1 = strlen(str1);
                    int sz2 = strlen(str2);
                    int sz3 = strlen(str3);
                    int sz4 = strlen(str4);
                    char *error_st = (char*)malloc(sz1 + sz2 + sz3 + sz4);
                    memcpy(error_st, str1, sz1);
                    memcpy(error_st + sz1, str2, sz2);
                    memcpy(error_st + sz1 + sz2, str3, sz3);
                    memcpy(error_st + sz1 + sz2 + sz3, str4, sz4);
                    error_statement[statement_itr++] = error_st;
                }
                //printf("%s\n", node->child[i]->string);
            }
        }
	}
	if (inside_func && strcmp(node->lborder, "return") == 0) {
		if (cur_func) {
			func_list[func_list_itr++] = cur_func;
			inside_func = 0;
			cur_func = NULL;
			return_data = 1;
		}
	}
	if (inside_func && strcmp(node->lborder, "return_semi") == 0) {
		if (cur_func) {
			if (strcmp(cur_func->dataType, "void") != 0) {
				error_statement[statement_itr++] = strcat("Returning void in a function of type ", cur_func->dataType);
			}
			func_list[func_list_itr++] = cur_func;
			inside_func = 0;
			cur_func = NULL;
			
		}
	}
	if (inside_func && strcmp(node->lborder, "proto_end") == 0) {
		if (cur_func) {
			cur_func->type = "proto";
			func_list[func_list_itr++] = cur_func;
			inside_func = 0;
			cur_func = NULL;
		}
	}

    //if (strcmp(node->string , none) != 0 || strcmp(node->dataType, none) != 0 || strcmp(node->lborder, none) != 0 || strcmp(node->rborder, none) != 0)
	//   printf("%s 			%s 			%s			%s			%s\n", node->nodeType, node->string, node->dataType, node->lborder, node->rborder);
    int i;
    if (node->Nchildren > 0){
        for (i = 0; i < node->Nchildren; i++){
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
%token INCR DECR EQUALS NEQUAL GT GE LT LE INT FLOAT CHAR VOID CONST STRUCT FOR WHILE DO IF ELSE BREAK CONTINUE RETURN 
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
%start parseTree

%type <ident>  INTCONST REALCONST STRCONST CHARCONST 
%type <func_def> PLUSASSIGN MINUSASSIGN STARASSIGN SLASHASSIGN ASSIGN assignment_operator
%type <func_def> AMP BANG STAR PLUS MINUS TILDE unary_operator
%type <ident> CONTINUE BREAK RETURN CONST INT FLOAT CHAR VOID
%type <func_def> program  program_unit_list function_definition stmt_specs func_declarator jump_stat variables
%type <func_def> type_spec id_list param_list param_decl stmt_declarator paranthesis_decl
%type <func_def> conditional_exp logical_or_exp logical_and_exp inclusive_or_exp and_exp equality_exp relational_exp 
%type <func_def> addition_exp mult_exp cast_exp unary_exp variable_exp argument_exp_list assignment_exp 
%type <func_def> initializer initializer_list   stmt program_unit

%type <func_def> stmt_list struct_spec struct_stmt_list init_declarator_list init_declarator type_spec_list 
%type <func_def> struct_decl struct_declarator_list type_name stat function_stmts stat_list selection_stat loop_stat exp_stat 
%type <func_def> exp  
%%
parseTree					:program 									//{printVariables($1);}
program						: program_unit_list							{$$=$1;}
							;
program_unit_list			: program_unit 								{$$=$1;}
							| program_unit_list program_unit       		{$$=newnode(none, none, yylineno, "program", none, none, none, 2, $1, $2);}
							;

program_unit				: function_definition						{printVariables($1); if(cur_func)   func_list[func_list_itr++] = cur_func; cur_func= NULL;}
							| stmt										{printVariables($1);}
							| init_declarator							{printVariables($1);}
							;
function_definition			: stmt_specs func_declarator function_stmts		{$$=newnode(none, none, yylineno, "function_definition", none, none, none, 3, $1, $2, $3);}
							| stmt_specs func_declarator	    			{$$=newnode(none, none, yylineno, "function_definition", none, none, none, 2, $1, $2);}
							| SEMI											{$$=newnode("proto_end", none, yylineno, "function_definition", none, none, none, 0);}
							;
stmt						: stmt_specs init_declarator_list SEMI 		{$$=newnode(none, none, yylineno, "stmt", none, none, none, 2, $1, $2);}
							| stmt_specs SEMI							{$$=newnode(none, none, yylineno, "stmt", none, none, none, 1, $1);}
							;
stmt_list					: stmt 									{$$=$1;}			
							| stmt_list stmt						{$$=newnode(none, none, yylineno, "stat_list", none, none, none, 2, $1, $2);}	
							;
stmt_specs					: type_spec stmt_specs					{$$=newnode(none, none, yylineno, "stmt_specs", none, none, $1->dataType, 2, $1, $2);}
							| type_spec 							{$$=newnode(none, none, yylineno, "stmt_specs", none, none, $1->dataType, 1, $1);}
							| CONST stmt_specs 						{$$=newnode(none, none, yylineno, "stmt_specs", none, none, "const", 1, $2);}
							| CONST 								{$$=newnode(none, none, yylineno, "stmt_specs", none, none, "const", 0);}	
							;
type_spec					: INT							{$$=newnode(none, none, yylineno, "type_spec", none, none, "int", 0);}			
							| FLOAT							{$$=newnode(none, none, yylineno, "type_spec", none, none, "float", 0);}
							| CHAR 							{$$=newnode(none, none, yylineno, "type_spec", none, none, "char", 0);}
							| VOID							{$$=newnode(none, none, yylineno, "type_spec", none, none, "void", 0);}
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
							| init_declarator_list COMMA init_declarator   			{$$=newnode(",", none, yylineno, "init_declarator_list", none, none, none, 2, $1, $3);}
							;
init_declarator				: stmt_declarator									{$$=$1;}
							| stmt_declarator ASSIGN initializer				{$$=newnode(none, none, yylineno, "init_declarator", "=", none, none, 2, $1, $3);}
							;
struct_decl					: type_spec_list struct_declarator_list SEMI     	{$$=newnode(none, none, yylineno, "struct_decl", none, none, none, 2, $1, $2);}
							;
type_spec_list				: type_spec type_spec_list							{$$=newnode(none, none, yylineno, "type_spec_list", none, none, none, 2, $1, $2);}
							| type_spec											{$$=newnode(none, none, yylineno, "type_spec_list", none, none, none, 1, $1);}	
							| CONST type_spec_list								{$$=newnode(none, none, yylineno, "type_spec_list", none, none, none, 1, $2);}
							| CONST												{$$=newnode(none, none, yylineno, "type_spec_list", none, none, constt, 0);}
							;
struct_declarator_list		: stmt_declarator									{$$=newnode(none, none, yylineno, "struct_declarator_list", none, none, none, 1, $1);}
							| struct_declarator_list COMMA stmt_declarator		{$$=newnode(",", none, yylineno, "struct_declarator_list", none, none, none, 2, $1, $3);}
							;
func_declarator				: IDENT													{$$ = newnode(none, none, yylineno, "func_declarator", $1, none, none, 0);}
							| func_declarator LPAR param_list RPAR 		{$$ = newnode("(", ")", yylineno,"func_declarator", none, none, none, 2, $1, $3);}								
							| func_declarator LPAR id_list RPAR 		{$$ = newnode("(", ")", yylineno,"func_declarator", none, none, none, 2, $1, $3);}							
							| func_declarator LPAR RPAR 				{$$ = newnode("(", ")", yylineno,"func_declarator", none, none, none, 1, $1);}								
							;
stmt_declarator				: IDENT													{$$ = newnode(none, none, yylineno,"stmt_declarator", $1, none, none, 0);}		
							| stmt_declarator LBRACKET conditional_exp RBRACKET		{$$ = newnode("[", "]", yylineno,"stmt_declarator", none, none, none, 2, $1, $3);}		
							| stmt_declarator LBRACKET RBRACKET						{$$ = newnode("[", "]", yylineno,"stmt_declarator", none, none, none, 1, $1);}		
							;
param_list					: param_decl											{$$=$1;}
							| param_list COMMA param_decl							{$$ = newnode(",", none, yylineno,"param_list", none, none, none, 2, $1, $3);}		
							;
param_decl					: stmt_specs stmt_declarator					{$$ = newnode(none, none, yylineno,"param_decl", none, none, none, 2, $1, $2);}		
							| stmt_specs paranthesis_decl					{$$ = newnode(none, none, yylineno,"param_decl", none, none, none, 2, $1, $2);}
							| stmt_specs									{$$ = newnode(none, none, yylineno,"param_decl", none, none, none, 1, $1);}		
							;
id_list						: IDENT								{$$ = newnode(none, none, yylineno,"id_list", $1, none, none, 0);}													
							| id_list COMMA IDENT				{$$ = newnode(",", none, yylineno,"id_list", $3, none, none, 1, $1);}									
							;
initializer					: assignment_exp											{$$=$1;}
							| LBRACE initializer_list RBRACE							{$$=newnode("{", "}", yylineno, "initializer", none, none, none, 1, $2);}
							| LBRACE initializer_list COMMA RBRACE						{$$=newnode("{", "}", yylineno, "initializer", none, none, none, 1, $2);}
							;
initializer_list			: initializer												{$$=$1;}
							| initializer_list COMMA initializer    					{$$=newnode(",", none, yylineno, "initializer_list", none, none, none, 2, $1, $3);}
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
selection_stat				: IF LPAR exp RPAR stat 									%prec "then"		{$$=newnode("(", ")", yylineno, "selection_stat", none, none, none, 2, $3, $5);}
							| IF LPAR exp RPAR stat ELSE stat												{$$=newnode("(", ")", yylineno, "selection_stat", none, none, none, 3, $3, $5, $7);}
							;
loop_stat					: WHILE LPAR exp RPAR stat								{$$=newnode("(", ")", yylineno, "loop_stat", none, none, none, 2, $3, $5);}
							| DO stat WHILE LPAR exp RPAR SEMI						{$$=newnode("(", ")", yylineno, "loop_stat", none, none, none, 2, $2, $5);}
							| FOR LPAR exp SEMI exp SEMI exp RPAR stat				{$$=newnode("(", ")", yylineno, "loop_stat", none, none, none, 4, $3, $5, $7, $9);}
							| FOR LPAR exp SEMI exp SEMI RPAR stat					{$$=newnode("(", ")", yylineno, "loop_stat", none, none, none, 3, $3, $5, $8);}
							| FOR LPAR exp SEMI SEMI exp RPAR stat					{$$=newnode("(", ")", yylineno, "loop_stat", none, none, none, 3, $3, $6, $8);}
							| FOR LPAR exp SEMI SEMI RPAR stat						{$$=newnode("(", ")", yylineno, "loop_stat", none, none, none, 2, $3, $7);}
							| FOR LPAR SEMI exp SEMI exp RPAR stat					{$$=newnode("(", ")", yylineno, "loop_stat", none, none, none, 3, $4, $6, $8);}
							| FOR LPAR SEMI exp SEMI RPAR stat						{$$=newnode("(", ")", yylineno, "loop_stat", none, none, none, 2, $4, $7);}
							| FOR LPAR SEMI SEMI exp RPAR stat						{$$=newnode("(", ")", yylineno, "loop_stat", none, none, none, 2, $5, $7);}
							| FOR LPAR SEMI SEMI RPAR stat							{$$=newnode("(", ")", yylineno, "loop_stat", none, none, none, 1, $6);}
							;
jump_stat					: CONTINUE SEMI										{$$=newnode(none, none, yylineno, "jump_stat", none, none, none, 0);}
							| BREAK SEMI										{$$=newnode(none, none, yylineno, "jump_stat", none, none, none, 0);}				
							| RETURN exp SEMI			  						{$$=newnode("return", none, yylineno, "jump_stat", none, none, none, 1, $2);}				
							| RETURN SEMI                 						{$$=newnode("return_semi", none, yylineno, "jump_stat", none, none, none, 0);}				
							;
exp_stat					: exp SEMI      									{$$=newnode(none, none, yylineno, "exp_stat", $1->string, ";", none, 1, $1);}
							| SEMI												{$$=newnode("exp_stat", none, yylineno, "exp_stat", ";", none, none, 0);}
							;
exp							: assignment_exp									{$$=newnode(none, none, yylineno, "exp", none, none, none, 1, $1);}										
							| exp COMMA assignment_exp 							{$$=newnode(none, none, yylineno, "exp", none, none, none, 2, $1, $3);}				
							;
assignment_exp				: conditional_exp									{$$=newnode(none, none, yylineno, "assignment_exp", none, none, none, 1, $1);}				
                            | unary_exp assignment_operator assignment_exp		{$$=newnode(none, none, yylineno, "assignment_exp", $2->string, none, none, 2, $1, $3);}
                            ;
assignment_operator			: PLUSASSIGN						{$$=newnode(none, none, yylineno, "assignment_operator", "+=", none, none, 0);}
							| MINUSASSIGN						{$$=newnode(none, none, yylineno, "assignment_operator", "-=", none, none, 0);}
							| STARASSIGN						{$$=newnode(none, none, yylineno, "assignment_operator", "*=", none, none, 0);}
							| SLASHASSIGN						{$$=newnode(none, none, yylineno, "assignment_operator", "/=", none, none, 0);}
							| ASSIGN							{$$=newnode(none, none, yylineno, "assignment_operator", "=", none, none, 0);}
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
							| LPAR type_name RPAR cast_exp			{$$=newnode("(", ")", yylineno, "cast_exp", none, none, none, 2, $2, $4);}				
							;
unary_exp					: variable_exp							{$$=newnode(none, none, yylineno, "unary_exp", none, none, none, 1, $1);}			
							| INCR unary_exp						{$$=newnode(none, none, yylineno, "unary_exp", "++", none, none, 1, $2);}			
							| DECR unary_exp						{$$=newnode(none, none, yylineno, "unary_exp", "--", none, none, 1, $2);}			
							| unary_operator cast_exp				{$$=newnode(none, none, yylineno, "unary_exp", $1->string, none, none, 2, $1, $2);}					
							| SIZEOF unary_exp						{$$=newnode(none, none, yylineno, "unary_exp", none, none, none, 1, $2);}			
							| SIZEOF LPAR type_name RPAR			{$$=newnode("(", ")", yylineno, "unary_exp", none, none, none, 1, $3);}						
							;
unary_operator				: AMP                                   {$$=newnode(none, none, yylineno, "unary_operator", "&", none, none, 0);}
                            | STAR                                  {$$=newnode(none, none, yylineno, "unary_operator", "*", none, none, 0);}
                            | PLUS                                  {$$=newnode(none, none, yylineno, "unary_operator", "+", none, none, 0);}
                            | MINUS                                 {$$=newnode(none, none, yylineno, "unary_operator", "-", none, none, 0);}
                            | TILDE                                 {$$=newnode(none, none, yylineno, "unary_operator", "`", none, none, 0);}
                            | BANG			                        {$$=newnode(none, none, yylineno, "unary_operator", "!", none, none, 0);}						
							;
variable_exp				: variables 										{$$ = newnode(none, none, yylineno, "variable_exp", none, none, none, 1, $1);}
							| variable_exp LBRACKET exp RBRACKET  				{$$ = newnode("[", "]", yylineno, "variable_exp", none, none, none, 2, $1, $3);}
							| variable_exp LPAR argument_exp_list RPAR 			{$$ = newnode("(", ")", yylineno, "variable_exp", none, none, none, 2, $1, $3);}
							| variable_exp LPAR RPAR 							{$$ = newnode("(", ")", yylineno, "variable_exp", none, none, none, 1, $1);}
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
							| LPAR exp RPAR						{$$=newnode("(", ")", yylineno, "variables_exp", none, none, none, 1, $2);}
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
		//fprintf(stdout, "There are no errors. Syntactically, %s is correct.\n", filename);
	} else {
		fprintf(stderr, "Error near %s line %d text '%s' \n\t%s\n", filename, yylineno, yytext, errormsg);
	}

    
	int i = 0, j;
	if (global_struct_itr > 0) {
		fprintf(stdout, "Global struct \n");
		fprintf(stdout, "\t");
	
		for (i = 0; i < global_struct_itr - 1; i++)
			fprintf(stdout, "%s, ", global_struct[i]);
		fprintf(stdout, "%s\n", global_struct[global_struct_itr - 1]);
	}
	if (global_itr > 0) {
		fprintf(stdout, "Global variables \n");
		fprintf(stdout, "\t");
		for (i = 0; i < global_itr - 1; i++)
			fprintf(stdout, "%s, ", global[i]);
		fprintf(stdout, "%s\n", global[global_itr - 1]);
		fprintf(stdout, "\n");
	}
	if (func_list_itr > 0) {
		for (i = 0; i < func_list_itr; i++) {
			struct function *func = func_list[i];
			
			char * type = "proto";
			if (strcmp(func->type, type) == 0) {
				fprintf(stdout, "Prototype %s, returns %s\n", func->name, func->dataType);
				fprintf(stdout, "\tParameters: ");
				for (j = 0; j < func->param_itr -1; j++) {
					fprintf(stdout, "%s, ", func->param[j]);
				}
				fprintf(stdout, "%s\n", func->param[func->param_itr - 1]);
			} else {
				fprintf(stdout, "Function %s, returns %s\n", func->name, func->dataType);
				if (func->param_itr > 0) {
					fprintf(stdout, "\tParameters: ");
					for(int j = 0; j < func->param_itr-1; j++)
						fprintf(stdout, "%s, ", func->param[j]);
					fprintf(stdout, "%s\n", func->param[func->param_itr-1]);
				}
				if (func->local_itr > 0) {
					fprintf(stdout, "\tLocal variables: ");
					for(int j = 0; j < func->local_itr-1; j++)
						fprintf(stdout, "%s, ", func->local_var[j]);
					fprintf(stdout, "%s\n", func->local_var[func->local_itr-1]);
				}
			}
			fprintf(stdout, "\n");
		}
    }
    
    return 0;
}

int semantic_analyzer(char * filename) {
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
		//fprintf(stdout, "There are no errors. Syntactically, %s is correct.\n", filename);
	} else {
		fprintf(stderr, "Error near %s line %d text '%s' \n\t%s\n", filename, yylineno, yytext, errormsg);
	}

    
	int i = 0, j;
	if (global_struct_itr > 0) {
		fprintf(stdout, "Global struct \n");
		fprintf(stdout, "\t");
	
		for (i = 0; i < global_struct_itr - 1; i++)
			fprintf(stdout, "%s, ", global_struct[i]);
		fprintf(stdout, "%s\n", global_struct[global_struct_itr - 1]);
	}
    fprintf(stdout, "Global variables \n");
    for (i = 0; i < global_itr; i++)
        fprintf(stdout, "\t%s\n", global[i]);
    fprintf(stdout, "\n");

    for (i = 0; i < func_list_itr; i++) {
        struct function *func = func_list[i];
        
        char * type = "proto";
        if (strcmp(func->type, type) == 0) {
            fprintf(stdout, "Prototype %s, returns %s\n", func->name, func->dataType);
            fprintf(stdout, "\tParameters:\n");
            for (j = 0; j < func->param_itr; j++) {
                fprintf(stdout, "\t\t%s\n", func->param[j]);
            }
        } else {
            fprintf(stdout, "Function %s, returns %s\n", func->name, func->dataType);
            
            fprintf(stdout, "\tParameters:\n");
            for(int j = 0; j < func->param_itr; j++)
                fprintf(stdout, "\t\t%s\n", func->param[j]);
            fprintf(stdout, "\n");
            fprintf(stdout, "\tLocal variables:\n");
            for(int j = 0; j < func->local_itr; j++)
                fprintf(stdout, "\t\t%s\n", func->local_var[j]);
        
            fprintf(stdout, "\n");
            fprintf(stdout, "\tStatements: ");
            for(int j = 0; j < func->statement_itr-1; j++)
                fprintf(stdout, "Expression on line %s, ", func->statements[j]);
            fprintf(stdout, "\n");
        }
        fprintf(stdout, "\n");
    }
    
    for (int i = 0; i < statement_itr; i++) {
        fprintf(stderr, "Error near %s %s\n", filename, error_statement[i]);
    }
    
    return 0;
}

void yyerror(const char* mesg)
{
	success = 0;
	errormsg = mesg;
}
