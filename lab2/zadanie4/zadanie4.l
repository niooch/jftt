%option noyywrap
%option nounput noinput

%{
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

#define STACK_MAX 4096

static long long st[STACK_MAX];
static int sp = 0;

static int had_token = 0; 
static int err_flag  = 0;
static char err_msg[256];

static void reset_line(void) {
    sp = 0;
    had_token = 0;
    err_flag = 0;
    err_msg[0] = '\0';
}

static void push(long long v) {
    if (sp >= STACK_MAX) {
        err_flag = 1;
        snprintf(err_msg, sizeof(err_msg), "Błąd: przepełnienie stosu");
        return;
    }
    st[sp++] = v;
}

static int pop2(long long *a, long long *b) {
    if (sp < 2) {
        err_flag = 1;
        snprintf(err_msg, sizeof(err_msg), "Błąd: za mała liczba argumentów");
        return 0;
    }
    *b = st[--sp];
    *a = st[--sp];
    return 1;
}

%}

%x DISCARD

%%

-?[0-9]+      {
                 if (!err_flag) {
                     long long v = strtoll(yytext, NULL, 10);
                     push(v);
                     had_token = 1;
                 }
              }

"+"           { 
                if (!err_flag) {
                    long long a,b;
                    if (pop2(&a,&b))
                        push(a+b);
                    had_token=1; }
              }
"-"           { 
                if (!err_flag)
                    { long long a,b;
                    if (pop2(&a,&b))
                        push(a-b);
                    had_token=1; 
                    } 
              }
"*"           {
                if (!err_flag){ 
                    long long a,b; 
                    if (pop2(&a,&b)) 
                        push(a*b);
                        had_token=1;
                }
              }
"/"           { 
                if (!err_flag){
                    long long a,b;
                    if (pop2(&a,&b)){ 
                        if (b==0){
                            err_flag=1;
                            snprintf(err_msg,sizeof(err_msg),"Błąd: dzielenie przez zero");
                        } else 
                        push(a/b);
                    } 
                    had_token=1; 
                } 
              }
"%"           { 
                if (!err_flag) {
                    long long a,b;
                    if (pop2(&a,&b)) {
                        if (b==0){
                            err_flag=1;
                            snprintf(err_msg,sizeof(err_msg),"Błąd: modulo przez zero");
                        } else push(a%b);
                    }
                    had_token=1;
                } 
              }
"^"           { 
                if (!err_flag) { 
                    long long a,b;
                    pop2(&a,&b);
                    if(b<0){
                        snprintf(err_msg, sizeof(err_msg), "Bład: ujemna potega");
                    }
                    push((long long)pow((double)a,(double)b));
                    had_token=1; 
                } 
             }
[ \t\r]+      { /*ignore*/ }
\n            {
                 if (err_flag) {
                     printf("%s\n", err_msg);
                 } else if (had_token) {
                     if (sp == 1) printf("= %lld\n", st[0]);
                     else         printf("Błąd: za mała liczba operatorów\n");
                 }
                 reset_line();
              }

.             {
                 if (!err_flag) {
                     char bad[8] = {0};
                     if (yytext[0] == '\"' || yytext[0] == '\\')
                         snprintf(bad, sizeof(bad), "\\%c", yytext[0]);
                     else
                         snprintf(bad, sizeof(bad), "%c", yytext[0]);
                     snprintf(err_msg, sizeof(err_msg), "Błąd: zły symbol \"%s\"", bad);
                     err_flag = 1;
                     BEGIN(DISCARD);
                 }
              }

<DISCARD>[^\n]*   { /*ignore*/ }
<DISCARD>\n       {
                     printf("%s\n", err_msg);
                     reset_line();
                     BEGIN(INITIAL);
                  }

<<EOF>>           {
                     if (err_flag) {
                         printf("%s\n", err_msg);
                     } else if (had_token) {
                         if (sp == 1) printf("= %lld\n", st[0]);
                         else         printf("Błąd: za mała liczba operatorów\n");
                     }
                     return 0;
                  }

%%

int main(void) {
    reset_line();
    yylex();
    return 0;
}
