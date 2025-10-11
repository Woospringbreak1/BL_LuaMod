-- UI_Terminal_FSM_NoMetatable.lua
-- Uses the no-metatable FSM:
--   local FSM = Include("Modules/fsm.lua")  -- or wherever you placed it
FSM = loadmodule("fsm.lua")
-- =======================
-- Utilities
-- =======================
function FormatSecondsToTimeString(seconds)
    local isNegative = seconds < 0
    seconds = math.abs(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    local formatted = string.format("%02d:%02d:%02d", hours, minutes, secs)
    if isNegative then formatted = "-" .. formatted end
    return formatted
end

function SetActive(go, on)
     if (go ~= nil) then 
        go.setActive(on) 
    end 
end

-- =======================
-- Cached refs / globals
-- =======================
WarehouseManager, OrderUI, OrderUIBehaviour = nil, nil, nil
ShiftOverScreen, EarningMessage, EarningMessageText = nil, nil, nil
LockScreen, StatusScreen = nil, nil
LaserCursorToggler, LASERCURSOR_UI = nil, nil
OrderTime, OrderTimeText = nil, nil
OrderSize, OrderSizeText = nil, nil
ItemsCollected, ItemsCollectedText = nil, nil
OrderBonus, OrderBonusText = nil, nil

Locked = true
terminalSM = nil  -- FSM instance (plain table)

-- =======================
-- UI helpers
-- =======================
function ShowLockedUI()
    SetActive(ShiftOverScreen, false)
    SetActive(LockScreen, true)
    SetActive(StatusScreen, false)
    SetActive(LaserCursorToggler, false)
    SetActive(LASERCURSOR_UI, false)
end

function ShowUnlockedUI()
    SetActive(ShiftOverScreen, false)
    SetActive(LockScreen, false)
    SetActive(StatusScreen, true)
    SetActive(LaserCursorToggler, true)
    SetActive(LASERCURSOR_UI, true)
end

function ShowShiftOverUI()
    SetActive(ShiftOverScreen, true)
    SetActive(LockScreen, false)
    SetActive(StatusScreen, false)
    SetActive(LaserCursorToggler, false)
    SetActive(LASERCURSOR_UI, false)
end

-- change-state helper exposed for other scripts
function ChangeState(name, force)
    if terminalSM then FSM.set_state(terminalSM, name, force) end
end

-- =======================
-- FSM State functions
-- =======================
-- LOCKED
function STATE_LOCKED_ENTER(self, prev)
    Locked = true
    ShowLockedUI()
    if OrderUIBehaviour then
        OrderUIBehaviour.CallFunction("LockTerminal", 1, nil, nil, nil)
    end
end

function STATE_LOCKED_UPDATE(self, dt)
    SetActive(LaserCursorToggler, false)
    SetActive(LASERCURSOR_UI, false)
end

-- UNLOCKED
function STATE_UNLOCKED_ENTER(self, prev)
    Locked = false
    ShowUnlockedUI()
    if OrderUIBehaviour then
        OrderUIBehaviour.CallFunction("UnlockTerminal", 1, nil, nil, nil)
    end
end

function STATE_UNLOCKED_UPDATE(self, dt)
    -- add per-frame cursor logic if needed
end

-- SHIFT_OVER
function STATE_SHIFT_OVER_ENTER(self, prev)
    Locked = true
    ShowShiftOverUI()
    -- EarningMessageText is populated by TerminalDisplayShiftOver() before we switch here
end

function STATE_SHIFT_OVER_UPDATE(self, dt)
    -- presentation screen; no per-frame work
end

-- =======================
-- Unity Hooks
-- =======================
function Start()
    WarehouseManager   = API_GameObject.BL_GetComponent(API_GameObject.BL_FindInWorld("WarehouseManager"), "LuaBehaviour")
    OrderUI            = API_GameObject.BL_FindInWorld("OrderUI")
    OrderUIBehaviour   = API_GameObject.BL_GetComponent(OrderUI, "LuaBehaviour")

    ShiftOverScreen    = API_GameObject.BL_FindInChildren(BL_Host, "ShiftOverScreen")
    EarningMessage     = API_GameObject.BL_FindInChildren(ShiftOverScreen, "EarningMessage")
    EarningMessageText = API_GameObject.BL_GetComponent(EarningMessage, "Text")

    LockScreen         = API_GameObject.BL_FindInChildren(BL_Host, "LockScreen")
    StatusScreen       = API_GameObject.BL_FindInChildren(BL_Host, "StatusScreen")

    LaserCursorToggler = API_GameObject.BL_FindInChildren(BL_Host, "LaserCursorToggler")
    LASERCURSOR_UI     = API_GameObject.BL_FindInChildren(BL_Host, "LASERCURSOR_UI")
    SetActive(LaserCursorToggler, false)
    SetActive(LASERCURSOR_UI, false)

    OrderTime          = API_GameObject.BL_FindInChildren(BL_Host, "OrderTime")
    OrderTimeText      = API_GameObject.BL_GetComponent(OrderTime, "Text")
    OrderSize          = API_GameObject.BL_FindInChildren(BL_Host, "OrderSize")
    OrderSizeText      = API_GameObject.BL_GetComponent(OrderSize, "Text")
    ItemsCollected     = API_GameObject.BL_FindInChildren(BL_Host, "ItemsCollected")
    ItemsCollectedText = API_GameObject.BL_GetComponent(ItemsCollected, "Text")
    OrderBonus         = API_GameObject.BL_FindInChildren(BL_Host, "OrderBonus")
    OrderBonusText     = API_GameObject.BL_GetComponent(OrderBonus, "Text")

    TruckCounter         = API_GameObject.BL_FindInChildren(BL_Host, "TruckCounter")
    TruckCounterText     = API_GameObject.BL_GetComponent(TruckCounter, "Text")

    -- Build FSM (plain table)
    terminalSM = FSM.new({ name = "terminal_ui", host = BL_Host, debug = false })

    -- Register states (functional style)
    FSM.add_state(terminalSM, "LOCKED",     { on_enter = STATE_LOCKED_ENTER,     on_update = STATE_LOCKED_UPDATE })
    FSM.add_state(terminalSM, "UNLOCKED",   { on_enter = STATE_UNLOCKED_ENTER,   on_update = STATE_UNLOCKED_UPDATE })
    FSM.add_state(terminalSM, "SHIFT_OVER", { on_enter = STATE_SHIFT_OVER_ENTER, on_update = STATE_SHIFT_OVER_UPDATE })

    -- Initial state
    if Locked then
        FSM.set_state(terminalSM, "LOCKED", true)
    else
        FSM.set_state(terminalSM, "UNLOCKED", true)
    end
end

function SetTruckCount( currentNum, TrucksToday)

    if(IsValid(TruckCounterText)) then
         TruckCounterText.text = "Trucks today: " .. tostring(currentNum) .. "/" .. tostring(TrucksToday)
    else
        print("TRUCK UI LINE INVALID")
    end
   
end

function SetNextTruckETA(seconds)

    if(IsValid(TruckCounterText)) then
         TruckCounterText.text = "Next truck ariving in 00:00:" .. tostring(seconds)
    else
        print("TRUCK UI LINE INVALID")
    end

end

function Update()
    if terminalSM then
        FSM.update(terminalSM, Time.deltaTime)
    end
end

-- =======================
-- External API
-- =======================
function UnlockTerminal()
    if Locked then
        print("Unlocking terminal")
        ChangeState("UNLOCKED")
    end
end

function LockTerminal()
    if not Locked then
        print("Locking terminal")
        ChangeState("LOCKED")
    end
end

function TerminalDisplayShiftOver(base, bonus)
    if EarningMessageText then
        local b = tonumber(base) or 0
        local x = tonumber(bonus) or 0
        EarningMessageText.text =
            "EARNINGS: $" .. tostring(b) ..
            "\nBONUS: $"   .. tostring(x) ..
            "\nTOTAL: $"   .. tostring(b + x)
    end
    print("Shifting display over")
    ChangeState("SHIFT_OVER")
end

-- =======================
-- UI text setters
-- =======================
function SetBonusString(bonus, penalized)
    if bonus ~= nil then
        OrderBonusText.text = "Bonus: $" .. tostring(bonus)
        OrderTimeText.color = penalized and Color.red or Color.white
    else
        print("Provided bonus value is invalid")
    end
end

function SetTimeString(seconds)
    if seconds ~= nil then
        local timeString = FormatSecondsToTimeString(seconds)
        OrderTimeText.text = "ORDER TIME: " .. timeString
        OrderTimeText.color = (seconds <= 0) and Color.red or Color.white
    else
        print("Provided time string is invalid")
    end
end

function SetItemsCollectedString(itemsCollected)
    if itemsCollected ~= nil then
        ItemsCollectedText.text = "ITEMS COLLECTED: " .. tostring(itemsCollected)
    else
        print("Provided items collected value is invalid")
    end
end

function SetOrderSizeString(orderSize)
    if orderSize ~= nil then
        OrderSizeText.text = "ORDER ITEMS: " .. tostring(orderSize)
    else
        print("Provided order size value is invalid")
    end
end
