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
Variables in XPL are symbolic names for values (closures, arrays, hashmaps, strings, files, null and numbers). A variable is
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

A variable is _always_ local to it's current closure. There are no globally mutable variables in XPL. Closures will
copy _free variables_ by value.

### Expressions
An expression is anything that can be on the rhs of an assignment or operated on by a select set of _statments_ (e.g return,
print (`@`), read, write, etc...). It includes literals, arithmetical operations on expressions, logical operartions,
file constants, null, array / hashmap indexing, lambda expressions, function calls and module inclusion.

```
primary    = (lhs | "(" , expression , ")") , args
           | "lambda" , optparams , block
           | "new" "[" , expression , "]" , {"[" , expression , "]"}
           | array
           | hashmap
           | numeral
           | "null"
           | "len" , expression
           | "(" , expression , ")"
           | ("stdin" | "stdout" | "stderr")
           | string
           | lhs
           | "require" , string

exponent   = primary , "^" , primary

negation   = {("-" | "!") , exponent

term       = negation , {("*" | "/" | "%") , negation}

addend     = term , {("+" | "-") , term}

comparison = addend , {("<" | ">" | "<=" | ">=" | "==" | "!=") , addend}

logical    = comparison { "and" , comparison }

expression = logical { "or" , logical }

```

An expression is not a valid XPL-program on it's own. It needs to be associated to a statement. From an implementation
perspective one can think of expressions as something that pushes a new value onto the stack of the VM.[^5]

#### Operators
XPL suppor the following operators

| Operator | Precendence | Arity | Comment                    |
|----------|--------------|-------|-----------------------------|
|    ^     |      1      |   1   | exponent, right associative|
|    -     |      2      |   1   | additive negation          |
|    !     |      2      |   1   | logical negation           |
|    *     |      3      |   2   | multiplication             |
|    /     |      3      |   2   | division                   |
|    %     |      3      |   2   | modulus                    |
|    +     |      4      |   2   | addition                   |
|    -     |      4      |   2   | subtraction                |
|    >     |      5      |   2   | greater then               |
|    >=    |      5      |   2   | greater or equal to        |
|    <     |      5      |   2   | less then                  |
|    >=    |      5      |   2   | less or equal to           |
|    ==    |      5      |   2   | equal to                   |
|    !=    |      5      |   2   | not equal to               |
|    and   |      6      |   2   | logical and                |
|    or    |      7      |   2   | logical or                 |



### Statements, Sequences and Blocks
A valid XPL program consists of _sequences_ of _statements_. A statement is either a _block_ (encompassing
control structures) or a set of special statements (assignment, return, break etc...):


```
program   = space * sequence

sequence  = block , [sequence]
          | statement , [";" , sequence]

block     = ifstmt
          | switchstmt
          | for1stmt
          | for2stmt
          | whilestmt
          | functionstmt
          | "{" , sequence , "}"

statement = block
          | "return" , expression
          | "break"
          | identifier , args
          | ":" , expression
          | "@" , expression
          | "read" , "(" , expression , "," , expression , ")"
          | "write" , "(" , expression , "," , expression , ")"
          | declaration
          | assignment
```

The control structures will be convered in other sections.

### Arrays and Hashmaps
XPL has support for arrays and hasmaps / tables[^6]. You can create them using the array or hashmap literal as described
in the "literals" section. You can also create arrays using the `new` keyword (see expressions):

```
"new" "[" , expression , "]" , {"[" , expression , "]"}
```

Examples of array and hashtable creation:

```
variable a = new [100][100]; # an array consisting of 100 elements, each being an array of 100 elements.
variable b = {1, 2, 3};      # an array containing the value 1, 2, 3.
variable h = [];             # an empty table.
variable i = ["test": 1, 
              "test2": 2]    # an table with string keys "test" and "test2" and values 1, 2 respectively.

```

To access into an array or table you can use the index operator `[]`:

```
indexop = identifier , "[" , expression , "]" , {"[" , expression , "]"} 
```

For tables (with string keys) you can also use the `.` operator:

```
dotop  = identifier , "." , expression , {"." , expression}

```
### Lambda expressions and Functions
A lambda expression creates a callable closure. A closure consists of an _environment_ with _parameters_, _local_ and
_free_ variables. Upon creation of a closure all _free_ variables are copied into the closure environment. When calling
a closure the formal _parameters_ are copied into the closure environment from the stack. 

A lambda expression has the following syntax:

```
idassign  = identifier , ["=", expression]
optparams = "(" , space , ")" | "(", idassign , {"," , idassign} , ")"
lambda = "lambda" , optparams , block
```

Examples of lambda expressions are:
```
variable a = lambda () { variable c = 0; return c; };
variable b = lambda (x, y, z) { return x + y + a(); };
```

Lambda expression have a central role in XPL and many other language constructs builds on these, most importantly
functions, but also modules and iterators. 

Function statements are syntactic sugar around lambda expressions (we will go into implementation details in another
section) and variables. It has the following syntax:

```
functions = "function" , identifier , optparams , block {, "and" , identifier , optparams , block}
```

Mutually recursive functions are defined in one statement as in the following example:

```
variable false = 0;
variable true  = 1;
function odd (n)
{
    if (n < 0)
    {
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
    if (n < 0)
    {
        return even(-n);
    }
    elseif (n == 0)
    {
        return true;
    }
    else
    {
        return odd(n - 1);
    }

}
```

