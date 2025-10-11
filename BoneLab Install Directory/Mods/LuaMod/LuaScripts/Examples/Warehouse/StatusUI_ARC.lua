function FormatSecondsToTimeString(seconds)
    local isNegative = seconds < 0
    seconds = math.abs(seconds)

    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)

    local formatted = string.format("%02d:%02d:%02d", hours, minutes, secs)
    if isNegative then
        formatted = "-" .. formatted
    end
    return formatted
end

function Start()

WarehouseManager = API_GameObject.BL_GetComponent(API_GameObject.BL_FindInWorld("WarehouseManager"),"LuaBehaviour")

OrderUI = API_GameObject.BL_FindInWorld("OrderUI")
OrderUIBehaviour = API_GameObject.BL_GetComponent(OrderUI,"LuaBehaviour")

ShiftOverScreen = API_GameObject.BL_FindInChildren(BL_Host,"ShiftOverScreen")
EarningMessage = API_GameObject.BL_FindInChildren(ShiftOverScreen,"EarningMessage")
EarningMessageText = API_GameObject.BL_GetComponent(EarningMessage,"Text")

LockScreen = API_GameObject.BL_FindInChildren(BL_Host,"LockScreen")
StatusScreen = API_GameObject.BL_FindInChildren(BL_Host,"StatusScreen")

LaserCursorToggler = API_GameObject.BL_FindInChildren(BL_Host,"LaserCursorToggler")
LaserCursorToggler.setActive(false)

LASERCURSOR_UI = API_GameObject.BL_FindInChildren(BL_Host,"LASERCURSOR_UI")
LASERCURSOR_UI.setActive(false)

OrderTime = API_GameObject.BL_FindInChildren(BL_Host,"OrderTime")
OrderTimeText = API_GameObject.BL_GetComponent(OrderTime,"Text")

OrderSize = API_GameObject.BL_FindInChildren(BL_Host,"OrderSize")
OrderSizeText = API_GameObject.BL_GetComponent(OrderSize,"Text")

ItemsCollected = API_GameObject.BL_FindInChildren(BL_Host,"ItemsCollected")
ItemsCollectedText = API_GameObject.BL_GetComponent(ItemsCollected,"Text")

OrderBonus = API_GameObject.BL_FindInChildren(BL_Host,"OrderBonus")
OrderBonusText = API_GameObject.BL_GetComponent(OrderBonus,"Text")

Locked = true

end


function UnlockTerminal()
    if(Locked) then
        print("Unlocking terminal")
        ShiftOverScreen.setActive(false)
        LockScreen.setActive(false)
        StatusScreen.setActive(true)
        LaserCursorToggler.setActive(true)
        LASERCURSOR_UI.setActive(true)
        Locked = false

        print("Unlocking status terminal")
        OrderUIBehaviour.CallFunction("UnlockTerminal",1,nil,nil,nil)

    end
end

function LockTerminal()
    if(not Locked) then
        print("Locking terminal")
        ShiftOverScreen.setActive(false)
        LockScreen.setActive(true)
        StatusScreen.setActive(false)
        LaserCursorToggler.setActive(false)
        LASERCURSOR_UI.setActive(false)
        Locked = true

        print("Locking status terminal")
        OrderUIBehaviour.CallFunction("LockTerminal",1,nil,nil,nil)
    end
end


function TerminalDisplayShiftOver(base,bonus)
    if(not Locked) then
        print("Shifting display over")
        ShiftOverScreen.setActive(true)
        EarningMessagesText.text = "EARNINGS: $" .. tostring(base) .. "\nBONUS: $" .. tostring(bonus) .. "\nTOTAL: $" .. tostring(base + bonus)
        LockScreen.setActive(false)
        StatusScreen.setActive(false)
        LaserCursorToggler.setActive(false)
        LASERCURSOR_UI.setActive(false)
        Locked = true
    end
end

function Update()


    if(Locked) then
        LaserCursorToggler.setActive(false)
        LASERCURSOR_UI.setActive(false)
    else

    end

end



function SetBonusString(bonus,penalized)
    if(bonus ~= nil) then

        OrderBonusText.text = "Bonus: $" .. tostring(bonus)   

        if(penalized) then
            OrderTimeText.color = Color.red
        else
            OrderTimeText.color = Color.white
        end

    else
        print("Provided bonus value is invalid")
    end
end


function SetTimeString(seconds)
    if(seconds ~= nil) then
        local timeString = FormatSecondsToTimeString(seconds)
        OrderTimeText.text = "ORDER TIME: " .. timeString   

        if(seconds <= 0) then
            OrderTimeText.color = Color.red
        else
            OrderTimeText.color = Color.white
        end

    else
        print("Provided time string is invalid")
    end
end

function SetItemsCollectedString(itemsCollected)
    if(itemsCollected ~= nil) then
        ItemsCollectedText.text = "ITEMS COLLECTED: " .. tostring(itemsCollected)   
    else
        print("Provided items collected value is invalid")
    end
end

function SetOrderSizeString(orderSize)
    if(orderSize ~= nil) then
        OrderSizeText.text = "ORDER ITEMS: " .. tostring(orderSize)   
    else
        print("Provided order size value is invalid")
    end
end
