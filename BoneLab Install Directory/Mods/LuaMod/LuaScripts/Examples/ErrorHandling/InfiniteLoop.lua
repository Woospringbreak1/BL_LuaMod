--require("Examples\\ErrorHandling\\BaseExample.lua")

local luaResources = API_GameObject.BL_GetComponent(BL_Host,"LuaResources")
require(luaResources.GetObject("BaseExample.lua","TextAsset"))


InfiniteLoop = false
function SetStatus(status)
    InfiniteLoop = status
end

function Update()

    if(not BL_This.Ready) then
        return
    end

   if(InfiniteLoop) then
        while true do
            --print("infinite loop")
        end
   end

end