This syntax is inspired by OCamls `let rec fun1 = ... and fun 2 = ...` syntax[^7]. Here is another example of a function
statement show how closures captures freevariables of the surrouding environment:
```
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
    }
}
```
#### Calls
A function / lambda expression / closure can be called using the following syntax:

```
args = "(" , space , ")" | "(" , expression , {"," , expression} , ")"
call = (lhs | "(" , expression , ")") , args
```

Examples
```
variable it = iterator(1, 20, 2);

@ (lambda () { return {1, 2, 3}; })();

```

Argument expressions are evaluated in order and pushed onto the stack. The closure then copies the params into the data
section reserved for the formal parameters.

### Control Structures

#### If-statement
The grammar for if statment is as follows:

```
ifstmt = "if" , expression , block , [ifrest | "else" , block]
ifrest = "elseif" , expression , block , [ifrest | 'else' , block]
```

Valid if statments:
```
variable x = 20;
## without else
if x > 15
{
    @ x;
}

## with else
if (x > 15)
{
    @ x;
}
else
{
    @ 0;
}

## with elseif
if (x > 15)
{
    @ x;
}
elseif (x > 10)
{
    @ x - 10;
}
elseif (x > 5)
{
    @ -x;
}
else
{
    # do nothing
}

```

Note that a `else` must always come last and `elseif` cannot start a if-statement.
#### Break-statement
A break statement is used for escaping loops or switch-cases early. 

```
break = "break"
```

The break statement is scoped so that if there are nested loop or switch statements the innermost `break` will only
escape the innermost loop or switch. 

#### Return-statement
A return statement returns control to the calling closure. In case of the TOP-closure execution in the VM is halted. A
return statement can take an optional argument that will be pushed onto the stack. If no argument is provided `null` is
push to the stack.

Syntax:

```
return = "return" , [expression]
```


#### Switch-statement
The syntax for the switch-statement closely follows that of C. The XPL grammar for switch statements is
```
switch = "switch" , expression , "{" , {"case" , expression , ":" , block } , ["default" , ":" , block] , "}"
```

If a case-block does not contain a `break` or `return` statement we will fall-through to the next case.

Examples of switch-cases:

```
variable x = 10;
switch (x)
{
    case 1:
    {
        write(stdout, "Case one\n");
        break;
    }
    case 10:
    {
        write(stdout, "Case ten, will fall through!\n");
    }
    case 11:
    {
        write(stdout, "Case eleven\n");
        break;
    }
    default:
    {
        write(stdout, "The default case\n");
    }
}
```
#### For statement
There are 2 different kind of _for_-loops in XPL. One is the _C-styled_ for
```
for1stmt = "for" , [identifier , "=" , expression ] , ";"
                 , [expression] , ";"
                 , [assignment] , ";"
                 , block
```

and the other is the _iterator_ for

```
for2stmt = "for" , identifier , "in" , expression , block
```

In the _iterator_ for-loop the `expression` should return a _thunk_[^8] that returns `null` when iteration is complete. 


Examples of for-statements:

```
# x local to for-loop block
for x = 10; x < 20; x = x + 3
{
    @ x;
}

# x outside for-loop block
variable x = 10;
for ; x < 20; x = x + 3
{
    @ x; 
}

for x in iterator(0, 100, 25)
{
    @ x;
}

```

#### While-statement
While statements has the following syntax:

```
whilestmt = "while" , expression , block
```

Example:

```
variable x = 10;
while (x < 100)
{
    @ x;
    if ( x < -3)
    {
        break; # break out of loop early.
    }

    x = x - 1;
}

```

### Modules
A module is a closure defined in another file. A module can be loaded and executed by the _require_ expression:

```
require = "require" , string
```

Modules are essentially handled as _thunk_ and executed as soon as they are loaded. Generally a module would return a
hashtable constisting of functions and values. 

The search paths for modules are passed to the compiler via the constructor. If no constructor is passed relative paths
are resolved relative to the CWD.

Example:
```
variable strings = require "std/strings.xpl"; 
```

This executes the closure defined in the script `std/strings.xpl` and puts the result in the variable _strings_. 

### Comments
There are two kinds of comments in the language: Line comments and Block comments. The grammar for comments is actually
baked into the grammar for white spaces (as in the case of Selene):

```
comment     = "#{" , block_rest | "#\n" | "#" * line_rest_0
block_rest  = "#}" | <any-character> , block_rest
line_rest_0 = (<any-character> - "{") , line_rest_1
line_rest_1 = (<any-character> - "\n") , line_rest_1 + "\n"
space       = {(" " | "\n" | "\t") + comment}
```

Example of comments:
```
## Line comment

variable y; # another line comment.

#{

#{
    # comment nested 
    This is still a comment 
#}

variable #{ in line comment #} x = 10;

```
### Other

#### Return and break


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
[^5]: Following the same line of thinking, a statement is then something that consumes that value pushed onto the stack.
    Returning it, or printing it etc.
[^6]: In the "reference implementation" both XPL arrays and tables are realized by Lua tables. 
[^7]: [Recursive definition of values](https://v2.ocaml.org/manual/letrecvalues.html)
[^8]: I.e a argument-less closure / lambda expression.
