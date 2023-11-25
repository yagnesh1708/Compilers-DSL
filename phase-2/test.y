%{
	#include <stdio.h>
	#include <stdlib.h>
    #include <string.h>
	extern int yylex();
    extern FILE *fp,*op,*in;
    extern int label_num;
    extern FILE *yyin ;
	void yyerror(char *s);
%}

%union{
    char * string ;
}


%token <string> DATATYPE_PR
%token <string> DATATYPE_MAT
%token <string> DATATYPE_SET
%token <string> DATATYPE_FD

%token <string> B_OPS
%token <string> E_OPS
%token <string> U_OPS
%token <string> TF 

%token <string> ID
%token <string> CONSTANT
%token <string> NUM
%token <string> DOUBLE
%token <string> STRUCT


%token <string> FILER
%token <string> F_OPEN
%token <string> F_CLOSE
%token <string> F_R_W

%token <string> IF
%token <string> ELSE
%token <string> BRE_CON
%token <string> COMPARITIVE_OPS
%token <string> SCOPE

%token <string> AND_OR
%token <string> NEG
%token <string> RETURN
%token <string> LOOP
%token <string> VOID




%start rhyme

%%

    rhyme 
        : CODE 

    CODE 
        : CODE_PART CODE | CODE_PART ;


    CODE_PART 
        : DECL_STMT ; 

    DECL_STMT
        : DATA LIST ;

    DATA 
        : DATATYPE_PR | DATATYPE_MAT | DATATYPE_FD | DATATYPE_SET ;

    LIST
        : ITEM ',' LIST
        | ITEM ;

    ITEM 
        : ID 
        | EXPR_STMT 
        | ID '[' DIMENSION ']' 
        | ID '[' DIMENSION ']' '[' DIMENSION ']' ;
    
    DIMENSION
        : ID
        | NUM ;


%%

void yyerror(char* s){
    fprintf(op," : Invalid statment\n");
	printf("%s\n",s);
}

int main(int argc , char* argv[])
{
	char ift[100] ;
	yyin = fopen(ift,"r") ;

    
	fp = fopen(to,"w");
	op = fopen(po,"w");


    fprintf(fp,"Name: Busireddy Asli Nitej Reddy\n");
    fprintf(fp,"ID: CS21BTECH11011\n");

    int kkk = yyparse() ;
    
    if(kkk)
    {
       if( kkk == 3 )
       {
          printf("No return Statement\n") ;
       }
       printf("Failure\n") ;
    }
    else
    { 
        printf("Success\n") ;
    }

	return 0;
}