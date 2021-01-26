mycc: main.o
	g++ main.o -o mycc

main.o: main.cpp
	g++ -c main.cpp

clean: 
	del *.o mycc.exe