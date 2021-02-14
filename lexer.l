%{
    #include "tokens.h"
    #include<string.h>

    #define MAX_INCLUDE_DEPTH 2
    YY_BUFFER_STATE include_stack[MAX_INCLUDE_DEPTH];
    int include_stack_ptr = 0;
    int yylval;
    int yywrap();
    
%}
%option yylineno

%% 

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

[ \t\r]*            { }
\n                  { }
\/\*.*\*\/          { }
\/\/.*\\n           { }

[a-zA-Z][_a-zA-Z0-9]*           { return IDENT; }

#include[ \t]*<.*>    {return DIRECTIVES; }
#include[ \t]*\"(.*)?\"\n   { /* got the include file name */
                    if ( include_stack_ptr >= MAX_INCLUDE_DEPTH ) {
                        fprintf( stderr, "ERROR: include cycles detected. Exiting..\n" );
                        exit( 1 );
                   }

                    include_stack[include_stack_ptr++] = YY_CURRENT_BUFFER;
                    printf("back to lexer %s\n", yytext); 
                    char *f;// = strdup(yytext);
                    f = strtok(yytext, " ");
                    f = strtok(NULL, " ");
                    f++;
                    f[strlen(f)-2] = 0;
                    yyin = fopen( f, "r" );

                    if ( !yyin ) {
                        printf("Error opening include file: %s\n", f);
                    }

                    yy_switch_to_buffer(yy_create_buffer( yyin, YY_BUF_SIZE ) );
                    printf("begin initial\n");

                    BEGIN(INITIAL);
                    }

<<EOF>>         {
                    if ( include_stack_ptr == 0 ) {
                        yyterminate();
                    } else {
                        yy_delete_buffer( YY_CURRENT_BUFFER );
                        include_stack_ptr -= 1;
                        yy_switch_to_buffer( include_stack[include_stack_ptr] );
                    }
                }  
.                   { return ERROR; } 

%%

int yywrap(){ return(1); }


    