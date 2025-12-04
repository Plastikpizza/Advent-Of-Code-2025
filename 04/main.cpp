#include<iostream>
#include<fstream>
#include<map>
#include<vector>

using namespace std;

using Coord = pair<int, int>;

ostream& operator << (ostream& out, const Coord& coord) {
    out << "("<<coord.first <<", " << coord.second<< ")";
    return out;
}

vector<Coord> neighbors(Coord pos) {
    vector<Coord> result;
    for (int dy = -1; dy < 2; dy++) {
        for (int dx = -1; dx < 2; dx++) {
            if (dy == 0 && dx == 0) continue;
            result.push_back(make_pair(pos.first + dx, pos.second + dy));
        }
    }
    return result;
}

char lookup(map<Coord, char>& field, Coord pos) {
    if (field.find(pos) != field.end()) {
        return field.at(pos);
    }
    return '.';
}

bool forklift_accessible(map<Coord, char>& field, Coord pos) {
    int paper_roll_count = 0;
    for (Coord neighbor : neighbors(pos)) {
        if (lookup(field, neighbor) == '@') paper_roll_count++;
    }
    return paper_roll_count < 4;
}

int main(int argc, char const *argv[])
{
    ifstream input(argv[1]);
    string line;
    map<Coord, char> field;
    int y = 0;
    int x = 0;
    while (getline(input, line)) {
        x = 0;
        for (char c : line) {
            if (c == '@') {
                field[Coord{x,y}] = c;
            }
            x++;
        }
        y++;
    }
    int total_rolls_accessible = 0;
    int total_rolls_removed = 0;
    bool show_part_one = true;
    do {
        total_rolls_accessible = 0;
        vector<Coord> to_remove;
        for (int i = 0; i < y; i++) {
            for (int j = 0; j < x; j++) {
                Coord pos = Coord{j,i};
                char c = lookup(field, pos);
                if (c == '@' && forklift_accessible(field, pos)) {
                    total_rolls_accessible++;
                    to_remove.push_back(pos);
                    cout << "x";
                }
                else cout << c;
            }
            cout << endl;
        }
        cout << "=== === === === === ===" << endl;
        if (show_part_one) {
            cout << "part 1: " << total_rolls_accessible << endl;
            show_part_one = false;
        }
        for (Coord pos : to_remove) {
            field.erase(pos);
            total_rolls_removed++;
        }
    } while (total_rolls_accessible > 0);
    cout << "part 2: " << total_rolls_removed << endl;
    return 0;    
}
