#include <fstream>
#include <iostream>
#include <unordered_map>
#include <sstream>
#include <vector>
#include <algorithm>
#include <cstdint>
#include <array>
#include <span>

const std::unordered_map<std::string, std::uint8_t> letters = {
    {"が", 197-64}, {"ぎ", 198-64}, {"ぐ", 199-64}, {"げ", 200-64}, {"ご", 201-64},
    {"ざ", 202-64}, {"じ", 203-64}, {"ず", 204-64}, {"ぜ", 205-64}, {"ぞ", 206-64},
    {"だ", 207-64}, {"ぢ", 208-64}, {"づ", 209-64}, {"で", 210-64}, {"ど", 211-64},
    {"ば", 217-64}, {"び", 218-64}, {"ぶ", 219-64}, {"べ", 220-64}, {"ぼ", 221-64},
    {"ぱ", 217-64-5}, {"ぴ", 218-64-5}, {"ぷ", 219-64-5}, {"ぺ", 220-64-5}, {"ぽ", 221-64-5},

    {"〇", 162},
    /* Emphasis mark with dakuten: 163, Emphasis mark with handakuten: 164 */
    {"」", 165}, {"「", 166}, {"　", 176},
    {"・", 180}, /* Emphasis mark: 181 */
    {"一", 182}, {"二", 183}, {"三", 184}, {"四", 185}, {"五", 186},
    {"六", 187}, {"七", 188}, {"八", 189}, {"九", 190}, {"十", 191},
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
    /* Dakuten: 238, Handakuten: 239 */
    {"、", 240}, {"。", 241},
    {"ぁ", 242}, {"ぃ", 243}, {"ぅ", 244}, {"ぇ", 245}, {"ぉ", 246},
    {"っ", 247}, {"ゃ", 248}, {"ゅ", 249}, {"ょ", 250},
    {"ー", 251}, {"！", 252}, {"？", 253}, {"♡", 254},

    {"ガ", 197-64-128}, {"ギ", 198-64-128}, {"グ", 199-64-128}, {"ゲ", 200-64-128}, {"ゴ", 201-64-128},
    {"ザ", 202-64-128}, {"ジ", 203-64-128}, {"ズ", 204-64-128}, {"ゼ", 205-64-128}, {"ゾ", 206-64-128},
    {"ダ", 207-64-128}, {"ヂ", 208-64-128}, {"ヅ", 209-64-128}, {"デ", 210-64-128}, {"ド", 211-64-128},
    {"バ", 217-64-128}, {"ビ", 218-64-128}, {"ブ", 219-64-128}, {"ベ", 220-64-128}, {"ボ", 221-64-128},
    {"パ", 217-64-5-128}, {"ピ", 218-64-5-128}, {"プ", 219-64-5-128}, {"ペ", 220-64-5-128}, {"ポ", 221-64-5-128},
    {"ア", 192-128}, {"イ", 193-128}, {"ウ", 194-128}, {"エ", 195-128}, {"オ", 196-128},
    {"カ", 197-128}, {"キ", 198-128}, {"ク", 199-128}, {"ケ", 200-128}, {"コ", 201-128},
    {"サ", 202-128}, {"シ", 203-128}, {"ス", 204-128}, {"セ", 205-128}, {"ソ", 206-128},
    {"タ", 207-128}, {"チ", 208-128}, {"ツ", 209-128}, {"テ", 210-128}, {"ト", 211-128},
    {"ナ", 212-128}, {"ニ", 213-128}, {"ヌ", 214-128}, {"ネ", 215-128}, {"ノ", 216-128},
    {"ハ", 217-128}, {"ヒ", 218-128}, {"フ", 219-128}, {"ヘ", 220-128}, {"ホ", 221-128},
    {"マ", 222-128}, {"ミ", 223-128}, {"ム", 224-128}, {"メ", 225-128}, {"モ", 226-128},
    {"ヤ", 227-128}, {"ユ", 228-128}, {"ヨ", 229-128},
    {"ラ", 230-128}, {"リ", 231-128}, {"ル", 232-128}, {"レ", 233-128}, {"ロ", 234-128},
    {"ワ", 235-128}, {"ヲ", 236-128}, {"ン", 237-128},
    {"ァ", 242-128}, {"ィ", 243-128}, {"ゥ", 244-128}, {"ェ", 245-128}, {"ォ", 246-128},
    {"ッ", 247-128}, {"ャ", 248-128}, {"ュ", 249-128}, {"ョ", 250-128},
};

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
    {'*', 5}, {'<', 3}, {'&', 5}
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
    auto this_char = letters.at(letter);
    if (this_char == 176) return;
    auto dakuten = std::uint8_t(238);
    auto handakuten = std::uint8_t(239);
    auto dot = false;
    if (this_char < 128) {
        this_char += 128;
        dakuten = 163;
        handakuten = 164;
        dot = true;
    }
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
        if (dot) output.push_back(181);
    }
}

