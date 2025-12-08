#include<map>
#include<set>
#include<regex>
#include<vector>
#include<fstream>
#include<iostream>

using namespace std;
using coord = pair<int, int>;
using ul = unsigned long;

ostream& operator << (ostream& out, const coord& coord) {
    out << "("<<coord.first <<", " << coord.second<< ")";
    return out;
}

ul splits_below(coord pos, map<coord, char>& field, int y, map<coord, ul>& result_cache) {
    coord beam = pos;
    while (beam.second < y) {
        coord down {beam.first, beam.second + 1};
        if(field.find(down) != field.end() && field.at(down) == '^') {
            coord left_pos {down.first - 1, down.second};
            ul left_res = 0;
            if (result_cache.find(left_pos) != result_cache.end()) {
                left_res = result_cache.at(left_pos);
            } else {
                left_res = splits_below(left_pos, field, y, result_cache);
                result_cache[left_pos] = left_res;
            }
            coord right_pos {down.first + 1, down.second};
            ul right_res = 0;
            if (result_cache.find(right_pos) != result_cache.end()) {
                right_res = result_cache.at(right_pos);
            } else {
                right_res = splits_below(right_pos, field, y, result_cache);
                result_cache[right_pos] = right_res;
            }
            return left_res + right_res;
        }
        beam = down;
    }
    return 1;
}

int main(int argc, char const *argv[])
{
    ifstream input(argv[1]);
    string line;
    map<coord, char> field;
    set<coord> active_beams;
    coord start{0,0};
    int y = 0;
    int x = 0;
    while (getline(input, line)) {
        x = 0;
        for (char c : line) {
            if (c == '^') field[coord{x,y}] = c;
            else if (c == 'S') {
                start = coord{x,y};
                active_beams.insert(start);
            }
            x++;
        }
        y++;
    }
    int splits = 0;
    while (active_beams.size() > 0) {
        set<coord> next_active_beams;
        for (coord beam : active_beams) {
            coord down = coord{beam.first, beam.second + 1};
            if(field.find(down) != field.end() && field.at(down) == '^') {
                // split!
                next_active_beams.insert(coord{down.first-1, down.second});
                next_active_beams.insert(coord{down.first+1, down.second});
                splits++;
            } else if (down.second < y) {
                next_active_beams.insert(down);
            }
        }
        active_beams = next_active_beams;
    }
    cout << "part 1: " << splits << endl;
    map<coord, ul> result_cache;
    cout << "part 2: " << splits_below(start, field, y, result_cache) << endl;
    return 0;    
}
