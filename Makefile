mycc: main.o lex_cc.o lex_main.h
	gcc -o mycc main.o lex_cc.o
	pdflatex developers

main.o: main.c
	gcc -c main.c

#lexer: lex_main.o lex_cc.o
#	gcc -o lexer lex_main.o lex_cc.o

#lex_main.o: lex_main.c tokens.h
#	gcc -c lex_main.c

lex_cc.o: lex_cc.c tokens.h
	gcc -c lex_cc.c

lex_cc.c: lexer.l tokens.h
	flex -o lex_cc.c lexer.l

clean: 
	rm *.o mycc lex_cc.c
	#developers.pdf developers.log developers.aux