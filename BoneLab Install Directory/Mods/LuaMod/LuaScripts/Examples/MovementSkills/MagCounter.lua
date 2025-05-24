

LeftHand = nil
RightHand = nil
Player = nil

function Start()
    API_Events.BL_SubscribeEvent("OnMagazineGrab",BL_This,"OnMagazineGrab")
    API_Events.BL_SubscribeEvent("OnMagazineInsert",BL_This,"OnMagazineInsert")
    API_Events.BL_SubscribeEvent("OnMagazineEject",BL_This,"OnMagazineEject")
    API_Events.BL_SubscribeEvent("OnGripDetached",BL_This,"OnGripDetached")

    
end

Magazines = {}
CurrentMag = nil
MagCounter = nil

function OnMagazineInsert(instance)
    API_GameObject.BL_SpawnByBarcode(BL_This,"MagCounter","BonelabMeridian.MagCounter.Spawnable.MagCounter", instance.transform.position, instance.transform.rotation,nil, true)
    CurrentMag = instance
end

function OnMagazineGrab(hand, instance)
    print("OnMagazineGrab " .. tostring(instance) .. " " .. tostring(instance.name))
    API_GameObject.BL_SpawnByBarcode(BL_This,"MagCounter","BonelabMeridian.MagCounter.Spawnable.MagCounter", instance.transform.position, instance.transform.rotation,nil, true)
    CurrentMag = instance
end

function OnMagazineEject(instance)
    for index,mag in ipairs(Magazines) do
        if(IsValid(mag[2]) and mag[2] == instance ) then
            API_GameObject.BL_Destroy(mag[1])
            table.remove(Magazines,index)
            break
        end

    end
end

function OnGripDetached(grip,hand)
    --print("OnGripDetached " .. tostring(grip) .. grip.name)
    for index,mag in ipairs(Magazines) do
        if(IsValid(mag[2])) then
            if((grip.gameObject.transform.root == mag[2].gameObject.transform.root) and not mag[2].isMagazineInserted) then
                API_GameObject.BL_Destroy(mag[1])
                table.remove(Magazines,index)
                break
            end
        end
    end
end

function UpdateMags()
    for index,magPair in ipairs(Magazines) do

        local magCounter = magPair[1]
        local magActual = magPair[2]

       if(IsValid(magCounter) and IsValid(magActual)) then
             local mag = magActual
            --local mag = API_GameObject.BL_GetComponent(magActual,"Magazine")
            if(mag ~= nil and mag.magazineState ~= nil) then

                local curBullets = mag.magazineState.AmmoCount
                local maxBullets = mag.magazineState.magazineData.rounds --maybe?
                local magString = tostring(curBullets) .. "/" .. tostring(maxBullets)
                local magTMP = API_GameObject.BL_GetComponent(magCounter,"TextMeshPro")
                magTMP.text = magString
                magTMP.ForceMeshUpdate() 
            end
       end
    end
end



function  OnDisable()
    for index,mag in ipairs(Magazines) do
        if(IsValid(mag[1])) then
            API_GameObject.BL_Destroy(mag[1])
        end
    end
end
 
function OnDestroy()
    for index,mag in ipairs(Magazines) do
        if(IsValid(mag[1])) then
            API_GameObject.BL_Destroy(mag[1])
        end
    end
end



function Update()

    UpdateMags()

    if(IsValid(MagCounter)) then
        MagCounter.transform.setParent(CurrentMag.transform)
        table.insert(Magazines,{MagCounter,CurrentMag}) 
        MagCounter = nil
        CurrentMag = nil
    end
end



