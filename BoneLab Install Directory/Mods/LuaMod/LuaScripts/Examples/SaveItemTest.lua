function Start()

    GameStateManagerObject = API_GameObject.BL_FindInWorld("NewSaveSystem")
    GameStateManager = API_GameObject.BL_GetComponent(GameStateManagerObject,"LuaBehaviour")
    Registered = false
    

    SAVE_IDENTITY = GetScenePath(BL_Host)
    print("My SAVE_IDENTITY is " .. SAVE_IDENTITY)

--GameStateManager.CallFunction("SaveGame")
   -- RegisterWithSaveSystem()
end

function  RegisterWithSaveSystem()
    if(not Registered and IsValid(GameStateManager)) then
       if( GameStateManager.CallFunction("SubscribeObject", BL_This) == true) then
            Registered = true
       end
        
    end
end

function Update()

    if(not IsValid(GameStateManager)) then
        GameStateManagerObject = API_GameObject.BL_FindInWorld("NewSaveSystem")
        GameStateManager = API_GameObject.BL_GetComponent(GameStateManagerObject,"LuaBehaviour")
        return
    elseif(not Registered) then
        RegisterWithSaveSystem()
        return
    end

end

function SAVE_SERIALIZE()

    local SAVE_TABLE = {}
    SAVE_TABLE["Position"] = SerializeUserdata(BL_Host.transform.position)
    SAVE_TABLE["Rotation"] = SerializeUserdata(BL_Host.transform.rotation)

    return SAVE_TABLE

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

function SAVE_DESERIALIZE(saveTableJSON)
    --deserialize here

    if(saveTableJSON == nil or saveTableJSON == "") then
        print("saveTableJSON is nil or empty")
        return
    end

    saveTable = json.parse(saveTableJSON)
    print("start of SAVE_DESERIALIZE function")
    if(saveTable == nil) then
        print("save data is nil")
        return
    end
    
    if (type(saveTable) ~= "table") then
        print("[SAVE_DESERIALIZE] INVALID SAVE DATA: not a table: " .. type(saveTable))
        print("table data: " .. tostring(saveTable))
        return false
    end

    local posBlob = saveTable.Position
    local rotBlob = saveTable.Rotation

    if(posBlob == nil or rotBlob == nil ) then
        print("incomplete save data for " .. BL_Host.name)
        return
    end

    BL_Host.transform.position = DeserializeUserdataBlob(posBlob)
    BL_Host.transform.eulerAngles = DeserializeUserdataBlob(rotBlob)

    local saveOK = true
    return saveOK
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
    end

    print("unsupported type " .. tname)
    return nil
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