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
--require("WeightedList.lua")
function Start()
    print("Initiating Proc Gen manager")

    -- Define hardcoded ProcGenBarcodes
    ProcGenBarcodes = {
       
       -- "BonelabMeridian.Luamodexamplecontent.Spawnable.PROCGENVentBase",
        --"BonelabMeridian.Luamodexamplecontent.Spawnable.PROCGENVentDrop",
       -- "BonelabMeridian.Luamodexamplecontent.Spawnable.PROCGENVentCorner",
        "BonelabMeridian.Luamodexamplecontent.Spawnable.PROCGENVentBase",
        "BonelabMeridian.Luamodexamplecontent.Spawnable.PROCGENSpawnRoom",
        "BonelabMeridian.Luamodexamplecontent.Spawnable.PROCGENSmallOffice",
        "BonelabMeridian.Luamodexamplecontent.Spawnable.PROCGENShortHallway2",
        "BonelabMeridian.Luamodexamplecontent.Spawnable.PROCGENShortHallway",
        "BonelabMeridian.Luamodexamplecontent.Spawnable.PROCGENLongHallwayVent",
        "BonelabMeridian.Luamodexamplecontent.Spawnable.PROCGENLongHallway",
        "BonelabMeridian.Luamodexamplecontent.Spawnable.PROCGENLargeRoomBase",
        "BonelabMeridian.Luamodexamplecontent.Spawnable.PROCGENLarge4DoorRoom",
        "BonelabMeridian.Luamodexamplecontent.Spawnable.PROCGENHallwayShort",
        "BonelabMeridian.Luamodexamplecontent.Spawnable.PROCGENDropDown",
        "BonelabMeridian.Luamodexamplecontent.Spawnable.PROCGENCorner2",
        "BonelabMeridian.Luamodexamplecontent.Spawnable.PROCGENBreakDown",
        "BonelabMeridian.Luamodexamplecontent.Spawnable.PROCGEN4DoorRoom",
        "BonelabMeridian.Luamodexamplecontent.Spawnable.PROCGEN3DoorTallHallway"
    }

    SpawnedSections = {}
    -- Entryway barcode
    EntrywayBarcode = "BonelabMeridian.Luamodexamplecontent.Spawnable.PROCGENSpawnRoom"

    -- Spawn Entryway
    API_GameObject.BL_SpawnByBarcode(BL_This, "Entryway", EntrywayBarcode, Vector3.one, Quaternion.identity, BL_Host, false)

    -- Spawn all prefabs dynamically
    for i, barcode in ipairs(ProcGenBarcodes) do
        API_GameObject.BL_SpawnByBarcode(BL_This, "P" .. i, barcode, Vector3.one, Quaternion.identity, BL_Host, false)
    end
end


