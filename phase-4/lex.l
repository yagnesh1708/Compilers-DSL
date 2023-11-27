%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    #include "y.tab.h"
    FILE *fp,*op,*in,*cppfile;
    int a , b , c ;
    int label_num;
%}      

spaces [ |\t]+

s_digit [0-9]+
s_letter [a-zA-Z_] 
s_alpnum [a-zA-Z_0-9]

datatype_pr ("bool"|"int"|"char"|"string"|"ifstream"|"ofstream")
datatype_fd ("float"|double)
datatype_mat ("matrix")

en_de_crypt ("str_encrypt"|"str_decrypt")
en_de_crypts ("file_encrypt"|"file_decrypt")


vo ("void")
tf ("TRUE"|"FALSE")

f_open ("f_open")
f_close ("f_close")
main ("main")

special_symbols ("["|"]"|"("|")"|"\{"|"\}")
b_ops ("add"|"mul"|"sub"|"div")
u_ops ("++"|"--")
e_ops ("=")

struc ("struct")

ret ("return")
loop ("iterate")

anor ("or"|"and")

number -?{s_digit}+
p_number {s_digit}+
fd_number {number}e{p_number}

punctuation [,:;]
conditional_stats_if ("if")
conditional_stats_el ("else")
comparitive_ops ("ne"|"geq"|"gt"|"leq"|"lt"|"eq")
neg ("neg")
f_printf ("print")
f_scanf ("scan")

id {s_letter}{s_alpnum}*
id2 {number}{s_letter}{s_alpnum}*

bre_con ("break"|"continue")


comment_1 #(.)*
comment_2 #"*"(.|\n)*"*"#

%%

{datatype_pr} { 
    yylval.string = strdup(yytext) ;
    fprintf(fp,"datatype: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return DATATYPE_PR ;
}

{datatype_mat} { 
    yylval.string = strdup(yytext) ;
    fprintf(fp,"datatype: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return DATATYPE_MAT ;
}

{datatype_fd} { 
    yylval.string = strdup(yytext) ;
    fprintf(fp,"datatype: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return DATATYPE_FD;
}

{f_printf} { 
    yylval.string = strdup(yytext) ;
    fprintf(fp,"reserved keyword: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return PRINT ;
}

{f_scanf} { 
    yylval.string = strdup(yytext) ;
    fprintf(fp,"reserved keyword: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return SCAN ;
}

{f_open} { 
    yylval.string = strdup(yytext) ;
    fprintf(fp,"reserved keyword: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return F_OPEN ;
}

{f_close} { 
    yylval.string = strdup(yytext) ;
    fprintf(fp,"reserved keyword: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return F_CLOSE ;
}

'r' {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"reserved keyword: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return R_W;
}

'w' {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"reserved keyword: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return R_W;
}

{number} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"constant: %s\n",yytext);
    fprintf(op,"%s",yytext); 
    return NUM ;
}

{fd_number} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"constant: %s\n",yytext);
    fprintf(op,"%s",yytext); 
    return DOUBLE ;
}

{en_de_crypt} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"constant: %s\n",yytext);
    fprintf(op,"%s",yytext); 
    return EN_DE_CRYPT ;
}

{en_de_crypts} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"constant: %s\n",yytext);
    fprintf(op,"%s",yytext); 
    return EN_DE_CRYPTS ;
}

{special_symbols} {

    yylval.string = strdup(yytext) ;
    fprintf(fp,"special symbol: %s\n",yytext);
    fprintf(op,"%s",yytext); 

    if(yytext[0] == '[') return yytext[0] ;
    if(yytext[0] == ']') return yytext[0] ;
    if(yytext[0] == '(') return yytext[0] ;
    if(yytext[0] == ')') return yytext[0] ;

    if(yytext[0] == '{')
    {
       b++ ;
       return yytext[0] ;
    } 

    if(yytext[0] == '}')
    { 
       b-- ;
       if( a == 1 && c == 0 && b <= 0  ) 
       {
          printf("No Return Statement\n") ;
          fprintf(op,"%s","No Return Statement\n"); 
          return 3 ;
       }
       return yytext[0] ;
    }

}

{b_ops} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"operator: %s\n",yytext);
    fprintf(op,"%s",yytext); 
    return B_OPS;
}

{u_ops} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"operator: %s\n",yytext);
    fprintf(op,"%s",yytext); 
    return U_OPS;
}

{e_ops} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"operator: %s\n",yytext);
    fprintf(op,"%s",yytext); 
    return E_OPS;
}

{tf} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"true_or_false: %s\n",yytext);
    fprintf(op,"%s",yytext); 
    return TF;
}

{struc} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"reserved keyword: %s\n",yytext);
    fprintf(op,"%s",yytext); 
    return STRUCT ;    
}

{main} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"reserved keyword: %s\n",yytext);
    fprintf(op,"%s",yytext); 
    return MAIN ;    
}

{punctuation} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"punctuation: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    if(yytext[0] == ',') return yytext[0] ;
    if(yytext[0] == ':') return yytext[0] ;
    if(yytext[0] == ';') return yytext[0] ;
}

{conditional_stats_if} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"reserved keyword: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return IF ;
}

{conditional_stats_el} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"reserved keyword: %s\n",yytext); 
    return ELSE ;
}

{bre_con} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"reserved keyword: %s\n",yytext); 
    return BRE_CON;
}

{comparitive_ops} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"reserved keyword: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return COMPARITIVE_OPS ;
}

{ret} {
    yylval.string = strdup(yytext) ;
    c = 1 ;
    a = 0 ;
    fprintf(fp,"reserved keyword: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return RETURN ;   
}

{vo} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"reserved keyword: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return VOID ;   
}


{anor} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"reserved keyword: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return AND_OR ;
}


{loop} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"reserved keyword: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return ITERATE ;
}


{neg} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"reserved keyword: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return NEG ;
}


\"(\\.|[^\\"])*\" {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"punctuation: \"\n");
    fprintf(fp,"constant: ");

    for(int i=1;i<yyleng-1;i++){
        fprintf(fp,"%c",yytext[i]);
    }

    fprintf(op,"%s",yytext); 

    fprintf(fp,"\npunctuation: \"\n");
    return CONSTANT ;
}

'.' {
    yylval.string = strdup(yytext) ;
    fprintf(op,"%s",yytext); 
    fprintf(fp,"punctuation: %c\n",yytext[0]);
    fprintf(fp,"constant: %c\n",yytext[1]);
    fprintf(fp,"punctuation: %c\n",yytext[2]);
    return CHAR;
}

{id} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"ID: %s\n",yytext);
    fprintf(op,"%s",yytext); 
    return ID ;
}

{id2} {
    yylval.string = strdup(yytext) ;
	fprintf(fp,"Invalid token at line number: %d",label_num);
    printf("Invalid token\n");
	return *yytext;
}

{spaces} {
    yylval.string = strdup(yytext) ;
    fprintf(op,"%s",yytext); 
	// fprintf(op,"%s","%s",yytext);
}

\n {
    yylval.string = strdup(yytext) ;
    fprintf(op,"%s",yytext); 
    fprintf(cppfile,"\n"); 
    label_num++ ;
	// fprintf(op,"%s","%s",yytext);
}

{comment_1} 

{comment_2} 

. {
    yylval.string = strdup(yytext) ;
	fprintf(fp,"Invalid token at line number: %d",label_num);
    fprintf(op,"%s",yytext); 
	return 0;
}

%%

int yywrap()
{
  return 1;
}