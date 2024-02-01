variable iterators = require "std/iterators.xpl";
variable range = iterators.range;

function decimal_width(n)
{
    if (n == 0)
    {
        return 1;
    }

    variable counter = 0;
    while (n > 0)
    {
        n = (n - (n % 10)) / 10;
        counter = counter + 1;
    }

    return counter;
}

variable digits = "0123456789";

function digit_to_string(d)
{
    return digits[d + 1];
}

function integer_to_string(x)
{
    variable width = decimal_width(x);
    variable str   = new[width];
    for i in range(width, 1, -1)
    {
        variable rem = x % 10;
        str[i] = digit_to_string(rem);
        x = (x - rem) / 10;    
    }
    return str;
}

variable module = [];
module["integer_to_string"] = integer_to_string;

return module;
