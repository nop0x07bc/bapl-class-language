width = 10;
height = 10;
cell = 3;

image = new [width][height][cell];

@ image;

w = 1;
while w <= width
{
    h = 1;
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

n = 10;
m = 7 * 7;
i = 8;
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

x = {1, 2, 3, 4};
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


counter = lambda (init)
{
    start_value = init;
    return lambda ()
    {
        temp = start_value;
        start_value = start_value + 1;
        return temp;
    };
};

@ 10;
c0 = counter (10);
c1 = counter (20);
@ 11;
@ c0();
@ c1();
@ c0();
@ c1();

@ c1();

flup = {0};
fac = {0};
fac[1] = lambda (x)
{
    @ x;
    if x <= 1
    {
        return 1;
    }
    else
    {
        return fac[1](x - 1) * x;
    }
};


@ fac[1](5);

test = lambda () { return 100; };

@ test() * 3;

#{
even_ref = &even;

odd = lambda (n)
{
    if n == 0
    {
        return 0;
    }
    else
    {
        return *even_ref(n - 1);
    }
};

odd_ref = &odd;

even = lambda (n)
{
    if n == 0
    {
        return 1;
    }
    else
    {
        return *odd_ref(n - 1);
    }
};

@ even(10);
#}
