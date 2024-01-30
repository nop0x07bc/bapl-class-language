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

## Language Syntax

In this section, describe the overall syntax of your language.

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
