# Import "standard" libraries.
variable strings   = require "std/strings.xpl";
variable iterators = require "std/iterators.xpl";
variable pallet    = require "pallet.xpl";

# Create local alias for range iterator.
variable range = iterators.range;

function write_pbm(img)
{
    variable height  = len(img);
    variable width   = len(img[1]);

    # write header
    # P6\n
    write(stdout, "P6\n");
    # <width><space>
    write(stdout, strings.integer_to_string(width));
    write(stdout, " ");
    # <height>\n
    write(stdout, strings.integer_to_string(height));
    write(stdout, "\n");
    # <maxval>\n
    write(stdout, "255\n");

    for row in range(1, height)
    {
        for col in range(1, width)
        {
            write(stdout, img[row][col]);
        }
    }
}

function norm2(z)
{
    return z[1]*z[1] + z[2]*z[2];
}

function mandelbrot_score(c)
{
    variable max_iterations = 256;
    variable iteration = 1;
    variable z = {0.0, 0.0};
    while (iteration < max_iterations and norm2(z) < 4)
    {
        variable re_temp = z[1] * z[1] - z[2] * z[2] + c[1];
        z[2] = 2 * z[1] * z[2] + c[2];
        z[1] = re_temp;
        iteration = iteration + 1;
    }

    return pallet[iteration];
}


function mandelbrot()
{
    variable height = 480;
    variable width  = 640;

    # short hand for strings.interger_to_string
    variable i2s = strings.integer_to_string;


    write(stderr, "Image size (wxh): ");
    write(stderr, i2s(width));
    write(stderr, "x");
    write(stderr, i2s(height));
    write(stderr, "\n");

    variable re_range = {-0.1475, 0.47};
    variable im_range = {-0.92625, -0.463125};

    variable re_step = (re_range[2] - re_range[1]) / width;
    variable im_step = (im_range[2] - im_range[1]) / height;


    variable img = new[height][width];
    
    for row in range(1, height)
    {
        write(stderr, "Processing row: ");
        write(stderr, i2s(row));
        write(stderr, "\r");
        for col in range(1, width)
        {
            variable re = re_range[1] + re_step * (col - 1);
            variable im = im_range[1] + im_step * (row - 1);
            variable score = mandelbrot_score({re, im});
            img[row][col]              = score;
        }
    }
    
    return img;
}

function main()
{
    write(stderr, "Welcome to v0.2 of the XPL mandelbrot generator!\n\n");
    variable img = mandelbrot();
    write_pbm(img);
}


main()
