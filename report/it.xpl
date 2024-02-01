function iterator (start, stop, step = 1)
{
    variable current = start;
    variable should_stop = lambda (current)
    {
        if (start > stop and current < stop)
        {
            return 1;
        }
        elseif (start <= stop and current > stop)
        {
            return 1;
        }
        else
        {
            return 0;
        }
    };
    return lambda ()
    {
        if (should_stop(current))
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


for i in iterator(1, 20)
{
    @ i;
}

for i in iterator(20, 1, -2)
{
    @ i;
}
