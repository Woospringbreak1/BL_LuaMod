
junk = {}

    
    local i = 1
    local chunk = string.rep("A", 1024 * 1024) -- 1MB string

    while i < 100 do
        junk[i] = chunk
        i = i + 1
        if i % 100 == 0 then
            print("Allocated approx: " .. tostring(i) .. " MB")
        end
    end
