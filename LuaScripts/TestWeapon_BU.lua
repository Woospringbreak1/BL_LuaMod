--LuaBehaviour


function Start()
    print("Hello, World from lua test gun!")
    --print("locating LuaGun")

    print("locating Rigidbody")
    TestRigidbody = API_GameObject.BL_GetComponent(BL_Host,"Rigidbody")
     print("CastTestRigidbody mass: " .. TestRigidbody.mass)
    
    print("locating LuaGun")
    Luascript = API_GameObject.BL_GetComponent(BL_Host,"LuaGun")
    print("active script: " .. Luascript.ScriptName)

end

function TriggerPulled()
    -- Note: TriggerPulled is called every frame when the trigger is held down
    -- regardless of magazine status, bullet chambered etc.

    --print("spawning projectile from Lua test gun!")
    --Pos = BL_Host.transform.position;
    --Rot = BL_Host.transform.rotation;
    --ProjectileInstance = API_GameObject.BL_SpawnByBarcode("33.33.Spawnable.PlasmaProjectile", Pos, Rot) 
end

function OnFire()
    -- Note: OnFire is called when the weapon is fired

    print("spawning projectile from Lua test gun!")
    Pos = BL_Host.transform.position + (BL_Host.transform.forward*0.2)
    Rot = BL_Host.transform.rotation;
    ProjectileInstance = API_GameObject.BL_SpawnByBarcode("33.33.Spawnable.PlasmaProjectile", Pos, Rot) 

end