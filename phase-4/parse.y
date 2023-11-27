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
    int cond;
    int loopcount;
%}

%union{
    char * string ;
    struct attr{
        char *id;
        char *value;
        char *type;
        int dim;
        char *size;
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
%type <string> UI_OP TEMP BI_OP CALL_STMT EXPR_STMT SINGLE_EN_DE_CRYPT
%start rhyme

%%
 /* Program initiation and every code must contain main function */
    rhyme 
        : CODE MAIN_FUNC CODE {} ;

    CODE 
        : CODE CODE_PART  {} 
        | {} ;

    CODE_PART 
        :  DECL_STMT ';' { fprintf(cppfile,";\n");  } 
        | STRUCTURE ';' { fprintf(cppfile,";\n");  } 
        | FUNCTION {} ;
    
    STRUCTURE : STRUCT ID {scope ++;} '{' { fprintf(cppfile,"struct ");
        fprintf(cppfile,$2);
        fprintf(cppfile,"\n{");
        }  STRUCT_STMTS  '}' {
        scope --;
        fprintf(cppfile,"}\n");
        if( check_dtype($2) ) return 2;
        add_type($2);
        delete_scope(1);
        
        } ;

    STRUCT_STMTS : DECL_STMT ';' {fprintf(cppfile,";\n");} STRUCT_STMTS
            | DECL_STMT ';' {fprintf(cppfile,";\n");} ;

    MAIN_FUNC : DATA MAIN '(' ')' { scope ++; } '{' 
    {
        fprintf(cppfile,data_type);
        fprintf(cppfile," main ");
        fprintf(cppfile,"()\n{");
    } STATS '}' { 
        fprintf(cppfile,"}\n");
        scope --;
         delete_scope(1);
         } 
            | VOID MAIN '(' ')' { scope ++ } '{'  
            {
                fprintf(cppfile,"void");
                fprintf(cppfile," main ");
                fprintf(cppfile,"()\n{");
            }
             STATS '}' {fprintf(cppfile,"}\n");scope --; delete_scope(1); } ;

    
    FUNCTION : FUNC_HEADER FUNC_BODY {scope --; delete_scope(1);} ; // function declaration
   
    FUNC_HEADER : DATA ID {
        fprintf(cppfile,data_type);
        fprintf(cppfile," ");
        fprintf(cppfile,$2);
        set1(data_type);
        } '(' {fprintf(cppfile,"(");} ARGS ')' {
            fprintf(cppfile,")"); 
        if(check_func($2)){ add_func(data_type,$2);}
        else {printf("Function name already exists"); return 2;} ; 
        scope ++;
        }
        | VOID ID '('{fprintf(cppfile,"void");fprintf(cppfile," ");fprintf(cppfile,$2);fprintf(cppfile,"(");} ARGS ')'  {
            fprintf(cppfile,")");
            if(check_func($2)){ add_func("void",$2);}
            else {printf("Function name already exists"); return 2;} ; 
            scope ++;
        };
    
    ARGS : ARG ',' {fprintf(cppfile,",")} ARGS  {} | ARG {} | {} ;

    ARG : DATA ID { 
        fprintf(cppfile,data_type);
        fprintf(cppfile," ");
        fprintf(cppfile,$2);
        addarg(data_type);
        if(check($2,1)) insert($2,data_type,0,$2,1);
        else { printf("Variable name already declared \n") ; return 2;}
         } ;
   
    FUNC_BODY : '{' {fprintf(cppfile,"\n{\n")} STATS '}' {fprintf(cppfile,"}\n")}  ;
    
    STATS : STAT STATS  {} 
        |'{' {fprintf(cppfile,"\n{\n")} STATS '}' {fprintf(cppfile,"}\n")} STATS {} 
        | {}   ;

    STAT
        : DECL_STMT ';'  {fprintf(cppfile," ;\n");}
        | CALL_STMT ';'  {fprintf(cppfile," ;\n");}
        | EXPR_STMT ';'  {fprintf(cppfile," ;\n");}
        | RET ';'  {fprintf(cppfile," ;\n");}
        | LOOP_STMT {fprintf(cppfile," \n");}
        | COND_STMT {fprintf(cppfile," \n");}
        | BRE_CON ';'  {
            if(loopcount == 0) return 1;
            fprintf(cppfile," ");
            fprintf(cppfile,$1);
            fprintf(cppfile," ;\n");}
        | PRINT_STMT ';' {fprintf(cppfile," ;\n");}
        | SCAN_STMT ';' {fprintf(cppfile," ;\n");}
        | FILE_STMTS ';' {fprintf(cppfile," ;\n");}
          ;

    DECL_STMT
        : DATA { fprintf(cppfile,data_type);} LIST ;

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
        : ITEM ',' {fprintf(cppfile,",");} LIST {
            if(check($1.id,scope)) 
            {
                insert($1.id,data_type,$1.dim,$1.size,scope);
            }
            else return 2;
        }
        | ITEM {
            if(check($1.id,scope)){
                insert($1.id,data_type,$1.dim,$1.size,scope);
            }
            else return 2;
        };
        // modified insert statements

    ITEM 
        : LHS {
            $$.id = $1.id ;
            $$.dim = $1.dim;
            $$.size = $1.size;
            }
        | LHS E_OPS {fprintf(cppfile," = ");} RHS1 {
            if(strcmp(data_type,$4.type) !=0) return 4;
            $$.id = $1.id ;
            $$.dim = $1.dim;
            $$.size = $1.size;
        } ;
        // initiation and declaration

    DIMENSION 
        : ID  {
            $$.value = $1;
            }
        | NUM  {
            $$.value = $1;
        };
    
    RET :  RETURN {fprintf(cppfile," return ");} | RETURN {fprintf(cppfile," return ");} RHS {} ;
    
    EXPR_STMT
        : LHS1 E_OPS {fprintf(cppfile," = ");} RHS {
            if(strcmp($1.type,$4.type)!=0) return 4;
            $1.value = $4.value;
        }
        | UI_OP {} ;
    
    LHS
        : ID  {
            $$.id = $1;
            $$.dim = 0;
            $$.size = $1; 
            fprintf(cppfile," ");
            fprintf(cppfile,$1);
        }
        | ID '[' DIMENSION  ']'   {
            char *temp;
            temp = $3.value;
            if(temp[0] < '0' || temp[0] > '9') 
            {
                if( check(temp,1) && check(temp,0) ) return 3 ;
            }
            fprintf(cppfile," ");
            fprintf(cppfile,$1);
            fprintf(cppfile,"[");
            fprintf(cppfile,temp);
            fprintf(cppfile,"]");
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
            fprintf(cppfile," ");
            fprintf(cppfile,$1);
            fprintf(cppfile,"[");
            fprintf(cppfile,temp);
            fprintf(cppfile,"]");  
            fprintf(cppfile,"[");
            fprintf(cppfile,temp2);
            fprintf(cppfile,"]");
            $$.id = $1;
            $$.dim = 2;
            $$.size = strcat($3.value,",");
            $$.size = strcat($$.size,$6.value);
        } ;
        
    LHS1
        : ID  {
            if(check($1,0) && check($1,1)) return 3;
            fprintf(cppfile," ");
            fprintf(cppfile,$1);
            $$.id = $1;
            $$.dim = 0;
            $$.size = $1; 
            $$.type = get_type($1);
            // printf("%s\n",get_type($1));
        }
        | ID '[' DIMENSION ']' {
            char *temp;
            temp = $3.value;
            if(temp[0] >= '0' && temp[0] <= '9') 
            {
                // if(!( check(temp,1) && check(temp,0)) ) return 1 ;
                if(outofbounds(temp,get_size($1))) return 5;
            }
            fprintf(cppfile," ");
            fprintf(cppfile,$1);
            fprintf(cppfile,"[");
            fprintf(cppfile,temp);
            fprintf(cppfile,"]");
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
            fprintf(cppfile," ");
            fprintf(cppfile,$1);
            fprintf(cppfile,"[");
                  fprintf(cppfile,temp);
            fprintf(cppfile,"]");
            fprintf(cppfile,"[");
            fprintf(cppfile,temp2);
            fprintf(cppfile,"]");
            // $$.size = strcat($3.value,",");
            // $$.size = strcat($$.size,$6.value);
            $$.type = get_type($1);
        } ;

    LOOP_LHS 
        : ID E_OPS {
            if(check($1,0) && check($1,1)) return 3;
            fprintf(cppfile," ");
            fprintf(cppfile,$1);
            fprintf(cppfile," = ");
            }
        | DATA ID E_OPS {
            if(check($2,0) && check($2,1)) return 3;
            fprintf(cppfile,data_type);
            fprintf(cppfile," ");
            fprintf(cppfile,$2);
            fprintf(cppfile," = ");
        } ;    
    
    RHS 
        : LHS1  {$$.type = $1.type; }
        | CONSTANT {char temp[] = "string"; $$.type = temp;fprintf(cppfile,$1);}
        | CHAR {char temp[] = "int"; $$.type = temp;fprintf(cppfile,$1);}
        | BI_OP {$$.type = $1;}
        | CALL_STMT {$$.type = $1;}
        | NUM  {char temp[] = "int"; $$.type = temp;fprintf(cppfile,$1); }
        | DOUBLE {char temp[] = "double"; $$.type = temp;fprintf(cppfile,$1);}
        | TF {char temp[] = "bool"; $$.type = temp;fprintf(cppfile,$1);}
        | ARRAY_1 {}
        | ARRAY_2 {}
        | PREDICATE {} ;

    RHS1 
        : LHS1  {$$.type = $1.type; }
        | CONSTANT {char temp[] = "string"; $$.type = temp;fprintf(cppfile,$1);}
        | CHAR {char temp[] = "int"; $$.type = temp;fprintf(cppfile,$1);}
        | BI_OP {$$.type = $1}
        | CALL_STMT {$$.type = $1}
        | NUM  {char temp[] = "int"; $$.type = temp;fprintf(cppfile,$1); }
        | DOUBLE {char temp[] = "double"; $$.type = temp;fprintf(cppfile,$1);}
        | TF {char temp[] = "bool"; $$.type = temp;fprintf(cppfile,$1);}
        | ARRAY_1 {}
        | ARRAY_2 {}    
    
    ARRAY_1 : '[' INT_LIST ']' {} ;
    INT_LIST : NUM ',' INT_LIST {} | NUM {} ;

    ARRAY_2 : '['  ARR_LIST ']' {} ;
    ARR_LIST : ARRAY_1 ',' ARR_LIST {} | ARRAY_1 {} ;

    COND_STMT 
        : IF_BLOCK ELSE_BLOCK ;
        
    IF_BLOCK
        : IF '(' {fprintf(cppfile,"if ( ");} 
            PREDICATE ')' '{' {fprintf(cppfile," )\n { \n "); } STATS 
        '}' {fprintf(cppfile," }\n "); } ;
    ELSE_BLOCK
        :
        ELSE '{' {;fprintf(cppfile,"else \n { ");} STATS 
             '}' {fprintf(cppfile," }\n "); }
        |  ;
    
    PREDICATE :  SIMPLE {}
                | '(' {fprintf(cppfile,"(");} PREDICATE ')' AND_OR '(' {
                    fprintf(cppfile,")");
                    if(strcmp($5,"and") == 0) fprintf(cppfile," && ");
                    else fprintf(cppfile," || ");
                    fprintf(cppfile,"(");
                    } PREDICATE ')' {fprintf(cppfile,")");}
                | NEG '(' {fprintf(cppfile,"!");fprintf(cppfile,"(");} PREDICATE ')' {fprintf(cppfile,")");} ;

    SIMPLE 
        : RHS1 COMPARITIVE_OPS {
            if(strcmp($2,"lt") == 0) fprintf(cppfile," < ");
            else if(strcmp($2,"gt") == 0) fprintf(cppfile," > ");
            else if(strcmp($2,"lteq") == 0) fprintf(cppfile," <= ");
            else if(strcmp($2,"gteq") == 0) fprintf(cppfile," >= ");
            else if(strcmp($2,"eq") == 0) fprintf(cppfile," == ");
            else if(strcmp($2,"neq") == 0) fprintf(cppfile," != ");
            } RHS1  {
                // printf("%s,%s\n",$1.type,$4.type);
            if( strcmp($1.type,$4.type) !=0 ) return 4;
            } ;

    CALL_STMT
        : ID '('{
            fprintf(cppfile," ");
            fprintf(cppfile,$1);fprintf(cppfile,"(");
        } PARAM_LIST ')' {
            fprintf(cppfile,")");
            if(check_func($1)) return 3;
            else{
                $$ = get_typefunc($1);
                if(!(func_seman($1))) return 4; 
            }
            }
        | SINGLE_EN_DE_CRYPT { char temp[] = "string" ; $$ = temp;}
        | MULTIPLE_EN_DE_CRYPT  {} ;      
    
    SINGLE_EN_DE_CRYPT : EN_DE_CRYPT '('  ID ',' ID ')'  {
         if(check($3,scope)) return 2;
            if(check($5,scope)) return 2;
        fprintf(cppfile,"encryptDecrypt (%s,%s)",$3,$5);
        // printf("%s,%s",get_type($3),get_type($5));
        // if(strcmp(get_type($3),"string") !=0 && strcmp(get_type($5),"string") !=0) return 4;
        // if(strcmp(get_type($5),"string") !=0){
        //    printf("%s",get_type($5));
        //     return 4;
        // }
        strcpy($$,get_type($3));
        } ;
    
    MULTIPLE_EN_DE_CRYPT: 
        EN_DE_CRYPTS '(' ID ',' ID ',' ID ')' {
            if(check($3,scope)) return 2;
            if(check($5,scope)) return 2;
            if(check($7,scope)) return 2;
            fprintf(cppfile,"encryptDecryptFile (%s,%s,%s)",$3,$5,$7);} 
       
    
    PRINT_STMT : PRINT  '(' PRINT_PARAM ')' {} ;

    SCAN_STMT : SCAN  '(' PRINT_PARAM ')' {} ;
        
    PRINT_PARAM : 
        ID { if(( strcmp($1,"cin")!=0 && strcmp($1,"cout")  !=0)){
            if(get_dim($1) != -1) return 3;
            if(check($1,scope)) return 2;
        }
         fprintf(cppfile,"%s ",$1);} PRINT_PARAM_2 ;

    PRINT_PARAM_2 :
        ',' {fprintf(cppfile,"<< ");} TEMP PRINT_PARAM_2
        | {fprintf(cppfile,"<< endl;");};
        //  ',' ID PRINT_PARAM_2 {if(check($1,0) && check($1,1)) return 1;}
        //  | ',' CONSTANT PRINT_PARAM_2 
        //  | ;

    FILE_STMTS
    : F_OPEN '(' ID ',' CONSTANT ')' { 
        // if(check($3,scope)) return 3;
        // dimx($3);
        fprintf(cppfile,"%s.open(%s)",$3,$5);
        }
    | F_CLOSE '(' ID ')' {if(check($3,scope)) return 3;fprintf(cppfile,"%s.close()",$3);} 
    ;

    LOOP_STMT 
        : ITERATE '(' { 
            fprintf(cppfile,"for(");
        } LOOP_LHS RHS ':' {fprintf(cppfile,";");} PREDICATE ':' {fprintf(cppfile,";");} EXPR_STMT ')' '{' {loopcount++;fprintf(cppfile,"){");} STATS '}' {loopcount--;fprintf(cppfile,"}");}
        | ITERATE '(' {fprintf(cppfile,"while(");}  PREDICATE  ')' '{' {loopcount++;fprintf(cppfile,"){");} STATS '}' {loopcount--;fprintf(cppfile,"}");} ;

    PARAM_LIST
        : PARAM ',' {fprintf(cppfile,",");} PARAM_LIST 
        | PARAM ;

    PARAM
        : TEMP {append($1);} ;
        // | CONSTANT {append("string");} ;

    BI_OP 
        : B_OPS '(' {
            if(strcmp($1,"add") == 0) cond = 1;
            else if(strcmp($1,"sub") == 0) cond = 2;
            else if(strcmp($1,"mul") == 0) cond = 3;
            else if(strcmp($1,"div") == 0) cond = 4;
            fprintf(cppfile,"(");
            } TEMP ',' {
                // printf("%d",cond);
                if(cond == 1) fprintf(cppfile," + ");
                else if(cond == 2) fprintf(cppfile," - ");
                else if(cond == 3) fprintf(cppfile," * ");
                else if(cond == 4) fprintf(cppfile," / ");
            } TEMP ')' {if(strcmp($4,$7)!=0) return 4; 
            fprintf(cppfile,")");
        $$ = $4 ;
        };

    UI_OP 
        : ID U_OPS {
            if(check($1,scope)) return 3;
            else{
                // strcpy($$,get_type($1));
                fprintf(cppfile,$1);
                fprintf(cppfile,$2);
                $$ = get_type($1);
            }
        }
        | U_OPS ID {
            if(check($2,scope)) return 3;
            else{
                fprintf(cppfile,$1);
                fprintf(cppfile,$2);
                $$ = get_type($2);
            }
        }
        ; 
        // check for a++, ++a
    TEMP 
        : UI_OP {$$ = $1;}
        | BI_OP {$$ = $1}
        | ID  {if(check($1,0) && check($1,1)) return 3;
         $$ = get_type($1);
         fprintf(cppfile," ");
         fprintf(cppfile,$1);
         }
        | NUM { fprintf(cppfile,$1); char temp[] = "int" ; $$ = temp; }
        | DOUBLE { fprintf(cppfile,$1); char temp[] = "double"; $$ = temp; }
        | CONSTANT { fprintf(cppfile,$1); char temp[] = "string"; $$ = temp; }
        | CHAR { fprintf(cppfile,$1); char *temp = "char"; $$ = temp; }
        | CALL_STMT {$$ = $1}
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
    cond = -1;
    scope = 0;
    loopcount = 0;
	yyin = fopen(argv[1],"r") ;

    fp = fopen("tokens.txt","w") ;
    op = fopen("parser.txt","w") ;

    cppfile = fopen("gen.cpp","w") ;
    fprintf(cppfile,"#include <bits/stdc++.h> \n #include \"ende.hpp\" \n using namespace std;\n");
    
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
    print_table();
    // print_ftable();
   return 0 ;
}