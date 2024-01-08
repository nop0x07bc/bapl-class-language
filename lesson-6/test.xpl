width = 100;
height = 100;
cell = 3;

image = new [width][height][cell];

w = 1;
while w <= width
{
    h = 1;
    while h <= height
    {
        cell = image[w][h];
        cell[1] = w;
        cell[2] = h;
        cell[3] = (w + h) / 2;

        h = h + 1;
    }

    w = w + 1;
}

@ image;
