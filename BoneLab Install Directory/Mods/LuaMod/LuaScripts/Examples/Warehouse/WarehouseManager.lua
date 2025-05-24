function Start()
    WarehouseContents = {} -- key = location string, value = table of QRCode references
    CurrentOrder = nil
    OrderUIGo = nil
    OrderUI = nil


    API_Events.BL_SubscribeEvent("ObjectDestructible_OnDestruction", BL_This, "ObjectDestructible_OnDestruction")
end

function ObjectDestructible_OnDestruction(object)
    print("object named " .. object.name .. " was destroyed")
end

function Update()
    if (not IsValid(OrderUI)) then
        print("OrderUI not valid - searching...")
        OrderUIGo = API_GameObject.BL_FindInWorld("OrderUI")
        if (IsValid(OrderUIGo)) then  
            OrderUI = API_GameObject.BL_GetComponent(OrderUIGo, "LuaBehaviour")
        end
        return
    end

    local orderBoardLocked = OrderUI.GetScriptVariable("Locked") 
    if (not orderBoardLocked) then
        if (CurrentOrder == nil) then
            print("Generating order for day 1")
            GenerateDaysOrder("DAY1")
            UpdateOrderBoard()
        end
    end
end

-- Use A-D as rows, shelf stays as A-D
function GenerateDaysOrder(day)
    CurrentOrder = {}
    if (day == "DAY1") then
        local Package1 = FindPackage("A", "A", 4)
        local Package2 = FindPackage("B", "A", 4)
        local Package3 = FindPackage("C", "A", 4)

        table.insert(CurrentOrder, Package1)
        table.insert(CurrentOrder, Package2)
        table.insert(CurrentOrder, Package3)
    end
end

OrderItemSlots = {}

function UpdateOrderBoard()
    local orderItems = API_GameObject.BL_FindInChildren(OrderUI.gameObject, "OrderItems")
    if orderItems == nil then
        print("Failed to find OrderItems under OrderUI")
        return
    end

    local numSlots = 6
    OrderItemSlots = {}

    for i = 1, numSlots do
        local slotName = "OrderItem_" .. i
        local slot = API_GameObject.BL_FindInChildren(orderItems, slotName)
        if slot ~= nil then
            OrderItemSlots[i] = slot

            local qr = CurrentOrder[i]
            if IsValid(qr) then
                slot.setActive(true)

                local shelf = qr.GetScriptVariable("ShelfPosition")
                local row = qr.GetScriptVariable("RowPosition")
                local column = qr.GetScriptVariable("ColumnPosition")
                local location = string.format("%s-%s-%s", tostring(shelf), tostring(row), tostring(column))

                FillOrderBoardSlot(slot, qr, location)
            else
                slot.setActive(false)
            end
        else
            print("Warning: " .. slotName .. " not found under OrderItems")
        end
    end
end


function ItemLoaded(item) 
    item.SetScriptVariable("ItemLoaded",true)
    UpdateOrderBoard()
end

function FillOrderBoardSlot(slot, QRCode, location)


    if(IsValid(QRCode)) then
      print("QR Code: " .. tostring(QRCode))
    else
        print("QRCode is not valid: ")
        return
    end

    local ItemTitle = API_GameObject.BL_GetComponent(API_GameObject.BL_FindInChildren(slot, "ItemTitle"), "Text")
    local ItemDescription = API_GameObject.BL_GetComponent(API_GameObject.BL_FindInChildren(slot, "ItemDescription"), "Text")
    local ItemUnit = API_GameObject.BL_GetComponent(API_GameObject.BL_FindInChildren(slot, "ItemUnit"), "Text")
    local Received = API_GameObject.BL_GetComponent(API_GameObject.BL_FindInChildren(slot, "Received"), "Text")
    local ItemLocation = API_GameObject.BL_GetComponent(API_GameObject.BL_FindInChildren(slot, "ItemLocation"), "Text")

    ItemTitle.text = "ITEM: " .. QRCode.GetScriptVariable("ItemID")
    ItemDescription.text = QRCode.GetScriptVariable("ItemDescription")
    ItemLocation.text = "LOCATION: " .. location

    local ItemLoaded = QRCode.GetScriptVariable("ItemLoaded")

    if(ItemLoaded == true) then
        Received.text = "✔️"     
        Received.color = Color.green

        ItemTitle.color = Color.green
        ItemDescription.color = Color.green
        ItemLocation.color = Color.green
        ItemUnit.color = Color.green
    else
        Received.text = "X"    
        Received.color = Color.white

        ItemTitle.color = Color.white
        ItemDescription.color = Color.white
        ItemLocation.color = Color.white
        ItemUnit.color = Color.white
    end
    

end

-- Shelf and row are now both letters
local ShelfOrder = {"A", "B", "C", "D"}
local RowOrder = {"A", "B", "C", "D"}

function FindPackage(startShelf, startRow, column)
    local shelfIndex, rowIndex = nil, nil

    for i, v in ipairs(ShelfOrder) do
        if v == startShelf then
            shelfIndex = i
            break
        end
    end

    for i, v in ipairs(RowOrder) do
        if v == startRow then
            rowIndex = i
            break
        end
    end

    if shelfIndex == nil or rowIndex == nil then
        print("Invalid shelf or row: " .. tostring(startShelf) .. ", " .. tostring(startRow))
        return nil
    end

    local originalShelf = shelfIndex
    local originalColumn = column
    local maxColumn = 8 -- can change if needed

    while true do
        local shelf = ShelfOrder[shelfIndex]
        local row = RowOrder[rowIndex]
        local key = string.format("%s-%s-%d", shelf, row, column)

        print("Searching for package at: " .. key)
        local packages = WarehouseContents[key]

        if packages and #packages > 0 then
            print("Found package at: " .. key)
            return packages[1]
        end

        -- increment column
        column = column + 1
        if column > maxColumn then
            column = 1
            shelfIndex = shelfIndex + 1
            if shelfIndex > #ShelfOrder then
                shelfIndex = 1
            end
        end

        -- full loop exit condition
        if shelfIndex == originalShelf and column == originalColumn then
            print("No packages found after full search")
            return nil
        end
    end
end

function RegisterPackage(spawnedObject)
    local QRCode = API_Utils.BL_ConvertObjectToType(spawnedObject, "LuaBehaviour")
    
    if IsValid(QRCode) then
        local qrCodeShelf = QRCode.GetScriptVariable("ShelfPosition") -- A-D
        local qrCodeRow = QRCode.GetScriptVariable("RowPosition")     -- A-D
        local qrCodeColumn = QRCode.GetScriptVariable("ColumnPosition") -- 1-8

        if(qrCodeShelf == nil or qrCodeRow == nil or qrCodeColumn == nil) then
            return
        end

        local qrCodeLocation = string.format("%s-%s-%d", qrCodeShelf, qrCodeRow, qrCodeColumn)
        print("Registering package at location " .. qrCodeLocation)

        if WarehouseContents[qrCodeLocation] == nil then
            WarehouseContents[qrCodeLocation] = {}
        end

        table.insert(WarehouseContents[qrCodeLocation], QRCode)
    else
        print("Failed to register package: " .. tostring(spawnedObject))
    end
end
