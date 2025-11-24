#include "cialo.h"

long long int cAdd(long long int a, long long int b, long long int shift) {
    long long int sum = (a + b )% (P + shift);
    return sum;
}

long long int cSub(long long int a, long long int b, long long int shift) {
    long long int diff = (a - b + (P + shift)) % (P + shift);
    return diff;
}

long long int cMul(long long int a, long long int b, long long int shift) {
    long long int prod = (a * b) % (P + shift);
    return prod;
}

long long int cPow(long long int a, long long int b, long long int shift) {
    long long int result = 1;
    a = a % (P + shift);
    while (b > 0) {
        if (b % 2 == 1) {
            result = (result * a) % (P + shift);
        }
        a = (a * a) % (P + shift);
        b = b / 2;
    }
    return result;
}

long long int cDiv(long long int a, long long int b, long long int shift) {
    return a * cPow(b, P + shift - 2, shift) % (P + shift);
}

long long int cMod(long long int a, long long int shift) {
    return a % (P + shift);
}
