#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <cstring>
#include <iomanip>
#include "aes.h"
#include "sha256.h"

class FileEncryption {
private:
    std::vector<unsigned char> deriveKey(const std::string& password, const std::vector<unsigned char>& salt) {
        SHA256 sha256;
        std::string saltedPassword = password;
        saltedPassword.insert(saltedPassword.end(), salt.begin(), salt.end());

        std::string hash = sha256(saltedPassword);

        std::vector<unsigned char> key;
        for (size_t i = 0; i < hash.length() && i < 64; i += 2) {
            std::string byteString = hash.substr(i, 2);
            unsigned char byte = static_cast<unsigned char>(strtol(byteString.c_str(), nullptr, 16));
            key.push_back(byte);
        }

        return key;
    }

    std::vector<unsigned char> generateSalt() {
        std::vector<unsigned char> salt(16);
        srand(static_cast<unsigned>(time(nullptr)));
        for (auto& byte : salt) {
            byte = static_cast<unsigned char>(rand() % 256);
        }
        return salt;
    }

    std::vector<unsigned char> generateIV() {
        std::vector<unsigned char> iv(AES_BLOCKLEN);
        srand(static_cast<unsigned>(time(nullptr) + 1));
        for (auto& byte : iv) {
            byte = static_cast<unsigned char>(rand() % 256);
        }
        return iv;
    }

public:
    bool encryptFile(const std::string& inputPath, const std::string& outputPath, const std::string& password) {
        std::cout << "Encrypting file: " << inputPath << std::endl;

        std::ifstream inFile(inputPath, std::ios::binary);
        if (!inFile) {
            std::cerr << "Error: Cannot open input file!" << std::endl;
            return false;
        }

        std::vector<unsigned char> fileData((std::istreambuf_iterator<char>(inFile)),
                                             std::istreambuf_iterator<char>());
        inFile.close();

        if (fileData.empty()) {
            std::cerr << "Error: Input file is empty!" << std::endl;
            return false;
        }

        auto salt = generateSalt();
        auto iv = generateIV();

        auto key = deriveKey(password, salt);

        size_t padding = AES_BLOCKLEN - (fileData.size() % AES_BLOCKLEN);
        if (padding != AES_BLOCKLEN) {
            fileData.insert(fileData.end(), padding, static_cast<unsigned char>(padding));
        }

        AES_ctx ctx;
        AES_init_ctx_iv(&ctx, key.data(), iv.data());
        AES_CBC_encrypt_buffer(&ctx, fileData.data(), fileData.size());

        std::ofstream outFile(outputPath, std::ios::binary);
        if (!outFile) {
            std::cerr << "Error: Cannot create output file!" << std::endl;
            return false;
        }

        outFile.write(reinterpret_cast<const char*>(salt.data()), salt.size());
        outFile.write(reinterpret_cast<const char*>(iv.data()), iv.size());
        outFile.write(reinterpret_cast<const char*>(fileData.data()), fileData.size());

        outFile.close();

        std::cout << "✓ Encryption successful!" << std::endl;
        std::cout << "  Output file: " << outputPath << std::endl;
        std::cout << "  Original size: " << fileData.size() - padding << " bytes" << std::endl;
        std::cout << "  Encrypted size: " << salt.size() + iv.size() + fileData.size() << " bytes" << std::endl;

        return true;
    }

    bool decryptFile(const std::string& inputPath, const std::string& outputPath, const std::string& password) {
        std::cout << "Decrypting file: " << inputPath << std::endl;

        std::ifstream inFile(inputPath, std::ios::binary);
        if (!inFile) {
            std::cerr << "Error: Cannot open input file!" << std::endl;
            return false;
        }

        std::vector<unsigned char> salt(16);
        inFile.read(reinterpret_cast<char*>(salt.data()), salt.size());

        std::vector<unsigned char> iv(AES_BLOCKLEN);
        inFile.read(reinterpret_cast<char*>(iv.data()), iv.size());

        std::vector<unsigned char> encryptedData((std::istreambuf_iterator<char>(inFile)),
                                                  std::istreambuf_iterator<char>());
        inFile.close();

        if (encryptedData.empty()) {
            std::cerr << "Error: No encrypted data found!" << std::endl;
            return false;
        }

        auto key = deriveKey(password, salt);

        AES_ctx ctx;
        AES_init_ctx_iv(&ctx, key.data(), iv.data());
        AES_CBC_decrypt_buffer(&ctx, encryptedData.data(), encryptedData.size());

        unsigned char padding = encryptedData.back();
        if (padding > 0 && padding <= AES_BLOCKLEN) {
            bool validPadding = true;
            for (size_t i = encryptedData.size() - padding; i < encryptedData.size(); i++) {
                if (encryptedData[i] != padding) {
                    validPadding = false;
                    break;
                }
            }

            if (validPadding) {
                encryptedData.erase(encryptedData.end() - padding, encryptedData.end());
            } else {
                std::cerr << "Warning: Invalid padding detected. Password may be incorrect." << std::endl;
            }
        }

        std::ofstream outFile(outputPath, std::ios::binary);
        if (!outFile) {
            std::cerr << "Error: Cannot create output file!" << std::endl;
            return false;
        }

        outFile.write(reinterpret_cast<const char*>(encryptedData.data()), encryptedData.size());
        outFile.close();

        std::cout << "✓ Decryption successful!" << std::endl;
        std::cout << "  Output file: " << outputPath << std::endl;
        std::cout << "  Decrypted size: " << encryptedData.size() << " bytes" << std::endl;

        return true;
    }
};

void printUsage(const char* programName) {
    std::cout << "\n";
    std::cout << "╔════════════════════════════════════════════════════════════╗\n";
    std::cout << "║          File Encryption Tool - AES-256 Encryption         ║\n";
    std::cout << "╚════════════════════════════════════════════════════════════╝\n";
    std::cout << "\nUsage:\n";
    std::cout << "  " << programName << " -e <input_file> <output_file> <password>\n";
    std::cout << "  " << programName << " -d <input_file> <output_file> <password>\n";
    std::cout << "\nOptions:\n";
    std::cout << "  -e    Encrypt file\n";
    std::cout << "  -d    Decrypt file\n";
    std::cout << "\nExamples:\n";
    std::cout << "  Encrypt: " << programName << " -e document.txt document.enc mypassword\n";
    std::cout << "  Decrypt: " << programName << " -d document.enc document.txt mypassword\n";
    std::cout << "\n";
}

int main(int argc, char* argv[]) {
    if (argc != 5) {
        printUsage(argv[0]);
        return 1;
    }

    std::string mode = argv[1];
    std::string inputFile = argv[2];
    std::string outputFile = argv[3];
    std::string password = argv[4];

    if (password.length() < 6) {
        std::cerr << "Error: Password must be at least 6 characters long!" << std::endl;
        return 1;
    }

    FileEncryption encryptor;

    if (mode == "-e") {
        if (!encryptor.encryptFile(inputFile, outputFile, password)) {
            return 1;
        }
    } else if (mode == "-d") {
        if (!encryptor.decryptFile(inputFile, outputFile, password)) {
            return 1;
        }
    } else {
        std::cerr << "Error: Invalid mode. Use -e for encryption or -d for decryption." << std::endl;
        printUsage(argv[0]);
        return 1;
    }

    return 0;
}
