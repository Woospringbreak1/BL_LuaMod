--LuaBehaviour


function Start()
    print("Hello, World from the minigun!")
    --print("locating LuaGun")

    print("locating Rigidbody")
    TestRigidbody = API_GameObject.BL_GetComponent(BL_Host,"Rigidbody")
     print("CastTestRigidbody mass: " .. TestRigidbody.mass)
    
    print("locating LuaGun")
    Luascript = API_GameObject.BL_GetComponent(BL_Host,"LuaGun")
    print("active script: " .. Luascript.ScriptName)
   
    Luascript.SetMagazineRounds(32)
    TrailRend = API_GameObject.BL_AddComponent(BL_Host,"TrailRenderer")

    SpinCylinder = API_GameObject.BL_FindInChildren(BL_Host,"SpinCylinder").gameObject
    SpinCylinderJoint = API_GameObject.BL_GetComponent(SpinCylinder,"ConfigurableJoint")
    
    
end

MaxSpinSpeed = 100.0
CurrentSpeed = 0.0
function Update()

    if(SpinCylinderJoint == nil) then
        print("SpinCylinderJoint is nil")
        return
    end 

    --print(CurrentSpeed .. " current speed?")

    if(BL_This.AttachedGun.isTriggerPulled) then
        
        if(CurrentSpeed <= MaxSpinSpeed) then
            CurrentSpeed = CurrentSpeed + 0.1
            SpinCylinderJoint.targetAngularVelocity = API_Vector.BL_Vector3(CurrentSpeed,CurrentSpeed,CurrentSpeed)
            print("Spinning up minigun to: " .. tostring(CurrentSpeed))
        end
    else
        if(CurrentSpeed > 0) then
            CurrentSpeed = CurrentSpeed - 0.1
            SpinCylinderJoint.targetAngularVelocity = API_Vector.BL_Vector3(CurrentSpeed,CurrentSpeed,CurrentSpeed)
            print("Slowing minigun to: " .. tostring(CurrentSpeed))
        end
    end
    

    if (API_Input.BL_IsKeyDown(99)) then
       if(Luascript ~= nil and Luascript.AttachedGun ~= nil) then
            Luascript.AttachedGun.
            Luascript.SetMagazineRounds(32)
            Luascript.ForceGunFire()
            
       end
    end
end


function TriggerPulled()
    -- Note: TriggerPulled is called every frame when the trigger is held down
    -- regardless of magazine status, bullet chambered etc.
    Luascript.AttachedGun.isCharged = true
   
end

function OnFire()
    -- Note: OnFire is called when the weapon is fired
    -- return true to allow the gun to fire normally
    Luascript.SetMagazineRounds(32)
    print("spawning projectile from minigun!")
    Fpoint = Luascript.GetFirepointPosition()

    Pos = Fpoint.position + Fpoint.forward*0.2--BL_Host.transform.position + (BL_Host.transform.forward*0.5)
    Rot = Fpoint.rotation--BL_Host.transform.rotation;
    ProjectileInstance = API_GameObject.BL_SpawnByBarcode("BonelabMeridian.Luamodexamplecontent.Spawnable.PlasmaProjectile", Pos, Rot) 
    return false
end