function PostStart()
    --print("Running setup now that everything is loaded")

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

    --print(tostring(#ProcGenPrefabs) .. " prefabs loaded " .. tostring(ProcGenPrefabs) .. " EntrywayPrefab " .. tostring(EntrywayPrefab) ..ProcGenPrefabs[1].name)
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
    --EntryRoom.transform.rotation = EntryRoom.transform.rotation * Quaternion.AngleAxis(45, Vector3.up)
    EntryRoomBoxCol = API_GameObject.BL_GetComponent(EntryRoom,"BoxCollider")
    API_Player.BL_SetAvatarPosition(EntryRoomBoxCol.bounds.center)
    ProccessRoom(EntryRoom)

end

function GetRandomDoor(existingDoor, room)
    local RoomBehaviours = API_GameObject.BL_GetComponentsInChildren(room,"LuaBehaviour",true)
   
    if(RoomBehaviours == nil) then
        return nil
    end

    local Doors = {}
    local existingDoorType = "DOORTYPE_UNDEFINED"

    for i = 0, existingDoor.ScriptTags.Count - 1 do
        if(existingDoor.ScriptTags[i]:find("DOORTYPE_")) then
            existingDoorType = existingDoor.ScriptTags[i]
        end
    end


    if(existingDoorType == "DOORTYPE_VENT_VERT_DOWN") then
        existingDoorType = "DOORTYPE_VENT_VERT_UP" --lazy fix, but avoids mirrored components
    elseif(existingDoorType == "DOORTYPE_VENT_VERT_UP") then
        existingDoorType = "DOORTYPE_VENT_VERT_DOWN" 
    end

    
    for _,Behaviour in ipairs(RoomBehaviours) do
       -- print("tags " .. tostring(Behaviour.ScriptTags))
        if (Behaviour.ScriptTags.Contains("ProcGen_Door") and Behaviour.ScriptTags.Contains(existingDoorType) and not Behaviour.ScriptTags.Contains("ProcGen_Door_ExitOnly") and not Behaviour.ScriptTags.Contains("ProcGen_Door_Generated")  )  then
           table.insert(Doors, Behaviour)
        else
            --print("Incompatible door type with: " .. tostring(existingDoorType))
        end
    end

    if(#Doors > 0) then
        -- Pick a random door from the Doors table
        local randomDoorIndex = math.random(1, #Doors)
        local randomDoor = Doors[randomDoorIndex]
        --randomDoor.gameObject.setActive(true)
        if(string.match(randomDoor.transform.parent.name,"DoorFrame") or string.match(randomDoor.transform.parent.name,"VentFrame") ) then
            randomDoor.transform.parent = randomDoor.transform.root
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
        B.transform.parent = B.transform.root
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

   -- print("new door forward: " .. tostring(forwardA))
    --print("existing door forward: " .. tostring(forwardB))

    -- Calculate the rotation needed to align A to B
    local angle = Vector3.SignedAngle(forwardA, -forwardB, Vector3.up)
    --print("target rotation: " .. tostring(angle))

    -- Compute the offset relative to A's parent
    local AOffset = A.transform.localPosition
   -- local DoorOffset = B.transform.position
    local RBounds = API_GameObject.BL_GetComponent(A.transform.parent.gameObject,"Renderer")
    if(RBounds ~= nil) then
       -- AOffset = AOffset -  RBounds.bounds.center
    end
    local Axis = API_Vector.BL_Vector3(0, 1, 0)

    -- Rotate A's offset to match the rotation
    local RotatedAOffset = RotateVector(AOffset, Axis, angle)
    --print("rotated offset: " .. tostring(RotatedAOffset))
    --print("B door offset: " .. tostring(BOffset))
    
    -- Apply rotation and move parent
    parent.RotateAround(A.transform.position, Axis, angle)
    parent.position = B.transform.position - RotatedAOffset
end



-- Function to attempt spawning a room, returns true if successful, false otherwise
function AttemptSpawnRoom(door, prefab)
    local NewRoom = API_GameObject.BL_InstantiateGameObject(prefab)
    local NewDoor = GetRandomDoor(door,NewRoom)

    --print("attempting to spawn " .. prefab.name)
    if (NewDoor == nil or not IsValid(NewDoor)) then
        print("ERROR - NO DOOR FOUND - DESTROYING NewRoom " .. NewRoom.name)
        API_GameObject.BL_Destroy(NewRoom)
        return false
    end

    NewDoor.ScriptTags.Add("ProcGen_Door_Generated")      
    MoveChildToTarget(NewDoor,door)

    BoxCol = API_GameObject.BL_GetComponent(NewRoom,"BoxCollider")

    if(BoxCol == nil) then
        print("main collider not found")
        return false

    end

    local colliders = Physics.OverlapBox(NewRoom.transform:TransformPoint(BoxCol.center),BoxCol.size*0.5*1.3,NewRoom.transform.rotation,-1,true)
    local objects = {}

    for f in colliders do
        local obj = f.gameObject
        if (obj ~= NewRoom and not obj.transform:IsChildOf(NewRoom.transform) and obj ~= door and not obj.transform:IsChildOf(door.transform.root) and not string.find(obj.name,"SW_Ventilation_Cap") ) then
            --print("Collision detected " .. obj.name .. " ")
            API_GameObject.BL_Destroy(NewRoom)
            return false
        end
    end


    NewRoom.SetActive(true)
    local existingRoom = door.transform.root.gameObject
    local newRoomZoneLink = API_GameObject.BL_GetComponent(NewRoom,"ZoneLink")
    local existingRoomZoneLink = API_GameObject.BL_GetComponent(existingRoom,"ZoneLink")

    if(IsValid(newRoomZoneLink) and IsValid(existingRoomZoneLink)) then
        
        API_Utils.BL_AppendToArray(newRoomZoneLink, "zoneLinks",existingRoomZoneLink)
        API_Utils.BL_AppendToArray(existingRoomZoneLink, "zoneLinks",newRoomZoneLink)
        --AddToNextEmptySlot(newRoomZoneLink.zoneLinks,existingRoomZoneLink)
        --AddToNextEmptySlot(existingRoomZoneLink.zoneLinks,newRoomZoneLink)
    end

    

    local NewRoom_LuaBehaviour = API_GameObject.BL_GetComponent(NewRoom,"LuaBehaviour")
    local DoorLuaBeh = API_GameObject.BL_GetComponent(door.gameObject,"LuaBehaviour")

    table.insert(SpawnedSections, NewRoom_LuaBehaviour)
    DoorLuaBeh.ScriptTags.Add("ProcGen_Door_Generated");

    return true
end


function SpawnRoomForDoor(door, forcespawn)
    -- Create a shuffled copy of ProcGenPrefabs to avoid bias
    local shuffledPrefabs = {}
    for i, prefab in ipairs(ProcGenPrefabs) do
        table.insert(shuffledPrefabs, { prefab = prefab, barcode = ProcGenBarcodes[i] })
    end

    
    for i = #shuffledPrefabs, 2, -1 do
        local j = math.random(i)
        shuffledPrefabs[i], shuffledPrefabs[j] = shuffledPrefabs[j], shuffledPrefabs[i]
    end
-- Fisher-Yates shuffle to randomize the order
    -- Try to spawn a room from the shuffled list
    for _, entry in ipairs(shuffledPrefabs) do
        if (AttemptSpawnRoom(door, entry.prefab)) then
            return true
        end
    end

    return false -- No room could be spawned
end



function ProccessRoom(room)

    local RoomExitCount = 0

    local RoomBehaviours = API_GameObject.BL_GetComponentsInChildren(room,"LuaBehaviour",true)
    local RoomBehaviourMain = API_GameObject.BL_GetComponent(room,"LuaBehaviour")
    RoomBehaviourMain.ScriptTags.Add("ProcGen_Section_Generated")
    --print("length of RoomBehaviours" .. tostring(RoomBehaviours) )

    local Doors = {}

    for _,Behaviour in ipairs(RoomBehaviours) do
        --print("tags " .. tostring(Behaviour.ScriptTags) .. tostring(Behaviour.ScriptTags.Count))
        if (Behaviour.ScriptTags.Contains("ProcGen_Door")) then
            if(not Behaviour.ScriptTags.Contains("ProcGen_Door_Generated")) then
                table.insert(Doors, Behaviour)
                --print(Behaviour.name .. " is a door")
            else
                --print(Behaviour.name .. " door already used")
            end
        end
    end

    if(#Doors == 0) then
        --print("no ungenerated doors for " .. room.name)
        return false
    end

    for i, Door in ipairs(Doors) do
        local isLast = (i == #Doors and RoomExitCount==0) -- Check if this is the last door in the list
        if(SpawnRoomForDoor(Door, isLast)) then
            Door.ScriptTags.Add("ProcGen_Door_Generated")
           RoomExitCount = RoomExitCount + 1
           -- print("spawned a new room")
        else
            print("failed to spawn")
            Door.ScriptTags.Add("ProcGen_Door_Generated")
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
                print("Prefab " .. ProcGenBarcodes[i] .. " not loaded yet")
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
        if (allLoaded and API_Player.BL_GetPhysicsRig() ~= nil) then
            math.randomseed(Time.time)
            PostStart()
            PostStartRan = true
        else
            print("Waiting for all prefabs to load...")
        end
    else

    end
end

function AllDoorsReady(room)
    local RoomBehaviours = API_GameObject.BL_GetComponentsInChildren(room.gameObject,"LuaBehaviour",true)
 
    for Behaviour in RoomBehaviours do
        if (Behaviour.ScriptTags.Contains("ProcGen_Door")) then
            --print("DOOR FOUND")
            if(not Behaviour.ScriptTags.Contains("ProcGen_Door_Ready")) then
               -- print(Behaviour.name .. " door not ready")
                return false    
            end
        end
    end
    return true
end


SearchRadius = 200.0
function SlowUpdate()

    if not PostStartRan then --wait until all prefabs are loaded
        return
    end


    if( API_Input.BL_LeftHand() ~= nil) then
        local PlayerPos = API_Input.BL_LeftHand().transform.position
        local colliders = FireCameraRaycastGrid(Camera.main, 20, 20, 99999,0.2)
       
        for _, f in pairs(colliders) do
            local obj = f.gameObject
            local Behaviour = API_GameObject.BL_GetComponentInChildren(obj.transform.root.gameObject,"LuaBehaviour")
        --    print("raycast hit" .. obj.name)
            if(Behaviour ~= nil and Behaviour.ScriptTags.Contains("ProcGen_Section")) then
                Behaviour.CallFunction("SeenByPlayer")
            end
        end

    end

    for index, value in ipairs(SpawnedSections) do



        if(IsValid(value) and not value.ScriptTags.Contains("ProcGen_Section_Spawned")) then
            --print("spawning " .. value.name)
            --spawn any CrateSpawners in the room
            value.CallFunction("Spawn")
        end


        if(IsValid(value) and not value.ScriptTags.Contains("ProcGen_Section_Generated")) then
            if(value.GetScriptVariable("Visible") == true) then
                ProccessRoom(value.gameObject)
                --return
            end
        else
            --print("Room " .. tostring(index) .. " not visible")
        end
    end

    
   
    

end




RoomSeemCount = 0
NextTimeRoomSeen = -100
RequiredOffset = 5.0 -- seconds
function IncrementRoomSeenCount()

    if(Time.timeSinceLevelLoad > NextTimeRoomSeen) then
        --print("sfsdf")
        RoomSeemCount = RoomSeemCount + 1
        NextTimeRoomSeen = Time.timeSinceLevelLoad + RequiredOffset
        --print("sdfsdf")
        print("Player has seen " .. tostring(RoomSeemCount) .. " rooms -- from manager")
        return true
    else
       -- print("not time yet " .. tostring(Time.timeSinceLevelLoad ) .. " " .. tostring(NextTimeRoomSeen))
    end
    return false
end

function FireCameraRaycastGrid(camera, gridSizeX, gridSizeY, maxDistance, jitterAmount)
    local hitColliders = {}  -- Table to store unique colliders hit

    -- Loop through the grid in viewport space
    for i = 0, gridSizeX - 1 do
        for j = 0, gridSizeY - 1 do
            -- Convert grid coordinates to normalized viewport space
            local viewportX = i / (gridSizeX - 1)
            local viewportY = j / (gridSizeY - 1)

            -- Add jitter
            local jitterX =  math.random(-jitterAmount, jitterAmount)
            local jitterY = math.random(-jitterAmount, jitterAmount)

            -- Ensure viewport coordinates remain in range [0,1]
            local jitteredViewportX = math.max(0, math.min(1, viewportX + jitterX))
            local jitteredViewportY = math.max(0, math.min(1, viewportY + jitterY))

            -- Get world position and direction of the ray
            local worldPos = camera.ViewportToWorldPoint(API_Vector.BL_Vector3(jitteredViewportX, jitteredViewportY, 0.3))
            local worldTarget = camera.ViewportToWorldPoint(API_Vector.BL_Vector3(jitteredViewportX, jitteredViewportY, maxDistance))

            -- Perform the raycast
            local hitInfo = API_Physics.BL_RayCast(worldPos, worldTarget)

            -- If hit, store collider in the table (prevent duplicates)
            if hitInfo and hitInfo.collider then
                hitColliders[hitInfo.collider] = hitInfo.collider
            end
        end
    end

    -- Convert table values to a list
    local result = {}
    for _, collider in pairs(hitColliders) do
        table.insert(result, collider)
    end

    return result  -- Return unique colliders struck by the raycasts
end

function IsObjectVisibleFromCamera(camera, Collider, numSamples)
    local objPos = Collider.transform.position
    local objBounds = Collider.bounds
    local radius = (objBounds.extents.x + objBounds.extents.y + objBounds.extents.z) / 3  -- Approximate bounding sphere radius

    -- Iterate through random points around the object
    for i = 1, numSamples do
        -- Generate a random direction vector
        local randomDir = Random.onUnitSphere * radius
        local targetPoint = objPos + randomDir  -- Offset from object's center

        -- Raycast from camera to this random point
        local direction = (targetPoint - camera.transform.position).normalized
        local hitInfo = API_Physics.BL_RayCast(camera.transform.position, direction,500)
      
        -- If the ray hits the object, return true
        if hitInfo and hitInfo.collider == Collider then
            return true
        end
    end

    return false  -- No ray hit the object
end


function GetObjectsInCameraView(camera, range, layerMask)
    -- Get near and far points in world space
    --source: ChatGPT
    local nearBottomLeft = camera:ViewportToWorldPoint(API_Vector.BL_Vector3(0, 0, camera.nearClipPlane))
    local nearBottomRight = camera:ViewportToWorldPoint(API_Vector.BL_Vector3(1, 0, camera.nearClipPlane))
    local nearTopLeft = camera:ViewportToWorldPoint(API_Vector.BL_Vector3(0, 1, camera.nearClipPlane))
    local nearTopRight = camera:ViewportToWorldPoint(API_Vector.BL_Vector3(1, 1, camera.nearClipPlane))

    local farBottomLeft = camera:ViewportToWorldPoint(API_Vector.BL_Vector3(0, 0, range))
    local farBottomRight = camera:ViewportToWorldPoint(API_Vector.BL_Vector3(1, 0, range))
    local farTopLeft = camera:ViewportToWorldPoint(API_Vector.BL_Vector3(0, 1, range))
    local farTopRight = camera:ViewportToWorldPoint(API_Vector.BL_Vector3(1, 1, range))

    -- Find the center of the box in world space
    local center = (nearBottomLeft + nearBottomRight + nearTopLeft + nearTopRight +
                    farBottomLeft + farBottomRight + farTopLeft + farTopRight) / 8

    -- Calculate box dimensions
    local width = Vector3.Distance(farBottomLeft, farBottomRight)  -- Frustum width at max range
    local height = Vector3.Distance(farBottomLeft, farTopLeft)     -- Frustum height at max range
    local depth = range - camera.nearClipPlane                    -- Depth from near to range

    local size = API_Vector.BL_Vector3(width, height, depth) -- Full volume of the viewable space

    -- Orientation should align with the camera’s forward direction
    local rotation = camera.transform.rotation

    -- Perform OverlapBox with extended depth
    local colliders = Physics.OverlapBox(center, size / 2, rotation, layerMask)
    --print(tostring(colliders) .. tostring(colliders == nil))    
   -- print(tostring(colliders.Length))    
    local visibleObjects = {}
 
   -- i = 0
    for f in colliders do
        --print("collider " .. tostring(f.gameObject.name))
        if IsObjectVisibleFromCamera(camera, f, 5) then
            table.insert(visibleObjects, f)
            --print("object visible " .. tostring(f.gameObject.name))
        end
        --i = i+1
    end

    return visibleObjects

end