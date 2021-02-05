#include <iostream>
#include <string>
#include <fstream>
using namespace std;

int main(int argc, char* argv[]) {
    if (argc < 2) {
        string line;
        ifstream myfile ("noargs.out.txt");
        while ( getline (myfile,line) )
        {
                cout << line << '\n';
        }
        myfile.close(); 
        return 0;
    }

    string mode = argv[1];
    if (mode == "-0") {
        string line;
        ifstream myfile ("zeroarg.out.txt");
        while ( getline (myfile,line) ) {
                cout << line << '\n';
        }
        myfile.close(); 
    } else if(mode == "-o") {
        string filename = argv[2];
        fstream f;
        f.open(filename);
        string line;
        ifstream myfile (filename);
        while ( getline (myfile,line) ) {
                cout << line << '\n';
        }
        myfile.close();
    } else {
            cout << "Not implemented yet" << endl;
    }
   return 0;
}