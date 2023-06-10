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
    {"ガ", 181-50-128}, {"ギ", 182-50-128}, {"グ", 183-50-128}, {"ゲ", 184-50-128}, {"ゴ", 185-50-128},
    {"ザ", 186-50-128}, {"ジ", 187-50-128}, {"ズ", 188-50-128}, {"ゼ", 189-50-128}, {"ゾ", 190-50-128},
    {"ダ", 191-50-128}, {"ヂ", 192-50-128}, {"ヅ", 193-50-128}, {"デ", 194-50-128}, {"ド", 195-50-128},
    {"バ", 201-50-128}, {"ビ", 202-50-128}, {"ブ", 203-50-128}, {"ベ", 204-50-128}, {"ボ", 205-50-128},
    {"パ", 196-50-128}, {"ピ", 197-50-128}, {"プ", 198-50-128}, {"ペ", 199-50-128}, {"ポ", 200-50-128},

    {"ア", 176-128}, {"イ", 177-128}, {"ウ", 178-128}, {"エ", 179-128}, {"オ", 180-128},
    {"カ", 181-128}, {"キ", 182-128}, {"ク", 183-128}, {"ケ", 184-128}, {"コ", 185-128},
    {"サ", 186-128}, {"シ", 187-128}, {"ス", 188-128}, {"セ", 189-128}, {"ソ", 190-128},
    {"タ", 191-128}, {"チ", 192-128}, {"ツ", 193-128}, {"テ", 194-128}, {"ト", 195-128},
    {"ナ", 196-128}, {"ニ", 197-128}, {"ヌ", 198-128}, {"ネ", 199-128}, {"ノ", 200-128},
    {"ハ", 201-128}, {"ヒ", 202-128}, {"フ", 203-128}, {"ヘ", 204-128}, {"ホ", 205-128},
    {"マ", 206-128}, {"ミ", 207-128}, {"ム", 208-128}, {"メ", 209-128}, {"モ", 210-128},
    {"ヤ", 211-128}, {"ユ", 212-128}, {"ヨ", 213-128},
    {"ラ", 214-128}, {"リ", 215-128}, {"ル", 216-128}, {"レ", 217-128}, {"ロ", 218-128},
    {"ワ", 219-128}, {"ヲ", 220-128}, {"ン", 221-128},
    {"ァ", 226-128}, {"ィ", 227-128}, {"ゥ", 228-128}, {"ェ", 229-128}, {"ォ", 230-128},
    {"ッ", 231-128}, {"ャ", 232-128}, {"ュ", 233-128}, {"ョ", 234-128},

    {"が", 181-50}, {"ぎ", 182-50}, {"ぐ", 183-50}, {"げ", 184-50}, {"ご", 185-50},
    {"ざ", 186-50}, {"じ", 187-50}, {"ず", 188-50}, {"ぜ", 189-50}, {"ぞ", 190-50},
    {"だ", 191-50}, {"ぢ", 192-50}, {"づ", 193-50}, {"で", 194-50}, {"ど", 195-50},
    {"ば", 201-50}, {"び", 202-50}, {"ぶ", 203-50}, {"べ", 204-50}, {"ぼ", 205-50},
    {"ぱ", 196-50}, {"ぴ", 197-50}, {"ぷ", 198-50}, {"ぺ", 199-50}, {"ぽ", 200-50},

    {"一", 160}, {"二", 161}, {"三", 162}, {"四", 163}, {"五", 164},
    {"六", 165}, {"七", 166}, {"八", 167}, {"九", 168}, {"十", 169},
    {"〇", 173},
    {"あ", 176}, {"い", 177}, {"う", 178}, {"え", 179}, {"お", 180},
    {"か", 181}, {"き", 182}, {"く", 183}, {"け", 184}, {"こ", 185},
    {"さ", 186}, {"し", 187}, {"す", 188}, {"せ", 189}, {"そ", 190},
    {"た", 191}, {"ち", 192}, {"つ", 193}, {"て", 194}, {"と", 195},
    {"な", 196}, {"に", 197}, {"ぬ", 198}, {"ね", 199}, {"の", 200},
    {"は", 201}, {"ひ", 202}, {"ふ", 203}, {"へ", 204}, {"ほ", 205},
    {"ま", 206}, {"み", 207}, {"む", 208}, {"め", 209}, {"も", 210},
    {"や", 211}, {"ゆ", 212}, {"よ", 213},
    {"ら", 214}, {"り", 215}, {"る", 216}, {"れ", 217}, {"ろ", 218},
    {"わ", 219}, {"を", 220}, {"ん", 221},
    {"、", 224}, {"。", 225},
    {"ぁ", 226}, {"ぃ", 227}, {"ぅ", 228}, {"ぇ", 229}, {"ぉ", 230},
    {"っ", 231}, {"ゃ", 232}, {"ゅ", 233}, {"ょ", 234},
    {"ー", 235},
    {"！", 236}, {"？", 237}, {"」", 238}, {"「", 239},
    {"…", 249}, {"・", 250}, {"　", 252}
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
    {'*', 5}
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
    if (this_char == 252 or this_char == 249) return;
    auto dakuten = std::uint8_t(222);
    auto handakuten = std::uint8_t(223);
    auto dot = false;
    if (this_char < 128) {
        this_char += 128;
        dakuten = 174;
        handakuten = 175;
        dot = true;
    }
    if (this_char < 160) {
        if (this_char >= 196-50 and this_char <= 200-50) {
            this_char += 5;
            this_char += 50;
            output.push_back(this_char);
            output.push_back(handakuten);
        }
        else {
            this_char += 50;
            output.push_back(this_char);
            output.push_back(dakuten);
        }
    }
    else {
        output.push_back(this_char);
        if (dot) output.push_back(250);
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
                while (get_fceux_width(line.substr(0, pos)) < 55) {
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
        auto num = 54 - get_fceux_width(s);
        if (num > 0) s.insert(0, num/2, '\\');
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
    const std::vector<std::string>& english3
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
    auto messages_file = std::ifstream("onigashima_messages.txt");
    auto output_data = std::vector<output_t>();
    int i = 0;
    int amount = 0;
    auto japanese = std::vector<std::vector<std::uint8_t>>{};
    auto english = std::vector<std::vector<std::string>>{};
    for (std::string line; std::getline(messages_file, line);) {
        if (amount == 0) {
            try {
                amount = std::stoi(line);
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
                        auto b = str.begin();
                        auto e = str.end();
                        for (std::size_t j = 1; j < spread - 1; ++j) {
                            english[last_nonblank + j].insert(
                                english[last_nonblank + j].end(),
                                b + j*s, b + (j+1)*s
                            );
                        }
                        english[i - 1].insert(
                            english[i - 1].end(),
                            b + (spread - 1)*s, e
                        );
                        english[last_nonblank].resize(s);
                    }
                    last_nonblank = i;
                }
            }
            if (english.size() < 3) english.resize(3);
            if (japanese.size() < 3) japanese.resize(3);
            output_data.push_back(make_output(
                japanese[0], {}, {},
                english[0], {}, {}
            ));
            output_data.push_back(make_output(
                japanese[0], japanese[1], {},
                english[0], english[1], {}
            ));
            for (auto i = 0; i < ssize(english) - 2; ++i) {
                output_data.push_back(make_output(
                    japanese[i], japanese[i+1], japanese[i+2],
                    english[i], english[i+1], english[i+2]
                ));
            }
            english.clear();
            japanese.clear();
            amount = 0;
            i = 0;
        }
    }

    auto output_file = std::ofstream("onigashima_messages.bin", std::ios::binary);
    for (const auto& [japanese, english] : output_data) {
        output_file.write((const char*)japanese.data(), japanese.size());
        output_file.write((const char*)english.data(), english.size());
    }
}

void write_options()
{
    auto options_file = std::ifstream("onigashima_options.txt");
    auto output = std::vector<std::uint8_t>();
    output.reserve(100'000); //NOLINT
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
                auto num = 48 - get_fceux_width(line1);
                if (num > 0) line1.insert(0, num/2, '\\');
                num = 48 - get_fceux_width(line2);
                if (num > 0) line2.insert(0, num/2, '\\');
                line = line1 + "\n" + line2;
            }
            else {
                auto num = 48 - get_fceux_width(line);
                if (num > 0) line.insert(0, num/2, '\\');
            }
            line.push_back('\n');
            for (auto c : line) {
                output.push_back(static_cast<std::uint8_t>(c));
            }
        }
        output.push_back(0);
        japanese = !japanese;
    }

    auto output_file = std::ofstream("onigashima_options.bin", std::ios::binary);
    output_file.write((const char*)output.data(), output.size());
}

int main()
{
    write_messages();
    write_options();
}