std::vector<std::string> space_english(const std::vector<std::string>& lines)
{
    std::vector<std::string> result;
    for (int i = 0; i < ssize(lines); ++i) {
        auto line = lines[i];
        while (!line.empty()) {
            try {
                auto pos = line.find_first_not_of(' ');
                if (pos != std::string::npos) line.erase(0, pos);
                pos = 0;
                auto previous_pos = 0UL;
                while (get_fceux_width(line.substr(0, pos)) < 172) {
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
    }
    for (auto& s : result) {
        auto pos = s.find('<');
        if (pos != s.npos) {
            s.insert(pos + 1, 1, char(get_fceux_width(s.substr(0, pos + 1))));
        }
    }
    return result;
}

struct output_t {
    std::vector<std::uint8_t> japanese;
    std::string english;
};

output_t make_output(
    const std::vector<std::uint8_t>& japanese1,
    const std::vector<std::uint8_t>& japanese2,
    const std::vector<std::uint8_t>& japanese3,
    const std::vector<std::string>& english1,
    const std::vector<std::string>& english2,
    const std::vector<std::string>& english3,
    const std::string& option
)
{
    auto all_japanese = std::vector<std::uint8_t>();
    all_japanese.reserve(
        japanese1.size() + japanese2.size() + japanese3.size() + 1
    );
    all_japanese.insert(
        all_japanese.end(), japanese1.begin(), japanese1.end()
    );
    all_japanese.insert(
        all_japanese.end(), japanese2.begin(), japanese2.end()
    );
    all_japanese.insert(
        all_japanese.end(), japanese3.begin(), japanese3.end()
    );
    for (auto s : option) {
        all_japanese.push_back(s);
    }
    all_japanese.push_back(0);
    auto all_english = std::string();
    for (const auto& s : english1) {
        all_english += s;
        all_english.push_back('\n');
    }
    for (const auto& s : english2) {
        all_english += s;
        all_english.push_back('\n');
    }
    for (const auto& s : english3) {
        all_english += s;
        all_english.push_back('\n');
    }
    all_english.push_back('\0');
    return {std::move(all_japanese), std::move(all_english)};
};

void write_messages()
{
    auto messages_file = std::ifstream("yuyuki_messages.txt");
    auto output_data = std::vector<output_t>();
    int i = 0;
    int amount = 0;
    auto japanese = std::vector<std::vector<std::uint8_t>>{};
    auto english = std::vector<std::vector<std::string>>{};
    auto option = std::string();
    for (std::string line; std::getline(messages_file, line);) {
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
                std::cerr << "Error found in reading the number of lines " << line << "\n";
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
                english.back().emplace_back(std::move(line));
            }
        }
        ++i;
        if (i == 3*amount) {
            auto last_nonblank = english.size();
            for (std::size_t i = 0; i < english.size(); ++i) {
                if (!english[i].empty()) {
                    english[i] = space_english(english[i]);
                }
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
            if (english.size() < 3) english.resize(3);
            if (japanese.size() < 3) japanese.resize(3);
            output_data.push_back(make_output(
                japanese[0], {}, {},
                english[0], {}, {},
                option
            ));
            output_data.push_back(make_output(
                japanese[0], japanese[1], {},
                english[0], english[1], {},
                option
            ));
            for (auto i = 0; i < ssize(english) - 2; ++i) {
                output_data.push_back(make_output(
                    japanese[i], japanese[i+1], japanese[i+2],
                    english[i], english[i+1], english[i+2],
                    option
                ));
            }
            english.clear();
            japanese.clear();
            amount = 0;
            i = 0;
        }
    }

    auto output_file = std::ofstream("yuyuki_messages.bin", std::ios::binary);
    for (const auto& [japanese, english] : output_data) {
        output_file.write((const char*)japanese.data(), japanese.size());
        output_file.write((const char*)english.data(), english.size());
    }
}

void write_options()
{
    auto options_file = std::ifstream("yuyuki_options.txt");
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
            while (get_fceux_width(line.substr(0, pos)) < 56) {
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

    auto output_file = std::ofstream("yuyuki_options.bin", std::ios::binary);
    output_file.write((const char*)output.data(), output.size());
}

int main()
{
    write_messages();
    write_options();
}
