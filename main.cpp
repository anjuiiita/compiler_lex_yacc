#include <iostream>
#include <string>
using namespace std;

int main(int argc, char* argv[]) {
    if (argc < 2)
        cout << "Please append valid mode in command" << endl;
        return 0;

    string mode = argv[1];
    if (mode == "-0") {
            cout << "gcc version 8.1.0" << endl; 
    } else {
            cout << "Not implemented yet" << endl;
    }
   return 0;
}