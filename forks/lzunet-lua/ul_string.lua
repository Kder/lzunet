--[[ Copyright (c) 2010 god6or@gmail.com under MIT license.
]]

-- split string with separator
string.split = function(s, sep)
    local pieces = {}
    s:gsub('([^' .. sep .. ']*)' .. sep .. '?', function(c) if #c > 0 then table.insert(pieces, c) end end)
    return pieces
end

-- adjust string to the right
string.rjust = function(s, l, c)
    if not c then c = ' ' end
    s = tostring(s)
    while #s < l do s = c .. s end
    return s
end
-- adjust string to the left
string.ljust = function(s, l, c)
    if not c then c = ' ' end
    s = tostring(s)
    while #s < l do s = s .. c end
    return s
end
-- center string
string.center = function(s, l, c)
    if not c then c = ' ' end
    s = tostring(s)
    while #s < l do
        s = c .. s
        if #s < l then s = s .. c end
    end
    return s
end

-- strip chars from the left
string.lstrip = function(s, c, l)
    if not c then c = ' ' end
    if not l then l = 0 end
    s = tostring(s)
    while (#s > l) and (s:sub(1,1) == c) do s = s:sub(2,-1) end
    return s
end
-- strip chars from the right
string.rstrip = function(s, c, l)
    if not c then c = ' ' end
    if not l then l = 0 end
    s = tostring(s)
    while (#s > l) and (s:sub(-1,-1) == c) do s = s:sub(1,-2) end
    return s
end
-- strip chars from the left and right
string.strip = function(s, c, l)
    if not c then c = ' ' end
    if not l then l = 0 end
    s = tostring(s)
    while (#s > l) do
        if (s:sub(1,1) == c) then s = s:sub(2,-1) end
        if (#s > l) and (s:sub(-1,-1) == c) then s = s:sub(1,-2) end
    end
    return s
end

-- multiple replace. repTab - replacement table in format {'pattern1'='repl1','pattern2'='repl2', ...}
string.mrepl = function(s, repTab)
    for p,r in pairs(repTab) do
        s = string.gsub(s, p, tostring(r))
    end
    return s
end

-- mirror string
string.mirror = function(s)
    local st = {}
    for sc=#s,0,-1 do
        table.insert(st, s:sub(sc,sc))
    end
    return table.concat(st, '')
end

