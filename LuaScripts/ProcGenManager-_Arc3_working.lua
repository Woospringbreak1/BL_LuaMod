-- LuaBehaviour

--
---
-----
----
-----
----
---- 15/3/25 TODO: NEED TO FINISH DRAFT BACKROOM ROOMS - NO COLLIDERS OR LuaBehaviours!
----
---
----
----
----
----
-----
---
function Start()
    print("initiating Proc Gen manager")

    ProcGenBarcodes = {}
    ProcGenBarcodes[1] = "sdf.LuaProcGen.Spawnable.Cube9"
    ProcGenBarcodes[2] = "sdf.LuaProcGen.Spawnable.Room1"
    ProcGenBarcodes[3] = "sdf.LuaProcGen.Spawnable.Room2"
    ProcGenBarcodes[4] = "sdf.LuaProcGen.Spawnable.Room2"
    ProcGenBarcodes[5] = "sdf.LuaProcGen.Spawnable.TestWorldEntryWay"
    ProcGenBarcodes[6] = "sdf.LuaProcGen.Spawnable.TestWorldPiece"
    ProcGenBarcodes[7] = "sdf.LuaProcGen.Spawnable.TestWorldPiece2"
    ProcGenBarcodes[8] = "sdf.LuaProcGen.Spawnable.TestWorldPiece3"
    EntrywayBarcode = "sdf.LuaProcGen.Spawnable.TestWorldEntryWay"
    API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This,"Entryway",EntrywayBarcode,Vector3.one, Quaternion.identity,BL_Host,false) 
    API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This,"P1",ProcGenBarcodes[1],Vector3.one, Quaternion.identity,BL_Host,false) 
    API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This,"P2",ProcGenBarcodes[2],Vector3.one, Quaternion.identity,BL_Host,false) 
    API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This,"P3",ProcGenBarcodes[3],Vector3.one, Quaternion.identity,BL_Host,false) 
    API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This,"P4",ProcGenBarcodes[4],Vector3.one, Quaternion.identity,BL_Host,false) 
    API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This,"P5",ProcGenBarcodes[5],Vector3.one, Quaternion.identity,BL_Host,false) 
    API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This,"P6",ProcGenBarcodes[6],Vector3.one, Quaternion.identity,BL_Host,false) 
    API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This,"P7",ProcGenBarcodes[7],Vector3.one, Quaternion.identity,BL_Host,false) 
    API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This,"P8",ProcGenBarcodes[8],Vector3.one, Quaternion.identity,BL_Host,false) 

    

end

function PostStart()
    
    print("running setup now that everything is loaded")
    print("P1 " .. tostring(P1) .. " " .. P1.name)
    print("P2 " .. tostring(P2) .. " " .. P2.name)


    ProcGenPrefabs = {}
    ProcGenPrefabs[1] = P1
    ProcGenPrefabs[2] = P2
    ProcGenPrefabs[3] = P3
    ProcGenPrefabs[4] = P4
    ProcGenPrefabs[5] = P5
    ProcGenPrefabs[6] = P6
    ProcGenPrefabs[7] = P7
    ProcGenPrefabs[8] = P8


    EntryWayPrefab = Entryway
    
    ProcGenPrefabs[1].SetActive(false)
    ProcGenPrefabs[2].SetActive(false)
    ProcGenPrefabs[3].SetActive(false)
    ProcGenPrefabs[4].SetActive(false)
    ProcGenPrefabs[5].SetActive(false)
    ProcGenPrefabs[6].SetActive(false)
    ProcGenPrefabs[7].SetActive(false)
    ProcGenPrefabs[8].SetActive(false)
    EntryWayPrefab.SetActive(false)
    SpawnEntryPoint()

end

function SpawnEntryPoint()
    ProcGenContainer = API_GameObject.BL_CreateEmptyGameObject()
    ProcGenContainer.transform.position = API_Vector.BL_Vector3(40,40,40)
    local EntryRoom = API_GameObject.BL_InstantiateGameObject(EntryWayPrefab)
    EntryRoom.transform.parent = ProcGenContainer.transform
    EntryRoom.transform.localPosition = API_Vector.BL_Vector3(0,0,0)
    EntryRoom.SetActive(true)
   -- EntryRoom.transform.rotation = EntryRoom.transform.rotation * Quaternion.AngleAxis(45, Vector3.up)
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

    --B.transform.parent = B.transform.parent.parent

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





function SpawnRoomForDoor(door,forcespawn)
    --either spawn a room for this door or return false to block it
    local randomIndex = math.random(1, #ProcGenPrefabs)
    local selectedPrefab = ProcGenPrefabs[randomIndex]
    local selectedBarcode = ProcGenBarcodes[randomIndex]

     local NewRoom = API_GameObject.BL_InstantiateGameObject( selectedPrefab)
   
    local NewDoor = GetRandomDoor(NewRoom)
    NewDoor.ScriptTags.Add("ProcGen_Door_Generated")    
    MoveChildToTarget(NewDoor,door)
    --NewRoom.transform.parent = ProcGenContainer.transform
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

function GetBoundsWithTempEnable(obj)
    -- Store the original active state
    local wasActive = obj.activeSelf
    obj:SetActive(true) -- Use ":" for method calls in Lua

    -- Get all renderers and colliders
    local Renderers = API_GameObject.BL_GetComponentsInChildren(obj, "Renderer")
    local Colliders = API_GameObject.BL_GetComponentsInChildren(obj, "Collider")

    -- Create an empty bounds at the object's position
    local bounds = Bounds(obj.transform.position, Vector3.zero) -- No 'new' keyword in Lua
    local hasBounds = false

    -- Encapsulate bounds for all renderers
    for _, Renderer in ipairs(Renderers) do
        if Renderer and Renderer.bounds then
            bounds:Encapsulate(Renderer.bounds)
            hasBounds = true
        end
    end

    -- Encapsulate bounds for all colliders
    for _, Collider in ipairs(Colliders) do
        if Collider and Collider.bounds then
            bounds:Encapsulate(Collider.bounds)
            hasBounds = true
        end
    end

    -- Restore original active state
    obj:SetActive(wasActive)

    -- Return the computed bounds
    return hasBounds and bounds or nil -- Return nil if no bounds were found
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

    --SpawnRoomForDoor(Doors[1], false)
    --SpawnRoomForDoor(Doors[2], false)
    --SpawnRoomForDoor(Doors[3], false)
    --SpawnRoomForDoor(Doors[4], false)



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

    if(not PostStartRan) then
        if(P1 ~= nil and P2 ~= nil and P3 ~= nil and  P4 ~= nil and P5 ~= nil and P6 ~= nil and P7 ~= nil and P8 ~= nil and Entryway ~= nil) then
        PostStart()
        PostStartRan = true
        else
            print("waiting for all prefabs to load")
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