-- LuaBehaviour
function Start()
    LineRenderer = API_GameObject.BL_GetComponent(BL_Host,"LineRenderer")
end

function OnDestroy()

end

function ToLuaTable(wrapper)
    local t = {}
    local index = 1

    -- MoonSharp EnumerableWrapper supports ipairs-style iteration
    for _,value in ipairs(wrapper) do
        t[index] = value
        index = index + 1
    end

    return t
end

function SetOwnerGun(owner)
    OwnerGun = owner
    OwnerGunRB = API_GameObject.BL_GetComponent(OwnerGun.gameObject,"Rigidbody")
end

function MarkArcFinished()
    print("generating arc")
    ArcFinished = true
    ChainLinks = ToLuaTable(API_GameObject.BL_GetComponentsInChildren(BL_Host,"LuaBehaviour"))
    print("arc length: " .. tostring(#ChainLinks))

    for index, value in ipairs(ChainLinks) do       
        if(LastLink ~= nil) then
            LinkProjectiles(LastLink,value)    
        end
        
        LastLink = value
    end

end

LastLink = nil
function Update()
    if(ArcFinished and ChainLinks ~= nil) then
        LineRenderer.positionCount = #ChainLinks
        for index, value in ipairs(ChainLinks) do
            LineRenderer.SetPosition(index-1,value.transform.position)
            --print(tostring(index) .. " set up? " .. tostring(value.GetScriptVariable("OwnerGun")~=nil))
        end
    end
end


function LinkProjectiles(a,b)
    --set up a length-limited joint between the projectile and the player
    local RopeLength = (a.transform.position - b.transform.position).magnitude

    
    local RopeJoint = API_GameObject.BL_AddComponent(a,"ConfigurableJoint")

    RopeJoint.connectedBody = API_GameObject.BL_GetComponent(b,"Rigidbody")
    RopeJoint.xMotion = ConfigurableJointMotion.Limited
    RopeJoint.yMotion = ConfigurableJointMotion.Limited    
    RopeJoint.zMotion = ConfigurableJointMotion.Limited  

    RopeJoint.angularXMotion = ConfigurableJointMotion.Locked
    RopeJoint.angularYMotion = ConfigurableJointMotion.Locked
    RopeJoint.angularZMotion = ConfigurableJointMotion.Locked   


    local Ropelimit =RopeJoint.linearLimit
    Ropelimit.limit = RopeLength
    RopeJoint.linearLimit = Ropelimit

    RopeJoint.enableCollision = false 
    RopeJoint.autoConfigureConnectedAnchor = false
    RopeJoint.connectedAnchor = API_Vector.BL_Vector3(0,0,0)
    RopeJoint.anchor = API_Vector.BL_Vector3(0,0,0)

end

