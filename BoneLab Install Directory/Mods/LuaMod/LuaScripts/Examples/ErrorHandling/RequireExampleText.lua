local luaResources = API_GameObject.BL_GetComponent(BL_Host,"LuaResources")
require(luaResources.GetObject("RequireExample.lua","TextAsset"))

function Start()
    print("starting require() tests")
    print(tostring(Example))
    TestMessage()
    print("TestMessage2: " .. TestMessage2)
end