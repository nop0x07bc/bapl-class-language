local ERROR_CODES = {
    -- syntax errors
    SYNTAX             = 0xE101,
    -- semantical errors
    UNDEFINED_VARIABLE = 0xE201,
    UNEXPECTED_TAG     = 0xE202,
    NO_LOOP            = 0xE203,
    UNEXPECTED_VALUE   = 0xE204,
    REDECLARATION      = 0xE205,
    PARAM_NO_DEFAULT   = 0xE205,
    -- runtime errors
    INDEX_OUT_OF_RANGE = 0xE301,
    TYPE_MISMATCH      = 0xE302,
    CLOSURE_ARITY      = 0xE303,
}
local ERROR_MESSAGES = {
    [ERROR_CODES.SYNTAX]             = "Syntax Error",
    [ERROR_CODES.UNDEFINED_VARIABLE] = "Undefined variable",
    [ERROR_CODES.UNEXPECTED_TAG]     = "Unexpected tag",
    [ERROR_CODES.UNEXPECTED_VALUE]   = "Unexpected value",
    [ERROR_CODES.NO_LOOP]            = "Break without a loop",
    [ERROR_CODES.INDEX_OUT_OF_RANGE] = "Index out of range",
    [ERROR_CODES.CLOSURE_ARITY]      = "Closure arity mismatch",
    [ERROR_CODES.REDECLARATION]      = "Redaclaration of variable or function",
    [ERROR_CODES.PARAM_NO_DEFAULT]   = "Expected a param with default value",
}

local function make_error(code, payload)
    return {
        code = code,
        message = ERROR_MESSAGES[code],
        payload = payload
    }
end

return {make_error = make_error, ERROR_CODES = ERROR_CODES}
