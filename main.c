#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "tokens.h"

int main(int argc, char* argv[]) {
    int c, i;
    FILE *file;
    if (argc < 2) {
        if ((file = fopen("noargs.out.txt", "r")) != NULL) {
            while ((c = getc(file)) != EOF)
                putchar(c);
            fclose(file);
        }
        return 0;
    }
    if (argv[1][0] != '-') {
        return 0;
    }
    char mode = argv[1][1];
    switch (mode) {
        case '0':
            if (argc >= 3) {
                if (argv[2][0] != '-') {
                    return 0;
                }
                char next_mode = argv[2][1];
                switch (next_mode) {
                    case 'o':
                        if (argc == 4) {
                            FILE * fptr = fopen(argv[3], "w");
                            if (fptr == NULL) {
                                printf("Error opening the file\n");
                                return 0;
                            }
                            if ((file = fopen("zeroarg.out.txt", "r")) != NULL) {
                                while ((c = getc(file)) != EOF) {
                                    fprintf(fptr, "%c", c);
                                }
                                fclose(file);
                                fclose(fptr);
                            }
                        } else {
                            printf("Please provide the filename after -o\n");
                        }
                        break;
                    default:
                        break;
                }
            } else {
                if ((file = fopen("zeroarg.out.txt", "r")) != NULL) {
                    while ((c = getc(file)) != EOF)
                        putchar(c);
                    fclose(file);
                }
            }
            break;
        case '1':
            if (argc < 3) {
                printf("Please provide the filename after -1\n");
            } else {
                for(i = 2; i < argc; i++) {
                    initialize_current_struct(argv[i]);
                }    
            }
            break;
        case '2':
            if (argc < 3) {
                printf("Please provide the filename after -1\n");
            } else {
                initialize_parser(argv[2]);
            }
            break;
        case '3':
            if (argc < 3) {
                printf("Please provide the filename after -1\n");
            } else {
                semantic_analyzer(argv[2]);
            }
            break;
        default:
            printf("Not implemented yet\n");
                break;
    }
    return 0;

}
