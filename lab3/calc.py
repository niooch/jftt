#!/usr/bin/env python3
import sys
import ply.lex as lex
import ply.yacc as yacc

# ==============================
#   GF(p) = GF(1234577)
# ==============================
P = 1234577

def cAdd(a, b, shift=0):
    return (a + b) % (P + shift)

def cSub(a, b, shift=0):
    return (a - b + (P + shift)) % (P + shift)

def cMul(a, b, shift=0):
    return (a * b) % (P + shift)

def cPow(a, b, shift=0):
    mod = P + shift
    a %= mod
    b %= mod
    res = 1
    while b > 0:
        if b & 1:
            res = (res * a) % mod
        a = (a * a) % mod
        b >>= 1
    return res

def cDiv(a, b, shift=0):
    mod = P + shift
    if b % mod == 0:
        raise ZeroDivisionError("dzielenie przez zero")
    # a * b^(p-2) mod p
    return (a * cPow(b, mod - 2, shift)) % mod

def cMod(a, shift=0):
    return a % (P + shift)


# ==========================================
#               LEXER (PLY)
# ==========================================

tokens = (
    'NUM',
    'ADD', 'SUB', 'MUL', 'DIV', 'POW',
    'LPAREN', 'RPAREN',
)

t_ADD    = r'\+'
t_SUB    = r'-'
t_MUL    = r'\*'
t_DIV    = r'/'
t_POW    = r'\^'
t_LPAREN = r'\('
t_RPAREN = r'\)'

t_ignore = ' \t\r'

# liczby
def t_NUM(t):
    r'\d+'
    t.value = int(t.value)
    return t

# komentarze – linia zawierająca # traktowana jako komentarz (cała reszta linii)
def t_COMMENT(t):
    r'\#.*'
    # ignorujemy do końca linii
    pass

# obsługa newlines (liczymy linie dla lepszych komunikatów, ale nie generujemy tokenów)
def t_newline(t):
    r'\n+'
    t.lexer.lineno += len(t.value)

# błąd leksykalny
def t_error(t):
    sys.stderr.write(f"Błąd leksykalny (linia {t.lexer.lineno}): nieznany znak '{t.value[0]}'\n")
    t.lexer.skip(1)

lexer = lex.lex()


# ==========================================
#               PARSER (PLY)
# ==========================================

# Każdy nieterminal zwraca krotkę:
#   (wartość_w_GF_p, lista_tokenów_RPN)

# priorytety
precedence = (
    ('left', 'ADD', 'SUB'),
    ('left', 'MUL', 'DIV'),
    ('right', 'POW'),
    ('right', 'UMINUS'),
)

# globalny komunikat błędu na bieżącą linię
error_message = None
SHIFT = 0  # w całym zadaniu używamy shift = 0


# -------------- nieterminale --------------

def p_expr_add(p):
    'expr : expr ADD term'
    val = cAdd(p[1][0], p[3][0], SHIFT)
    rpn = p[1][1] + p[3][1] + ['+']
    p[0] = (val, rpn)

def p_expr_sub(p):
    'expr : expr SUB term'
    val = cSub(p[1][0], p[3][0], SHIFT)
    rpn = p[1][1] + p[3][1] + ['-']
    p[0] = (val, rpn)

def p_expr_term(p):
    'expr : term'
    p[0] = p[1]


def p_term_mul(p):
    'term : term MUL power'
    val = cMul(p[1][0], p[3][0], SHIFT)
    rpn = p[1][1] + p[3][1] + ['*']
    p[0] = (val, rpn)

def p_term_div(p):
    'term : term DIV power'
    global error_message
    denom = cMod(p[3][0], SHIFT)
    if denom == 0:
        error_message = "Błąd: dzielenie przez zero"
        raise SyntaxError
    val = cDiv(p[1][0], p[3][0], SHIFT)
    rpn = p[1][1] + p[3][1] + ['/']
    p[0] = (val, rpn)

def p_term_power(p):
    'term : power'
    p[0] = p[1]


# power: baza ^ wykładnik_bez_potęg
def p_power_unary(p):
    'power : unary'
    p[0] = p[1]

def p_power_pow(p):
    'power : unary POW expNoPow'
    base_val = cMod(p[1][0], SHIFT)
    exp_val  = cMod(p[3][0], SHIFT)
    val = cPow(base_val, exp_val, SHIFT)
    rpn = p[1][1] + p[3][1] + ['^']
    p[0] = (val, rpn)


