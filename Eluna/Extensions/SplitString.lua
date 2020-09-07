function SplitString(inputstr)
    local t = {}
    local e, i = 0, 1
    
    while true do
        local b = e+1
        b = inputstr:find("%S",b)
        
        if b == nil then
            break
        end
        
        if inputstr:sub(b,b) == "'" then
            e = inputstr:find("'", b+1)
            b = b+1
        elseif inputstr:sub(b,b) == '"' then
            e = inputstr:find('"', b+1)
            b = b+1
        else
            e = inputstr:find("%s", b+1)
        end
        
        if e == nil then 
            e = #inputstr+1
        end
 
        t[i] = inputstr:sub(b,e-1)
        i = i + 1
    end
    
    return t
end