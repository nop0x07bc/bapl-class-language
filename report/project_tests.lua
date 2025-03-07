-- Loads Stack Machine implementation.
require "machine"
-- Loads compiler that compiles arithmetic expressions to machine code
local compiler = require "compiler"
local lu = require "luaunit"
local errors = require "errors"
local trace = false

if arg[1] == "--trace" then
    trace = true
end

-- Make sure we are not regressing due to modifications.
TestMachine = {}
    function TestMachine:testExpressions()
        local TestIO = { prints = {}}
        function TestIO:write(...)
            io.stdout:write(... .. "\n")
            table.insert(self.prints, ...)
        end

        local machine = Machine:new(TestIO)
        machine:setTrace(trace) -- print trace of execution to stdout
        local function eval(str)
            local program = compiler.compile(str, {"report/examples"})
            machine:load(program)
            machine:run()
            return machine:tos()
        end

        local function eval_print(str)
            local program = compiler.compile(str, {"report/examples"})
            TestIO.prints = {}
            machine:load(program)
            machine:run()
            return TestIO.prints
        end
        local status = true
        local payload = {}
        -- Regression
        lu.assertEquals(eval("variable x = 2.3; variable y = 4.3 + -2.0^(2 - 3.3); variable z = x^2 + y^2; return z; z = 20"), 2.3^2 + (4.3 + -2.0^(2 - 3.3))^2)
        lu.assertEquals(eval_print("variable z = 10; @ z; @ z^2"), {"10\n", "100.0\n"})
        lu.assertError(eval, "variable z = x + y; @ z; return z")

        status, data = pcall(compiler.compile, "x = 10  ;{};;{ ;;;};;y = 5   ;  \n\n_letter = 3 * ) \t\n\n\n")
        lu.assertFalse(status)
        lu.assertEquals(data.payload.row, 3)
        lu.assertEquals(data.payload.col, 14)
        print(data.payload.message)

        status, data = pcall(compiler.compile, "\n\nx = 1;\ny = 5;\n\n\na =  ")
        lu.assertFalse(status)
        lu.assertEquals(data.payload.row, 7)
        lu.assertEquals(data.payload.col, 4)
        print(data.payload.message)

        lu.assertEquals(eval("variable x = 3; # x value ###\nvariable y = 4; # y-value not z = 4; \nreturn x + y;"), 7)
        lu.assertEquals(
            eval("variable m #{ mass #} = 3.0; variable v #{ velocity #} = 2.4;  variable W #{ kinetical energy #} = m * v^2 / 2.0; return W;"),
            8.64)
        lu.assertEquals(
            eval("variable m #{\n# mass\n #} = 3.0; variable v #{ velocity\n # m/s \n #} = 2.4; variable W = m * v^2 / 2.0; return W;"),
            8.64)
        lu.assertEquals(
            eval("variable m #} ## mass\n  = 3.0; variable v #{ velocity\n # m/s \n #} = 2.4; variable W = m * v^2 / 2.0; return W;"),
            8.64)
        lu.assertEquals(
            eval("variable m #{ #{ \n# #{ mass\n #} = 3.0; variable v #{ velocity\n # m/s \n #} = 2.4; variable W = m * v^2 / 2.0; return W;"),
            8.64)
        lu.assertEquals(
            eval("variable W = 1.0; {\nW = 8.64;\n#{ block } @ W; {} {comments nested in a block\n # W = 9.0;  #} }; return W;"),
            8.64)
       
        status, data = pcall(compiler.compile, "x = 3; #{ Some unfinished commment\n y = x + 3; return y")
        lu.assertFalse(status)
        lu.assertEquals(data.payload.row, 1)
        lu.assertEquals(data.payload.col, 7)
        print(data.payload.message)

        status, data = pcall(compiler.compile, "return = 3; y = return + 3; return return")
        lu.assertFalse(status)
        lu.assertEquals(data.payload.row, 1)
        lu.assertEquals(data.payload.col, 7)
        print(data.payload.message)

        lu.assertEquals(eval("variable x = ! 10; return x;"), 0)
        lu.assertEquals(eval("variable x = 10; return ! -x;"), 0)
        lu.assertEquals(eval("variable x = 0; return ! x;"), 1)
        lu.assertEquals(eval("variable x = 1; variable y = 10; return ! x > y"), 0)
        lu.assertEquals(eval("variable x = 1; variable y = 11; variable z = 12; return ! x + y < z"), 1)
        lu.assertEquals(eval("variable x = 1; variable y = 11; variable z = 12; return ! (x + y < z)"), 1)
        lu.assertEquals(eval("variable x = 1; variable y = 1; return ! x < y"), 1)
        lu.assertEquals(eval("variable x = 1; variable y = 1; return  x < !y"), 0)
        lu.assertEquals(eval("variable x = 1; variable y = 1; return ! (x < y)"), 1)
        lu.assertEquals(eval("variable x = 1; return -!-!-x"), -1)

        lu.assertEquals(eval("variable x = 10; variable y = 3; if x - 2 == 8 { y = 2; }; return y"), 2)
        lu.assertEquals(eval("variable x = 10; variable y = 3; if x - 2 == 7 { y = 2; }; return y"), 3)
        lu.assertEquals(eval("variable x = 2.1e2; variable y = 3; if ! (y == 2) { y = x^y; }; return y"), 2.1e2^3)
        lu.assertEquals(eval("variable x = 2.1e2; variable y = 3; if (y == 2) { y = x^y; }; return y"), 3)
        lu.assertEquals(eval("variable x = 10; variable y = 0; if x == 10 { y = 1; } else { y = 2; }; return y"),  1)
        lu.assertEquals(eval("variable x = 10; variable y = 0; if ! (x == 10) { y = 1; } else { y = 2; }; return y"),  2)

        lu.assertEquals(eval("variable x = 10; variable y = 0; if x == 10 { y = 1; } elseif x == 9 { y = 2; } else { y = 3; }; return y"), 1)
        lu.assertEquals(eval("variable x = 9; variable y = 0; if x == 10 { y = 1; } elseif x == 9 { y = 2; } else { y = 3; }; return y"), 2)
        lu.assertEquals(eval("variable x = 8; variable y = 0; if x == 10 { y = 1; } elseif x == 9 { y = 2; } else { y = 3; }; return y"), 3)

        lu.assertEquals(eval("variable x = 8; variable y = 0; if x == 10 { y = 1; } elseif x == 9 { y = 2; }; return y"), 0)

        -- While
        lu.assertEquals(eval("variable x = 0; while x < 3 { @ x; x = x + 1; }; return x"), 3)
        lu.assertEquals(eval("variable x = 0; while 0 { @ x; x = x + 1; }; return x"), 0)
        lu.assertEquals(eval("variable n = 6; variable r = 1; while n > 0 { r = n * r; n = n - 1; }; return r"), 720)

        -- Logical expr (constant fold)
        lu.assertEquals(eval("variable x = 5 and 4; return x"), 4)
        lu.assertEquals(eval("variable x = 0 and 4; return x"), 0)
        lu.assertEquals(eval("variable x = 5 and 0; return x"), 0)
        lu.assertEquals(eval("variable x = 0 and 0; return x"), 0)
        lu.assertEquals(eval("variable x = 5 or 4; return x"), 5)
        lu.assertEquals(eval("variable x = 0 or 4; return x"), 4)
        lu.assertEquals(eval("variable x = 5 or 0; return x"), 5)
        lu.assertEquals(eval("variable x = 0 or 0; return x"), 0)
        lu.assertEquals(eval("variable x = 5 and 4 and 3; return x"), 3)
        lu.assertEquals(eval("variable x = 0 and 5 and 4; return x"), 0)
        lu.assertEquals(eval("variable x = 5 and 4 and 0; return x"), 0)
        lu.assertEquals(eval("variable x = 0 or 1 and 2; return x"), 2)
        lu.assertEquals(eval("variable x = 3 or 1 and 2; return x"), 3)
        lu.assertEquals(eval("variable x = 2 and (0 or 1); return x"), 1)
        lu.assertEquals(eval("variable x = 2 and (1 or 0); return x"), 1)

        -- Logical expr
        lu.assertEquals(eval("variable x = 5; variable y = 4; variable z = 3; variable f = 0; return x and y;"), 4)
        lu.assertEquals(eval("variable x = 5; variable y = 4; variable z = 3; variable f = 0; return f and x;"), 0)
        lu.assertEquals(eval("variable x = 5; variable y = 4; variable z = 3; variable f = 0; return x and f;"), 0)
        lu.assertEquals(eval("variable x = 5; variable y = 4; variable z = 3; variable f = 0; return f and f;"), 0)
        lu.assertEquals(eval("variable x = 5; variable y = 4; variable z = 3; variable f = 0; return x or y;"), 5)
        lu.assertEquals(eval("variable x = 5; variable y = 4; variable z = 3; variable f = 0; return f or x;"), 5)
        lu.assertEquals(eval("variable x = 5; variable y = 4; variable z = 3; variable f = 0; return x or f;"), 5)
        lu.assertEquals(eval("variable x = 5; variable y = 4; variable z = 3; variable f = 0; return f or f;"), 0)
        lu.assertEquals(eval("variable x = 5; variable y = 4; variable z = 3; variable f = 0; return x and y and z;"), 3)
        lu.assertEquals(eval("variable x = 5; variable y = 4; variable z = 3; variable f = 0; return f and x and y;"), 0)
        lu.assertEquals(eval("variable x = 5; variable y = 4; variable z = 3; variable f = 0; return x and y and f;"), 0)
        lu.assertEquals(eval("variable x = 5; variable y = 4; variable z = 3; variable f = 0; return f or x and y;"), 4)
        lu.assertEquals(eval("variable x = 5; variable y = 4; variable z = 3; variable f = 0; return x or y and z;"), 5)
        lu.assertEquals(eval("variable x = 5; variable y = 4; variable z = 3; variable f = 0; return x and (f or y);"), 4)
        lu.assertEquals(eval("variable x = 5; variable y = 4; variable z = 3; variable f = 0; return x and (y or f);"), 4)

        lu.assertEquals(eval("variable x = 10; variable y = 9; return x > y and y == 9;"), 1)
        lu.assertEquals(eval("variable x = 10; variable y = 9; return x < y and y == 9;"), 0)
        lu.assertEquals(eval("variable x = 10; variable y = 9; return x > y and y != 9;"), 0)
        lu.assertEquals(eval("variable x = 10; variable y = 9; return x < y and y != 9;"), 0)

        lu.assertEquals(eval("variable x = 10; variable y = 9; return x > y or y == 9;"), 1)
        lu.assertEquals(eval("variable x = 10; variable y = 9; return x < y or y == 9;"), 1)
        lu.assertEquals(eval("variable x = 10; variable y = 9; return x > y or y != 9;"), 1)
        lu.assertEquals(eval("variable x = 10; variable y = 9; return x < y or y != 9;"), 0)

        -- Array operations.
        lu.assertEquals(eval("variable x = new [10]; return x;"), {size=10, tag = "array", id = 0}) 
        lu.assertEquals(eval("variable x = new [10]; x[1] = 10; x[2] = -10; return x[1];"), 10) 
        lu.assertEquals(eval("variable x = new [2 * 2 + 1]; variable i = 1; x[2*i + 2] = -10; return x[4];"), -10) 
        lu.assertEquals(eval("variable x = new[2]; x[1] = 3; x[2] = 4; variable y = x[1]^2 + x[2]^2; return y;"), 25) 

        status, data = pcall(eval, "variable x = new [10]; x[12] = 5")
        lu.assertFalse(status)
        lu.assertEquals(data.code, errors.ERROR_CODES.INDEX_OUT_OF_RANGE)
        
        status, data = pcall(eval, "variable x = new [10]; x[-1] = 5")
        lu.assertFalse(status)
        lu.assertEquals(data.code, errors.ERROR_CODES.INDEX_OUT_OF_RANGE)

        -- Test array print.
        lu.assertEquals(eval_print("variable x = new [3]; @ x"), {"{,,}\n"})
        lu.assertEquals(eval_print("variable x = new [3]; x[2] = 2; @ x"), {"{,2,}\n"})
        lu.assertEquals(eval_print("variable x = new [3]; x[1] = 3; x[2] = 2; @ x"), {"{3,2,}\n"})
        lu.assertEquals(eval_print("variable x = new [3]; x[1] = 3; x[2] = 2; x[3] = 1; @ x"), {"{3,2,1}\n"})
        lu.assertEquals(eval_print("variable x = new [3]; x[1] = new [3]; x[2] = 0; x[3] = 0; @ x"), {"{{,,},0,0}\n"})

        -- Multidimensional arrays
        lu.assertEquals(eval("variable x = new [2]; x[2] = new [2]; x[2][2] = 5; @ x; return x[2][2];"), 5)
        lu.assertEquals(eval("variable x = new [2][3]; x[2][2] = 5; @ x; return x[2][2];"), 5)
        lu.assertEquals(eval("variable x = new [2][3][4]; x[2][2][3] = 5; @ x; return x[2][2][3];"), 5)
        lu.assertEquals(eval("variable n = 2; variable m = 5; variable x = new [n*2][m]; @ x; x[n][m - 1] = 33; return x[n][m - 1] / 3"), 11)
        lu.assertEquals(eval("variable n = 2; variable m = 5; variable y = new [2]; y[2] = 4; variable x = new [y[2]][m]; @ x; x[n][m - 1] = 33; return x[n][m - 1] / 3"), 11)

        -- Block scoping.
        lu.assertEquals(eval("variable x = 10; { variable y = 15; x = x + y; } return x;"), 25)
        status, data = pcall(eval, "variable x = 10; { variable y = 15; x = x + y; } return y;");
        lu.assertEquals(status, false)
        lu.assertEquals(data.code, errors.ERROR_CODES.UNDEFINED_VARIABLE)
        lu.assertEquals(data.payload.identifier, "y")
        status, data = pcall(eval, "variable x = 10; { variable y = 15; x = x + y; }; variable x = 10; return x;");
        lu.assertEquals(status, false)
        lu.assertEquals(data.code, errors.ERROR_CODES.REDECLARATION)
        lu.assertEquals(data.payload.identifier, "x")
        lu.assertEquals(eval("variable x = 10; variable y; { variable x = 15; y = -10; y = x + y; } return y;"), 5)
        lu.assertEquals(eval("variable x = 10; variable y; { variable x = 15; y = -10; y = x + y; } return x;"), 10)


        -- Functions
        lu.assertEquals(eval("variable f = lambda () { return 10; }; return f();"), 10)
        lu.assertEquals(eval("variable y = 2; variable x = 100; @ x; variable f = lambda () { return x; }; return y + f();"), 102)
        lu.assertEquals(eval("variable y = 2; variable f = lambda (x) { return x + y; }; @ f (10); return f(11);"), 13)
        lu.assertEquals(eval("variable y = 2; variable f = lambda (x) { return x + y; }; y = 6; @ f (10); return f(11);"), 13)

        -- Optional arguments
        -- status, data = pcall(eval, "function g(x, y = 2, z) { return x + y + z; }")
        status, data = pcall(eval, "function g(x, y = 2, z) { return x + y + z; }")
        lu.assertEquals(status, false)
        lu.assertEquals(data.code, errors.ERROR_CODES.PARAM_NO_DEFAULT)
        lu.assertEquals(data.payload.identifier, "z")

        lu.assertEquals(eval("function g(x, y = 2, z = 3) { return x + y + z; }; return g(10);"), 15) 
        lu.assertEquals(eval("function g(x, y = 2, z = 3) { return x + y + z; }; return g(10, 20);"), 33) 
        lu.assertEquals(eval("function g(x, y = 2, z = 3) { return x + y + z; }; return g(10, 20, 30);"), 60) 
        status, data = pcall(eval, "function g(x, y = 2, z = 3) { return x + y + z; }; return g();")
        lu.assertEquals(status, false)
        lu.assertEquals(data.code, errors.ERROR_CODES.CLOSURE_ARITY)
        status, data = pcall(eval, "function g(x, y = 2, z = 3) { return x + y + z; }; return g(1, 2, 3, 4);")
        lu.assertEquals(status, false)
        lu.assertEquals(data.code, errors.ERROR_CODES.CLOSURE_ARITY)

        test_file = io.open("report/examples/test.xpl", "r"):read("a")
        status, data = pcall(eval, test_file)
        lu.assertEquals(status, true)

        test_file = io.open("report/examples/rec.xpl", "r"):read("a")
        status, data = pcall(eval, test_file)
        lu.assertEquals(status, true)

        test_file = io.open("report/examples/it.xpl", "r"):read("a")
        status, data = pcall(eval, test_file)
        lu.assertEquals(status, true)
    end

os.exit(lu.LuaUnit:run())

