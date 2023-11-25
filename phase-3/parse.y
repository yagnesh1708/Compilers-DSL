%{
	#include <stdio.h>
	#include <stdlib.h>
    #include <string.h>
    #include "semantics.hpp"
	extern int yylex();
    extern FILE *fp,*op,*in,*cppfile;
    extern int label_num;
    extern FILE *yyin ;
	void yyerror(char *s);
    char *data_type;
    int scope;
%}

%union{
    char * string ;
    struct attr{
        char *id;
        char *value;
        char *type;
        int dim;
        char *size;
        char *scope;
        // added scope
    } entry;
    struct params{
        char *type;
        char *var;
    } param;
}

%token <string> DATATYPE_PR
%token <string> DATATYPE_MAT
%token <string> DATATYPE_FD

%token <string> B_OPS
%token <string> E_OPS
%token <string> U_OPS
%token <string> TF 

%token <string> ID
%token <string> CONSTANT
%token <string> CHAR
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

%type <entry> ITEM LHS DIMENSION RHS DATA LHS1 RHS1 SIMPLE PREDICATE
%type <param> PARAM
%type <string> UI_OP TEMP BI_OP CALL_STMT EXPR_STMT
%start rhyme

%%
 /* Program initiation and every code must contain main function */
    rhyme 
        : CODE MAIN_FUNC CODE {} ;

    CODE 
        : CODE CODE_PART  {} 
        | {} ;

    CODE_PART 
        : DECL_STMT ';' { fprintf(cppfile,";");  }  {}
        | STRUCTURE ';' { fprintf(cppfile,";");  } {}
        | FUNCTION {} ;
    
    STRUCTURE : STRUCT ID {scope ++;} '{'   STRUCT_STMTS  '}' {scope --;} {
        
        if( check_dtype($2) ) return 2;
        add_type($2);
        delete_scope(1);
        
        } ;

    STRUCT_STMTS : DECL_STMT ';' STRUCT_STMTS  {} | DECL_STMT ';' ;

    MAIN_FUNC : DATA MAIN '(' ')' { scope ++; } '{' STATS '}' { scope --; delete_scope(1); } 
            | VOID MAIN '(' ')' { scope ++ } '{'   STATS '}' {scope --; delete_scope(1); } ;

    
    FUNCTION : FUNC_HEADER FUNC_BODY {scope --; delete_scope(1);} ; // function declaration
   
    FUNC_HEADER : DATA ID {set1(data_type);} '('  ARGS ')' { 
        if(check_func($2)){ add_func(data_type,$2);}
        else {printf("Function name already exists"); return 2;} ; 
        scope ++;
        }
        | VOID ID '(' ARGS ')'  {
            if(check_func($2)){ add_func("void",$2);}
            else {printf("Function name already exists"); return 2;} ; 
            scope ++;
        };
    
    ARGS : ARG ',' ARGS  {} | ARG {} | {} ;

    ARG : DATA ID { 
        addarg(data_type);
        if(check($2,1)) insert($2,data_type,0,$2,1);
        else { printf("Variable name already declared \n") ; return 2;}
         } ;
   
    FUNC_BODY : '{'  STATS '}'  ;
    
    STATS : STAT STATS  {} | '{' STATS '}' STATS {} | {}   ;

    STAT
        : DECL_STMT ';'  
        | CALL_STMT ';'  
        | EXPR_STMT ';'  
        | RET ';'  
        | LOOP_STMT 
        | COND_STMT 
        | BRE_CON ';'  
        | PRINT_STMT ';' 
        | SCAN_STMT ';' 
        | FILE_STMTS ';'   ;

    DECL_STMT
        : DATA LIST ;

    DATA 
        : DATATYPE_PR { 
            data_type = $1;
            }
        | DATATYPE_MAT {data_type = $1 ; } 
        | DATATYPE_FD {data_type = $1 ;}
        | ID  { 
            if(check_dtype($1)) data_type = $1 ;
            else return 3;
            }
        | STRUCT ID  { 
            if(check_dtype($2)) data_type = $2 ;
            else return 3;
            } ;

    LIST
        : ITEM ',' LIST {
            if(check($1.id,scope)) insert($1.id,data_type,$1.dim,$1.size,scope);
            else return 2;
        }
        | ITEM {

            if(check($1.id,scope)) insert($1.id,data_type,$1.dim,$1.size,scope);
            else return 2;
        };
        // modified insert statements

    ITEM 
        : LHS {
            $$.id = $1.id ;
            $$.dim = $1.dim;
            $$.size = $1.size;
            }
        | LHS E_OPS RHS1  ;
        // initiation and declaration

    DIMENSION 
        : ID  {
            $$.value = $1;
            }
        | NUM  {
            $$.value = $1;
        };
    
    RET :  RETURN {} | RETURN RHS {} ;
    
    EXPR_STMT
        : LHS1 E_OPS RHS {
            if(strcmp($1.type,$3.type)!=0) return 4;
            $1.value = $3.value;
        }
        | UI_OP {} ;
    
    LHS
        : ID  {
            $$.id = $1;
            $$.dim = 0;
            $$.size = $1; 
        }
        | ID '[' DIMENSION  ']'   {
            char *temp;
            temp = $3.value;
            if(temp[0] < '0' || temp[0] > '9') 
            {
                if( check(temp,1) && check(temp,0) ) return 3 ;
            }
            $$.id = $1 ;
            $$.dim = 1;
            $$.size = $3.value;
        }
        | ID '[' DIMENSION ']' '[' DIMENSION ']' {
            char *temp;
            temp = $3.value;
            if(temp[0] < '0' || temp[0] > '9') 
            {
                if( check(temp,1) && check(temp,0) ) return 3 ;
            }
            char *temp2;
            temp2 = $6.value;
            if(temp2[0] < '0' || temp2[0] > '9') 
            {
                if( check(temp,1) && check(temp,0) ) return 3 ;
            }            
            $$.id = $1;
            $$.dim = 2;
            $$.size = strcat($3.value,",");
            $$.size = strcat($$.size,$6.value);
        } ;
        
    LHS1
        : ID  {
            if(check($1,0) && check($1,1)) return 3;
            $$.id = $1;
            $$.dim = 0;
            $$.size = $1; 
            $$.type = get_type($1);
        }
        | ID '[' DIMENSION ']' {
            char *temp;
            temp = $3.value;
            if(temp[0] >= '0' && temp[0] <= '9') 
            {
                // if(!( check(temp,1) && check(temp,0)) ) return 1 ;
                if(outofbounds(temp,get_size($1))) return 5;
            }
            $$.id = $1 ;
            $$.dim = 1;
            $$.type = get_type($1);
        }
        | ID '[' DIMENSION ']' '[' DIMENSION ']' {
            char *temp;
            temp = $3.value;
            if(temp[0] >= '0' && temp[0] <= '9') 
            {
                // if(!( check(temp,1) && check(temp,0)) ) return 1 ;
                if(outofbounds(temp,get_dim($1))) return 5;
            }
            char *temp2;
            temp2 = $6.value;
            if(temp2[0] >= '0' || temp2[0] <= '9') 
            {
                // if( check(temp2,1) && check(temp2,0) ) return 1 ;
                if(outofbounds(temp2,get_dim($1))) return 5;
            }            
            $$.id = $1;
            $$.dim = 2;
            // $$.size = strcat($3.value,",");
            // $$.size = strcat($$.size,$6.value);
            $$.type = get_type($1);
        } ;

    LOOP_LHS 
        : ID E_OPS {if(check($1,0) && check($1,1)) return 3;}
        | DATA ID E_OPS  ;    
    
    RHS 
        : LHS1  {$$.type = $1.type}
        | CONSTANT {char *temp = "string"; $$.type = temp;}
        | CHAR {char *temp = "int"; $$.type = temp;}
        | BI_OP {$$.type = $1}
        | CALL_STMT {$$.type = $1}
        | NUM  {char *temp = "int"; $$.type = temp; }
        | DOUBLE {char *temp = "double"; $$.type = temp;}
        | TF {char *temp = "bool"; $$.type = temp;}
        | ARRAY_1 {}
        | ARRAY_2 {}
        | PREDICATE {} ;

    RHS1 
        : LHS1  {$$.type = $1.type}
        | CONSTANT {char *temp = "string"; $$.type = temp;}
        | CHAR {char *temp = "int"; $$.type = temp;}
        | BI_OP {$$.type = $1}
        | CALL_STMT {$$.type = $1}
        | NUM  {char *temp = "int"; $$.type = temp; }
        | DOUBLE {char *temp = "double"; $$.type = temp;}
        | TF {char *temp = "bool"; $$.type = temp;}
        | ARRAY_1 {}
        | ARRAY_2 {}    
    
    ARRAY_1 : '[' INT_LIST ']' {} ;
    INT_LIST : NUM ',' INT_LIST {} | NUM {} ;

    ARRAY_2 : '['  ARR_LIST ']' {} ;
    ARR_LIST : ARRAY_1 ',' ARR_LIST {} | ARRAY_1 {} ;

    COND_STMT 
        : IF '(' PREDICATE ')' '{' STATS '}' {}
        | IF '(' PREDICATE ')' '{' STATS '}' ELSE COND_STMT {}
        | IF '(' PREDICATE ')' '{' STATS '}' ELSE '{' STATS '}' {} ;
    
    PREDICATE :  SIMPLE {}
                | '(' PREDICATE ')' AND_OR '(' PREDICATE ')' {}
                | NEG '(' PREDICATE ')' {} ;

    SIMPLE 
        : RHS1 COMPARITIVE_OPS RHS1  {
            if( strcmp($1.type,$3.type) !=0 ) return 4;
            } ;

    CALL_STMT
        : ID  '(' PARAM_LIST ')' {
            if(check_func($1)) return 3;
            else{
                $$ = get_typefunc($1);
                if(!(func_seman($1))) return 4; 
            }
            }
        | SINGLE_EN_DE_CRYPT {}
        | MULTIPLE_EN_DE_CRYPT  {} ;      
    
    SINGLE_EN_DE_CRYPT : EN_DE_CRYPT '(' ID ')'  {} ;
    
    MULTIPLE_EN_DE_CRYPT: 
        EN_DE_CRYPTS '(' LHS ',' ID ')' {} 
        | EN_DE_CRYPTS '(' NUM ',' ID ')' {} ;
    
    PRINT_STMT : PRINT '(' PRINT_PARAM ')' {} ;

    SCAN_STMT : SCAN '(' PRINT_PARAM ')' {} ;
        
    PRINT_PARAM : 
        ID  PRINT_PARAM_2 {} ;

    PRINT_PARAM_2 :
        ',' TEMP PRINT_PARAM_2
        | ;
        //  ',' ID PRINT_PARAM_2 {if(check($1,0) && check($1,1)) return 1;}
        //  | ',' CONSTANT PRINT_PARAM_2 
        //  | ;

    FILE_STMTS
    : F_OPEN '(' ID ',' CONSTANT ',' R_W ')'
    | F_CLOSE '(' ID ')' {if(check($3,scope)) return 3;} 
    ;

    LOOP_STMT 
        : ITERATE '(' LOOP_LHS RHS ':' PREDICATE ':' EXPR_STMT ')' '{' STATS '}' 
        | ITERATE '('  PREDICATE  ')' '{' STATS '}'  ;

    PARAM_LIST
        : PARAM ',' PARAM_LIST 
        | PARAM ;

    PARAM
        : TEMP {append($1);} ;

    BI_OP 
        : B_OPS '(' TEMP ',' TEMP ')' {if(strcmp($3,$5)!=0) return 4; $$ = $3 ;};

    UI_OP 
        : ID U_OPS {
            if(check($1,scope)) return 3;
            else{
                $$ = get_type($1);
            }
        }
        | U_OPS ID {
            if(check($2,scope)) return 3;
            else{
                $$ = get_type($2);
            }
        }
        ; 
        // check for a++, ++a
    TEMP 
        : UI_OP {$$ = $1;}
        | BI_OP {$$ = $1; }
        | CALL_STMT {$$ = $1; }
        | ID  {if(check($1,0) && check($1,1)) return 3; $$ = get_type($1);}
        | NUM {strcpy($$,"int");}
        | DOUBLE {strcpy($$,"float");}
        | CONSTANT {strcpy($$,"string");}
        | CHAR {strcpy($$,"char");}
        ;
        // check for a,b in add(a,b)
%%

void yyerror(char* s){
    fprintf(op," : Invalid statment\n");
	printf("%s\n",s);
}

int main(int argc , char* argv[])
{
    init();
    scope = 0;
	yyin = fopen(argv[1],"r") ;

    fp = fopen("tokens.txt","w") ;
    op = fopen("parser.txt","w") ;

    cppfile = fopen("gen.cpp","w") ;
    fprintf(cppfile,"#include <bits/stdc++.h> \n using namespace std;\n");
    
    fprintf(fp,"Team 19\n");

    int kkk = yyparse() ;
    
    if(kkk)
    {
       if(kkk == 1) printf("Semantic Error\n") ;
       else if(kkk == 2) printf("Redeclaration Error\n");
       else if(kkk == 3) printf("Undeclaration Error\n");
       else if(kkk == 4) printf("Type Error\n");
       else if(kkk == 5) printf("Out of bound Error\n");
    }
    else
    {
        printf("Success\n") ;
    }
    // print_table();
    // print_ftable();
   return 0 ;
}