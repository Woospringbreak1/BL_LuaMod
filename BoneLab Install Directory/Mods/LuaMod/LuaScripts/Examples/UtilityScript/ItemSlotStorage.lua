-- Tracked items for specific slots
TrackedItems = {
    {
        name = "LeftPistol",
        slot = function() return API_Player.Slot_Left_Pistol end,
        barcode = "c1534c5a-bcb7-4f02-a4f5-da9550333530"
    },
    {
        name = "RightPistol",
        slot = function() return API_Player.Slot_Right_Pistol end,
        barcode = "c1534c5a-bcb7-4f02-a4f5-da9550333530"
    },
    {
        name = "Butt",
        slot = function() return API_Player.Slot_Butt end,
        barcode = "c1534c5a-38df-474e-abb3-7e81466c6173"
    },
    {
        name = "BackLeft",
        slot = function() return API_Player.Slot_BackLeft end,
        barcode = "c1534c5a-38df-474e-abb3-7e81466c6173"
    },
    {
        name = "BackRight",
        slot = function() return API_Player.Slot_BackRight end,
        barcode = "c1534c5a-38df-474e-abb3-7e81466c6173"
    }
}

function Start()
    API_Events.BL_SubscribeEvent("InventorySlot_OnInsertInSlot", BL_This, "InventorySlot_OnInsertInSlot")
    API_Events.BL_SubscribeEvent("OnGripDetached", BL_This, "OnGripDetached")
    API_Events.BL_SubscribeEvent("InventorySlot_OnHandDrop", BL_This, "OnHandDropped")

    for _, item in ipairs(TrackedItems) do
        item.host = nil
        item.returnTime = 0.0
        item.flagReturn = false
        item.init = false

        -- Variable name string gets used by spawn system to assign _G[name]
        API_GameObject.BL_SpawnByBarcode(BL_This, item.name, item.barcode, Vector3.zero, Quaternion.identity, nil, true)
    end
end

--function InventorySlot_OnInsertInSlot(slot, host)
 --   print("Inserted " .. host.name .. " into " .. slot.name)
--end

function OnHandDropped(slot, host, dropobject)

    --=================================================================================================
    --note: current bug related to root gameobject being part of the player when holstering matched item
    --=================================================================================================

    if(not IsValid(dropobject)) then return end

    local dropObjectRoot = dropobject.transform.root
    local matchedItem = nil
    local slotTracked = false

    -- First pass: check if this slot is a tracked slot and find the matched item (if any)
    for _, item in ipairs(TrackedItems) do
        local expectedSlot = item.slot()
        if(IsValid(expectedSlot) and expectedSlot.inventorySlotReceiver == slot) then
            slotTracked = true
        end

        local obj = _G[item.name]
        if(IsValid(obj) and obj.transform.root == dropObjectRoot) then
            matchedItem = item
        end
    end

    -- Case 1: tracked item in wrong slot
    if(matchedItem and slot ~= matchedItem.slot().inventorySlotReceiver) then
        slot.DropWeapon()
        print("wrong slot, dropping " .. dropObjectRoot.name)
        return
    end

    -- Case 2: non-tracked item in tracked slot
    if(not matchedItem and slotTracked) then
        slot.DropWeapon()
        print("non-tracked item dropped from reserved slot: " .. dropObjectRoot.name)
        return
    end
end

function OnGripDetached(grip, hand)
    for _, item in ipairs(TrackedItems) do
        local obj = _G[item.name]
        if(IsValid(obj) and grip.transform.root == obj.transform.root) then
            if(API_Player.BL_GetSlotContents(item.slot()) ~= obj) then
                item.flagReturn = true
                item.returnTime = Time.time + 3.0
            end
        end
    end
end

function ReturnItem(item, obj)
    if(IsValid(obj) and IsValid(item.host)) then
        local leftHand = API_Input.BL_LeftHandContents()
        local rightHand = API_Input.BL_RightHandContents()

        local notInLeft = (leftHand == nil or leftHand.transform.root ~= obj.transform.root)
        local notInRight = (rightHand == nil or rightHand.transform.root ~= obj.transform.root)

        if(notInLeft and notInRight) then
            local slot = item.slot()
            if(IsValid(slot)) then
                slot.inventorySlotReceiver.InsertInSlot(item.host)
            end
        end
    end
end

function Update()
    for _, item in ipairs(TrackedItems) do
        local obj = _G[item.name]
        if(IsValid(obj) and not item.init and IsValid(item.slot())) then
            item.host = API_GameObject.BL_GetComponent(obj, "InteractableHost")
            ReturnItem(item, obj)
            item.init = true
        end

        if(item.flagReturn and Time.time > item.returnTime) then
            item.flagReturn = false
            ReturnItem(item, obj)
        end
    end
end
