Range = 100*100
--Range = 0
AlreadySeen = false
SwitchRenderers = {}
function Start()
    Renderers = API_GameObject.BL_GetComponentsInChildren(BL_Host,"Renderer")
    ProcGenManager = API_GameObject.BL_GetComponent2(GameObject.Find("ProgGenManager"),"LuaBehaviour")
    --PlayerRoot = API_Player.
    local i = 0
        for renderer in Renderers do
            if(renderer.name ~= "DOOR") then
                SwitchRenderers[i] = renderer
                i = i + 1
            end
        end

end

function OnTriggerEnter(OtherCollider) 
    --print("Someone entered my trigger collider: " .. OtherCollider.gameObject.name)

    if(OtherCollider.gameObject.name == "Root_M") then
        --print("Player has entered my trigger collider")
        if(not AlreadySeen and ProcGenManager.CallFunction("IncrementRoomSeenCount")) then
          --  print("Incremented room -- from section")
            AlreadySeen = true
        end 
        if(OtherCollider.transform.root == API_Player.BL_GetAvatarGameObject().transform.root) then
        print("other check also good")  
        end

    end

end

function SeenByPlayer()
    DisplayTime = MaxDisplayTime
   -- print("seen by player!")
end

MaxDisplayTime = 5
DisplayTime = 30.0*MaxDisplayTime
function SlowUpdate()
--check for player
--SlowUpdate continues when game object is disabled

    if( API_Input.BL_LeftHand() == nil) then
        return
    end

    local PlayerPos = API_Input.BL_LeftHand().transform.position
    if(PlayerPos ~= nil) then
        local Distance = BL_Host.transform.position - PlayerPos

        if (Distance.sqrMagnitude > Range and DisplayTime <= 0 )then 
            for _, renderer in pairs(SwitchRenderers) do  
                renderer.enabled = false 
            end
        else
            for _, renderer in pairs(SwitchRenderers) do
                renderer.enabled = true
            end
        end
        
    end

    DisplayTime = DisplayTime - BL_This.SlowUpdateTime

end