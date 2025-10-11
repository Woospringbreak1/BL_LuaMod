SpawnedObjects = {}

function Start()

    GameStateManagerObject = API_GameObject.BL_FindInWorld("NewSaveSystem")
    GameStateManager = API_GameObject.BL_GetComponent(GameStateManagerObject,"LuaBehaviour")


    CrateSpawner = API_GameObject.BL_GetComponent(BL_Host,"CrateSpawner")
    Registered = false
    

    SAVE_IDENTITY = GetScenePath(BL_Host)
    print("My SAVE_IDENTITY is " .. SAVE_IDENTITY)

end

function  RegisterWithSaveSystem()
    if(not Registered and IsValid(GameStateManager)) then
       if( GameStateManager.CallFunction("SubscribeObject", BL_This) == true) then
            Registered = true
       end
        
    end
end

WaitingForSpawn = true
function Update()

    if(not IsValid(GameStateManager)) then
        GameStateManagerObject = API_GameObject.BL_FindInWorld("NewSaveSystem")
        GameStateManager = API_GameObject.BL_GetComponent(GameStateManagerObject,"LuaBehaviour")
        return
    elseif(not Registered) then
        RegisterWithSaveSystem()
        return
    end

    for i = #SpawnedObjects, 1, -1 do
        local poolee = SpawnedObjects[i]
        if not IsPooleeActive(poolee) then
            table.remove(SpawnedObjects, i)
        end
    end

    if(LoadData ~= nil and #LoadData > 0 ) then --we have data to load
        
        if( WaitingForSpawn) then
            
            print("have data to load but waiting on spwning")
        end
    
        local numberOfItems = #LoadData
        local numberOfSpawnedPoolees = #SpawnedObjects
        local numberToSpawn = numberOfItems-numberOfSpawnedPoolees

        print(" loaded " .. tostring(numberOfItems) .. " data. Pool has " .. tostring(numberOfSpawnedPoolees) .. " spawned items so I need to spawn " .. tostring(numberToSpawn) .. " more")

        if(numberToSpawn <= 0 ) then
            for i,itemData in ipairs(LoadData) do
                local pooleToConfigure = SpawnedObjects[i]
                SAVE_DESERIALIZE_POOLEE(itemData,pooleToConfigure)
            end
            LoadData = {}
            --load
        else
            print("attemptingt to spawn new item")
            CrateSpawner.SpawnSpawnable()
            WaitingForSpawn = true
        end

    end


end

function SAVE_DESERIALIZE_POOLEE(saveTable,poolee)

    print("start of SAVE_DESERIALIZE_POOLEE function for poolee " .. poolee.name)
    
    if(saveTable == nil) then
        print("save data is nil")
        return false
    end
    
    if (type(saveTable) ~= "table") then
        print("[SAVE_DESERIALIZE_POOLEE] INVALID SAVE DATA: not a table: " .. type(saveTable))
        print("table data: " .. tostring(saveTable))
        return false
    end

    local posBlob = saveTable.Position
    local rotBlob = saveTable.Rotation
    local aIBrainBlob = saveTable.aIBrain
    local RigidbodyBlob = saveTable.Rigidbody

    if(posBlob == nil or rotBlob == nil ) then
        print("incomplete save data for " .. poolee.name)
        return false
    end

   poolee.transform.position = DeserializeUserdataBlob(posBlob)
   poolee.transform.eulerAngles = DeserializeUserdataBlob(rotBlob)

   if(aIBrainBlob ~= nil) then
        local aIBrain = API_GameObject.BL_GetComponent(poolee,"AIBrain")
        if(IsValid(aIBrain)) then
            local aIBrainData = DeserializeUserdataBlob(aIBrainBlob)
            local dead = (aIBrainData.isDead)
            aIBrain.isDead = dead
            aIBrain.puppetMaster.Teleport(DeserializeUserdataBlob(posBlob),Quaternion.Euler(DeserializeUserdataBlob(rotBlob)),false)
            print("setting AIBrain details. Is AI dead? " .. tostring(dead) .. " " .. tostring(aIBrainData.isDead))
        else
           print("Error - no AIBrain component found although data was provided") 
        end
   end

 

   if(RigidbodyBlob ~= nil) then
    print("setting Rigidbody details")

   end

    return true
end

function IsPooleeActive(poolee)
    return IsValid(poolee) and poolee.activeInHierarchy
end

function SAVE_SERIALIZE()

    local SAVE_TABLE = {}

    for i,spawnedObject in ipairs(SpawnedObjects) do
        if(IsPooleeActive(spawnedObject)) then --what about active objects that are disabled due to being unloaded? need to investigate crate spawner and poole objects
            local objectData = {}

            --special handling for nullbodies

            local aIBrain = API_GameObject.BL_GetComponent(spawnedObject,"AIBrain")
            local Rigidbody = API_GameObject.BL_GetComponent(spawnedObject,"Rigidbody")

            local physicsObject = nil
            if(aIBrain ~= nil) then
                physicsObject = API_GameObject.BL_FindInChildren(spawnedObject,"Physics")
            end

            if(IsValid(physicsObject)) then
                print("using npc physics object for position and rotation")
                objectData["Position"] = SerializeUserdata(physicsObject.transform.position)
                objectData["Rotation"] = SerializeUserdata(physicsObject.transform.rotation)
            else
                objectData["Position"] = SerializeUserdata(spawnedObject.transform.position)
                objectData["Rotation"] = SerializeUserdata(spawnedObject.transform.rotation)
            end

            --per component checks
            if(IsValid(rigidBody)) then
                objectData["Rigidbody"] =  SerializeUserdata(Rigidbody)
            end

            if(IsValid(aIBrain)) then
                objectData["aIBrain"] =  SerializeUserdata(aIBrain)
            end

            local objectDataPair = {i,objectData}
            table.insert(SAVE_TABLE,objectData)
        end
    end



    return SAVE_TABLE

end

LoadData = {}

function SAVE_DESERIALIZE(saveTableJSON)
    --deserialize here



    if(saveTableJSON == nil or saveTableJSON == "") then
        print("saveTableJSON is nil or empty")
        return
    end

    local saveTable = json.parse(saveTableJSON) --note: table, not singular

    LoadData = saveTable
end

function DeepCopyTable(original)
    if type(original) ~= "table" then
        return original
    end

    local copy = {}
    for key, value in pairs(original) do
        if type(value) == "table" then
            copy[key] = DeepCopyTable(value)
        else
            copy[key] = value
        end
    end
    return copy
end


function SerializeUserdata(UserData)
    local typeName = API_Utils.BL_GetClassName(UserData)
    if not typeName then
        print("SerializeUserdata: unknown userdata type")
        return nil
    end

    local data
    if typeName == "UnityEngine.Vector3" then
         data = { x = (UserData.x), y = (UserData.y), z = (UserData.z) }

    elseif typeName == "UnityEngine.Quaternion" then
        local e = UserData.eulerAngles
        data = { x = (e.x), y = (e.y), z = (e.z) }

    elseif typeName == "Il2CppSLZ.Marrow.AI.AIBrain" then
        local isDead = UserData.isDead
        data = {isDead = isDead}
    else
        print("TYPE " .. tostring(typeName) .. " SERIALIZATION NOT IMPLEMENTED")
        return nil
    end

    -- Return wrapper that matches your deserializer
    return {
        DataType = typeName,
        Data = data
    }
end

function DeserializeUserdataBlob(ud)

    if (ud == nil or type(ud) ~= "table") then
        print("invalid userdata blob provided")
         return nil 
    end

    local tname = ud.DataType
    local data  = ud.Data

    if (tname == nil or data == nil or type(data) ~= "table") then 
        print("data type or tname is invalid")
        return nil 
    end

    if tname == "UnityEngine.Vector3" then
        -- Only use named fields (x, y, z)
        local x = tonumber(data.x)
        local y = tonumber(data.y)
        local z = tonumber(data.z)
        if x and y and z then
            return API_Vector.BL_Vector3(x, y, z)
        else
        end

    elseif tname == "UnityEngine.Quaternion" then
        -- Use only Euler angles, not quaternion x/y/z/w
        local ex = tonumber(data.x)
        local ey = tonumber(data.y)
        local ez = tonumber(data.z)
        if ex and ey and ez then
            return API_Vector.BL_Vector3(ex, ey, ez)
        else
            print("invalid Quaternion components")
        end
    elseif tname == "Il2CppSLZ.Marrow.AI.AIBrain" then
            local isDeadDat = (data.isDead == true)
            return {isDead=isDeadDat}
    else

    print("unsupported type " .. tname)
    return nil
    end
end

function GetScenePath(go)
    if not IsValid(go) then
        return nil
    end

    local path = go.name
    local current = go.transform.parent

    while IsValid(current) do
        path = current.name .. "/" .. path
        current = current.parent
    end

    return path
end

function CrateSpawned(nil1,nil2,nil3,Spawned)
    local spawnedObject = API_Utils.BL_ConvertObjectToType(Spawned,"GameObject")
    table.insert(SpawnedObjects,spawnedObject)
    WaitingForSpawn = false
    print("registering new item " .. Spawned.name)
    print("I am aware of " .. tostring(#SpawnedObjects) .. " items")
end