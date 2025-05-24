--manage a system where specific items go in specific body slots
--when the item is dropped, it will return to the slot
--when attempting to store an item, if it is incorrect it will be dropped

function  Start()
    API_Events.BL_SubscribeEvent("InventorySlot_OnInsertInSlot", BL_This, "InventorySlot_OnInsertInSlot")
    API_Events.BL_SubscribeEvent("OnGripDetached", BL_This, "OnGripDetached")
    FlashLight = nil
    FlashlightInteractableHost = nil
    FlashlightReturnTime = 0.0
    FlagFlashlightReturn = false
    FlashlightInit = false
    API_GameObject.BL_SpawnByBarcode(BL_This,"FlashLight","c1534c5a-38df-474e-abb3-7e81466c6173", Vector3.zero, Quaternion.identity,nil, true)
end



function InventorySlot_OnInsertInSlot(slot,host)
    print("Inserted " .. host.name .. " into " .. slot.name)
end

function OnGripDetached(grip,hand)
    if(grip.transform.root == FlashLight.transform.root) then
        FlagFlashlightReturn = true
        FlashlightReturnTime = Time.time+3.0
    end
end


function ReturnFlashlight()

    if(IsValid(FlashLight)) then
        local leftHandContents = API_Input.BL_LeftHandContents()
        local rightHandContents = API_Input.BL_RightHandContents()
        local notInLeftHand = (leftHandContents == nil or leftHandContents.transform.root ~= FlashLight.transform.root)
        local notInRightHand = (rightHandContents == nil or rightHandContents.transform.root ~= FlashLight.transform.root)
        if(notInLeftHand and notInRightHand) then
            API_Player.Slot_BackRight.inventorySlotReceiver.InsertInSlot(FlashlightInteractableHost)
        end
    end
end


function Update()


    if(IsValid(FlashLight) and not FlashlightInit and IsValid(API_Player.Slot_BackRight)) then
        FlashlightInteractableHost = API_GameObject.BL_GetComponent(FlashLight,"InteractableHost")
        ReturnFlashlight()
        FlashlightInit = true
    end

    if(FlagFlashlightReturn and Time.time > FlashlightReturnTime) then
        FlagFlashlightReturn = false
        ReturnFlashlight()
    end


end
