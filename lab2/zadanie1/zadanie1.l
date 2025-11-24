%option noyywrap

%{
#include <stdio.h>
#include <stdbool.h>

static long line_count = 0;  
static long word_count = 0; 
static bool first_on_line = true; //czy następne słowo jest pierwsze
static bool emitted_any   = false; //czy w tej linii coś wypisaliśmy
%}

%%
^[ \t]*\r?\n { 
    first_on_line = true; 
    emitted_any = false;
    }

^[ \t]+ { 
    first_on_line = true;
    emitted_any = false;
    }

[ \t]+ {/*ignore*/}

[^ \t\r\n]+ {
    if (!first_on_line) putchar(' ');
    fwrite(yytext, 1, yyleng, stdout);
    first_on_line = false;
    emitted_any   = true;
    word_count++;
    }

\r?\n {
    if (emitted_any) {
        putchar('\n');
        line_count++;
    }
    first_on_line = true;
    emitted_any   = false;
    }

\r {/*ignore*/ }

<<EOF>>{
        if (emitted_any) {
            putchar('\n');
            line_count++;
        }
        printf("%ld %ld\n", line_count, word_count);
        return 0;
    }
%%

int main(void) {
    yylex();
    return 0;
}
