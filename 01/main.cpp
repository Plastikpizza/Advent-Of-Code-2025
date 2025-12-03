#include<iostream>
#include<fstream>
#include<regex>

using namespace std;

int main(int argc, char const *argv[])
{
    ifstream input(argv[1]);
    string line;
    int dial_position = 50;
    int password1 = 0;
    int password2 = 0;
    regex lineRegex("(L|R)(.+)");
    smatch lineRegMatch;
    while(getline(input, line)) {
        if (regex_match(line, lineRegMatch, lineRegex)) {
            bool leftTurn = (lineRegMatch[1].str().at(0) == 'L');
            int steps = stoi(lineRegMatch[2]);
            for (int i = 0; i < steps; i++) {
                leftTurn ? dial_position-- : dial_position++;
                if (dial_position > 99) dial_position-=100;
                else if (dial_position < 0) dial_position += 100;
                if (dial_position == 0) password2++;
            }
            if (dial_position == 0) {
                password1++;
            }
        } 
        cout << line << " dial_position: " << dial_position << endl;
    }
    cout << "p1: " << password1 << endl;
    cout << "p1: " << password2 << endl;
    return 0;
}
