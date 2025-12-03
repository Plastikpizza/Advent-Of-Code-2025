#include<iostream>
#include<fstream>
#include<vector>

using namespace std;
using ul = unsigned long;

struct Best {
    char rune;
    int index;
};

Best highest_in_range(string& line, int start, int end) {
    Best result {line.at(start), start};
    for(int i = start; i < end; i++) {
        if(line.at(i) > result.rune) {
            result.rune = line.at(i);
            result.index = i;
        }
    }
    return result;
}

int main(int argc, char const *argv[])
{
    ifstream input(argv[1]);
    string line;
    int total_joltage = 0;
    ul total_joltage_part_2 = 0;
    while (getline(input, line)) {
        // part 1
        {
            vector<Best> scores = vector<Best>(2);
            scores[0] = highest_in_range(line, 0, line.length()-1);
            scores[1] = highest_in_range(line, scores[0].index+1, line.length());
            string result;
            for (auto& h : scores) {
                result += h.rune;
            }
            total_joltage += stoul(result);
        }
        // part 2
        {
            vector<Best> scores = vector<Best>(12);
            scores[0] = highest_in_range(line, 0, line.length()-11);
            for (int i = 1; i < 12; i++) {
                scores[i] = highest_in_range(line, scores[i-1].index+1, line.length()-(11-i));
            }
            string result;
            for(auto h : scores) {
                result += h.rune;
            }
            total_joltage_part_2 += stoul(result);
        }
    }
    cout << total_joltage << endl;
    cout << total_joltage_part_2 << endl;
    return 0;    
}
