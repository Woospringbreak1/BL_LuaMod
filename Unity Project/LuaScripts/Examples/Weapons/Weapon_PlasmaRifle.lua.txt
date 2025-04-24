--LuaBehaviour


function Start()
    print("Hello, World from lua test gun!")
    GunRB = API_GameObject.BL_GetComponent(BL_Host,"Rigidbody")
end


function TriggerPulled()
    -- Note: TriggerPulled is called every frame when the trigger is held down
    -- regardless of magazine status, bullet chambered etc.

end

function OnFire()
    local Fpoint = BL_This.GetFirepointPosition()
    local Pos = Fpoint.position + Fpoint.forward*0.2--BL_Host.transform.position + (BL_Host.transform.forward*0.5)
    local Rot = BL_Host.transform.rotation;
    API_GameObject.BL_SpawnByBarcode(BL_This,"Projectile","BonelabMeridian.Luamodexamplecontent.Spawnable.PlasmaProjectile", Pos, Rot,nil, true)
    return false -- return false to prevent the default firing behaviour
end

function Update()

    if(Projectile ~= nil ) then
        local ProjectileBehaviour = API_GameObject.BL_GetComponentInChildren(Projectile,"LuaBehaviour")

        if(ProjectileBehaviour.Ready) then
            ProjectileBehaviour.CallFunction("SetOwnerGun", GunRB)
            Projectile = nil
        end
    end
end