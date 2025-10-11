MonsterBehaviour = nil
lookVector = nil
NPCAnimator = nil

function Update()
    if(not IsValid(MonsterBehaviour)) then
        MonsterBehaviour = API_GameObject.BL_GetComponent(BL_Host.transform.root.gameObject, "LuaBehaviour")
        return
    end

    if(not IsValid(NPCAnimator)) then
        NPCAnimator =API_GameObject.BL_GetComponent(BL_Host, "Animator")
        return
    end

    lookVector = MonsterBehaviour.GetScriptVariable("lookVector")  

end

function OnAnimatorIK(layerIndex)

    if(lookVector == nil) then
        print("waiting on lookVector")
        return
    end

    if(not IsValid(NPCAnimator)) then
        print("waiting on NPCAnimator")
        return
    end


    --print ("looking at " .. tostring(lookVector.x) .. " " .. tostring(lookVector.y) .. " " .. tostring(lookVector.z))
    NPCAnimator.SetLookAtPosition(lookVector)
    NPCAnimator.SetLookAtWeight(1.0,0.5,0.5,0.5,0.5)

end