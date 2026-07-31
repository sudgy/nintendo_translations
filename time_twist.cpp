#include <unordered_map>
#include <string>
#include <cstdint>
#include <vector>
#include <iostream>
#include <fstream>

const std::unordered_map<std::string, std::uint8_t> letters = {
    {"が", 197-64}, {"ぎ", 198-64}, {"ぐ", 199-64}, {"げ", 200-64}, {"ご", 201-64},
    {"ざ", 202-64}, {"じ", 203-64}, {"ず", 204-64}, {"ぜ", 205-64}, {"ぞ", 206-64},
    {"だ", 207-64}, {"ぢ", 208-64}, {"づ", 209-64}, {"で", 210-64}, {"ど", 211-64},
    {"ば", 217-64}, {"び", 218-64}, {"ぶ", 219-64}, {"べ", 220-64}, {"ぼ", 221-64},
    {"ぱ", 217-64-5}, {"ぴ", 218-64-5}, {"ぷ", 219-64-5}, {"ぺ", 220-64-5}, {"ぽ", 221-64-5},
    {"　", 172},
    {"”", 176},
    // 177 is thick dashes
    {"「", 178},
    {"」", 179},
    {"・", 180}, // Actually two dots
    {"＿", 181}, // The real one dot, these look weird because two dots is more common
    {"１", 182}, {"２", 183}, {"３", 184}, {"４", 185}, {"５", 186},
    {"６", 187}, {"７", 188}, {"８", 189}, {"９", 190}, {"０", 191},
    {"あ", 192}, {"い", 193}, {"う", 194}, {"え", 195}, {"お", 196},
    {"か", 197}, {"き", 198}, {"く", 199}, {"け", 200}, {"こ", 201},
    {"さ", 202}, {"し", 203}, {"す", 204}, {"せ", 205}, {"そ", 206},
    {"た", 207}, {"ち", 208}, {"つ", 209}, {"て", 210}, {"と", 211},
    {"な", 212}, {"に", 213}, {"ぬ", 214}, {"ね", 215}, {"の", 216},
    {"は", 217}, {"ひ", 218}, {"ふ", 219}, {"へ", 220}, {"ほ", 221},
    {"ま", 222}, {"み", 223}, {"む", 224}, {"め", 225}, {"も", 226},
    {"や", 227}, {"ゆ", 228}, {"よ", 229},
    {"ら", 230}, {"り", 231}, {"る", 232}, {"れ", 233}, {"ろ", 234},
    {"わ", 235}, {"を", 236}, {"ん", 237},
    // Dakuten: 238, Handakuten: 239
    {"、", 240}, {"。", 241},
    {"ぁ", 242}, {"ぃ", 243}, {"ぅ", 244}, {"ぇ", 245}, {"ぉ", 246},
    {"っ", 247}, {"ゃ", 248}, {"ゅ", 249}, {"ょ", 250},
    {"ー", 251}, {"！", 252}, {"？", 253}, {"♡", 254},
};

// Rom characters, in case you ever need them:
// 0b000000 あ
// 0b000101 か
// 0b001010 さ
// 0b001111 た
// 0b010100 な
// 0b011001 は
// 0b011110 ま
// 0b100011 や
// 0b100110 ら
// 0b101011 わ
// 0b101100 を
// 0b101101 ん
// 0b101110 、
// 0b101111 。

