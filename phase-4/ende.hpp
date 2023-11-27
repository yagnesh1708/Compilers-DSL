#include <iostream>
#include <fstream>
#include <string>
using namespace std;


string encryptDecrypt(const string &input, const string &key)
{
    string output = input;
    for (size_t i = 0; i < input.size(); ++i)
    {
        output[i] = input[i] ^ key[i % key.size()];
    }
    return output;
}

void encryptDecryptFile(const string &inputFileName, const string &outputFileName, const string &key)
{


    ifstream inputFile(inputFileName, ios::binary);
    ofstream outputFile(outputFileName, ios::binary);

    if (!inputFile.is_open() || !outputFile.is_open())
    {
        cerr << "Error opening files." << endl;
        return;
    }

    char ch;
    size_t keyIndex = 0;

    while (inputFile.get(ch))
    {
        // Encrypt/Decrypt each byte in the file using the key
        ch ^= key[keyIndex++ % key.size()];
        outputFile.put(ch);
    }

    inputFile.close();
    outputFile.close();
}
