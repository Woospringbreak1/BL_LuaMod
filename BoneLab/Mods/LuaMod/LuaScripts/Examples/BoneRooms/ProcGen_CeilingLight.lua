
function Start()
    print("ProcGen_CeilingLight Start")

    meshRenderer = API_GameObject.BL_GetComponent(BL_Host,"MeshRenderer")
    local  resources = API_GameObject.BL_GetComponent(BL_Host,"LuaResources")
    local dynamicLight = API_GameObject.BL_GetComponentInChildren(BL_Host, "Light")

    onMaterial = resources.GetObject("On","Material")
    offMaterial = resources.GetObject("Off","Material")

    HumSound =  API_GameObject.BL_GetComponent(BL_Host,"AudioSource")

    local LightVal = API_Random.RangeInt(0, 10)
    --print("Lightswitch random value: " .. tostring(LightVal))


    if(LightVal<3) then
        dynamicLight.enabled = false
        --print("switching off light " .. tostring(meshRenderer) )
        --print("off material " .. tostring(offMaterial))

        API_Renderer.BL_SetMaterialAt(meshRenderer,1,offMaterial)

    end
  
end


function Update()

    if(BL_This.Ready) then
        if(not HumSound.isPlaying) then
           -- HumSound.Play() 
        end
    end

end

function OnDestroy()
API_GameObject.BL_Destroy(onMaterial)
API_GameObject.BL_Destroy(offMaterial)
end

