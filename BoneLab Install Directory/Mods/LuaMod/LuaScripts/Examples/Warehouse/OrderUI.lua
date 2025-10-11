-- OrderUI_FSM.lua
-- Uses the plain (no-metatable) FSM module
local FSM = loadmodule("fsm.lua")
-- =======================
-- Helpers / small utils
-- =======================
function SetActive(go, on)
     if go ~= nil then
        go.setActive(on) 
    end 
end

-- =======================
-- Cached refs / globals
-- =======================
StatusUI = nil
StatusUIBehaviour = nil
LockScreen = nil
OrderScreen = nil

ShiftOverScreen = nil
EarningMessage = nil
EarningMessageText = nil
LaserCursorToggler  = nil
LASERCURSOR_UI = nil

Locked = true
orderSM = nil  -- FSM instance (plain table)

-- =======================
-- UI show/hide helpers (mirrors terminal script style)
-- =======================
function ShowLockedUI()
    SetActive(ShiftOverScreen, false)
    SetActive(LockScreen, true)
    SetActive(OrderScreen, false)
    SetActive(LaserCursorToggler, false)
    SetActive(LASERCURSOR_UI, false)
end

function ShowUnlockedUI()
    SetActive(ShiftOverScreen, false)
    SetActive(LockScreen, false)
    SetActive(OrderScreen, true)
    SetActive(LaserCursorToggler, true)
    SetActive(LASERCURSOR_UI, true)
end

function ShowShiftOverUI()
    SetActive(ShiftOverScreen, true)
    SetActive(LockScreen, false)
    SetActive(OrderScreen, false)
    SetActive(LaserCursorToggler, false)
    SetActive(LASERCURSOR_UI, false)
end

-- expose a small helper so other scripts can force transitions if needed
function ChangeState(name, force)
    if orderSM then FSM.set_state(orderSM, name, force) end
end

-- =======================
-- FSM State functions (enter/update)
-- =======================
-- LOCKED
function STATE_LOCKED_ENTER(self, prev)
    ShiftOver = false
    Locked = true
    ShowLockedUI()
    -- keep the cross-notify behavior from original script
    if StatusUIBehaviour then
        StatusUIBehaviour.CallFunction("LockTerminal")
    end
end

function STATE_LOCKED_UPDATE(self, dt)
    -- ensure laser is off while locked
    SetActive(LaserCursorToggler, false)
    SetActive(LASERCURSOR_UI, false)
end

-- UNLOCKED
function STATE_UNLOCKED_ENTER(self, prev)
    ShiftOver = false
    Locked = false
    ShowUnlockedUI()
    -- mirror original: tell Status UI it is unlocked
    if StatusUIBehaviour then
        StatusUIBehaviour.CallFunction("UnlockTerminal")
    end
end

function STATE_UNLOCKED_UPDATE(self, dt)
    -- no per-frame logic needed for now
end

-- SHIFT_OVER
ShiftOver = false
function STATE_SHIFT_OVER_ENTER(self, prev)
    ShiftOver = true
    Locked = true
    ShowShiftOverUI()
    -- EarningMessageText is populated by TerminalDisplayShiftOver() before we transition
end

function STATE_SHIFT_OVER_UPDATE(self, dt)
    -- presentation state; nothing per frame
end

-- =======================
-- Unity lifecycle
-- =======================
function Start()
    StatusUI          = API_GameObject.BL_FindInWorld("StatusUI")
    StatusUIBehaviour = API_GameObject.BL_GetComponent(StatusUI, "LuaBehaviour")

    LockScreen        = API_GameObject.BL_FindInChildren(BL_Host, "LockScreen")
    OrderScreen       = API_GameObject.BL_FindInChildren(BL_Host, "OrderScreen")

    ShiftOverScreen   = API_GameObject.BL_FindInChildren(BL_Host, "ShiftOverScreen")
    EarningMessage    = API_GameObject.BL_FindInChildren(ShiftOverScreen, "EarningMessage")
    EarningMessageText= API_GameObject.BL_GetComponent(EarningMessage, "Text")

    LaserCursorToggler= API_GameObject.BL_FindInChildren(BL_Host, "LaserCursorToggler")
    LASERCURSOR_UI    = API_GameObject.BL_FindInChildren(BL_Host, "LASERCURSOR_UI")
    SetActive(LaserCursorToggler, false)
    SetActive(LASERCURSOR_UI, false)

    -- Build FSM (functional style)
    orderSM = FSM.new({ name = "order_ui", host = BL_Host, debug = false })
    FSM.add_state(orderSM, "LOCKED",     { on_enter = STATE_LOCKED_ENTER,     on_update = STATE_LOCKED_UPDATE })
    FSM.add_state(orderSM, "UNLOCKED",   { on_enter = STATE_UNLOCKED_ENTER,   on_update = STATE_UNLOCKED_UPDATE })
    FSM.add_state(orderSM, "SHIFT_OVER", { on_enter = STATE_SHIFT_OVER_ENTER, on_update = STATE_SHIFT_OVER_UPDATE })

    -- Initial state from current flag
    if Locked then
        FSM.set_state(orderSM, "LOCKED", true)
    else
        FSM.set_state(orderSM, "UNLOCKED", true)
    end
end

function Update()
    if orderSM then
        FSM.update(orderSM, Time.deltaTime)
    end
end

-- =======================
-- External API (unchanged names, now FSM-backed)
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
    if (IsValid(EarningMessageText)) then
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