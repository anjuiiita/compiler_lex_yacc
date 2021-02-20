#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "tokens.h"

int token_analyzer_util() {
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
        case TYPE:
            printf("%s line %d text %s token TYPE\n", current_fname, yylineno, yytext);
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
        case DIRECTIVES:
            printf("Warning: ignoring %s directive in %s line %d\n", yytext, current_fname, yylineno);
            break;
        default:
            printf("Error: Syntax error in file %s in line %d text %s\n", current_fname, yylineno, yytext);
            break;
        }
        token = yylex();
    }
    fclose(yyin);
    return yylval;
}