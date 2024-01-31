# Final Project Report: eXperimental Programming Language (XPL)

<p align="center">
    <img width="640" height="480" src="mandelbrot.png">
</p>

The name for XPL is inspired by the _X-plane_ series of experimental aircrafts. Just as its aerodynamical "brothers"
it's not a finished product nor intended for production use[^1]. XPL is, simply, a tool for exploring programming
language design and implementation. 

XPL is implemented using [Lua](https://www.lua.org) and [LPeg](https://www.inf.puc-rio.br/~roberto/lpeg/) and inspired
by the _Selene_[^2] language. The design goal was an imperative, dynamically typed language with closures as first class
citizens and I believe we reached that goal.

The official logo for XPL is a rendition of the [Mandelbrot set](https://en.wikipedia.org/wiki/Mandelbrot_set) in a
rectangular area of the complex plane given by the two points $z_0 = -0.1475 - 0.92625i$ and $z_1 = 0.47 - 0.463125i$.
This was the first useful program implemented in XPL so it seemed appropriate. 

## Using the language
The basic requirements for running the interpreter is an installation of Lua (>= 5.3) and LPeg. To run the tests suite
you'll also need [luaunit](https://github.com/bluebird75/luaunit) installed[^3]. 

To run a XPL-script you navigate to the root of this repository and then execute the following command:

```bash
./run [--trace] [--load_path <path/to/xpl/libdir> ...] --load <path/to/xpl/script>

```

For example to run the `report/mandelbrot.xpl` script you would write
```bash
./run --load_path "report" --load report/mandelbrot.xpl > mandelbrot.ppm
```

### Load Paths
The `--load_path` argument specifys the path to search locations for XPL modules / libraries. XPL scripts might source
other XPL scripts and it needs to know where to find them. It will search the (possibly multiple) _load paths_ provided
by the `--load_path` argument when sourcing dependent scripts (see the section on Modules below).

### Traces
The `--trace` argument will show a _disassembly_ of the VM-instructions as it runs through the program. This is useful
for debug purposes but is very slow and interfers with output. Use with care.


## Language Syntax
The basic language syntax follows that of the Selene language but several additions have been made, especially when it
comes to control structures and functions / lambda expressions. The examples of the grammar are given in _pseudo EBNF_
together with examples.

### Identifiers
An identifier in XPL starts with a `letter` (`"A" | "B" ... "Z" | "a" ... "z"`) followed one ore more `letter`, `digit`
(`"1" | "2" ... "9"`) or `"_"` symbols. 

```
identifer = letter , { letter | digit | "_" }
```

Examples of valid identifiers are 
- `a`, 
- `alpha`,
- `alpha3342`,
- `Beta_` 
- `Theta_2032_3`. 

Examples of invalid identifiers are 
- `.x124`, 
- `434dfx`,
- `ab ba`. 

#### Note 
Some identifers are reserved for language constructs and can not be used in for example variable or function names.
Please refer to `report/compiler.lua` for reserved words.

### Literals

#### Numerals
XPL supports numerals in either decimal or scientific notations in base 10. Integers can also be given using hexadecimal
notation. A numeral can be prefixed with either a `+` or `-` symbol[^4].

```
sign     = "+" | "-"
digit    = "0" | "1" | ... | "9"
posint   = digit , {digit}
integer  = [sign] , posint
hexdigit = digit | "a" | "b" | ... | "f" | "A" | ... | "F"
hexint   = [sign] , "0" , ("x" | "X") , hexdigit , {hexdigit} 
decimal  = integer , ["."] , [posint] | [sign] , "." , posint
numeral  = hexint | decimal | decimal , ("e" | "E") , integer
```

Examples of valid numeral literals are
- `1`
- `202423`
- `0xdeadc0de`
- `123.3432`
- `123.2e10`
- `-123.2E10`
- `+0x43f`

Examples of invalid numeral literals are
- `0x534.5`
- `1.24e343.4`
- `232.232.232`


#### Array
XPL supports array literals using the _array constructor_ syntax:

```
array = "{", {expression}, "}"
```

A array literal starts with a curly brace, then an optional sequence of expressions follow and the literal ends with a
closing curly brace.

Examples of arrays are:
- `{1, 2, 3}`
- `{(1 + 1), {3, "hello"}, lambda () { return 10; }}`
- `{}`


#### Hashmaps
XPL support hashmap literals using a similar constructor expression as arrays. It uses the following syntax:

```
keyval  = expression , ":" , expression
hashmap = "[" , {keyval} , "]"
```

That is a hashmap starts with a opening bracket, then an optional sequence of key value expressions follow (i.e pair of
expressions seperated by a ":" character) and then it ends with a closing bracket.

Examples of hashmaps:
- `[1: "Peter", 2: "Sven"]`
- `["Alpha": "a", "Beta": "b"]`
- `[(16 * 7): lambda (x, y) { return x + y; }]`

#### Strings
XPL supports double quoted strings with escape sequences. A string starts with a double quote and ends with a _non_
escaped double quote. Any byte sequence can be inserted by the means of the escape sequence `"\", "x" , hexdigit , hexdigit` 
(e.g `\x0a` for a linefeed symbol).

```
hexescape  = "\" , "x" , hexdigit , hexdigit
lfescape   = "\" , "n"
crescape   = "\" , "r"
tabescape  = "\" , "t"
quotescape = "\" , """
backescape = "\" , "\"
char       = <printable character>
string     = """ , {hexescape | lfescape | crescape | tabescape | quotescape | backescape | char} , """
```

Example of valid strings are
- `"This's an example of a valid string."`
- `" Hello\n\tBrave\x0aNew World!!!"`
- `"\"Quoted string\""`

Example of invalid strings are
- `"does not end with a double quote`
- `'single quotes are not strings'`
- `does not start with a double quote"`
- `"forgot to escape "in this string"`

##### String implementation
String are implemented as XPL-arrays with integer values. This is a bit wasteful and complicates, for instance, string
comparision (we actually have to compare strings element by element). Otoh I can use the same code-generation facilities
that I use for array-literals, which makes it very easy to implement.

### Variables
Variables in XPL are symbolic names for values (closures, arrays, hashmaps, strings, null and numbers). A variable is
named by an _identifier_ (excluding reserved words) and must be declared before first use, using a variable
_declaration_ statement:

```
declaration = "variable" , identifier [= , expression]

```
Examples of valid variable declarations are:

```
variable my_var; # declares my_var and initiates it to "null"
variable my_other_var = 234 * 25; # variable with initialization.

```

Once a variable has been declared it can be used in any expression:

```
variable v = 1.54;
variable m = 99.0;
variable W = m * v^2 / 2;
```

Since XPL is dynamically typed it's up to the user to guarantee that the expressions involving variables (or any other
values) make sense. Trying to multiply a closure with a number will lead to a runtime error!

#### Assignment
A variable is updated via an _assignment_ statement. For a assignment to be valid the variable first has to be declared
(semantic check in compiler). The assigment statement takes the following form:

```
lhs        = identifier , "[" , expression , "]" , {"[" , expression , "]"} 
           | identifier , "." , expression , {"." , expression}
           | identifier
assignment = lhs , "=" , expression
```

Note that this grammar also includes array / hashmap assignment through indices. 


#### Variables and scope
It is an error to declare the same variable more than once in the same _scope_ (e.g the same block or closure). However
you can declare a variable with the same name in a different block or closure. Examples

Invalid re-declaration.
```
variable x;
variable x = 10; # Error! 

```

Valid re-declarations.
```
variable x = 10;
{
    # A block introduces a new scope.
    variable x = 20; # Here 'x' refers to a differnt storage cell.

}

function its_ok_to_use_x(y)
{
    variable x = y;
    # ...
}

```

A variable is _always_ local to it's current closure / scope. There are no globally mutable variables in XPL.

### Statements, Sequences and Blocks

### Arrays and Hashmaps

### Lambda expressions

### Functions

### Control Structures

### Modules

### Comments

### Other

## New Features/Changes

In this section, describe the new features or changes that you have added to the programming language. This should include:

* Detailed explanation of each feature/change
* Examples of how they can be used
* Any trade-offs or limitations you are aware of

## Future

In this section, discuss the future of your language / DSL, such as deployability (if applicable), features, etc.

* What would be needed to get this project ready for production?
* How would you extend this project to do something more? Are there other features you’d like? How would you go about adding them?

## Self assessment

* Self assessment of your project: for each criteria described on the final project specs, choose a score (1, 2, 3) and explain your reason for the score in 1-2 sentences.
* Have you gone beyond the base requirements? How so?

## References

List any references used in the development of your language besides this courses, including any books, papers, or online resources.


[^1]: In fact there might be bugs hidden deep inside that cause the computational equivalent of a complete "loss of control" (LOC). 
[^2]: As developed during the course of the [BaPL](https://classpert.com/classpertx/courses/building-a-programming-language/cohort) course. 
[^3]: On Ubuntu you can install this package using `sudo apt install lua-unit`.
[^4]: This is somewhat redundant since we also have the unary operator `-`, but I decided to keep it since it was part of an exercise.
