#include <string>
#include <vector>
#include <cstdlib>

namespace Gambit
{
    std::string NarrowString(const std::string& str)
    {
        return str;
    }

    std::string NarrowString(const std::wstring& str)
    {
        if (str.empty())
            return {};

        const std::size_t len = str.size() * 4 + 1;
        std::vector<char> buf(len, '\0');
        std::wcstombs(buf.data(), str.c_str(), len);
        return std::string(buf.data());
    }
}
