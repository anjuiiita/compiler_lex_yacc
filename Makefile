mycc: main.o
	g++ main.o -o mycc
	pdflatex developers

main.o: main.cpp
	g++ -c main.cpp

clean: 
	rm *.o mycc.exe developers.pdf developers.log developers.aux