const std::unordered_map<char, int> fceux_widths = {
    {'a', 4}, {'b', 4}, {'c', 4}, {'d', 4}, {'e', 4}, {'f', 4}, {'g', 4}, {'h', 4},
    {'i', 1}, {'j', 3}, {'k', 4}, {'l', 1}, {'m', 5}, {'n', 4}, {'o', 4}, {'p', 4},
    {'q', 4}, {'r', 4}, {'s', 4}, {'t', 3}, {'u', 4}, {'v', 4}, {'w', 5}, {'x', 4},
    {'y', 4}, {'z', 4}, {'A', 5}, {'B', 5}, {'C', 5}, {'D', 5}, {'E', 5}, {'F', 5},
    {'G', 5}, {'H', 5}, {'I', 3}, {'J', 5}, {'K', 5}, {'L', 5}, {'M', 5}, {'N', 5},
    {'O', 6}, {'P', 5}, {'Q', 5}, {'R', 5}, {'S', 5}, {'T', 5}, {'U', 5}, {'V', 5},
    {'W', 5}, {'X', 5}, {'Y', 5}, {'Z', 5}, {'-', 4}, {'!', 2}, {'?', 5}, {':', 2},
    {'"', 4}, {'\'', 2}, {'.', 2}, {' ', 5}, {'\\', 0}, {',', 2}, {'0', 5}, {'1', 5},
    {'2', 5}, {'3', 5}, {'4', 5}, {'5', 5}, {'6', 5}, {'7', 5}, {'8', 5}, {'9', 5},
    {'*', 5}, {'<', 3}, {'&', 5}, {'$', 5}
};

int get_fceux_width(const std::string& str)
{
    int result = 0;
    for (auto c : str) {
        result += fceux_widths.at(c);
    }
    result += str.size() - 1;
    return result;
}

void write_letter(std::vector<std::uint8_t>& output, const std::string& letter)
{
    if (letter == "｜") return;
    auto this_char = letters.at(letter);
    if (this_char == 172) return;
    auto dakuten = std::uint8_t(238);
    auto handakuten = std::uint8_t(239);
    //auto dot = false;
    //if (this_char < 128) {
    //    this_char += 128;
    //    dakuten = 163;
    //    handakuten = 164;
    //    dot = true;
    //}
    if (this_char < 162) {
        if (this_char >= 217-64-5 and this_char <= 221-64-5) {
            this_char += 5;
            this_char += 64;
            output.push_back(this_char);
            output.push_back(handakuten);
        }
        else {
            this_char += 64;
            output.push_back(this_char);
            output.push_back(dakuten);
        }
    }
    else {
        output.push_back(this_char);
        //if (dot) output.push_back(181);
    }
}

std::vector<std::string> space_english(std::string line)
{
    std::vector<std::string> result;
    while (!line.empty()) {
        try {
            auto pos = line.find_first_not_of(' ');
            if (pos != std::string::npos) line.erase(0, pos);
            pos = 0;
            auto previous_pos = 0UL;
            while (get_fceux_width(line.substr(0, pos)) < 24*8) {
                if (pos == std::string::npos) {
                    previous_pos = std::string::npos;
                    break;
                }
                previous_pos = pos;
                pos = line.find(' ', pos + 1);
            }
            if (previous_pos == std::string::npos or previous_pos == 0) {
                result.push_back(line);
                break;
            }
            else {
                result.push_back(line.substr(0, previous_pos));
                line = line.substr(previous_pos);
            }
        }
        catch (std::out_of_range& e) {
            std::cerr << "Error found in English line " << line << "\n";
            throw;
        }
    }
    //for (auto& s : result) {
    //    auto pos = s.find('<');
    //    auto ppos = 0;
    //    while (pos != s.npos) {
    //        auto size = get_fceux_width(s.substr(ppos, pos + 1 - ppos));
    //        s.insert(pos + 1, 1, char(size));
    //        ppos = pos+2;
    //        pos = s.find('<', pos+2);
    //    }
    //}
    return result;
}

