Range = 20*20
--Range = 0
AlreadySeen = false
SwitchRenderers = {}
DisableTime = 5.0
MaxDisableTime = 15.0
Visible = false
function Start()
    Renderers = API_GameObject.BL_GetComponentsInChildren(BL_Host,"Renderer")
    Lights = API_GameObject.BL_GetComponentsInChildren(BL_Host,"Light")
    CrateSpawners = API_GameObject.BL_GetComponentsInChildren(BL_Host,"CrateSpawner")
    ProcGenManager = API_GameObject.BL_GetComponent(GameObject.Find("ProcGenManager"),"LuaBehaviour")
    --PlayerRoot = API_Player.
    local i = 0



        for _,renderer in ipairs(Renderers) do

            local isblocker = false
            if(renderer.transform.parent ~= nil and renderer.transform.parent.name == "Blockers") then
                isblocker = true
                --print("skipping blocker")
            end

            if(not isblocker and renderer.name ~= "DOOR" and  renderer.name ~= "CeilingLight" and not string.find(renderer.name,"CrateSpawner")) then
                SwitchRenderers[i] = renderer
                i = i + 1
            end
        end

end

Spawned = false
function Spawn()
    if(not Spawned) then
        Spawned = true
        BL_This.ScriptTags.Add("ProcGen_Section_Spawned")

        if(CrateSpawners == nil) then
            return
        end
            
        for _,spawner in ipairs(CrateSpawners) do
            spawner.SpawnSpawnable()
            local meshRenderer = API_GameObject.BL_GetComponent(spawner.gameObject,"MeshRenderer")
            API_GameObject.BL_Destroy(meshRenderer) --get rid of VOID meshes
        end

        
    end
      
end

function ToLuaTable(wrapper)
    local t = {}
    local index = 1

    -- MoonSharp EnumerableWrapper supports ipairs-style iteration
    for value in wrapper do
        t[index] = value
        index = index + 1
    end

    return t
end


function HideRenderers()
    if(Lights ~= nil) then
        for _, light in pairs(Lights) do 
            if(IsValid(light)) then
                light.enabled = false
            end
        end
    end

    for _, renderer in pairs(SwitchRenderers) do  
        if(IsValid(renderer)) then
            renderer.enabled = false 
            Hidden = true
            Visible = false
        end
    end
end

function ShowRenderers()
    if(Lights ~= nil) then
        for _, light in pairs(Lights) do 
            if(IsValid(light)) then
                light.enabled = true
            end
        end
    end

    for _, renderer in pairs(SwitchRenderers) do  
        if(IsValid(renderer)) then
            renderer.enabled = true 
            Hidden = false
            Visible = true
        end
    end
end

function OnBecameInvisible()
   -- print("became invisible")
    DisableTime = Time.time+MaxDisableTime
    Visible = false
end

function OnBecameVisible()
    --print("became visible")
    DisableTime = nil
end

function OnTriggerEnter(OtherCollider) 
    --print("Someone entered my trigger collider: " .. OtherCollider.gameObject.name)

    if(OtherCollider.gameObject.name == "Root_M") then
        --print("Player has entered my trigger collider")
        if(not AlreadySeen and ProcGenManager.CallFunction("IncrementRoomSeenCount")) then
          --  print("Incremented room -- from section")
            AlreadySeen = true
        end 

    end

end

function SeenByPlayer()
   -- DisplayTime = MaxDisplayTime
    Visible = true
   -- print("seen by player!")

    if(Hidden) then

        ShowRenderers()
    end

end


CloseToPLayer = false
function SlowUpdate()

    
    if( API_Player.BL_GetAvatarCenter() == nil) then
        return
    end


    local PlayerPos = API_Player.BL_GetAvatarCenter()
    local Distance = BL_Host.transform.position - PlayerPos

    if (Distance.sqrMagnitude < Range)then 

        ShowRenderers()
        CloseToPLayer = true
    else
        CloseToPLayer = false
    end
  
    if(not Visible and not CloseToPLayer --[[and DisableTime ~= nil and Time.time > DisableTime--]] ) then
        HideRenderers()
    end

end