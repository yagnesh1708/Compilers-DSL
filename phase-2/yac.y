%{
    #include <iostream>
	#include <stdio.h>
	#include <stdlib.h>
    #include <string.h>
    using namespace std;
	extern int yylex();
    extern FILE *fp,*op,*in;
    extern int label_num;
    extern FILE *yyin ;
	void yyerror(char *s);
    struct symbol_table_entry{
        char * value;   
        char * type;
        char * id;
    };

    struct symbol_table_entry symbol_table[1000];
%}

%union{
    char * string ;
}


%token <string> DATATYPE_PR
%token <string> DATATYPE_MAT
%token <string> DATATYPE_SET
%token <string> DATATYPE_FD

%token <string> B_OPS
%token <string> B_OPS_WS
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
%token <string> SCOPE

%token <string> AND_OR
%token <string> NEG
%token <string> RETURN
%token <string> ITERATE
%token <string> VOID
%token <string> PRINT
%token <string> SCAN
%token <string> MAIN
%token <string> TYPEDEF



%start rhyme

%%

    rhyme 
        : CODE MAIN_FUNC CODE { cout << "Hello" << endl; };

    CODE 
        : CODE CODE_PART | ;

    CODE_PART 
        : DECL_STMT ';'
        | STRUCTURE ';'
        | FUNC_HEADER ';'
        | FUNCTION 
        ;
    
    STRUCTURE : STRUCT ID '{'  STRUCT_STMTS '}' ';' ;

    STRUCT_STMTS : DECL_STMT ';' STRUCT_STMTS | DECL_STMT ';' ;

    MAIN_FUNC : DATA MAIN '(' ')' '{' STATS '}' ;

    FUNCTION : FUNC_HEADER FUNC_BODY ;
   
    FUNC_HEADER : DATA ID '[' NUM ']' '(' ARGS ')' {ID.type = DATA.value}
            | VOID ID '[' NUM ']' '(' ARGS ')'  {ID.type = "VOID"}
            ;
    
    ARGS : ARG ',' ARGS | ARG | ;

    ARG : DATA ID {ID.type = DATA.value}
        ;
   
    FUNC_BODY : '{' STATS '}' ;
    
    STATS : STAT STATS | STAT | ;

    STAT
        : DECL_STMT ';' | CALL_STMT ';' | EXPR_STMT ';' 
        | RET ';' 
        | LOOP_STMT | COND_STMT ;

    DECL_STMT
        : DATA LIST {LIST.type = DATA.value};

    DATA 
        : DATATYPE_PR | DATATYPE_MAT | DATATYPE_FD | ID | STRUCT ID ;

    LIST
        : ITEM ',' LIST {ITEM.type = LIST.type}
        | ITEM {ITEM.type = LIST.type}
        ;

    ITEM 
        : ID  
        | ID '[' DIMENSION ']' 
        | ID '[' DIMENSION ']' '[' DIMENSION ']' 
        | ID  E_OPS RHS  ;

    DIMENSION 
        : ID  
        | NUM  ;
    

    RET : RETURN LHS 
        | RETURN CALL_STMT 
        | RETURN PREDICATE 
        | RETURN  ;
    

    EXPR_STMT
        : LHS E_OPS RHS {LHS.type = RHS.type}
        | UI_OP 
        | FILE_OPEN ;

    FILE_OPEN
        : F_OPEN '(' ID ',' CONSTANT ',' R_W ')'
        | F_CLOSE '(' ID ')' ;
    
    LHS
        : ID  
        | ID '[' DIMENSION ']' 
        | ID '[' DIMENSION ']' '[' DIMENSION ']' ;

    LOOP_LHS 
        : ID E_OPS
        | DATA ID E_OPS ;    
    
    RHS 
        : ID {RHS.type = ID.type}
        | CONSTANT {RHS.type = "String"}
        | BI_OP 
        | CALL_STMT {RHS.type = CALL_STMT.type}
        | NUM {RHS.type = "int"}
        | DOUBLE {RHS.type = "double"}
        | TF {RHS.type = "bool"};
        
    COND_STMT 
        : IF '(' PREDICATE ')' '{' STATS '}' 
        | IF '(' PREDICATE ')' '{' STATS '}' ELSE COND_STMT 
        | IF '(' PREDICATE ')' '{' STATS '}' ELSE '{' STATS '}' ;
    
    PREDICATE :  SIMPLE 
                | '(' PREDICATE ')' AND_OR '(' PREDICATE ')'
                | NEG '(' PREDICATE ')' ;
    
    SIMPLE : RHS COMPARITIVE_OPS RHS | CALL_STMT ;

    CALL_STMT
        : ID '(' PARAM_LIST ')' {CALL_STMT.type = ID.type}
        | PRINT_STMT {CALL_STMT.type = "void"}
        | SCAN_STMT {CALL_STMT.type = "void"} ;
    
    PRINT_STMT : PRINT '(' PRINT_PARAM ')' ;
    SCAN_STMT : SCAN '(' PRINT_PARAM ')' ;
        
    PRINT_PARAM : ID ',' CONSTANT PRINT_PARAM_2 | CONSTANT PRINT_PARAM_2 ;
    PRINT_PARAM_2 : | ',' ID PRINT_PARAM_2 ;

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
   return 0 ;
}