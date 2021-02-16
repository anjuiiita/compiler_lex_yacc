
# mycc compiler

This is the repository for building a Java compiler.

## To build the compiler please run following command:

make

## To run the comiler please run below command:

mycc

## Feature Part 0

For part 0,  mode 0 is implemented which is reading from file and printing it.

And generating developers.pdf file from developers.tex is implemented

### To run mycc in mode 0, give below command after mycc.

mycc -0

## Feature Part 1

For part 1,  mode 1 is implemented which uses flex to tokenize the input file. To run mode 1 please run below command.

mycc -1 <input_file>

For processing multiple files, run below command:

mycc -1 <input_file>  <input_file>... 

In Part 1,  #include is implemented.
If there is error opening include file, error is genrated and if a cycle if detected then also Error is generated at max depth 256.

#define is also implemented, if the defined var is a keyword, it generates approriate erroe message and also checks the length of replacement text and appropriate error is generated.

#ifdef, #ifndef #endif #else directive mismatched in implemented

#ifdef indetifier if not defined then Error is printed.

## To read from input file please run below command

mycc -o out.txt

## Command to clean the auto generated files

make clean