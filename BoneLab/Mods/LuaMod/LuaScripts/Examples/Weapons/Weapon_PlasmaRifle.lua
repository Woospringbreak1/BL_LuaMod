--LuaBehaviour


function Start()
    print("Hello, World from lua test gun!")
end


function TriggerPulled()
    -- Note: TriggerPulled is called every frame when the trigger is held down
    -- regardless of magazine status, bullet chambered etc.

end

function OnFire()
    local Fpoint = BL_This.GetFirepointPosition()
    local Pos = Fpoint.position + Fpoint.forward*0.2--BL_Host.transform.position + (BL_Host.transform.forward*0.5)
    local Rot = BL_Host.transform.rotation;
    local ProjectileInstance = API_GameObject.BL_SpawnByBarcode("BonelabMeridian.Luamodexamplecontent.Spawnable.PlasmaProjectile", Pos, Rot) 
    return false -- return false to prevent the default firing behaviour
end