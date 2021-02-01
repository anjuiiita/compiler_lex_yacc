mycc: main.o
	g++ main.o -o mycc
	pdflatex post

main.o: main.cpp
	g++ -c main.cpp

clean: 
	rm *.o mycc.exe post.aux post.log texput.log