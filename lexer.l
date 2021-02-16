%{
    #include "tokens.h"
    #include <string.h>
    #include <ctype.h>

    #define MAX_INCLUDE_DEPTH 256
    #define MAX_REPLACEMENT_LENGTH 4096

    int include_stack_ptr = 0;
    int yylval;
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
    
    char *include_files[MAX_INCLUDE_DEPTH];
    int include_files_ptr = 0;
%}

%option yylineno

%% 
\/\/.*                 { }
\/\*.*\*\/             { }
[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]       { /* DO NOTHING */ }
[/][*]               { printf("%s Error near tricky.txt line %d Unclosed comment\n", current_fname, yylineno); exit(1); }
"("                  { return LPAR; }          
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

"void"               { return TYPE; }     
"char"               { return TYPE; }
"int"                { return TYPE; }
"float"              { return TYPE; }
"const"              { return CONST; }
"struct"             { return STRUCT; }
"for"                { return FOR; }
"while"              { return WHILE; }
"do"                 { return DO; }
"if"                 { return IF; }
"else"               { return ELSE; }
"break"              { return BREAK; }
"continue"           { return CONTINUE; }
"return"             { return RETURN; }

[0-9]+               { yylval = atoi(yytext); return INTCONST; }
[-+]?[0-9]+\.?[0-9]+([eE][-+]?[0-9]+)? { return REALCONST; }
\".*\"               { return STRCONST; }
\'.*\'              { return CHARCONST;}

[ \t\r]*            { /* Ignore */ }
\n                  { /* Ignore */ }


[a-zA-Z][_a-zA-Z0-9]*           { return IDENT; }

#include[ \t]*<.*>    {return DIRECTIVES; }
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
                    }

<<EOF>>         {   
                    struct stack *bs = cur_stack;
                    if( bs->ifdef_count > bs->endif_count) {
                        printf("%s Error: mismatched ifdef directive\n", current_fname);
                    }
                    
                    struct stack **prevbs;
                    if(!bs) return 0;

                    prevbs = bs->prev;
                    fclose(bs->f);
                    yy_delete_buffer(bs->buf);
                    if(bs->size == 0) {
                        yyterminate();
                    }
                    bs->size -= 1;
                    yy_switch_to_buffer(prevbs[bs->size]->buf);
                    cur_stack = prevbs[bs->size];
                    cur_stack->size -= 1;
                    yylineno = cur_stack->lineno;
                    current_fname = cur_stack->filename;
                    include_stack_ptr -= 1;
                }  


#define[ \t]+(.*?)[ \t]+(.*?)[ \t\n]+    {
                                    char *p = strtok(yytext, " ");
                                    p = strtok(NULL, " ");
                                    char *s, *word = p;
                                    for ( ; *s; ++s) *s = tolower(*s);
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
            bs->prev[bs->size++] = cur_stack;
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
        BEGIN(INITIAL);
    }
}