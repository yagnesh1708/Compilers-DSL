flex lex.l
bison -d parse.y
g++ lex.yy.c parse.tab.c 
./a.exe inp.txt 