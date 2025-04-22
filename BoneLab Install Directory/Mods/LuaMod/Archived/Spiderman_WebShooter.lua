--LuaBehaviour


function Start()
    print("Hello, World from Spiderman_Webshooter!")
    --print("locating LuaGun")

    print("locating Rigidbody")
    TestRigidbody = API_GameObject.BL_GetComponent2(BL_Host,"Rigidbody")
     print("CastTestRigidbody mass: " .. TestRigidbody.mass)
    
    print("locating LuaGun")
    Luascript = API_GameObject.BL_GetComponent2(BL_Host,"LuaGun")
    print("active script: " .. Luascript.ScriptName)
end



function TriggerPulled()
    -- Note: TriggerPulled is called every frame when the trigger is held down
    -- regardless of magazine status, bullet chambered etc.

end

WebShooterProjectiles = {}
function Update()
    if(WebProjectile ~= nil ) then
        local WebProjectileBehaviour = API_GameObject.BL_GetComponentInChildren(WebProjectile,"LuaBehaviour")

        if(WebProjectileBehaviour.Ready) then
            local suc = WebProjectileBehaviour.CallFunction("SetOwnerGun", BL_This)
            table.insert(WebShooterProjectiles,WebProjectileBehaviour)
            WebProjectile = nil
        else
            print("webshooter projectile not ready")
        end
    end

    if(not BL_This.AttachedGun.isTriggerPulled) then
        for _,webproj in pairs(WebShooterProjectiles) do
            API_GameObject.BL_DestroyGameObject(webproj.gameObject)
        end
        WebShooterProjectiles = {}
    end
end

function OnFire()
    -- Note: OnFire is called when the weapon is fired

    print("spawning projectile from spiderman webshooter!")
    Fpoint = Luascript.GetFirepointPosition()
    Pos = Fpoint.position + Fpoint.forward*0.5--BL_Host.transform.position + (BL_Host.transform.forward*0.5)
    Rot = BL_Host.transform.rotation;
    API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This,"WebProjectile","33.33.Spawnable.SpidermanWebProjectile", Pos, Rot,nil, true)

    return false;

end