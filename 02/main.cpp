#include<iostream>
#include<fstream>
#include<regex>
#include<cmath>
#include<optional>
#include<set>

using namespace std;

using ul = unsigned long;

ul n_digits(ul n) {
    return floor(log10(n))+1;
}

optional<pair<ul,ul>> split_halves(ul n) {
    int digits = n_digits(n);
    if (digits % 2 == 1) return nullopt;
    int part_length = digits / 2;
    ul divisor = exp10(part_length);
    return make_pair(
        n / divisor,
        n % divisor
    );
}

ul first_digits(ul num, ul dig) {
    ul len = n_digits(num);
    if (len <= dig) return num;
    ul divisor = exp10(len-dig);
    return num / divisor;
}

ul append_digits(ul num, ul dig) {
    ul len = n_digits(dig);
    ul multiplicator = exp10(len);
    return num * multiplicator + dig;
}

ul make_invalid(ul n) {
    int digits = n_digits(n);
    ul multiplicator = exp10(digits);
    return multiplicator * n + n;
}

struct Range {
    ul start;
    ul end;
    bool contains(ul n) {
        return n >= start && n <= end;
    }
};

int main(int argc, char const *argv[])
{
    ifstream input(argv[1]);
    string line;
    string current;
    int currentEnd = -1;
    int currentStart = 0;
    regex rangeregex("(.+)-(.+)");
    smatch rangematch;
    vector<Range> ranges;
    while(getline(input, line)) {
        do {
            currentEnd = line.find(',', currentStart);
            current = line.substr(currentStart, currentEnd - currentStart);
            currentStart = currentEnd + 1;
            if (regex_match(current, rangematch, rangeregex)) {
                cout << rangematch[1] << " to " << rangematch[2] << endl;
                ranges.push_back(Range{stoul(rangematch[1]), stoul(rangematch[2])});
            }
        } while(currentEnd != -1);
    }
    
    ul invalidIdSum = 0;
    for(auto& r : ranges) {
        auto starthalves = split_halves(r.start);
        auto endhalves = split_halves(r.end);
        ul iterstart = 0;
        ul iterend   = 0;
        if (starthalves.has_value()) {
            iterstart = starthalves.value().first;
        } else {
            // construct start half:
            starthalves = split_halves(r.start * 10); // now it has to work!
            iterstart = starthalves.value().first / 10;
        }
        if (endhalves.has_value()) {
            iterend = endhalves.value().first;
        } else {
            // construct start half:
            endhalves = split_halves(r.end * 10); // now it has to work!
            iterend = endhalves.value().first;
        }
        cout << "iterstart " << iterstart << endl;
        cout << "iterend " << iterend << endl;
        for (ul i = iterstart; i <= iterend; i++) {
            ul invalid = make_invalid(i);
            if (r.contains(invalid)) {
                invalidIdSum += invalid;
                cout << "invalid " << invalid << " for i " << i<< endl;
            }
        }
    }
    cout << "part one: " << invalidIdSum << endl;

    ul invalidIdSum2 = 0;
    for (auto& r : ranges) {
        ul n_start_digits = n_digits(r.start);
        ul n_end_digits = n_digits(r.end);
        ul n_base_difference_offset = n_end_digits - n_start_digits;
        vector<ul> relevant_lengths;
        set<ul> invalidIds;

        cout << "---" << endl;
        cout << "n_start_digits " << n_start_digits << endl;
        cout << "n_end_digits " << n_end_digits << endl;
        cout << "n_base_difference_offset " << n_base_difference_offset << endl;
        cout << "r.start " << r.start << endl;
        cout << "r.end " << r.end << endl;
        for (int i = 1; i <= max(n_start_digits, n_end_digits); i++) {
            if ((n_start_digits % i == 0) || (n_end_digits % i == 0) || true) {
                relevant_lengths.push_back(i);
                cout << "   i " << i << endl;
            }
        }
        for (ul len : relevant_lengths) {
            ul first_n_digits_of_start = first_digits(r.start, len-n_base_difference_offset);
            ul first_n_digits_of_end = first_digits(r.end, len);
            cout << "   len " << len << endl;
            cout << "   first_n_digits_of_start " << first_n_digits_of_start << endl;
            cout << "   first_n_digits_of_end " << first_n_digits_of_end << endl;
            for (ul c = first_n_digits_of_start; c <= first_n_digits_of_end; c++) {
                // make invalid id
                if (c == 0) continue;
                ul invalid = c;
                while (invalid < r.end) {
                    invalid = append_digits(invalid, c);
                    if (r.contains(invalid)) {
                        cout << "found invalid " << invalid << endl;
                        // invalidIdSum2 += invalid;
                        invalidIds.insert(invalid);
                    }
                }
            }
        }
        for (ul invalidId : invalidIds) {
            invalidIdSum2 += invalidId;
            cout << "invalidIdSum2 adds " << invalidId << endl;
        }
    }
    cout << "invalidIdSum2 " << invalidIdSum2 << endl;
    return 0;
}
