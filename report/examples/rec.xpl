variable strings = require "std/strings.xpl";
variable true  #{ alias for 1 #} = 1;
variable false #{ alias for 0 #} = 0;

# factorial return the factorial of a positive integer.
#
# @param x the integer
# @return factorial of x
#
function factorial (n)
{
    write(stderr, "DEBUG: ");
    write(stderr, strings.integer_to_string(n));
    write(stderr, "\n");
    if (n <= 0)
    {
        return 1;
    }
    else
    {
        return factorial(n - 1) * n;
    }
}


@ factorial(9);

#{
# odd returns true if input integer is odd.
#
# @param n integer under test.
# @return true (1) if odd false (0) otherwise.
#}
function odd(n)
{
    write(stderr, "DEBUG: odd(");
    write(stderr, strings.integer_to_string(n));
    write(stderr, ")\n");
    if (n < 0)
    {
        #{ don't recurse forever!! #}
        return odd(-n);
    }
    elseif (n == 0)
    {
        return false;
    }
    else
    {
        return even(n - 1);
    }
}
and even(n)
{
    write(stderr, "DEBUG: even(");
    write(stderr, strings.integer_to_string(n));
    write(stderr, ")\n");
    if (n < 0)
    {
        return even(-n);
    }
    elseif (n  == 0)
    {
        return true;
    }
    else
    {
        return odd(n - 1);
    }
}

@ odd(10);
