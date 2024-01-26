variable width = 10;
variable height = 10;
variable cell = 3;

variable image = new [width][height][cell];

@ image;

variable w = 1;
while w <= width
{
    variable h = 1;
    while h <= height
    {
        # Note: cell is a reference to an array!
        cell = image[w][h];
        cell[1] = w;
        cell[2] = h;
        cell[3] = (w + h) / 2;

        h = h + 1;
    }

    w = w + 1;
}

@ image;

variable n = 10;
variable m = 7 * 7;
variable i = 8;
while n > 0
{
    switch n*n
    {
        case 100:
        {
            @ -1;
            # no fall through;
            break;
        }
        case 81:
        {
            @ -2;
            # fall through!
        }
        case i * i:
        {
            @ -3;
            break;
        }
        case m:
        {
            @ -4;
            break;
        }
        default:
        {
            @ -5;
        }
    }
    @ 0;
    @ n;
    if n < 3
    {
        break;
    }
    n = n - 1;
}

variable x = {1, 2, 3, 4};
@ x;

x = {1, {2, 3}, 4, width, height};
@ x;

x[1] = x;
@ x;
x[2][1] = x;
@ x;

for x = 0; x < 3; x = x + 1
{
    @ x;
}

@ 9999;
x = 3;
for ; x > -1; x = x - 1
{
    @ x;
}

for ;; x = x + 1
{
    @ x;
    if x > 3
    {
        # escape loop
        break;
    }
}

for ;;
{
    @ x;
    if x < -1
    {
        #{
        # loop
        #}
        break;
    }
    x = x - 1;
}

for x = 0; x < 5; x = x + 1
{
    @ -x;
    for y = 0; y < x; y = y + 1
    {
        @ y;
    }
}


#{

for x in {1, 2, 3, 4}
{
    @ x;
}

y = { { 1, 2, 3}, {-5, -6, -7}, {0, 1, 0} };
for row in y
{
    for elem in row
    {
        @ elem;
    }
}

n = 0;
for x in {101, 102, 103, 104, 105, 106}
{
    if n > 3
    {
        break;
    }

    @ x;
    n = n + 1;
}

#}

variable counter = lambda (init)
{
    variable start_value = init;
    return lambda ()
    {
        variable temp = start_value;
        start_value = start_value + 1;
        return temp;
    };
};

@ 10;
variable c0 = counter (10);
variable c1 = counter (20);
@ 11;
@ c0();
@ c1();
@ c0();
@ c1();

@ c1();


variable test = lambda () { return 100; };

@ test() * 3;

x = (lambda (x) { @ x; return x;})(10);

variable f = lambda () { @ 10; };

: f();

function fac(n)
{
    if (n < 1)
    {
        return 1;
    }
    else
    {
        return fac(n - 1) * n;
    }
}

@ (lambda (x) { @ 33344; })(20);

@ fac(5);


function odd(n)
{
    if (n < 0)
    {
        return odd(-n);
    }
    elseif (n == 0)
    {
        return 0;
    }
    else
    {
        return even(n - 1);
    }
}
and even(n)
{
    if (n < 0)
    {
        return even(-n);
    }
    elseif (n == 0)
    {
        return 1;
    }
    else
    {
        return odd(n - 1);
    }
}

@ odd(10);
@ even(10);

function fib(n)
{
    if (n == 0)
    {
        return 0;
    }
    elseif (n == 1)
    {
        return 1; 
    }
    else
    {
        return fib(n - 1) + fib(n - 2);
    }
}

@ fib(10);


function fac_acc(n, acc)
{
    @ n;
    @ acc;
    if (n == 0)
    {
        return acc;
    }
    else
    {
        return fac_acc(n - 1, acc * n);
    }
}

@ fac_acc(6, 1);

function range(start, stop, step)
{
    variable current = start;
    return lambda ()
    {
        if (current < stop)
        {
            variable temp = current;
            current = current + step;
            return temp;
        }
        else
        {
            return null;
        }
    };
}

variable r = range(-5, 0, 1.5);

@ r();
@ r();
@ r();
@ r();
@ r();
@ null == 1;


@ len({0, 1, 2});

function iterarray(a)
{
    variable index = 1;
    variable size  = len(a);
    return lambda()
    {
        if (index <= size)
        {
            variable temp = a[index];
            index = index + 1;
            return temp;
        }
        else
        {
            return null;
        }
    }
}

variable a = iterarray({5, 6, 7});
@ a();
@ a();
@ a();
@ a();


function main()
{
    for x in iterarray({3, 2, 1, 100, 110, 120})
    {
        @ x;
        if (x >= 110)
        {
            break;
        }
    }

    function iterarray2(a)
    {
        variable index = 1;
        variable size  = len(a);
        return lambda()
        {
            if (index <= size)
            {
                variable temp = a[index];
                index = index + 1;
                return temp;
            }
            else
            {
                return null;
            }
        }
    }

    variable y = { { 1, 2, 3}, {-5, -6, -7}, {0, 1, 0} };
    for row in iterarray2(y)
    {
        for elem in iterarray(row)
        {
            @ elem;
        }
    }
    write(stdout, {0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x57, 0x6f, 0x72, 0x6c, 0x64, 0x21, 0x0a});
    write(stdout, "\x0aHello Brave\x20World!\n");

    function range(start, stop)
    {
        variable current = start;
        return lambda ()
        {
            if (current <= stop)
            {
                variable temp = current;
                current = current + 1;
                return temp;
            }
            else
            {
                return null;
            }
        };
    }

    function linefeed()
    {
        write(stdout, 0x0a);
    }
    
    for c in range(0x20, 0x7e)
    {
        write(stdout, c);
        if (c % 16 == 0)
        {
            linefeed();
        }
    }

}

function rgb(r = 0x00, g = 0x00, b = 0x00)
{
    return {r, g, b};
}

@ rgb();
@ rgb(123);
@ rgb(99, 15);
@ rgb(93, 23, 22);


main();

