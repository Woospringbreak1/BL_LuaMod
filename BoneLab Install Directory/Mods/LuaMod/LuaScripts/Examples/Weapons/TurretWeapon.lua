--LuaBehaviour


function Start()
   -- print("Hello, World from the turret gun!")
    --print("locating LuaGun")

   -- print("locating Rigidbody")
    TestRigidbody = API_GameObject.BL_GetComponent(BL_Host,"Rigidbody")
     print("CastTestRigidbody mass: " .. TestRigidbody.mass)
    
   -- print("locating LuaGun")
    Luascript = API_GameObject.BL_GetComponent(BL_Host,"LuaGun")
   -- print("active script: " .. Luascript.ScriptName)

    
end

function Update()
    if (API_Input.BL_IsKeyDown(97)) then
       if(Luascript ~= nil and Luascript.AttachedGun ~= nil) then
            Luascript.SetMagazineRounds(32)
            Luascript.ForceGunFire()
       end
    end
end


function TriggerPulled()
    -- Note: TriggerPulled is called every frame when the trigger is held down
    -- regardless of magazine status, bullet chambered etc.

end

function OnFire()
    -- Note: OnFire is called when the weapon is fired
    -- return true to allow the gun to fire normally
    --print("spawning projectile from turret gun!")
    Fpoint = Luascript.GetFirepointPosition()

    Pos = Fpoint.position + Fpoint.forward*0.2--BL_Host.transform.position + (BL_Host.transform.forward*0.5)
    Rot = Fpoint.rotation--BL_Host.transform.rotation;
    ProjectileInstance = API_GameObject.BL_SpawnByBarcode("BonelabMeridian.Luamodexamplecontent.Spawnable.PlasmaProjectile", Pos, Rot) 
    return false
end