function Start()
    WarehouseBudget = 150
    WarehouseContents = {} -- key = location string, value = table of QRCode references
    CurrentOrder = nil

    StatusUI = API_GameObject.BL_FindInWorld("StatusUI")
    StatusUIBehaviour = API_GameObject.BL_GetComponent(StatusUI,"LuaBehaviour")

    OrderUI = API_GameObject.BL_FindInWorld("OrderUI")
    OrderUIBehaviour = API_GameObject.BL_GetComponent(OrderUI,"LuaBehaviour")

    --API_Events.BL_SubscribeEvent("ObjectDestructible_OnDestruction", BL_This, "ObjectDestructible_OnDestruction")

    OrderStartTime = nil
    OrderTime = nil
    Bonus = nil
    ParTime = nil
end

function AddBudget(amount)

    WarehouseBudget = WarehouseBudget + amount

    if(WarehouseBudget < 0) then
        WarehouseBudget = 0
    end
    
    print("Added " .. tostring(amount) .. " to budget. New budget: " .. tostring(WarehouseBudget))
end

function ObjectDestructible_OnDestruction(object)
    print("object named " .. object.name .. " was destroyed")
end

function CalculateBonus()
    if(OrderTime > 0) then
        return Bonus
    else
        return math.ceil(math.max(Bonus+OrderTime,0))
    end
end

function GetOrderCount(order)
    local packageCount = 0
    for index, value in ipairs(order) do
        if(value ~= nil and IsValid(value)) then
            packageCount = packageCount+1
        end
    end
    return packageCount
end

function GetFufilledOrderCount(order)

    local loadedPackageCount = 0
    for index, value in ipairs(order) do
        if(value ~= nil and IsValid(value)) then
            --print("QR COde? " .. tostring(value))
            local itemLoaded = value.GetScriptVariable("ItemLoaded")
            if(itemLoaded) then
                loadedPackageCount = loadedPackageCount+1
            end
        end
    end
    return loadedPackageCount

end


function SlowUpdate()

    if(not IsValid(StatusUIBehaviour)) then
        print("required script components not found")
        return
    end

    local StatusUILocked = StatusUIBehaviour.GetScriptVariable("Locked")

    if(not StatusUILocked) then
        if(OrderStartTime == nil) then
            OrderStartTime = Time.time
        end

        local timePassed = Time.time-OrderStartTime --seconds passed
        OrderTime = ParTime-timePassed
        StatusUIBehaviour.CallFunction("SetTimeString",OrderTime)

        local orderCount = GetOrderCount(CurrentOrder)
        local fufilledOrderCount = GetFufilledOrderCount(CurrentOrder)

        StatusUIBehaviour.CallFunction("SetItemsCollectedString",fufilledOrderCount)
        StatusUIBehaviour.CallFunction("SetOrderSizeString",orderCount)
        StatusUIBehaviour.CallFunction("SetBonusString",CalculateBonus(),OrderTime<=0)
        
    end

       
end


function Update()
    if (not IsValid(OrderUIBehaviour)) then
        print("OrderUI not valid - searching...")
        OrderUI = API_GameObject.BL_FindInWorld("OrderUI")
        if (IsValid(OrderUI)) then  
            OrderUIBehaviour = API_GameObject.BL_GetComponent(OrderUI, "LuaBehaviour")
        end
        return
    end

    local orderBoardLocked = OrderUIBehaviour.GetScriptVariable("Locked") 
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
       -- local Package2 = FindPackage("B", "A", 4)
       -- local Package3 = FindPackage("C", "A", 4)

        table.insert(CurrentOrder, Package1)
        --table.insert(CurrentOrder, Package2)
        --table.insert(CurrentOrder, Package3)

        Bonus = 100
        ParTime = (60*1) -- seconds
    end
end



OrderItemSlots = {}

function UpdateOrderBoard()
    local orderItems = API_GameObject.BL_FindInChildren(OrderUI, "OrderItems")
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

    local fufilledOrderCount = GetFufilledOrderCount(CurrentOrder)
    local orderCount = GetOrderCount(CurrentOrder)
    if(fufilledOrderCount >= orderCount) then
        print("Order complete!")
        local bonus = CalculateBonus()
        local baseEarnings = orderCount * 50
        print("Awarding bonus of " .. tostring(bonus))
        

        StatusUIBehaviour.CallFunction("TerminalDisplayShiftOver",baseEarnings,bonus)
        OrderUIBehaviour.CallFunction("TerminalDisplayShiftOver",baseEarnings,bonus)

        AddBudget(baseEarnings + bonus)
       -- OrderStartTime = nil
        --OrderTime = nil
       -- Bonus = nil
        --ParTime = nil

        --CurrentOrder = nil
    end
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

