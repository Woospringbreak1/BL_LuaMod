--prevent spawning dev tools or avatar changing
function  Start()
    API_Events.BL_SubscribeEvent("OnSwitchAvatarPrefix", BL_This, "OnSwitchAvatarPrefix")
    API_Events.BL_SubscribeEvent("OnSwitchAvatarPostfix", BL_This, "OnSwitchAvatarPostfix")
    API_Events.BL_SubscribeEvent("OnDevToolSpawned", BL_This, "OnDevToolSpawned")

    AvatarBarcode = "SLZ.BONELAB.Core.Avatar.PeasantFemaleA"
   
end


function OnSwitchAvatarPrefix(avatar)

end

FlagAvatarChanged = false
function OnSwitchAvatarPostfix(avatar)
    --note: this call is too early - checking the avatar will return the old one
    FlagAvatarChanged = true
end




function OnDevToolSpawned(devtool)
    --API_GameObject.BL_Destroy(devtool.gameObject)
end

BodyLog = nil
function Update()

   if(FlagAvatarChanged) then
    if(API_Player.BL_GetAvatarBarcode() ~= AvatarBarcode) then
        print("setting avatar back to "..AvatarBarcode)
        API_Player.BL_SetAvatar(AvatarBarcode)
        BodyLog = nil
    end
    FlagAvatarChanged = false
   

    

    --disable the bodylog 
        if(BodyLog == nil or BodyLog.activeInHierarchy) then
            BodyLog = API_Player.BL_GetBodyLog()
            if(BodyLog ~= nil) then
                print("Disabling BodyLog")
                BodyLog.SetActive(false)
            end
        end

    end
        

end
