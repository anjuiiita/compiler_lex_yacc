mycc: main.o lex_cc.o yacc_parser.tab.o
	gcc -o mycc main.o lex_cc.o yacc_parser.tab.o 
	#pdflatex developers

main.o: main.c tokens.h
	gcc -c main.c

yacc_parser.tab.o: yacc_parser.tab.c yacc_parser.tab.h
	gcc -c yacc_parser.tab.c

yacc_lex_cc.o: yacc_lex_cc.c yacc_parser.tab.h
	gcc -c yacc_lex_cc.c

lex_cc.o: lex_cc.c tokens.h yacc_parser.tab.h
	gcc -c lex_cc.c

lex_cc.c: lexer.l tokens.h yacc_parser.tab.h
	flex -o lex_cc.c lexer.l



yacc_lex_cc.c: yacc_lex.l yacc_parser.tab.h
	flex -o yacc_lex_cc.c yacc_lex.l

yacc_parser.tab.h yacc_parser.tab.c: yacc_parser.y
	bison -d yacc_parser.y
	#bison --debug --verbose -d yacc_parser.y

clean: 
	rm *.o mycc lex_cc.c yacc_parser.tab.c
	#developers.pdf developers.log

