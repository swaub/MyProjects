#ifndef SHA256_H
#define SHA256_H

#include <string>

class SHA256 {
public:
    std::string operator()(const std::string& input);

private:
    static const unsigned int sha256_k[];
    static unsigned int rotr(unsigned int x, unsigned int n);
    static unsigned int choose(unsigned int e, unsigned int f, unsigned int g);
    static unsigned int majority(unsigned int a, unsigned int b, unsigned int c);
    static unsigned int sig0(unsigned int x);
    static unsigned int sig1(unsigned int x);
    void transform(const unsigned char* message, unsigned int block_nb);
    unsigned int m_tot_len;
    unsigned int m_len;
    unsigned char m_block[2 * 64];
    unsigned int m_h[8];
};

#endif
