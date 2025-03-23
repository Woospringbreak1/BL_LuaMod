-- LuaBehaviour

--
---
-----
----
-----
----
----
---
----
----
----
----
-----
---
function Start()
    print("Initiating Proc Gen manager")

    -- Define hardcoded ProcGenBarcodes
    ProcGenBarcodes = {
        "sdf.LuaProcGen.Spawnable.Cube9",
        "sdf.LuaProcGen.Spawnable.Room1",
        "sdf.LuaProcGen.Spawnable.Room2",
        "sdf.LuaProcGen.Spawnable.Room2",
        "sdf.LuaProcGen.Spawnable.TestWorldEntryWay",
        "sdf.LuaProcGen.Spawnable.TestWorldPiece",
        "sdf.LuaProcGen.Spawnable.TestWorldPiece2",
        "sdf.LuaProcGen.Spawnable.TestWorldPiece3",
        "sdf.LuaProcGen.Spawnable.DropDown",
        "sdf.LuaProcGen.Spawnable.TestWorldPiece3"
    }

    -- Entryway barcode
    EntrywayBarcode = "sdf.LuaProcGen.Spawnable.TestWorldEntryWay"

    -- Spawn Entryway
    API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This, "Entryway", EntrywayBarcode, Vector3.one, Quaternion.identity, BL_Host, false)

    -- Spawn all prefabs dynamically
    for i, barcode in ipairs(ProcGenBarcodes) do
        API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This, "P" .. i, barcode, Vector3.one, Quaternion.identity, BL_Host, false)
    end
end


