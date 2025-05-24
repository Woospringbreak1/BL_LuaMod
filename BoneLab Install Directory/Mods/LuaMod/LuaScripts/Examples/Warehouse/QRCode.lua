function Start()

    local warehouseManager = API_GameObject.BL_GetComponent(API_GameObject.BL_FindInWorld("WarehouseManager"),"LuaBehaviour")
    ItemLoaded = false
    if(warehouseManager == nil) then
        print("failed to find warehouse manager")
        API_GameObject.BL_Destroy(BL_Host.transform.parent.gameObject)
    end

    math.randomseed(API_Random.RangeFloat(0,10000))

    ShelfPosition = nil
    RowPosition = nil
    ColumnPosition = nil
    FindStoreLocation()

    if(ShelfPosition ~= nil and RowPosition ~= nil and ColumnPosition ~= nil) then
        --only run for items on the shelf - will leave UI and world codes alone

        local shouldDelete = math.random()
        if(shouldDelete < 0.2) then
           -- print("random number is " .. tostring(shouldDelete) .. ", deleting")
            API_GameObject.BL_Destroy(BL_Host.transform.parent.gameObject)
        else
           -- print("random number is " .. tostring(shouldDelete) .. ", not deleting")
        end

        if(ShelfPosition == "B" or ShelfPosition == "C") then
            if(math.random() < 0.5) then
                --print("rotating to 0")
                BL_Host.transform.parent.localRotation = Quaternion.Euler(0,0,0)
            else
               -- print("rotating to 180")
                BL_Host.transform.parent.localRotation = Quaternion.Euler(0,180,0)
            end
        end
    end

    ItemID = "ID NOT SET"
    ItemDescription = "DESCRIPTION NOT SET"
    local luaResources = API_GameObject.BL_GetComponent(BL_Host,"LuaResources")
    local resourceID = nil
    local resourceDescription = nil

    if(IsValid(luaResources)) then 
        resourceID = luaResources.GetString("ItemID")
        resourceDescription = luaResources.GetString("ItemDescription")
    end


    if(resourceID ~= nil and resourceDescription ~= nil) then
        ItemID = resourceID
        ItemDescription = resourceDescription
    else
        GenerateContents()
    end 

    ScannedEvent = API_GameObject.BL_GetComponent(BL_Host,"UltEventHolder")
    warehouseManager.CallFunction("RegisterPackage",BL_This)
end


function AttachToSpawned(nil1,nil2,nil3,spawnedObject)
    SpawnedGameObject = API_Utils.BL_ConvertObjectToType(spawnedObject,"GameObject")

    if(IsValid(SpawnedGameObject)) then
       -- print("attached to spawned object: " .. SpawnedGameObject.name)
        BL_Host.transform.parent = SpawnedGameObject.transform
        local rb = API_GameObject.BL_GetComponent(SpawnedGameObject.transform.root.gameObject,"Rigidbody")
        rb.Sleep()
    else
      -- print("failed to attach to spawned object")
    end


end

function Scanned()
    --print("Scanned event triggered " .. tostring(ScannedEvent))
    if(IsValid(ScannedEvent)) then
       -- print("Scanned event invoking...")
        ScannedEvent.Invoke()
    end
end

-- Word pools
local Qualifier = {
    "Industrial", "Military", "Utility", "Aerospace", "Biomedical", "Pet-grade",
    "Experimental", "Subsurface", "Cryogenic", "High-Torque", "Compact", "Heavy-Duty"
}

local Function = {
    "Thermal", "Pressure", "Magnetic", "Fluidic", "Rotary", "Optical",
    "Kinetic", "Hydraulic", "Vacuum-Sealed", "Dual-Stage", "Multi-phase", "Electrostatic","Subspace","Hyper-geometric"
}

local Noun = {
    "Regulator", "Actuator", "Sensor", "Module", "Interface", "Relay",
    "Processor", "Assembly", "Housing", "Casing", "Conduit", "Injector", "Controller", "Transducer"
}

-- Helper: pick random element
local function RandomFrom(tbl)
    return tbl[math.random(#tbl)]
end

-- Helper: generate random version/serial label
local function RandomVersion()
    local r = math.random()
    if r < 0.3 then
        return string.format("Mk-%d", math.random(1, 4))
    elseif r < 0.6 then
        return string.format("v%d.%d", math.random(1, 3), math.random(0, 9))
    elseif r < 0.8 then
        return string.format("#%03d-%s", math.random(100, 999), string.char(math.random(65, 90)))
    else
        return string.format("Batch-%d", math.random(1, 99))
    end
end

-- Main generator
function GenerateDescription()
    local baseName = string.format(
        "%s %s %s",
        RandomFrom(Qualifier),
        RandomFrom(Function),
        RandomFrom(Noun)
    )

    -- 50% chance to append a version or serial
    if math.random() < 0.5 then
        baseName = baseName .. " " .. RandomVersion()
    end

    return baseName
end


function GenerateContents()
    ItemID = string.format("%05d", math.random(0, 9999))
    ItemDescription = tostring(GenerateDescription())
end

function FindStoreLocation()
    -- figure out where you are in the store
    local triggers = API_Physics.BL_OverlapSphere(BL_Host.transform.position,0.5,-5,true)

    for i, obj in ipairs(triggers) do
        if (string.match(obj.name,"Shelf")) then
          ShelfPosition = string.sub(obj.name, -1)
        end

        if (string.match(obj.name,"Row")) then
          RowPosition = string.sub(obj.name, -1)
        end

        if (string.match(obj.name,"Column")) then
          ColumnPosition = string.sub(obj.name, -1)
        end
    end

    --print("I am in location " .. tostring(ShelfPosition) .. "-" .. tostring(RowPosition) .. "-" .. tostring(ColumnPosition))
end