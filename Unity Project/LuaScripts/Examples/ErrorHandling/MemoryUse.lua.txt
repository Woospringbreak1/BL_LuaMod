--require("Examples\\ErrorHandling\\BaseExample.lua")

local luaResources = API_GameObject.BL_GetComponent(BL_Host,"LuaResources")
require(luaResources.GetObject("BaseExample.lua","TextAsset"))


function SetStatus(status)
    --print("MemoryUse setStatus called " .. tostring(status))
    if(status) then
        print("allocating as much memory as possible")
        AllocateAllMemory()
    end
end

junk = {}
function AllocateAllMemory()
    
    local i = 1
    local chunk = string.rep("A", 1024 * 1024) -- 1MB string

    while i < 100 do
        junk[i] = chunk
        i = i + 1
        if i % 100 == 0 then
            print("Allocated approx: " .. tostring(i) .. " MB")
        end
    end
end
