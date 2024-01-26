# Week 8
The same note as for last weeks exercises applies for this week. Due to design choices I will not complete all exercies
(in this case Exercise 9. "Check for Main"). I will however reason about a solution below.


## Status of the language implementation.

Since Week 7 there was already support for 1:st class functions / closures with parameters. Mainly I focused on adding
support for variable declarations, checks for redeclarations and default arguments. In addition to these features I also
implemented support for strings. Please see individual notes below.


### Variable declaration and scope.
Here I followed the grammar in the lectures pretty close, however the implementation is quite different. The language
now requires the user to declare a variable before usage using the syntax

```
variable x = z^2 + y^2 # some expression, note that z and y must already be declared!
```
or

```
variable x;  # x will have the "null" value. 
```

You cannot redeclare the same variable, so programs such as

```
variable x = 5;
variable x = 10; # ERROR!
```
generates a compiler error. 

However shadowing of variables in scope is ok

```
variable x = 5;
{
    variable x = 10; # ok!
}
```

Please refer to `lesson-8/lesson_test.lua` and `lesson-8/test.xpl` for examples. 

*Note:* As a curios side effect we also get uniqueness checks for functions due to functions just being syntactic sugar
for `lambda` expressions (see last weeks notes).


*Note:* This implementation effectivly solves exercies *3*, *5* and *7*.


### Default arguments
Functions and lambda expressions can now take an arbitrary number of default arguments. I follow the `c-style`
convention of requiring all parameters _following_ the first parameter with default arguments to have default arguments.
E.g 

```
function test(a, b = 10, c = 20, d = 15)
{
    return {a, b, c, d};
}
```
is ok, whereas
```
function test(a, b = 10, c, d)
{
    return {a, b, c, d};
}
```
yields and compiler error (see `lesson-8/lesson_test.lua` for tests). The code generation for this was suprisingly easy
to implement!


*Note:* This solves execise *11*.


### On Exercies 9. Check for Main
As stated in the notes for Week7 I don't want to assign importance to any special function / closure. In fact I don't
even keep a list of functions in the compiler / virtual machine. A function is just a closure attached to a variable,
that's it. 

If were to implement this feature I would do the following:

1. The compiler state gets a new table containing function names.
2. In the compiler where I generate code for `function` nodes I add the id:s of the function as well as the closure code
   generated. 
3. If a function with name `main` appears I check that the arity is `0`.
4. As final mechanism I ensure the top-level closure will start to execute `main`.


### Additional updates.
I added support for *strings* to the language. This was quite straight-forward and required very little implementation
once I decided that strings are simply *arrays* of integers. Since I already implemented an array-construction
mechanism, e.g

```
variable my_array = {1, 2, 4, 5};
```

I could hook in the same aparatus for nodes that parses strings. E.g 

```
variable my_string = "\x0a\"Hello Brave\x20World!\"\n\n";
#{

"Hello Brave World!"



#}
```
Is simply translated to an array of integers.

Strings support escape sequences for linefeed, carriage return, tab, backslash, quotation and hexadecimal byte
sequences. Please refer to test and `lesson-8/test.xpl` as well as `lesson-8/fractal.xpl` for usage.
