
function Start()
    Doorframe = BL_Host.transform.parent.gameObject
    Renderer = API_GameObject.BL_GetComponent(BL_Host,"Renderer")
    Blockers = API_GameObject.BL_FindInChildren(Doorframe,"Blockers")
    Doors = API_GameObject.BL_FindInChildren(Doorframe,"Doors")

    Blocked = false
    DoorSpaned = false
    
    Blockers.setActive(false)
    --Doors.setActive(false)
    Renderer.enabled = false

   -- BL_Host.transform.parent = BL_Host.transform.parent.parent
    BL_This.ScriptTags.Add("ProcGen_Door_Ready")


    --hacky bug fix - vents are always blocked. fix later.
    if(BL_This.ScriptTags.Contains("DOORTYPE_VENT")) then
        Block()
        BL_This.ScriptTags.Add("ProcGen_Door_Generated")
        print("blocking vent on spawn")
    end

end

function SpawnDoor()
--spawn an interactable door 
    Doors.setActive(true)
end

function Block()
--block this door so the player can't pass
    print("attempting to block door")
    Blocked = true
    Blockers.setActive(true)
end


