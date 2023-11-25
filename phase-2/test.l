%{
    #include "y.tab.h"
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    #include "y.tab.h"
    FILE *fp,*op,*in;
    FILE *yyin ;
    int a , b , c ;
    int label_num;
%}


spaces [ |\t]+
special_chars [-] 

s_digit [0-9]+
s_letter [a-zA-Z_]
s_alpnum [a-zA-Z_0-9]

datatype_pr ("bool"|"int"|"char"|"string")
datatype_fd ("float"|double)
datatype_mat ("matrix")
datatype_set ("set")


vo ("void")
tf ("TRUE"|"FALSE")

filer ("file")
f_open ("open")
f_close ("close")
f_t ("read"|"write")

special_symbols ("["|"]"|"("|")"|"\{"|"\}")
b_ops ("add"|"mul"|"sub"|"div")
b_ops_ws ("+"|"*"|"-"|"/")
u_ops ("postincr"|"postdecr")
a_ops ("->")
e_ops ("=")

struc ("struct")

ret ("return")
loop ("iterate")

anor ("or"|"and")
this ("this")

number -?{s_digit}+
p_number {s_digit}+
fd_number {number}e{p_number}

punctuation [,:;]
conditional_stats_if ("if")
conditional_stats_el ("else")
comparitive_ops ("ne"|"geq"|"gt"|"leq"|"lt"|"eq")
neg ("neg")
scope ("global"|"local")

id {s_letter}{s_alpnum}*
id2 {number}{s_letter}{s_alpnum}*

f_printf ("print")
bre_con ("break"|"continue")

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

{datatype_set} { 
    yylval.string = strdup(yytext) ;
    fprintf(fp,"datatype: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return DATATYPE_SET ;
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
    return PRINTER ;
}

{filer} { 
    yylval.string = strdup(yytext) ;
    fprintf(fp,"datatype: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return FILER ;
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

{f_t} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"id: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return F_R_W ;
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

{b_ops_ws} {
    yylval.string = strdup(yytext) ;a
    fprintf(fp,"operator: %s\n",yytext);
    fprintf(op,"%s",yytext); 
    return B_OPS_WS;
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

{scope} {
    a = 1 ; b = 0 ; c = 0 ;
    yylval.string = strdup(yytext) ;
    fprintf(fp,"reserved keyword: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return SCOPE ;
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
    return LOOP ;
}


{neg} {
    yylval.string = strdup(yytext) ;
    fprintf(fp,"reserved keyword: %s\n",yytext); 
    fprintf(op,"%s",yytext); 
    return NEG ;
}


\".*\" {
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
    return CONSTANT ;
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
	return 0;
}

{spaces} {
    yylval.string = strdup(yytext) ;
    fprintf(op,"%s",yytext); 
	// fprintf(op,"%s","%s",yytext);
}

\n {
    yylval.string = strdup(yytext) ;
    fprintf(op,"%s",yytext); 
    label_num++ ;
	// fprintf(op,"%s","%s",yytext);
}

. {
    yylval.string = strdup(yytext) ;
	fprintf(fp,"Invalid token at line number: %d",label_num);
    fprintf(op,"%s",yytext); 
	return 0;
}


%%

int yywrap()
{
    return 1;
}