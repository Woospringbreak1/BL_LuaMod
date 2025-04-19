--LuaBehaviour

LaserMaxRange = 100

function Start()
    print("Hello, World from Mounted gun lua!")


end

function Update()
    if(BL_This == nil or not API_GameObject.BL_IsValid(BL_Host) or not BL_This.Ready) then
        print("script not ready")
        return
    end

    BL_This.AttachedGun.hammerState = HammerStates.COCKED
    if (BL_This.AttachedGun.isTriggerPulled) then
        BL_This.SetMagazineRounds(320)
        BL_This.ForceGunFire()
    end

end


function OnFire()
   return true
end