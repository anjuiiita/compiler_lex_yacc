%{
    #include "tokens.h"
    #include "yacc_parser.tab.h"

    #include <string.h>
    #include <ctype.h>

    #define MAX_INCLUDE_DEPTH 256
    #define MAX_REPLACEMENT_LENGTH 4096

    int include_stack_ptr = 0;

    int yywrap();
    struct stack {
        struct stack *prev[MAX_INCLUDE_DEPTH];
        YY_BUFFER_STATE buf;
        int lineno;
        char *filename;
        FILE *f;
        int ifdef_count;
        int endif_count;
        int else_count;
        char *define[20];
        int define_ptr;
        int size;
    };
    char *current_fname;

    struct stack*cur_stack;
    char *include_files[MAX_INCLUDE_DEPTH];
    int include_files_ptr = 0;
%}

%option yylineno

%% 
\/\/.*                 { }
\/\*.*\*\/             { }
[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]       { /* DO NOTHING */ }
[/][*]               { printf("%s Error near line %d Unclosed comment\n", current_fname, yylineno); exit(1); }
"("                  {  return LPAR; }          
")"                  { return RPAR; }
"["                  { return LBRACKET; }
"]"                  { return RBRACKET; }
"{"                  { return LBRACE; }
"}"                  { return RBRACE; }
"."                  { return DOT; }
","                  { return COMMA; }
";"                  { return SEMI; }
"?"                  { return QUEST; }
":"                  { return COLON; }
"+"                  { return PLUS; }
"-"                  { return MINUS; }
"*"                  { return STAR; }
"/"                  { return SLASH; }
"%"                  { return MOD; }
"`"                  { return TILDE; }
"|"                  { return PIPE; }
"&"                  { return AMP; }
"!"                  { return BANG; }
"||"                 { return DPIPE; }
"&&"                 { return DAMP; }
"="                  { return ASSIGN; }
"+="                 { return PLUSASSIGN; }
"-="                 { return MINUSASSIGN; }
"*="                 { return STARASSIGN; }
"/="                 { return SLASHASSIGN; }
"++"                 { return INCR; }
"--"                 { return DECR; }
"=="                 { return EQUALS; }
"!="                 { return NEQUAL; }
">"                  { return GT; }
">="                 { return GE; }
"<"                  { return LT; }
"<="                 { return LE; }

"void"               { yylval.ident = strdup(yytext); return VOID; }     
"char"               { yylval.ident = strdup(yytext); return CHAR; }
"int"                { yylval.ident = strdup(yytext); return INT; }
"float"              { yylval.ident = strdup(yytext); return FLOAT; }
"const"              { return CONST; }
"struct"             { 
                        /*begin_func = 0;
                        begin_struct = 1;*/
                        return STRUCT; 
                     }
"for"                { return FOR; }
"while"              { return WHILE; }
"do"                 { return DO; }
"if"                 { return IF; }
"else"               { return ELSE; }
"switch"             { return SWITCH; }
"case"               { return CASE; }
"default"            { return DEFAULT; }
"sizeof"             { return SIZEOF; }
"break"              { return BREAK; }
"continue"           { return CONTINUE; }
"return"             { return RETURN; }        

[0-9]+               { yylval.ident = strdup(yytext); return INTCONST; }
[-+]?[0-9]+\.?[0-9]+([eE][-+]?[0-9]+)? { yylval.ident = strdup(yytext); return REALCONST; }
\".*\"               { yylval.ident = strdup(yytext); return STRCONST; }
\'.*\'              { yylval.ident = strdup(yytext); return CHARCONST;}

[ \t\r\n]*            { /* Ignore */ }


[a-zA-Z_][a-zA-Z_0-9]*          { yylval.ident = strdup(yytext);  return IDENT; }

#include[ \t]*<.*>    {return HEADER; }
#include[ \t]*\"(.*)?\"\n   { /* got the include file name */
                        if ( include_stack_ptr >= MAX_INCLUDE_DEPTH) {
                            fprintf( stderr, "ERROR: include cycles detected. Exiting..\n" );
                            exit( 1 );
                        }
                        char *fn;
                        fn = strtok(yytext, " ");
                        fn = strtok(NULL, " ");
                        fn++;
                        fn[strlen(fn)-2] = 0;
                        initialize_current_struct(fn);
			            BEGIN(INITIAL);
                    }

