local path = {}

local sep = "/"

function path.split(str)
    local parts = {}
    while #str > 0 do
        local start, stop = string.find(str, sep)
        if start == nil then
            table.insert(parts, str)
            break;
        else
            table.insert(parts, string.sub(str, 1, start - 1))
            str = string.sub(str, stop + 1, #str)
        end

    end
    return parts
end


function path.basename(str)
    local ps = path.split(str)
    return ps[#ps]
end

function path.dirname(str)
    local ps = path.split(str)
    table.remove(ps)
    return table.concat(ps, sep)
end

function path.join(...)
    local args = {...}
    local res = table.concat(args, sep)
    local function aux (str, len)
        local str = string.gsub(str, sep..sep, sep)
        if #str == len then
            return str
        else
            return aux(str, #str)
        end
    end

    return aux(res, #res)
end

function path.absolute(str)
    return string.sub(str, 1, 1) == sep
end

return path
