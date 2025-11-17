%option noyywrap
%{
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
bool print_doc = false;
%}
%x IN_STRING
%x LINE_COMMENT
%x BLOCK_COMMENT
%x DOC_BLOCK_COMMENT
%%

\s*"#include "<[^>]*> { printf("%s", yytext); }

<INITIAL>{
    "//" BEGIN(LINE_COMMENT);
    "/*" BEGIN(BLOCK_COMMENT);
    "/**/" {/*ignoruj pusty comment, aby nie mylic z doc commentem*/}
    "/**"|"/\\*!" { if (print_doc) ECHO; BEGIN(DOC_BLOCK_COMMENT); }
    "///"|"//!" { if (print_doc) { yyless(1); ECHO; } else { BEGIN(LINE_COMMENT); } }
    \" { ECHO; BEGIN(IN_STRING); }
    .|\n ECHO;
}
<IN_STRING>{
    \" { ECHO; BEGIN(INITIAL); }
    "\\\"" ECHO; 
    "\\\\" ECHO;
    "\\\n" ECHO;
    .|\n ECHO;
}
<LINE_COMMENT>{
    "\\\n"                      
    \n { BEGIN(INITIAL); printf("\n"); }
    .                           
}
<BLOCK_COMMENT>{
    "*/" BEGIN(INITIAL);
    .|\n 
}
<DOC_BLOCK_COMMENT>{
    "*/" { if (print_doc) ECHO; BEGIN(INITIAL); }
    .|\n { if (print_doc) ECHO; }
}
%%

int main(int argc, char* argv[]){
    if(argc>1){
        //zostaw docstring
        print_doc=true;
    }
    yylex();
    return 0;
}
