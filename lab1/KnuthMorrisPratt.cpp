#include <fstream>
#include <iostream>
#include <string>
#include <vector>

std::vector<int> computePrefixFunction(std::string pattern){
    int m = pattern.size();
    std::vector<int> pi(m, 0);
    int k=0;

    for (int q = 1; q<m; ++q){
        while (k>0 && pattern[k] != pattern[q])
            k = pi[k-1];
        if(pattern[k] == pattern[q])
            ++k;
        pi[q]=k;
    }
    return pi;
}

void printPi(std::vector<int> pi, std::string pattern){
    int m = pi.size();
    //rzad i
    std::cout<<"   i  | ";
    for (int i = 0; i<m; i++)
        std::cout<<i<<" ";
    std::cout<<std::endl;
    //separator
    for (int i = 0; i<m+5; i++)
        std::cout<<"__";
    std::cout<<std::endl;
    //P[i]
    std::cout<<" P[i] | ";
    for (int i = 0; i<m; i++)
        std::cout<<pattern[i]<<" ";
    std::cout<<std::endl;
    //pi[i]
    std::cout<<"pi[i] | ";
    for(int i = 0; i < m; i++)
        std::cout<<pi[i]<<" ";
    std::cout<<std::endl;
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
    auto pi = computePrefixFunction(pattern);
    printPi(pi, pattern);

    //KMP-matcher
    int m = pattern.size();
    int q = 0;
    char t;
    int i = 0;
    while(in.get(t)){
        while(q>0 && pattern[q] != t)
            q=pi[q-1];
        if(pattern[q] == t)
            ++q;
        if(q==m){
            std::cout<<"Pattern occurs with shift "<<i-m+1<<std::endl;
            q=pi[q-1];
        }
        i++;
    }

    return 0;
}

