SubscribedObjects = {}
StoryFlags = {}
CachedLoadData = {}
SavePrefix = "MD-Save-"
SaveCounter = 0
LoadInAction = false --should we be loading data into objects as they spawn
function Start()

end


function SubscribeObject(SubObj)

    if not IsValid(SubObj) then
        print("Invalid object")
        return false
    end

    if not (table.contains(SubscribedObjects,SubObj)) then
        table.insert(SubscribedObjects,SubObj)
        print("GameStateManager registered " .. SubObj.name)

        local subObjScenePath = GetScenePath(SubObj)

        for i,data in ipairs(CachedLoadData) do
            local dataname = data[1]    
            if(subObjScenePath == dataname) then
                print("found data to match newly registered object")
                subObject.CallFunction("SAVE_DESERIALIZE", json.serialize(data[2]))
                table.remove(CachedLoadData,i)
                return true
            end
        end
        return true
    else
        print("GameStateManager already contains definition for " .. SubObj.name)
        return false
    end
end


function table.contains(tbl, val)
    if tbl == nil then return false end
    for _, v in pairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end

function GenerateSavegameName()
    local newName = SavePrefix .. tostring(SaveCounter) .. ".txt"
   -- SaveCounter = SaveCounter + 1
    return newName
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


-- Replace scientific-notation numbers in a string with fixed-point decimals.
-- Example: "1.23e-5" -> "0.0000123"
function ReplaceScientificNotation(s, precision)
    precision = precision or 10
    local fmt = "%." .. tostring(precision) .. "f"

    return s:gsub("[-+]?%d+%.?%d*[eE][+-]?%d+", function(tok)
        local n = tonumber(tok)
        if not n then return tok end
        local out = string.format(fmt, n)
        -- trim trailing zeros and trailing dot
        out = out:gsub("(%..-)0+$", "%1"):gsub("%.$", "")
        return out
    end)
end



function LoadGame()
--hard code file name for now
    local saveGameFile = "MD-Save-0.txt"
    FileAccess = API_FileAccess.BL_OpenFile(saveGameFile)

    if(FileAccess == nil) then
        print("Failed to open " .. saveGameFile .. " for reading")
        return
    end

    FileAccess.ReadLine() --header
    local line = FileAccess.ReadLine()
    while line ~= nil do
        -- process line here
        print(line)
        LineJSON = json.parse(line,10) 
        local foundMatchForLine  =false
        if(LineJSON ~= nil) then
            local objectName = LineJSON[1]
            local objectData = LineJSON[2]  -- already a table now (no double-parse)

            print("Object Name " .. tostring(objectName) .. " Object Data " .. tostring(objectData) )

            for i,subObject in ipairs(SubscribedObjects) do
                if(IsValid(subObject)) then
                    local objectScenePath = GetScenePath(subObject)
                    if(objectScenePath == objectName) then
                        print("matching object found - calling SAVE_DESERIALIZE on " .. objectName .. " passing type " .. type(objectData))
                        subObject.CallFunction("SAVE_DESERIALIZE", json.serialize(objectData))
                        foundMatchForLine = true
                    else
                        print("object path mismatch: " .. objectScenePath .. " " .. tostring(objectName))
                    end
                else
                    print("Subscribed object reference is Invalid")
                end
            end

            if(not foundMatchForLine) then
                table.insert(CachedLoadData,LineJSON)
            end


        end

        line = FileAccess.ReadLine()
    end
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

function SaveGame()
    
    local saveGameFile = GenerateSavegameName() 
    print("attempting to save game at " .. saveGameFile)
    FileAccess = API_FileAccess.BL_OpenFile(saveGameFile)

    if(FileAccess == nil) then
        print("Failed to open " .. saveGameFile .. " for writing")
        return
    end

    FileAccess.WriteLine("BEGIN SAVE DATA",false)

    SaveFileLines = {}
    local savedIdenties = {}
    local storyFlagOutput = json.serialize(StoryFlags)

    for i,subObject in ipairs(SubscribedObjects) do
        local objSerializeTable = subObject.CallFunction("SAVE_SERIALIZE") 
        local objSerializeIdentity = GetScenePath(subObject) --subObject.GetScriptVariable("SAVE_IDENTITY")
        if(objSerializeTable ~= nil and objSerializeIdentity ~= nil) then
            
            if type(objSerializeTable) == "table" then
                local objSerializeTable_local = DeepCopyTable(objSerializeTable)
                -- serialize the pair directly: [ identity, <table> ]
                local tableLine = json.serialize({ tostring(objSerializeIdentity), objSerializeTable_local })
                FileAccess.WriteLine(tableLine,true)
                print("JSON line: " .. tableLine)
            else
                print("error - save table type is " .. type(objSerializeTable))
            end

            table.insert(savedIdenties,objSerializeIdentity)
        else
            print("objSerializeTable or objSerializeIdentity are nil")
        end

    end
end
