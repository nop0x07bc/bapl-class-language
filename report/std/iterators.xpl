function range(start, stop, step = 1)
{
    variable current = start;
    return lambda ()
    {
        variable should_stop = 0;
        if (start >= stop and step < 0)
        {
            should_stop = current < stop;
        }
        else
        {
            should_stop = current > stop;
        }
        if (should_stop)
        {
            return null;
        }
        else
        {
            variable temp = current;
            current = current + step;
            return temp;
        }
    };
}

variable module = ["range": range];

return module;
