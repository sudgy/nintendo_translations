#include <fstream>
#include <iostream>
#include <unordered_map>
#include <sstream>
#include <vector>
#include <algorithm>
#include <cstdint>

const std::unordered_map<std::string, std::uint8_t> ram_letters = {
    {"　", 0},
    {"あ", 12}, {"い", 13}, {"う", 14}, {"え", 15}, {"お", 16},
    {"か", 17}, {"き", 18}, {"く", 19}, {"け", 20}, {"こ", 21},
    {"さ", 22}, {"し", 23}, {"す", 24}, {"せ", 25}, {"そ", 26},
    {"た", 27}, {"ち", 28}, {"つ", 29}, {"て", 30}, {"と", 31},
    {"な", 32}, {"に", 33}, {"ぬ", 34}, {"ね", 35}, {"の", 36},
    {"は", 37}, {"ひ", 38}, {"ふ", 39}, {"へ", 40}, {"ほ", 41},
    {"ま", 42}, {"み", 43}, {"む", 44}, {"め", 45}, {"も", 46},
    {"や", 47}, {"ゆ", 48}, {"よ", 49},
    {"ら", 50}, {"り", 51}, {"る", 52}, {"れ", 53}, {"ろ", 54},
    {"わ", 55}, {"を", 56}, {"ん", 57},
    {"ゃ", 58}, {"ゅ", 59}, {"ょ", 60},
    {"っ", 61}, {"、", 62}, {"。", 63},
    {"０", 64}, {"１", 65}, {"２", 66}, {"３", 67}, {"４", 68},
    {"５", 69}, {"６", 70}, {"７", 71}, {"８", 72}, {"９", 73},
    {"＊", 74}, {"＃", 75}, {"！", 76}, {"？", 77},
    {"「", 80}, {"」", 81},
    {"ユ", 83}, {"キ", 84}, {"ア", 85}, {"イ", 86},
    {"カ", 87}, {"ク", 88}, {"ケ", 89}, {"コ", 90},
    {"サ", 91}, {"シ", 92}, {"ス", 93}, {"セ", 94}, {"ソ", 95},
    {"タ", 96}, {"ツ", 97}, {"テ", 98}, {"ト", 99},
    {"ナ", 100}, {"ニ", 101},
    {"ハ", 102}, {"ヒ", 103}, {"フ", 104}, {"ヘ", 105}, {"ホ", 106},
    {"マ", 107}, {"ミ", 108}, {"メ", 109}, {"モ", 110},
    {"ヤ", 111},
    {"ラ", 112}, {"リ", 113}, {"ル", 114}, {"レ", 115}, {"ロ", 116},
    {"ン", 117},
    {"ァ", 118}, {"ィ", 119}, {"ャ", 120}, {"ョ", 121}, {"ッ", 122},
    {"ー", 123}, {"Ａ", 124}, {"Ｂ", 125}, {"・", 126},
    {"が", 0x80 + 17}, {"ぎ", 0x80 + 18}, {"ぐ", 0x80 + 19},
    {"げ", 0x80 + 20}, {"ご", 0x80 + 21}, {"ざ", 0x80 + 22}, {"じ", 0x80 + 23},
    {"ず", 0x80 + 24}, {"ぜ", 0x80 + 25}, {"ぞ", 0x80 + 26}, {"だ", 0x80 + 27},
    {"ぢ", 0x80 + 28}, {"づ", 0x80 + 29}, {"で", 0x80 + 30}, {"ど", 0x80 + 31},
    {"ば", 0x80 + 37}, {"び", 0x80 + 38}, {"ぶ", 0x80 + 39}, {"べ", 0x80 + 40},
    {"ぼ", 0x80 + 41}, {"ギ", 0x80 + 84}, {"ガ", 0x80 + 87}, {"グ", 0x80 + 88},
    {"ゲ", 0x80 + 89}, {"ゴ", 0x80 + 90}, {"ザ", 0x80 + 91}, {"ジ", 0x80 + 92},
    {"ズ", 0x80 + 93}, {"ゼ", 0x80 + 94}, {"ゾ", 0x80 + 95}, {"ダ", 0x80 + 96},
    {"ヅ", 0x80 + 97}, {"デ", 0x80 + 98}, {"ド", 0x80 + 99}, {"バ", 0x80 + 102},
    {"ビ", 0x80 + 103}, {"ブ", 0x80 + 104}, {"ベ", 0x80 + 105}, {"ボ", 0x80 + 106},
    {"ぱ", 0x80 + 107}, {"ぴ", 0x80 + 108}, {"ぷ", 0x80 + 109}, {"ぺ", 0x80 + 110},
    {"ぽ", 0x80 + 111}, {"パ", 0x80 + 112}, {"ピ", 0x80 + 113}, {"プ", 0x80 + 114},
    {"ペ", 0x80 + 115}, {"ポ", 0x80 + 116},
};