void write_messages()
{
    auto messages_file = std::ifstream("time_twist_messages.txt");
    auto output_file = std::ofstream("time_twist_messages.bin", std::ios::binary);
    int amount = 0;
    int i = 0;
    auto japanese = std::vector<std::vector<std::uint8_t>>{};
    auto english = std::vector<std::vector<std::string>>{};
    auto option = std::string();
    for (std::string line; std::getline(messages_file, line); ) {
        if (amount == 0) {
            try {
                auto space = line.find(' ');
                if (space == std::string::npos) {
                    amount = std::stoi(line);
                    option = "";
                }
                else {
                    amount = std::stoi(line.substr(0, space));
                    option = line.substr(space + 1);
                }
                continue;
            }
            catch (std::invalid_argument& e) {
                std::cerr << "Error found in reading the number of lines "
                    << line << "\n";
                throw;
            }
        }
        if (i < amount) {
            japanese.emplace_back();
            try {
                if (!line.empty()) {
                    line = line.substr(line.find_first_not_of(' '));
                    for (int j = 0; j < ssize(line) / 3; ++j) {
                        write_letter(japanese.back(), line.substr(j*3, 3));
                    }
                }
            }
            catch (std::out_of_range& e) {
                std::cerr << "Error found in Japanese line " << line << "\n";
                throw;
            }
        }
        else if (i < 2*amount) { }
        else {
            english.emplace_back();
            if (!line.empty()) {
                english.back() = space_english(line);
            }
        }
        ++i;
        if (i == 3*amount) {
            auto last_nonblank = english.size();
            for (std::size_t i = 0; i < english.size(); ++i) {
                if (!english[i].empty() or (i + 1 == english.size())) {
                    if (english[i].empty() and i + 1 == english.size()) ++i;
                    if (last_nonblank + 1 < i) {
                        auto& str = english[last_nonblank];
                        auto spread = i - last_nonblank;
                        auto s = str.size() / spread;
                        auto extra = str.size() % spread;
                        auto b = str.begin() + s;
                        auto e = str.end();
                        if (extra) ++b;
                        for (std::size_t j = 1; j < spread - 1; ++j) {
                            auto s2 = s;
                            if (j < extra) ++s2;
                            english[last_nonblank + j].insert(
                                english[last_nonblank + j].end(),
                                b, b + s2
                            );
                            b += s2;
                        }
                        english[i - 1].insert(
                            english[i - 1].end(),
                            b, e
                        );
                        if (extra) ++s;
                        english[last_nonblank].resize(s);
                    }
                    last_nonblank = i;
                }
            }
            for (auto& s : japanese) {
                s.push_back('\2');
                output_file.write((const char*)s.data(), s.size());
            }
            output_file.put('\1');
            output_file.write(option.data(), option.size());
            output_file.put('\1');
            for (auto& e : english) {
                for (auto& s : e) {
                    s.push_back('\3');
                    output_file.write((const char*)s.data(), s.size());
                }
                output_file.put('\2');
            }
            output_file.put('\1');

            english.clear();
            japanese.clear();
            amount = 0;
            i = 0;
        }
    }
}

void write_options()
{
    auto options_file = std::ifstream("time_twist_options.txt");
    auto output = std::vector<std::uint8_t>();
    output.reserve(100'000);
    bool japanese = true;
    for (std::string line; std::getline(options_file, line);) {
        if (japanese) {
            try {
                for (int i = 0; i < ssize(line) / 3; ++i) {
                    write_letter(output, line.substr(i*3, 3));
                }
            }
            catch (std::out_of_range& e) {
                std::cerr << "Error found in Japanese option " << line << "\n";
                throw;
            }
        }
        else {
            auto pos = 0UL;
            auto previous_pos = 0UL;
            while (get_fceux_width(line.substr(0, pos)) < 48) {
                if (pos == std::string::npos) {
                    previous_pos = std::string::npos;
                    break;
                }
                previous_pos = pos;
                pos = line.find(' ', pos + 1);
            }
            if (previous_pos != std::string::npos) {
                auto line1 = line.substr(0, previous_pos);
                auto line2 = line.substr(previous_pos + 1);
                //auto num = 48 - get_fceux_width(line1);
                //if (num > 0) line1.insert(0, num/2, '\\');
                //num = 48 - get_fceux_width(line2);
                //if (num > 0) line2.insert(0, num/2, '\\');
                line = line1 + "\n" + line2;
            }
            else {
                //auto num = 48 - get_fceux_width(line);
                //if (num > 0) line.insert(0, num/2, '\\');
            }
            line.push_back('\n');
            for (auto c : line) {
                output.push_back(static_cast<std::uint8_t>(c));
            }
        }
        output.push_back(0);
        japanese = !japanese;
    }

    auto output_file = std::ofstream("time_twist_options.bin", std::ios::binary);
    output_file.write((const char*)output.data(), output.size());
}

int main()
{
    write_messages();
    write_options();
}
