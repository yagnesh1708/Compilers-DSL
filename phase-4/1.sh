flex lex.l
yacc -d parse.y
g++ lex.yy.c parse.tab.c 
./a.out $1