const std::unordered_map<std::string, std::uint8_t> rom_letters = {
    {"　", 0},
    {"あ", 12}, {"い", 13}, {"う", 14}, {"え", 15}, {"お", 16},
    {"か", 17}, {"き", 18}, {"く", 19}, {"け", 20}, {"こ", 21},
    {"さ", 22}, {"し", 23}, {"す", 24}, {"せ", 25}, {"そ", 26},
    {"た", 27}, {"ち", 28}, {"つ", 29}, {"て", 30}, {"と", 31},
    {"な", 32}, {"に", 33}, {"ぬ", 34}, {"ね", 35}, {"の", 36},
    {"は", 37}, {"ひ", 38}, {"ふ", 39}, {"へ", 40}, {"ほ", 41},
    {"ま", 42}, {"み", 43}, {"む", 44}, {"め", 45}, {"も", 46},
    {"や", 47}, {"ゆ", 48}, {"よ", 49},
    {"ら", 50}, {"り", 51}, {"る", 52}, {"れ", 53}, {"ろ", 54},
    {"わ", 55}, {"を", 56}, {"ん", 57},
    {"ゃ", 58}, {"ゅ", 59}, {"ょ", 60},
    {"っ", 61}, {"、", 62}, {"。", 63},
    {"０", 64}, {"１", 65}, {"２", 66}, {"３", 67}, {"４", 68},
    {"５", 69}, {"６", 70}, {"７", 71}, {"８", 72}, {"９", 73},
    {"＊", 74}, {"＃", 75}, {"！", 76}, {"？", 77},
    {"「", 80}, {"」", 81},
    {"ユ", 83}, {"キ", 84}, {"ア", 85}, {"イ", 86},
    {"カ", 87}, {"ク", 88}, {"ケ", 89}, {"コ", 90},
    {"サ", 91}, {"シ", 92}, {"ス", 93}, {"セ", 94}, {"ソ", 95},
    {"タ", 96}, {"ツ", 97}, {"テ", 98}, {"ト", 99},
    {"ナ", 100}, {"ニ", 101},
    {"ハ", 102}, {"ヒ", 103}, {"フ", 104}, {"ヘ", 105}, {"ホ", 106},
    {"マ", 107}, {"ミ", 108}, {"メ", 109}, {"モ", 110},
    {"ヤ", 111},
    {"ラ", 112}, {"リ", 113}, {"ル", 114}, {"レ", 115}, {"ロ", 116},
    {"ン", 117},
    {"ァ", 118}, {"ィ", 119}, {"ャ", 120}, {"ョ", 121}, {"ッ", 122},
    {"ー", 123}, {"Ａ", 124}, {"Ｂ", 125}, {"・", 126},
    // 127 Copyright symbol
    // 128 Newline
    // 129 Tile
    // 130 Nothing
    // 131 Nothing
    {"ぁ", 132}, // Last name
    {"ぃ", 133}, // First name
    // 134 Music change
    // 135-143 Tile
    // 144 あ with dakuten
    {"が", 145}, {"ぎ", 146}, {"ぐ", 147}, {"げ", 148}, {"ご", 149},
    {"ざ", 150}, {"じ", 151}, {"ず", 152}, {"ぜ", 153}, {"ぞ", 154},
    {"だ", 155}, {"ぢ", 156}, {"づ", 157}, {"で", 158}, {"ど", 159},
    // 160-164 な-の with dakuten
    {"ば", 165}, {"び", 166}, {"ぶ", 167}, {"べ", 168}, {"ぼ", 169},
    // 170-180 are all illegal characters
    {"ぱ", 181}, {"ぴ", 182}, {"ぷ", 183}, {"ぺ", 184}, {"ぽ", 185},
    // 186-195 are all illegal characters
    {"ギ", 196},
    // 197 is ア with dakuten
    // 198 is イ with dakuten
    {"ガ", 199}, {"グ", 200}, {"ゲ", 201}, {"ゴ", 202},
    {"ザ", 203}, {"ジ", 204}, {"ズ", 205}, {"ゼ", 206}, {"ゾ", 207},
    {"ダ", 208}, {"ヅ", 209}, {"デ", 210}, {"ド", 211},
    // 212-213 Illegal
    {"バ", 214}, {"ビ", 215}, {"ブ", 216}, {"ベ", 217}, {"ボ", 218},
    // 219-223 Illegal
    // 224 あずさ　「
    // 225 まさえ　「
    // 226 あかね　「
    // 227 かんじ　「
    // 228 。」
    // 229 げんしん　「
    {"パ", 230}, {"ピ", 231}, {"プ", 232}, {"ペ", 233}, {"ポ", 234},
    // 235 くまだ　「
    // 236 あまち　「
    // 237-241 Nothing
    // 242-247 n spaces, with 24n
    // 248 　「
    // 249 ぜんぞう　「
    // 250 ・・・
    // 251 あやしろけ
    // 252-254 Nothing
    // 255 End
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
    {'*', 5}, {'/', 3}
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

int get_line_spacing(const std::string& line)
{
    auto pos = line.find(": \"");
    if (pos == std::string::npos) return -1;
    else return std::min(get_fceux_width(line.substr(0, pos + 3)), 50);
}

void write_letter(std::vector<std::uint8_t>& output, const std::string& letter)
{
    auto this_char = ram_letters.at(letter);
    if (!this_char) return;
    if (this_char >= 112 + 0x80) {
        this_char -= (112 + 0x80 - 102);
        if (this_char == 26) output.push_back(1);
        else output.push_back(this_char);
        output.push_back(79);
    }
    else if (this_char >= 107 + 0x80) {
        this_char -= (107 + 0x80 - 37);
        if (this_char == 26) output.push_back(1);
        else output.push_back(this_char);
        output.push_back(79);
    }
    else if (this_char >= 0x80) {
        this_char -= 0x80;
        if (this_char == 26) output.push_back(1);
        else output.push_back(this_char);
        output.push_back(78);
    }
    else {
        if (this_char == 26) output.push_back(1);
        else output.push_back(this_char);
    }
}

std::string space_english(const std::vector<std::string>& lines)
{
    std::vector<int> spacings;
    for (const auto& line : lines) {
        spacings.push_back(get_line_spacing(line));
    }
    const int spacing = *std::ranges::max_element(spacings);
    std::string result;
    for (int i = 0; i < ssize(lines); ++i) {
        auto line = lines[i];
        while (!line.empty()) {
            try {
                auto pos = line.find_first_not_of(' ');
                if (pos != std::string::npos) line.erase(0, pos);
                line.insert(0, std::string(spacing - get_line_spacing(line), '\\'));
                pos = 0;
                auto previous_pos = 0UL;
                while (get_fceux_width(line.substr(0, pos)) < 207) {
                    if (pos == std::string::npos) {
                        previous_pos = std::string::npos;
                        break;
                    }
                    previous_pos = pos;
                    pos = line.find(' ', pos + 1);
                }
                if (previous_pos == std::string::npos) {
                    result += line;
                    result.push_back('\n');
                    break;
                }
                else {
                    result += line.substr(0, previous_pos);
                    result.push_back('\n');
                    line = line.substr(previous_pos);
                }
            }
            catch (std::out_of_range& e) {
                std::cerr << "Error found in English line " << line << "\n";
                throw;
            }
        }
    }
    result.push_back('\0');
    return result;
}

void write_messages()
{
    auto messages_file = std::ifstream("heir_messages.txt");
    struct output_t {
        std::vector<std::uint8_t> japanese;
        std::string english;
    };
    auto output_data = std::vector<output_t>();
    int i = 0;
    auto current_japanese = std::vector<std::uint8_t>();
    auto current_english = std::vector<std::string>();
    for (std::string line; std::getline(messages_file, line);) {
        if (i < 4) {
            try {
                if (!line.empty()) {
                    line = line.substr(line.find_first_not_of(' '));
                    for (int j = 0; j < ssize(line) / 3; ++j) {
                        auto letter = rom_letters.at(line.substr(j*3, 3));
                        if (letter) {
                            if (letter == 26) current_japanese.push_back(1);
                            else current_japanese.push_back(letter);
                        }
                    }
                }
            }
            catch (std::out_of_range& e) {
                std::cerr << "Error found in Japanese line " << line << "\n";
                throw;
            }
        }
        else if (i < 8) { }
        else {
            if (!line.empty()) {
                current_english.push_back(std::move(line));
            }
        }
        ++i;
        if (i == 12) {
            i = 0;
            current_japanese.push_back(0);
            output_data.push_back(output_t{
                std::move(current_japanese),
                space_english(current_english)
            });
            current_japanese = {};
            current_english = {};
        }
    }
    std::sort(output_data.begin(), output_data.end(),
            [](const auto& a, const auto& b)
    {
        return a.japanese < b.japanese;
    });

    auto output_file = std::ofstream("heir_messages.bin", std::ios::binary);
    for (const auto& [japanese, english] : output_data) {
        output_file.write((char*)japanese.data(), japanese.size());
        output_file.write((char*)english.data(), english.size());
    }
}

void write_options()
{
    auto options_file = std::ifstream("heir_options.txt");
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
                line[previous_pos] = '\n';
            }
            for (auto c : line) {
                output.push_back(static_cast<std::uint8_t>(c));
            }
        }
        output.push_back(0);
        japanese = !japanese;
    }

    auto output_file = std::ofstream("heir_options.bin", std::ios::binary);
    output_file.write((char*)output.data(), output.size());
}

int main()
{
    write_messages();
    write_options();
}