function PostStart()
    print("Running setup now that everything is loaded")

    -- Dynamically retrieve prefab variables P1, P2, ..., Pn based on ProcGenBarcodes length
    local prefabVars = {}
    for i = 1, #ProcGenBarcodes do
        local prefab = _G["P" .. i] -- Dynamically access P1, P2, ..., Pn
        if prefab then
            table.insert(prefabVars, prefab)
        end
    end

    -- Initialize ProcGenPrefabs
    ProcGenPrefabs = {}

    -- Assign prefab list dynamically
    for _, prefab in ipairs(prefabVars) do
        table.insert(ProcGenPrefabs, prefab)
    end

    -- Deactivate all prefabs
    for _, prefab in ipairs(ProcGenPrefabs) do
        prefab.SetActive(false)
    end
    EntryWayPrefab = Entryway

    print(tostring(#ProcGenPrefabs) .. " prefabs loaded " .. tostring(ProcGenPrefabs) .. " EntrywayPrefab " .. tostring(EntrywayPrefab) ..ProcGenPrefabs[1].name)
    EntryWayPrefab.SetActive(false)

    -- Call SpawnEntryPoint
    SpawnEntryPoint()
end

function SpawnEntryPoint()
    ProcGenContainer = API_GameObject.BL_CreateEmptyGameObject()
    ProcGenContainer.transform.position = API_Vector.BL_Vector3(40,40,40)
    local EntryRoom = API_GameObject.BL_InstantiateGameObject(EntryWayPrefab)
    EntryRoom.transform.parent = ProcGenContainer.transform
    EntryRoom.transform.localPosition = API_Vector.BL_Vector3(0,0,0)
    EntryRoom.SetActive(true)
    EntryRoom.transform.rotation = EntryRoom.transform.rotation * Quaternion.AngleAxis(45, Vector3.up)
    ProccessRoom(EntryRoom)
end

function GetRandomDoor(room)
    local RoomBehaviours = API_GameObject.BL_GetComponentsInChildren(room,"LuaBehaviour",true)
   
    if(RoomBehaviours == nil) then
        return nil
    end

    local Doors = {}
    
    for Behaviour in RoomBehaviours do
       -- print("tags " .. tostring(Behaviour.ScriptTags))
        if (Behaviour.ScriptTags.Contains("ProcGen_Door") and not Behaviour.ScriptTags.Contains("ProcGen_Door_Generated"))  then
           table.insert(Doors, Behaviour)
        end
    end

    if(#Doors > 0) then
        -- Pick a random door from the Doors table
        local randomDoorIndex = math.random(1, #Doors)
        local randomDoor = Doors[randomDoorIndex]
        --randomDoor.gameObject.setActive(true)
        if(string.match(randomDoor.transform.parent.name,"DoorFrame")) then
            randomDoor.transform.parent = randomDoor.transform.parent.parent
        end 
       
        return randomDoor
    else
        return nil
    end
end


function RotateVector(vector, axis, angle)
    -- Convert angle to quaternion
    local rotation = Quaternion.AngleAxis(angle, axis)
    
    -- Rotate the vector
    local rotated_vector = rotation * vector

    return rotated_vector
end




function MoveChildToTarget(A, B)
    if A == nil or B == nil then
        print("Error: A or B is nil")
        return
    end
    
    local parent = A.transform.parent
    if parent == nil then
        print("Error: A has no parent object")
        return
    end

   

    if(string.match(B.transform.parent.name,"DoorFrame")) then
        B.transform.parent = B.transform.parent.parent
    end 

    -- Get A and B's world forward vectors
    local forwardA = A.transform.forward
    local forwardB = B.transform.forward

    -- Flatten the vectors to ignore vertical differences
    forwardA.y = 0
    forwardB.y = 0

    -- Normalize them
    forwardA = forwardA.normalized
    forwardB = forwardB.normalized

    print("new door forward: " .. tostring(forwardA))
    print("existing door forward: " .. tostring(forwardB))

    -- Calculate the rotation needed to align A to B
    local angle = Vector3.SignedAngle(forwardA, -forwardB, Vector3.up)
    print("target rotation: " .. tostring(angle))

    -- Compute the offset relative to A's parent
    local AOffset = A.transform.localPosition
   -- local DoorOffset = B.transform.position
    RBounds = API_GameObject.BL_GetComponent2(A.transform.parent.gameObject,"Renderer")
    if(RBounds ~= nil) then
       -- AOffset = AOffset -  RBounds.bounds.center
    end
    local Axis = API_Vector.BL_Vector3(0, 1, 0)

    -- Rotate A's offset to match the rotation
    local RotatedAOffset = RotateVector(AOffset, Axis, angle)
    print("rotated offset: " .. tostring(RotatedAOffset))
    print("B door offset: " .. tostring(BOffset))
    
    -- Apply rotation and move parent
    parent.RotateAround(A.transform.position, Axis, angle)
    parent.position = B.transform.position - RotatedAOffset --+ 2.0*API_Vector.BL_Vector3(-0.25001,-0.3370695,9.250367)
end



-- Function to attempt spawning a room, returns true if successful, false otherwise
function AttemptSpawnRoom(door, prefab)
    local NewRoom = API_GameObject.BL_InstantiateGameObject(prefab)
    local NewDoor = GetRandomDoor(NewRoom)

    if not NewDoor then
        API_GameObject.BL_DestroyGameObject(NewRoom)
        return false
    end

    NewDoor.ScriptTags.Add("ProcGen_Door_Generated")    
    MoveChildToTarget(NewDoor,door)

    BoxCol = API_GameObject.BL_GetComponent2(NewRoom,"BoxCollider")

    if(BoxCol == nil) then
        print("main collider not found")
        return false

    end

    local colliders = Physics.OverlapBox(NewRoom.transform:TransformPoint(BoxCol.center),BoxCol.size*0.5*1.3,NewRoom.transform.rotation)
    local objects = {}

    for f in colliders do
        local obj = f.gameObject
        if (obj ~= NewRoom and not obj.transform:IsChildOf(NewRoom.transform) and obj ~= door and not obj.transform:IsChildOf(door.transform.parent) ) then
            print("Collision detected " .. obj.name .. " ")
            API_GameObject.BL_DestroyGameObject(NewRoom)
            return false
        end
    end


    NewRoom.SetActive(true)

    local DoorLuaBeh = API_GameObject.BL_GetComponent2(door.gameObject,"LuaBehaviour")
    DoorLuaBeh.ScriptTags.Add("ProcGen_Door_Generated");

    return true
end

function SpawnRoomForDoor(door, forcespawn)
    -- Create a shuffled copy of ProcGenPrefabs to avoid bias
    local shuffledPrefabs = {}
    for i, prefab in ipairs(ProcGenPrefabs) do
        table.insert(shuffledPrefabs, { prefab = prefab, barcode = ProcGenBarcodes[i] })
    end

    -- Fisher-Yates shuffle to randomize the order
    for i = #shuffledPrefabs, 2, -1 do
        local j = math.random(i)
        shuffledPrefabs[i], shuffledPrefabs[j] = shuffledPrefabs[j], shuffledPrefabs[i]
    end

    -- Try to spawn a room from the shuffled list
    for _, entry in ipairs(shuffledPrefabs) do
        if AttemptSpawnRoom(door, entry.prefab) then
            return true
        else
            print("failed to spawn room - trying again")
        end
    end

    return false -- No room could be spawned
end



function ProccessRoom(room)

    local RoomExitCount = 0

    local RoomBehaviours = API_GameObject.BL_GetComponentsInChildren(room,"LuaBehaviour",true)
    local RoomBehaviourMain = API_GameObject.BL_GetComponent2(room,"LuaBehaviour")
    RoomBehaviourMain.ScriptTags.Add("ProcGen_Section_Generated")
    print("length of RoomBehaviours" .. tostring(RoomBehaviours) )

    local Doors = {}

    for Behaviour in RoomBehaviours do
        print("tags " .. tostring(Behaviour.ScriptTags) .. tostring(Behaviour.ScriptTags.Count))
        if (Behaviour.ScriptTags.Contains("ProcGen_Door")) then
            if(not Behaviour.ScriptTags.Contains("ProcGen_Door_Generated")) then
                table.insert(Doors, Behaviour)
                print(Behaviour.name .. " is a door")
            else
                print(Behaviour.name .. " door already used")
            end
        end
    end

    if(#Doors == 0) then
        print("no ungenerated doors for " .. room.name)
        return false
    end

    for i, Door in ipairs(Doors) do
        local isLast = (i == #Doors and RoomExitCount==0) -- Check if this is the last door in the list
        if(SpawnRoomForDoor(Door, isLast)) then
        Door.ScriptTags.Add("ProcGen_Door_Generated")
           RoomExitCount = RoomExitCount + 1
            print("spawned a new room")
        else
            print("failed to spawn")
            Door.CallFunction("Block")
        end
    end

   return true
    

end


PostStartRan = false
function Update()
    if not PostStartRan then
        -- Check if all prefabs are loaded
        local allLoaded = true

        for i = 1, #ProcGenBarcodes do
            local prefabVar = _G["P" .. i] -- Dynamically access P1, P2, ..., Pn
            if prefabVar == nil then
                print("Prefab " .. prefabVar .. " not loaded yet")
                allLoaded = false
                break
            end
        end

        -- Ensure Entryway is also loaded
        if Entryway == nil then
            print("Entryway" .. " not loaded yet")
            allLoaded = false
        end

        -- Run PostStart when everything is loaded
        if allLoaded then
            PostStart()
            PostStartRan = true
        else
            print("Waiting for all prefabs to load...")
        end
    end
end

function AllDoorsReady(room)
    local RoomBehaviours = API_GameObject.BL_GetComponentsInChildren(room.gameObject,"LuaBehaviour",true)
 
    for Behaviour in RoomBehaviours do
        if (Behaviour.ScriptTags.Contains("ProcGen_Door")) then
            print("DOOR FOUND")
            if(not Behaviour.ScriptTags.Contains("ProcGen_Door_Ready")) then
                print(Behaviour.name .. " door not ready")
                return false    
            end
        end
    end
    return true
end


SearchRadius = 20.0
function SlowUpdate()
    --print("running slow update on " .. BL_Host.name)
    local PlayerPos = API_Input.BL_LeftHand().transform.position --API_Player.BL_GetAvatarPosition()
    --print("playerpos " .. tostring(PlayerPos))
    if(PlayerPos ~= nil) then
        local colliders = Physics.OverlapSphere(PlayerPos, SearchRadius)
        --print("number of colliders detected " .. tostring(colliders.Length))
        for f in colliders do
            local obj = f.gameObject
            local Behaviour = API_GameObject.BL_GetComponentInChildren(obj.transform.root.gameObject,"LuaBehaviour")
            
          --  if(Behaviour ~= nil) then
            --    local BehaviourTags = Behaviour.ScriptTags
               -- print(Behaviour.name .. " ScriptTags " .. tostring(BehaviourTags) .. " Length " .. #BehaviourTags )
               
            --    for i = 0, Behaviour.ScriptTags.Count - 1 do
                   -- print("tag " .. tostring(i + 1) .. " " .. Behaviour.ScriptTags[i])  -- Convert 0-based to Lua's 1-based index
            --    end


          --  end


            if(Behaviour ~= nil and Behaviour.ScriptTags.Contains("ProcGen_Section")) then
                if(not Behaviour.ScriptTags.Contains("ProcGen_Section_Generated")) then
                    ProccessRoom(Behaviour.gameObject)
                end
            end
        end

    end
end