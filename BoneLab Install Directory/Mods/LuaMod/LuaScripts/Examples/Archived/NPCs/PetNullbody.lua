
function Start()
   
    BL_This.AttachedNPCBehaviour.displayNavpath = true
    
end


function OnDeath()
    print("OnDeath")
end

function OnResurrection()
    print("OnResurrection")
end

function LocateTargets()
    local position = BL_Host.transform.position

    -- Debug prints
    --print("position " .. tostring(position))
    --print("SearchRadius " .. tostring(SearchRadius))
    --print("Physics.OverlapSphere " .. tostring(Physics.OverlapSphere))

    -- Get colliders within the sphere
    local colliders = Physics.OverlapSphere(position, SearchRadius)
    local objects = {}


    for f in colliders do
        local obj = f.gameObject
        if (obj ~= TurretParent and not obj.transform:IsChildOf(TurretParent.transform)) then
            local distance = (obj.transform.position - position).sqrMagnitude
            table.insert(objects, { obj = obj, distance = distance })
        end
    end


-- If no valid objects remain after filtering, return
if #objects == 0 then
    --print("No valid objects found in sphere.")
    return
end

-- Sort the table by distance
table.sort(objects, function(a, b) return a.distance < b.distance end)

-- Iterate and print the sorted objects
for i = 1, #objects do
    --print("Object: " .. objects[i].obj.name .. ", Distance: " .. objects[i].distance)
    npc = API_GameObject.BL_GetComponentInChildren(objects[i].obj.transform.root.gameObject,"AIBrain")
    if(npc ~= nil and not npc.isDead) then
        Target = npc
        TargetRenderer = API_GameObject.BL_GetComponentInChildren(objects[i].obj.transform.root.gameObject,"Renderer")
        --print("setting target to: " .. npc.name)
        return
    end

end
    
   

end


function SlowUpdate()
    PlayerHand = API_Input.BL_LeftHand()

    if(PlayerHand ~= nil ) then
        BL_This.AttachedNPCBehaviour.navTarget = PlayerHand.transform.position
        print("PLayer position " .. tostring(PlayerHand.transform.position)) 
        BL_This.AttachedNPCBehaviour.EnableNav()
    end
    
end

function FixedUpdate()
    --print("lua turret fixed up
end

function OnEnable()
    print("OnEnable")
end

function OnDisable()
    print("OnDisable")
end

function OnDestroy()
    print("OnDestroy")
end
