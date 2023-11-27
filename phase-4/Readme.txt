
Download and extract all the files from the zip file.
The input program should be placed in ".txt" file.
Input should follow the specifications of our DSL.

Now we need to run "1.sh" bash script by providing input file name as command line argument.

Let "inp.txt" be the input file.

Now run the following command 

> ./1.sh inp.txt

The output will be printed in 3 different files.

(i) tokens.txt => contains all the tokens generated.

(ii) parser.txt => This is the parsed file which is generated if there is no syntax error.

(ii) gen.cpp => After performing semantic checks, this is the cpp code genrated by the compiler.

Now we can run the generated "gen.cpp" file using the following commands.

> g++ gen.cpp

> ./a.out