<<EOF>>         {
                    if (cur_stack) {
                        int value = handle_end_of_file();
                        if (value == 1) {
                            yyterminate();
                        }
                    }
                    yyterminate();
                }  

"#define"[ ]+[a-zA-z_][a-zA-z_0-9]* 									{return DEFINE;}
#define[ \t]+(.*?)[ \t]+(.*?)[ \t\n]+    {
                                    char *p = strtok(yytext, " ");
                                    p = strtok(NULL, " ");
                                    char *word = p;
                                    YY_BUFFER_STATE buf;
                                    buf = yy_scan_string(p);

                                    int token;
                                    token = yylex();
                                    if (token < 57) {
                                        printf("%s Error: Identifier is already in the set of preprocessor symbols %s\n", current_fname, word);
                                    }
                                    int i;
                                    for (i = 0; i < cur_stack->define_ptr; i++) {
                                        if (strcmp(cur_stack->define[i], word) == 0) {
                                            printf("Error near %s line %d text %s\n", current_fname, cur_stack->lineno, yytext);
	                                        printf("re-defining preprocessor symbol %s", word);
                                        }
                                    }
                                    cur_stack->define[(cur_stack->define_ptr)++] = word;
                                    yy_delete_buffer(buf);
                                    yy_switch_to_buffer(cur_stack->buf);
                                    p = strtok(NULL, " ");
                                    int value_l = strlen(p);
                                    if (value_l >= MAX_REPLACEMENT_LENGTH) {
                                        printf("%s Error: replacement text length exceeded\n", current_fname);
                                    }
                                }

#ifdef[ a-zA-Z0-9\t]+       {
                                cur_stack->ifdef_count += 1;
                                char *p;
                                p = strtok(yytext, " ");
                                p = strtok(NULL, " ");
                                int idx;
                                for (idx = 0; idx < cur_stack->define_ptr; idx++ ) {
                                    if (strcmp(cur_stack->define[idx], p) != 0) {
                                        printf("%s ERROR: ifdef %s is not defined\n", current_fname, p);
                                    }
                                }
                            }        


#endif                  { cur_stack->endif_count+= 1;
                            if ( cur_stack->endif_count > cur_stack->ifdef_count ) {
                                printf("%s Error: mismatched endif directive\n", current_fname);
                            }
                         }
#ifndef                 {   cur_stack->ifdef_count += 1; 
                            char *p;
                            p = strtok(yytext, " ");
                            p = strtok(NULL, " ");
                            int idx;
                            for (idx = 0; idx < cur_stack->define_ptr; idx++ ) {
                                if (strcmp(cur_stack->define[idx], p) == 0) {
                                    printf("%s ERROR: ifndef %s is defined\n", current_fname, p);
                                }
                            }
                        }
#else                   { cur_stack->else_count += 0;
                          if (cur_stack->else_count > cur_stack->ifdef_count) {
                              printf("%s Error: mismatched else directive\n", current_fname);
                          }
                        }
.                   { return ERROR; } 

%%

int yywrap() {
    return(1); 
}

void initialize_current_struct(char *fn) {
    FILE *f = fopen( fn, "r" );

    struct stack *bs;

    int i;
    for (i = 0; i < include_files_ptr; i++) {
        if (strcmp(include_files[i], fn) == 0) {
            printf("%s Error: Includes cycle\n", fn);
            printf("Error near %s line %d text %s\n", fn, yylineno, yytext);
	        printf("#include cycle:\n");
	        printf("File %s includes %s\n", current_fname, fn);
	        printf("File %s includes %s\n", fn, current_fname);
            exit(1);
        }
    }
    if ( !f ) {
        printf("Error: Opening include file: %s\n", fn);
        perror(fn);
    } else {
        include_stack_ptr += 1;
        include_files[include_files_ptr++] = fn;
        bs = malloc(sizeof(struct stack));
        if(!bs) { perror("malloc"); exit(1); }
        bs->size = 0;
        if(cur_stack) {
            	cur_stack->lineno = yylineno;
            	bs->prev[bs->size] = cur_stack;
	    	bs->size += 1;
        }
        bs->f = f;
        bs->filename = fn;
        bs->buf = yy_create_buffer(f, YY_BUF_SIZE);
        yy_switch_to_buffer(bs->buf);
        bs->ifdef_count = 0;
        bs->endif_count = 0;
        bs->else_count = 0;
        bs->define_ptr = 0;
        cur_stack = bs;
        yylineno = 1;
        current_fname = fn;
	token_analyzer_util(current_fname);
	BEGIN(INITIAL);
    }
}

