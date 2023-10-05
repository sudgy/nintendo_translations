#include <fstream>
#include <iostream>
#include <unordered_map>
#include <sstream>
#include <vector>
#include <algorithm>
#include <cstdint>

const std::unordered_map<std::string, std::uint8_t> letters = {
    {"　", 0},
    {"あ", 10},  {"い", 11},  {"う", 12},  {"え", 13},  {"お", 14},
    {"か", 15},  {"き", 16},  {"く", 17},  {"け", 18},  {"こ", 19},
    {"さ", 20},  {"し", 21},  {"す", 22},  {"せ", 23},  {"そ", 24},
    {"た", 25},  {"ち", 26},  {"つ", 27},  {"て", 28},  {"と", 29},
    {"な", 30},  {"に", 31},  {"ぬ", 32},  {"ね", 33},  {"の", 34},
    {"は", 35},  {"ひ", 36},  {"ふ", 37},  {"へ", 38},  {"ほ", 39},
    {"ま", 40},  {"み", 41},  {"む", 42},  {"め", 43},  {"も", 44},
    {"や", 45},  {"ゆ", 46},  {"よ", 47},
    {"ら", 48},  {"り", 49},  {"る", 50},  {"れ", 51},  {"ろ", 52},
    {"わ", 53},  {"を", 54},  {"ん", 55},
    {"ゃ", 56},  {"ゅ", 57},  {"ょ", 58},  {"っ", 59},
    {"、", 62},  {"。", 63},  {"＊", 64},  {"＃", 65},  {"！", 66}, {"？", 67},
    {"「", 68},  {"」", 69},  {"ー", 70},  {"・", 71},
    {"０", 72},  {"１", 73},  {"２", 74},  {"３", 75},  {"４", 76},
    {"５", 77},  {"６", 78},  {"７", 79},  {"８", 80},  {"９", 81},
    {"Ａ", 82},  {"Ｂ", 83},
    {"少", 84},  {"女", 85},
    {"ア", 86},  {"イ", 87},  {"エ", 88},  {"オ", 89},
    {"カ", 90},  {"キ", 91},  {"ク", 92},  {"ケ", 93},  {"コ", 94},
    {"サ", 95},  {"シ", 96},  {"ス", 97},  {"セ", 98},
    {"タ", 99},  {"チ", 100}, {"ツ", 101}, {"テ", 102}, {"ト", 103},
    {"ナ", 104}, {"ニ", 105}, {"ノ", 106},
    {"ハ", 107}, {"ヒ", 108}, {"フ", 109}, {"ホ", 110},
    {"マ", 111}, {"ミ", 112}, {"ム", 113}, {"メ", 114}, {"モ", 115},
    {"ヨ", 116},
    {"ラ", 117}, {"ル", 118}, {"レ", 119}, {"ロ", 120},
    {"ン", 121}, {"ャ", 122}, {"ュ", 123}, {"ョ", 124},
    {"ッ", 125}, {"ァ", 126}, {"ィ", 127},
    {"Ｈ", 128}, {"Ｔ", 129}, {"Ｕ",  130}, {"ED ", 131}, {"SP ", 132},

    {"が", 128+15},  {"ぎ", 128+16},  {"ぐ", 128+17},  {"げ", 128+18},  {"ご", 128+19},
    {"ざ", 128+20},  {"じ", 128+21},  {"ず", 128+22},  {"ぜ", 128+23},  {"ぞ", 128+24},
    {"だ", 128+25},  {"ぢ", 128+26},  {"づ", 128+27},  {"で", 128+28},  {"ど", 128+29},
    {"ば", 128+35},  {"び", 128+36},  {"ぶ", 128+37},  {"べ", 128+38},  {"ぼ", 128+39},
    {"ガ", 128+90},  {"ギ", 128+91},  {"グ", 128+92},  {"ゲ", 128+93},  {"ゴ", 128+94},
    {"ザ", 128+95},  {"ジ", 128+96},  {"ズ", 128+97},  {"ゼ", 128+98},
    {"ダ", 128+99},  {"ヂ", 128+100}, {"ヅ", 128+101}, {"デ", 128+102}, {"ド", 128+103},
    {"バ", 128+107}, {"ビ", 128+108}, {"ブ", 128+109}, {"ボ", 128+110},
    {"ぱ", 128+35+80}, {"ぴ", 128+36+80}, {"ぷ", 128+37+80}, {"ぺ", 128+38+80}, {"ぽ", 128+39+80},
    {"パ", 128+107+15}, {"ピ", 128+108+15}, {"プ", 128+109+15}, {"ポ", 128+110+15},
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
    auto this_char = letters.at(letter);
    if (!this_char) return;
    if (this_char >= 128 + 107 + 15) {
        this_char -= (128 + 15);
        output.push_back(61);
        output.push_back(this_char);
    }
    else if (this_char >= 128 + 35 + 80) {
        this_char -= (128 + 80);
        output.push_back(61);
        output.push_back(this_char);
    }
    else if (this_char >= 128) {
        this_char -= 128;
        output.push_back(60);
        output.push_back(this_char);
    }
    else {
        output.push_back(this_char);
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
    auto messages_file = std::ifstream("girl_messages.txt");
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
                        write_letter(current_japanese, line.substr(j*3, 3));
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

    auto output_file = std::ofstream("girl_messages.bin", std::ios::binary);
    for (const auto& [japanese, english] : output_data) {
        output_file.write((char*)japanese.data(), japanese.size());
        output_file.write((char*)english.data(), english.size());
    }
}

void write_options()
{
    auto options_file = std::ifstream("girl_options.txt");
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

    auto output_file = std::ofstream("girl_options.bin", std::ios::binary);
    output_file.write((char*)output.data(), output.size());
}

int main()
{
    write_messages();
    write_options();
}
