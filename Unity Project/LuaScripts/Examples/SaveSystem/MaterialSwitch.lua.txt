function Start()
    print("Hello, World from colour switching example")
    resources = API_GameObject.BL_GetComponent(BL_Host,"LuaResources")
    meshRenderer = API_GameObject.BL_GetComponent(BL_Host,"MeshRenderer")

    --print("resources " .. tostring(resources))
    onMaterial = resources.GetObject("On","Material")
    offMaterial = resources.GetObject("Off","Material")

    --print("onMaterial " .. onMaterial.name .. " " .. tostring(onMaterial))
    --print("offMaterial " .. offMaterial.name .. " " .. tostring(offMaterial))

    Status = false --off
    SetStatus(Status)
end

function SetStatus(status,floatstatus,nil2,nil3)
    --print("incoming status: " .. tostring(status))
    --print("incoming Float status: " .. tostring(floatstatus))
    Status = (status == 1 or status == true) --hack to accomodate the incoming event as well as button loading
    --print("Status: " .. tostring(Status))


    if Status then
        meshRenderer.material = onMaterial
    else
        meshRenderer.material = offMaterial
    end
    
end

