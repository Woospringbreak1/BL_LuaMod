function Start()
    local luaResources = API_GameObject.BL_GetComponent(BL_Host,"LuaResources")
    require(luaResources.GetObject("BaseExample.lua","TextAsset"))
end

StackOverflow = false
function SetStatus(status)
StackOverflow = status
end

function Update()

    if(not BL_This.Ready) then
        return
    end

    if(StackOverflow) then
        print("triggering stack overflow")
        Update()
    end
end