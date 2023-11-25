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
    char *string ;
    struct symbol_table_entry{
        char *value;   
        char *type;
        char *id;
    } entry ;
    char* type;
}

%type <type> DATA
%token <string> DATATYPE_PR
%token <string> DATATYPE_MAT
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

%token <string> F_OPEN
%token <string> F_CLOSE
%token <string> R_W

%token <string> IF
%token <string> ELSE
%token <string> BRE_CON
%token <string> COMPARITIVE_OPS

%token <string> AND_OR
%token <string> NEG
%token <string> RETURN
%token <string> ITERATE
%token <string> VOID
%token <string> PRINT
%token <string> SCAN
%token <string> EN_DE_CRYPT
%token <string> EN_DE_CRYPTS
%token <string> MAIN

%type <entry> ITEM

%start rhyme

%%
 /* Program initiation and every code must contain main function */
    rhyme 
        : CODE MAIN_FUNC CODE ;

    CODE 
        : CODE CODE_PART | ;

    CODE_PART 
        : DECL_STMT ';'
        | STRUCTURE ';'
        | FUNC_HEADER ';'
        | FUNCTION ;
    
    STRUCTURE : STRUCT  ID  '{'  STRUCT_STMTS '}' ';'  ;

    STRUCT_STMTS : DECL_STMT ';' STRUCT_STMTS | DECL_STMT ';' ;

    MAIN_FUNC : DATA MAIN '(' ')' '{' STATS '}' 
            | VOID MAIN '(' ')' '{' STATS '}' ;

    FUNCTION : FUNC_HEADER FUNC_BODY ;
   
    FUNC_HEADER : DATA ID '(' ARGS ')'
            | VOID ID '(' ARGS ')' ;
    
    ARGS : ARG ',' ARGS 
        | ARG 
        | ;

    ARG : DATA ID ;
   
    FUNC_BODY : '{' STATS '}' ;
    
    STATS : STAT STATS 
        | '{' STATS '}' STATS 
        |   ;

    STAT
        : DECL_STMT ';' | CALL_STMT ';' | EXPR_STMT ';' | RET ';' | LOOP_STMT | COND_STMT 
        | BRE_CON ';' //only inside loop
        | PRINT_STMT ';'
        | SCAN_STMT ';'
        | FILE_STMTS ';' ;

    DECL_STMT
        : DATA LIST ;

    DATA 
        : DATATYPE_PR {strcpy($$.type,$1)}
        | DATATYPE_MAT {strcpy($$.type,$1)}
        | DATATYPE_FD {strcpy($$.type,$1)}
        | ID 
        | STRUCT ID ;

    LIST
        : ITEM ',' LIST
        | ITEM ;

    ITEM 
        : LHS {}
        | LHS E_OPS RHS {} ;

    DIMENSION 
        : ID  
        | NUM  ;
    
    RET : 
        RETURN 
        | RETURN RHS ;
    
    EXPR_STMT
        : LHS E_OPS RHS 
        | UI_OP  ;
    
    LHS
        : ID {printf("%s\n",$1)}   
        | ID '[' DIMENSION ']' 
        | ID '[' DIMENSION ']' '[' DIMENSION ']' ;

    LOOP_LHS 
        : ID E_OPS
        | DATA ID E_OPS ;    
    
    RHS 
        : LHS
        | CONSTANT 
        | BI_OP 
        | CALL_STMT 
        | NUM 
        | DOUBLE
        | TF
        | ARRAY_1
        | ARRAY_2 
        | PREDICATE ;

    RHS1 
        : LHS
        | CONSTANT 
        | BI_OP 
        | CALL_STMT 
        | NUM 
        | DOUBLE
        | TF
        | ARRAY_1
        | ARRAY_2 ;    
    
    ARRAY_1 : '[' INT_LIST ']' ;

    INT_LIST : NUM ',' INT_LIST 
        | NUM ;

    ARRAY_2 : '['  ARR_LIST ']' ;

    ARR_LIST : ARRAY_1 ',' ARR_LIST 
        | ARRAY_1;

    COND_STMT 
        : IF '(' PREDICATE ')' '{' STATS '}' 
        | IF '(' PREDICATE ')' '{' STATS '}' ELSE COND_STMT 
        | IF '(' PREDICATE ')' '{' STATS '}' ELSE '{' STATS '}' ;
    
    PREDICATE :  SIMPLE 
                | '(' PREDICATE ')' AND_OR '(' PREDICATE ')'
                | NEG '(' PREDICATE ')' ;

    SIMPLE 
        : RHS1 COMPARITIVE_OPS RHS1 ;

    CALL_STMT
        : ID '(' PARAM_LIST ')' 
        | SINGLE_EN_DE_CRYPT 
        | MULTIPLE_EN_DE_CRYPT ;      
    
    SINGLE_EN_DE_CRYPT : EN_DE_CRYPT '(' ID ')' ;

    MULTIPLE_EN_DE_CRYPT: EN_DE_CRYPTS '(' LHS ',' ID ')' | EN_DE_CRYPTS '(' NUM ',' ID ')' ;
    
    PRINT_STMT : PRINT '(' PRINT_PARAM ')' ;

    SCAN_STMT : SCAN '(' PRINT_PARAM ')' ;
        
    PRINT_PARAM : ID ',' CONSTANT PRINT_PARAM_2 | CONSTANT PRINT_PARAM_2 ;

    PRINT_PARAM_2 : | ',' ID PRINT_PARAM_2 ;

    FILE_STMTS
        : F_OPEN '(' ID ',' CONSTANT ',' R_W ')'
        | F_CLOSE '(' ID ')' ;

    LOOP_STMT 
        : ITERATE '(' LOOP_LHS RHS ':' PREDICATE ':' EXPR_STMT ')' '{' STATS '}' 
        | ITERATE '('  PREDICATE  ')' '{' STATS '}'  ;

    PARAM_LIST
        : PARAM ',' PARAM_LIST 
        | PARAM ;

    PARAM
        : TEMP 
        | CONSTANT ;

    BI_OP 
        : B_OPS '(' TEMP ',' TEMP ')' ;

    UI_OP 
        : ID U_OPS 
        | U_OPS ID ; 

    TEMP 
        : UI_OP 
        | BI_OP 
        | ID  
        | NUM 
        | DOUBLE ;

%%

void yyerror(char* s){
    fprintf(op," : Invalid statment\n");
	printf("%s\n",s);
}

int main(int argc , char* argv[])
{
	yyin = fopen(argv[1],"r") ;

    fp = fopen("tokens.txt","w") ;
    op = fopen("parser.txt","w") ;

    fprintf(fp,"Team 19\n");

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
   return 0 ;
}