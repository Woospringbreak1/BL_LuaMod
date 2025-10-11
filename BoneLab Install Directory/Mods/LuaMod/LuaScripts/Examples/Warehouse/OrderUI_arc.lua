--See WarehouseManager.lua for functionality

function Start()
StatusUI = API_GameObject.BL_FindInWorld("StatusUI")
StatusUIBehaviour = API_GameObject.BL_GetComponent(StatusUI,"LuaBehaviour")
LockScreen = API_GameObject.BL_FindInChildren(BL_Host,"LockScreen")
OrderScreen = API_GameObject.BL_FindInChildren(BL_Host,"OrderScreen")

ShiftOverScreen = API_GameObject.BL_FindInChildren(BL_Host,"ShiftOverScreen")
EarningMessage = API_GameObject.BL_FindInChildren(ShiftOverScreen,"EarningMessage")
EarningMessageText = API_GameObject.BL_GetComponent(EarningMessage,"Text")

LaserCursorToggler = API_GameObject.BL_FindInChildren(BL_Host,"LaserCursorToggler")
LaserCursorToggler.setActive(false)

LASERCURSOR_UI = API_GameObject.BL_FindInChildren(BL_Host,"LASERCURSOR_UI")
LASERCURSOR_UI.setActive(false)
Locked = true
end


function UnlockTerminal()
    if(Locked) then
        print("Unlocking terminal")
        LockScreen.setActive(false)
        OrderScreen.setActive(true)
        LaserCursorToggler.setActive(true)
        LASERCURSOR_UI.setActive(true)
        Locked = false


        print("Unlocking status terminal")
        StatusUIBehaviour.CallFunction("UnlockTerminal")
    end
end

function LockTerminal()
    if(not Locked) then
        print("Locking terminal")
        LockScreen.setActive(true)
        OrderScreen.setActive(false)
        LaserCursorToggler.setActive(false)
        LASERCURSOR_UI.setActive(false)
        Locked = true

        print("Locking status terminal")
        StatusUIBehaviour.CallFunction("LockTerminal")
    end
end

function TerminalDisplayShiftOver(base,bonus)
    if(not Locked) then
        print("Shifting display over")
        ShiftOverScreen.setActive(true)
        EarningMessagesText.text = "EARNINGS: $" .. tostring(base) .. "\nBONUS: $" .. tostring(bonus) .. "\nTOTAL: $" .. tostring(base + bonus)
        LockScreen.setActive(false)
        OrderScreen.setActive(false)
        LaserCursorToggler.setActive(false)
        LASERCURSOR_UI.setActive(false)
        Locked = true
    end
end

function Update()
    
if(Locked) then
    LaserCursorToggler.setActive(false)
    LASERCURSOR_UI.setActive(false)
end

end