
function Start()
    Doorframe = BL_Host.transform.parent.gameObject
    Renderer = API_GameObject.BL_GetComponent2(BL_Host,"Renderer")
    Blockers = API_GameObject.BL_FindInChildren(Doorframe,"Blockers").gameObject
    Doors = API_GameObject.BL_FindInChildren(Doorframe,"Doors").gameObject

    Blocked = false
    DoorSpaned = false
    

    Blockers.setActive(false)
    Doors.setActive(false)
    Renderer.enabled = false

   -- BL_Host.transform.parent = BL_Host.transform.parent.parent
    BL_This.ScriptTags.Add("ProcGen_Door_Ready")
end

function SpawnDoor()
--spawn an interactable door 
    Doors.setActive(true)
end

function Block()
--block this door so the player can't pass
    print("attempting to block door")
    if(not Blocked) then
        Blocked = true
        Blockers.setActive(true)

    end
end


function PrintChildren(gameObject)
    if gameObject == nil then
        print("GameObject is nil!")
        return
    end
    print("printing children: ")
    local transform = gameObject.transform
    for i = 0, transform.childCount - 1 do
        local child = transform:GetChild(i)
        print(child.name)
    end
end

