/*enum yytokentype {       
    LPAR = 1,
    RPAR = 2,
    LBRACKET = 3,
    RBRACKET = 4,
    LBRACE = 5,
    RBRACE = 6,
    DOT = 7,
    COMMA = 8,
    SEMI = 9,
    QUEST = 10,
    COLON = 11,
    PLUS = 12,
    MINUS = 13,
    STAR = 14,
    SLASH = 15,
    MOD = 16,
    TILDE = 17,
    PIPE = 18,
    AMP = 19,
    BANG = 20,
    DPIPE = 21,
    DAMP = 22,
    ASSIGN = 23,
    PLUSASSIGN = 24,
    MINUSASSIGN = 25,
    STARASSIGN = 26,
    SLASHASSIGN = 27,
    INCR = 28,
    DECR = 29,
    EQUALS = 30,
    NEQUAL = 31,
    GT = 32,
    GE = 33,
    LT = 34,
    LE = 35,

    TYPE = 46,
    CONST = 47,
    STRUCT = 48,
    FOR = 49,
    WHILE = 50,
    DO = 51,
    IF = 52,
    ELSE = 53,
    BREAK = 54,
    CONTINUE = 55,
    RETURN = 56,
    IDENT = 57,
    INTCONST = 58,
    REALCONST = 59,
    STRCONST = 60,
    CHARCONST = 61,
    ERROR = 62,
    DIRECTIVES = 63
};*/

//extern int yylval;
//extern int yylineno;
//extern char* yytext;
//extern FILE *yyin, *yyout;

void token_analyzer_util(char *current_fname);
void initialize_current_struct();
int initialize_parser();
int semantic_analyzer();
int handle_end_of_file();
void print_parsed_tokens();
