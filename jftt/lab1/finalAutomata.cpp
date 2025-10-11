#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <set>
#include <iomanip>

std::vector<std::vector<int>> buildTransFunc(const std::string &pattern){
    int m = pattern.size();
    const int alphabet = 256;
    std::vector<std::vector<int>> delta(m+1, std::vector<int>(alphabet, 0));
    //kozystajac z pseudo kodu podanego w kormenie
    for (int q = 0; q<=m; q++){
        for (int a = 0; a <alphabet; a++){
            //wez minimum
            int k = (m<q+1) ? m : q+1;
            std::string prefix = pattern.substr(0,k); //P_k
            while(k>0 && prefix != (pattern.substr(0,q) + (char)a).substr(q+1-k)){ //P_k jest sufixem P_q+a
                prefix = pattern.substr(0, --k);
            }
            delta[q][a] = k;
        }
    }
    return delta;
}

// Pretty-print helper for a byte as column header
static std::string showByte(unsigned int b) {
    if (b >= 32 && b <= 126) { // printable ASCII
        char c = static_cast<char>(b);
        if (c == '\\') return "\\\\";
        if (c == '\'') return "\\'";
        if (c == '\"') return "\\\"";
        return std::string(1, c);
    }
    char buf[8];
    std::snprintf(buf, sizeof(buf), "0x%02X", b & 0xFF);
    return std::string(buf);
}

/**
 * Print the transition function.
 *
 * @param delta   (m+1) x alphabet table as returned by buildTransFunc
 * @param pattern pattern string (used only to choose compact default columns)
 * @param full    if true, print all 256 columns; otherwise only bytes used in pattern
 */
void printDelta(const std::vector<std::vector<int>>& delta,
                const std::string& pattern,
                bool full = false)
{
    const int ROWS = static_cast<int>(delta.size());
    const int ALPH = delta.empty() ? 0 : static_cast<int>(delta[0].size());

    // Build column set
    std::vector<int> cols;
    if (full || pattern.empty()) {
        cols.resize(ALPH);
        for (int a = 0; a < ALPH; ++a) cols[a] = a;
    } else {
        std::set<int> uniq;
        for (unsigned char c : pattern) uniq.insert(static_cast<int>(c));
        cols.assign(uniq.begin(), uniq.end());
    }

    // Column widths
    const int w_q   = 4;   // width for state index
    const int w_col = 6;   // width for each delta entry
    const int w_hdr = 6;   // width for header labels

    // Header
    std::cout << std::left << std::setw(w_q) << "q" << "|";
    for (int a : cols) {
        std::cout << std::setw(w_hdr) << showByte(a);
    }
    std::cout << "\n";

    // Separator
    std::cout << std::string(w_q, '-') << "+";
    for (size_t i = 0; i < cols.size(); ++i) {
        std::cout << std::string(w_col, '-');
    }
    std::cout << "\n";

    // Rows
    for (int q = 0; q < ROWS; ++q) {
        std::cout << std::setw(w_q) << q << "|";
        for (int a : cols) {
            int nxt = (a >= 0 && a < ALPH) ? delta[q][a] : 0;
            std::cout << std::setw(w_col) << nxt;
        }
        std::cout << "\n";
    }
}
int main(int argc, char* argv[]){
    //wczytaj dane
    if (argc != 3){
        std::cerr << "uzycie " <<argv[0] <<" <wzorzec> <nazwa pliku>\n";
        return 1;
    }
    const std::string pattern = argv[1];
    const std::string path = argv[2];

    std::ifstream in(path);
    if (!in){
        std::cerr << "nie moge otworzyc pliku "<<path<<"\n";
        return 1;
    }
    auto delta = buildTransFunc(pattern);
    printDelta(delta, pattern, false);

    //szukanie patternu w pliku
    char t;
    int q=0, c=0;
    int m = pattern.length();
    while(in.get(t)){
        c++;
        q=delta[q][t];
        if(q==m){
            std::cout<<"Pattern occurs with shift " << c -m<<std::endl;
        }
    }
    return 0;
}

