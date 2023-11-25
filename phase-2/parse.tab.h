
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     DATATYPE_PR = 258,
     DATATYPE_MAT = 259,
     DATATYPE_FD = 260,
     B_OPS = 261,
     E_OPS = 262,
     U_OPS = 263,
     TF = 264,
     ID = 265,
     CONSTANT = 266,
     NUM = 267,
     DOUBLE = 268,
     STRUCT = 269,
     F_OPEN = 270,
     F_CLOSE = 271,
     R_W = 272,
     IF = 273,
     ELSE = 274,
     BRE_CON = 275,
     COMPARITIVE_OPS = 276,
     AND_OR = 277,
     NEG = 278,
     RETURN = 279,
     ITERATE = 280,
     VOID = 281,
     PRINT = 282,
     SCAN = 283,
     EN_DE_CRYPT = 284,
     EN_DE_CRYPTS = 285,
     MAIN = 286
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 13 "parse.y"

    char *string ;
    struct symbol_table_entry{
        char *value;   
        char *type;
        char *id;
    } entry ;



/* Line 1676 of yacc.c  */
#line 94 "parse.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


