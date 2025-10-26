%option noyywrap

%{
#include <stdio.h>
#include <stdbool.h>

static long line_count = 0;  // liczba wypisanych (niepustych) linii
static long word_count = 0;  // liczba słów

// stan bieżącej linii
static bool first_on_line = true; // czy następne słowo jest pierwsze
static bool emitted_any   = false; // czy w tej linii coś wypisaliśmy
%}

%%

/* --- Normalizacja na poziomie linii, „regex-first” --- */

/* 1) Usuń całe puste linie (opcjonalne spacje/taby + newline na początku linii) */
^[ \t]*\r?\n        { first_on_line = true; emitted_any = false; /* nic nie wypisuj */ }

/* 2) Na początku linii zjedz wiodące spacje/taby (trim left) */
^[ \t]+             { first_on_line = true; emitted_any = false; /* tylko połknij */ }

/* 3) W środku linii zjedz ciągi spacji/tabów — pojedynczą spację dodamy PRZED następnym słowem */
[ \t]+              { /* nic: spację wstawimy w regule słowa, jeśli nie jest pierwsze */ }

/* 4) Słowa: dowolne nie-białe poza CR/LF i spacją/tabem */
[^ \t\r\n]+         {
                      if (!first_on_line) putchar(' ');
                      fwrite(yytext, 1, yyleng, stdout);
                      first_on_line = false;
                      emitted_any   = true;
                      word_count++;
                    }

/* 5) Koniec linii: jeśli coś było w linii, domknij ją newline’em (trim right już zapewniony powyżej) */
\r?\n               {
                      if (emitted_any) {
                        putchar('\n');
                        line_count++;
                      }
                      first_on_line = true;
                      emitted_any   = false;
                    }

/* 6) Samotne CR (np. pliki Mac-owe) — ignoruj */
\r                  { /* ignore */ }

/* 7) Koniec pliku: dopisz liczby (linie, słowa) */
<<EOF>>             {
                      /* Jeśli plik nie kończył się \n i coś było w ostatniej linii — domknij ją */
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