# unarny minus
def p_unary_neg(p):
    'unary : SUB unary %prec UMINUS'
    # -x w GF(p) = 0 - x
    val = cSub(0, p[2][0], SHIFT)
    # dla RPN zrobimy stałą znegowaną (jak -1 -> p-1)
    rpn = [str(val)]
    p[0] = (val, rpn)

def p_unary_atom(p):
    'unary : atom'
    p[0] = p[1]


# atom
def p_atom_num(p):
    'atom : NUM'
    val = cMod(p[1], SHIFT)
    rpn = [str(val)]
    p[0] = (val, rpn)

def p_atom_paren(p):
    'atom : LPAREN expr RPAREN'
    p[0] = p[2]


# ===== wykładnik bez operatora ^ =====

def p_expNoPow_term(p):
    'expNoPow : expTerm'
    p[0] = p[1]

def p_expNoPow_add(p):
    'expNoPow : expNoPow ADD expTerm'
    val = cAdd(p[1][0], p[3][0], SHIFT)
    rpn = p[1][1] + p[3][1] + ['+']
    p[0] = (val, rpn)

def p_expNoPow_sub(p):
    'expNoPow : expNoPow SUB expTerm'
    val = cSub(p[1][0], p[3][0], SHIFT)
    rpn = p[1][1] + p[3][1] + ['-']
    p[0] = (val, rpn)


def p_expTerm_unary(p):
    'expTerm : expUnary'
    p[0] = p[1]

def p_expTerm_mul(p):
    'expTerm : expTerm MUL expUnary'
    val = cMul(p[1][0], p[3][0], SHIFT)
    rpn = p[1][1] + p[3][1] + ['*']
    p[0] = (val, rpn)

def p_expTerm_div(p):
    'expTerm : expTerm DIV expUnary'
    global error_message
    denom = cMod(p[3][0], SHIFT)
    if denom == 0:
        error_message = "Dzielenie przez zero w wykładniku"
        raise SyntaxError
    val = cDiv(p[1][0], p[3][0], SHIFT)
    rpn = p[1][1] + p[3][1] + ['/']
    p[0] = (val, rpn)


def p_expUnary_neg(p):
    'expUnary : SUB expUnary %prec UMINUS'
    val = cSub(0, p[2][0], SHIFT)
    rpn = [str(val)]
    p[0] = (val, rpn)

def p_expUnary_atom(p):
    'expUnary : expAtom'
    p[0] = p[1]


def p_expAtom_num(p):
    'expAtom : NUM'
    val = cMod(p[1], SHIFT)
    rpn = [str(val)]
    p[0] = (val, rpn)

def p_expAtom_paren(p):
    'expAtom : LPAREN expNoPow RPAREN'
    p[0] = p[2]


# --------- obsługa błędów ---------

def p_error(p):
    global error_message
    if error_message is None:
        error_message = "Błąd składniowy"
    raise SyntaxError


parser = yacc.yacc(start='expr')


# ==========================================
#             GŁÓWNA PĘTLA
# ==========================================

def logical_lines_from_stdin():
    """
    Generator „logicznych linii”:
    - skleja linie zakończone znakiem '\\'
    - pomija linie-komentarze (zaczynające się od # po opcjonalnych spacjach)
    - pomija puste linie
    """
    buffer = ""
    for raw in sys.stdin:
        line = raw.rstrip('\n')

        # komentarz (tylko jeśli to początek nowej linii logicznej)
        if not buffer and line.lstrip().startswith('#'):
            continue

        # kontynuacja linii
        if line.endswith('\\'):
            buffer += line[:-1]
            continue
        else:
            buffer += line

            expr_str = buffer.strip()
            buffer = ""

            if expr_str == "":
                continue

            yield expr_str

    # gdy plik nie kończy się newline, a coś zostało
    if buffer.strip():
        yield buffer.strip()


def main():
    global error_message
    for expr_str in logical_lines_from_stdin():
        error_message = None
        try:
            result = parser.parse(expr_str, lexer=lexer)
            if result is None:
                # błąd został już obsłużony w p_error
                if error_message:
                    print(f"ERROR: {error_message}")
                error_message = None
                continue

            val, rpn_tokens = result
            rpn_str = " ".join(rpn_tokens)
            print(rpn_str)
            print(f"Wynik: {cMod(val, SHIFT)}")

        except SyntaxError:
            msg = error_message or "Błąd składniowy"
            print(f"ERROR: {msg}")
            error_message = None
        except ZeroDivisionError:
            msg = error_message or "Błąd: dzielenie przez zero"
            print(f"ERROR: {msg}")
            error_message = None


if __name__ == '__main__':
    main()