int handle_end_of_file() {
	struct stack *bs = cur_stack;

    struct stack **prevbs;
    if(!bs) {
        printf("hello\n");
		return 0;
	}
	//if (!bs->prev) return 0;
    prevbs = bs->prev;
    fclose(bs->f);
    yy_delete_buffer(bs->buf);
    if(!prevbs) {
		return 0;
    }
    if( bs->ifdef_count > bs->endif_count) {
		printf("%s Error: mismatched ifdef directive\n", current_fname);
    }
	
	bs->size -= 1;
	if (bs->size >= 0) {
        	yy_switch_to_buffer(prevbs[bs->size]->buf);
        	cur_stack = prevbs[bs->size];
        	yylineno = cur_stack->lineno;
        	current_fname = cur_stack->filename;
        	include_stack_ptr -= 1;
	}
	return 1;
}

void token_analyzer_util(char * current_fname) {
    int token = yylex();
    while (token) {
        switch (token)
        {
        case LPAR:
            printf("%s line %d text %s token LPAR\n", current_fname, yylineno, yytext);
            break;
        case RPAR: 
            printf("%s line %d text %s token RPAR\n", current_fname, yylineno, yytext);
            break;
        case LBRACKET: 
            printf("%s line %d text %s token LBRACKET\n", current_fname, yylineno, yytext);
            break;
        case RBRACKET:
            printf("%s line %d text %s token RBRACKET\n", current_fname, yylineno, yytext);
            break;
        case LBRACE: 
            printf("%s line %d text %s token LBRACE\n", current_fname, yylineno, yytext);
            break;
        case RBRACE:  
            printf("%s line %d text %s token RBRACE\n", current_fname, yylineno, yytext);
            break;  
        case DOT:
            printf("%s line %d text %s token DOT\n", current_fname, yylineno, yytext);
            break;
        case COMMA: 
            printf("%s line %d text %s token COMMA\n", current_fname, yylineno, yytext);
            break; 
        case SEMI:
            printf("%s line %d text %s token SEMI\n", current_fname, yylineno, yytext);
            break;
        case QUEST:  
            printf("%s line %d text %s token QUEST\n", current_fname, yylineno, yytext);
            break;
        case COLON: 
            printf("%s line %d text %s token COLON\n", current_fname, yylineno, yytext);
            break;
        case PLUS: 
            printf("%s line %d text %s token PLUS\n", current_fname, yylineno, yytext);
            break;
        case MINUS:  
            printf("%s line %d text %s token MINUS\n", current_fname, yylineno, yytext);
            break;
        case STAR:
            printf("%s line %d text %s token STAR\n", current_fname, yylineno, yytext);
            break;
        case SLASH:  
            printf("%s line %d text %s token SLASH\n", current_fname, yylineno, yytext);
            break;
        case MOD:
            printf("%s line %d text %s token MOD\n", current_fname, yylineno, yytext);
            break;
        case TILDE: 
            printf("%s line %d text %s token TILDE\n", current_fname, yylineno, yytext);
            break; 
        case PIPE:
            printf("%s line %d text %s token PIPE\n", current_fname, yylineno, yytext);
            break;
        case AMP:
            printf("%s line %d text %s token AMP\n", current_fname, yylineno, yytext);
            break;
        case BANG:  
            printf("%s line %d text %s token BANG\n", current_fname, yylineno, yytext);
            break;
        case DPIPE:  
            printf("%s line %d text %s token DPIPE\n", current_fname, yylineno, yytext);
            break;
        case DAMP:
            printf("%s line %d text %s token DAMP\n", current_fname, yylineno, yytext);
            break;
        case ASSIGN:  
            printf("%s line %d text %s token ASSIGN\n", current_fname, yylineno, yytext);
            break;
        case PLUSASSIGN: 
            printf("%s line %d text %s token PLUSASSIGN\n", current_fname, yylineno, yytext);
            break; 
        case MINUSASSIGN:  
            printf("%s line %d text %s token MINUSASSIGN\n", current_fname, yylineno, yytext);
            break;
        case STARASSIGN:
            printf("%s line %d text %s token STARASSIGN\n", current_fname, yylineno, yytext);
            break;
        case SLASHASSIGN:  
            printf("%s line %d text %s token SLASHASSIGN\n", current_fname, yylineno, yytext);
            break;
        case INCR:
            printf("%s line %d text %s token INCR\n", current_fname, yylineno, yytext);
            break;
        case DECR: 
            printf("%s line %d text %s token DECR\n", current_fname, yylineno, yytext);
            break;
        case EQUALS:  
            printf("%s line %d text %s token EQUALS\n", current_fname, yylineno, yytext);
            break;
        case NEQUAL: 
            printf("%s line %d text %s token NEQUAL\n", current_fname, yylineno, yytext);
            break;
        case GT:
            printf("%s line %d text %s token GT\n", current_fname, yylineno, yytext);
            break;
        case GE: 
            printf("%s line %d text %s token GE\n", current_fname, yylineno, yytext);
            break;
        case LT: 
            printf("%s line %d text %s token LT\n", current_fname, yylineno, yytext);
            break;
        case LE:
            printf("%s line %d text %s token LE\n", current_fname, yylineno, yytext);
            break;
        case INT:
            printf("%s line %d text %s token INT\n", current_fname, yylineno, yytext);
            break;
        case CHAR:
            printf("%s line %d text %s token CHAR\n", current_fname, yylineno, yytext);
            break;
        case VOID:
            printf("%s line %d text %s token VOID\n", current_fname, yylineno, yytext);
            break;
        case FLOAT:
            printf("%s line %d text %s token FLOAT\n", current_fname, yylineno, yytext);
            break;
        case CONST:
            printf("%s line %d text %s token CONST\n", current_fname, yylineno, yytext);
            break;
        case STRUCT:
            printf("%s line %d text %s token STRUCT\n", current_fname, yylineno, yytext);
            break;
        case FOR:
            printf("%s line %d text %s token FOR\n", current_fname, yylineno, yytext);
            break;
        case WHILE:
            printf("%s line %d text %s token WHILE\n", current_fname, yylineno, yytext);
            break;
        case DO:
            printf("%s line %d text %s token DO\n", current_fname, yylineno, yytext);
            break;
        case IF:
            printf("%s line %d text %s token IF\n", current_fname, yylineno, yytext);
            break;
        case ELSE:
            printf("%s line %d text %s token ELSE\n", current_fname, yylineno, yytext);
            break;
        case BREAK:
            printf("%s line %d text %s token BREAK\n", current_fname, yylineno, yytext);
            break;
        case CONTINUE:
            printf("%s line %d text %s token CONTINUE\n", current_fname, yylineno, yytext);
            break;
        case RETURN:
            printf("%s line %d text %s token RETURN\n", current_fname, yylineno, yytext);
            break;
        case IDENT:
            printf("%s line %d text %s token IDENT\n", current_fname, yylineno, yytext);
            break;
        case INTCONST:
            printf("%s line %d text %s token INTCONST\n", current_fname, yylineno, yytext);
            break;
        case REALCONST:
            printf("%s line %d text %s token REALCONST\n", current_fname, yylineno, yytext);
            break;
        case STRCONST:
            printf("%s line %d text %s token STRCONST\n", current_fname, yylineno, yytext);
            break;
        case CHARCONST:
            printf("%s line %d text %s token CHARCONST\n", current_fname, yylineno, yytext);
            break;
	    case ERROR:
            printf("Error: Bad Character in file %s in line %d text %s\n", current_fname, yylineno, yytext);
            break;
        case HEADER:
            printf("Warning: ignoring %s directive in %s line %d\n", yytext, current_fname, yylineno);
            break;
        default:
            printf("Error: Syntax error in file %s in line %d text %s\n", current_fname, yylineno, yytext);
            break;
        }
        token = yylex();
    }
}
