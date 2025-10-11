local FSM = loadmodule("fsm.lua")

-- =========================
-- Tunables / Globals
-- =========================
WarehouseBudget = 150

-- Trucks per day (currently set to 2 for all days; change here later if needed)
local TrucksPerDay = {
    DAY1 = 2,
    DAY2 = 2,
    DAY3 = 2,
    DAY4 = 2,
    DAY5 = 2,
}
local DefaultTrucksPerDay = 2
local NextTruckDelayS = 8.0  -- wait time between trucks (seconds)

-- Data
WarehouseContents = {} -- key = "Shelf-Row-Column", value = { QRCode, ... }

-- Per-truck orders (array of arrays); CurrentOrder is an alias to TruckOrders[CurrentTruckIndex+1]
TruckOrders = nil
CurrentOrder = nil

-- UI refs
StatusUI = nil
StatusUIBehaviour = nil
OrderUI = nil
OrderUIBehaviour = nil

-- Timing/score
OrderStartTime = nil
OrderTime = nil
OrderTimePassed = 0
Bonus = nil
ParTime = nil

-- Shelf and row orders
local ShelfOrder = {"A", "B", "C", "D"}
local RowOrder   = {"A", "B", "C", "D"}

-- =========================
-- Day FSM
-- =========================
local DaySM = nil
local DayOrderQueued = false  -- blocks re-generation once a day's orders are produced

function ChangeState(name, force)
    FSM.set_state(DaySM, name, force)
end

function GetState()
    return FSM.get_state(DaySM)
end

local function StateToDayToken(st)
    if st == "FirstDay"  then return "DAY1"
    elseif st == "SecondDay" then return "DAY2"
    elseif st == "ThirdDay"  then return "DAY3"
    elseif st == "FourthDay" then return "DAY4"
    elseif st == "FifthDay"  then return "DAY5"
    end
    return "DAY1"
end

-- =========================
-- Truck flow (per day)
-- =========================
local CurrentTruckIndex = 0      -- 0-based index of current truck for the day
local TrucksToday = 0
local WaitingNextTruck = false
local NextTruckArriveAt = 0.0

local function GetTrucksForDay(dayToken)
    return TrucksPerDay[dayToken] or DefaultTrucksPerDay
end

local function UpdateTruckUI()
    local currentNum = math.min(CurrentTruckIndex + 1, math.max(TrucksToday, 1))
    if IsValid(StatusUIBehaviour) then
        StatusUIBehaviour.CallFunction("SetTruckCount", currentNum, TrucksToday)
    end
    if IsValid(OrderUIBehaviour) then
        OrderUIBehaviour.CallFunction("SetTruckCount", currentNum, TrucksToday)
    end
end

local function SetNextTruckETAUI(seconds)
    local s = math.max(0, math.ceil(seconds))
    if IsValid(StatusUIBehaviour) then
        StatusUIBehaviour.CallFunction("SetNextTruckETA", s)
    end
    if IsValid(OrderUIBehaviour) then
        OrderUIBehaviour.CallFunction("SetNextTruckETA", s)
    end
end

-- Stubs you can wire to your truck animation/scene logic
function TruckLeave()
    print("[Truck] Leaving bay...")
end

function TruckArrive()
    print("[Truck] Arriving at bay...")
end

-- =========================
-- Package Registration Stabilization (3s quiet)
-- =========================
local _lastPackageCount = 0
local _lastPackageChangeTime = 0
local _packagesStable = false

local function CountAllPackages()
    local total = 0
    for _, list in pairs(WarehouseContents) do
        if list then total = total + #list end
    end
    return total
end

local function HasAnyPackages()
    return CountAllPackages() > 0
end

local function PackagesStableFor3Seconds()
    if _lastPackageCount == 0 then
        return false
    end
    return (Time.time - _lastPackageChangeTime) >= 3.0
end

-- =========================
-- Per-truck order generation (manual)
-- =========================
local function maybe_add(tbl, pkg)
    if pkg ~= nil and IsValid(pkg) then table.insert(tbl, pkg) end
end

-- Build all truck orders for the current day (MANUAL per day, currently two trucks each).
-- You can change only the TrucksPerDay table later and extend this function accordingly.
local function GenerateAllTruckOrdersForDay(dayToken, trucksCount)
    TruckOrders = {}

    local t1 = {}  -- Truck 1 order list
    local t2 = {}  -- Truck 2 order list

    if dayToken == "DAY1" then
        -- Truck 1
        maybe_add(t1, FindPackage("A", "A", 2))
        -- Truck 2
        maybe_add(t2, FindPackage("A", "A", 4))
        Bonus  = 100
        ParTime = 60 * 1.0

    elseif dayToken == "DAY2" then
        -- Truck 1
        maybe_add(t1, FindPackage("B", "A", 4))
        -- Truck 2
        maybe_add(t2, FindPackage("B", "A", 5))
        Bonus  = 150
        ParTime = 60 * 1.5

    elseif dayToken == "DAY3" then
        -- Truck 1
        maybe_add(t1, FindPackage("C", "A", 6))
        maybe_add(t1, FindPackage("C", "B", 7))
        -- Truck 2
        maybe_add(t2, FindPackage("B", "C", 6))
        maybe_add(t2, FindPackage("D", "A", 3))
        Bonus  = 200
        ParTime = 60 * 2.0

    elseif dayToken == "DAY4" then
        -- Truck 1
        maybe_add(t1, FindPackage("D", "A", 6))
        maybe_add(t1, FindPackage("C", "A", 4))
        -- Truck 2
        maybe_add(t2, FindPackage("A", "D", 8))
        maybe_add(t2, FindPackage("D", "D", 5))
        Bonus  = 250
        ParTime = 60 * 2.5

    elseif dayToken == "DAY5" then
        -- Truck 1
        maybe_add(t1, FindPackage("A", "B", 6))
        maybe_add(t1, FindPackage("B", "D", 2))
        -- Truck 2
        maybe_add(t2, FindPackage("C", "B", 8))
        maybe_add(t2, FindPackage("D", "C", 3))
        Bonus  = 300
        ParTime = 60 * 3.0

    else
        -- Fallback if an unknown day sneaks in; still two trucks.
        maybe_add(t1, FindPackage("A", "A", 2))
        maybe_add(t2, FindPackage("A", "C", 4))
        Bonus  = 100
        ParTime = 60 * 1.0
    end

    -- Enforce exactly 2 entries for now (you can extend to more later)
    TruckOrders[1] = t1
    TruckOrders[2] = t2

    -- Activate Truck 1
    CurrentTruckIndex = 0
    CurrentOrder = TruckOrders[1]

    OrderStartTime = nil
    OrderTime = nil
    OrderTimePassed = 0
    DayOrderQueued = true

    print(string.format("[Orders] Generated %d manual truck orders for %s", #TruckOrders, dayToken))
end

-- =========================
-- Order generation gating (per-day, waits for 3s stability)
-- =========================
local function EnsureOrdersForCurrentDay()
    if DayOrderQueued then return end
    if not IsValid(OrderUIBehaviour) then return end
    if not HasAnyPackages() then return end
    if not PackagesStableFor3Seconds() then return end

    local day = StateToDayToken(GetState())
    TrucksToday = GetTrucksForDay(day)
    GenerateAllTruckOrdersForDay(day, TrucksToday)
    UpdateTruckUI()
    UpdateOrderBoard()
end

-- =========================
-- FSM State handlers
-- =========================
local function RESET_DAY_STATE()
    DayOrderQueued = false
    TruckOrders = nil
    CurrentOrder = nil
    CurrentTruckIndex = 0
    WaitingNextTruck = false
    TrucksToday = GetTrucksForDay(StateToDayToken(GetState()))
    UpdateTruckUI()
end

local function FIRST_DAY_ENTER(self)  RESET_DAY_STATE() EnsureOrdersForCurrentDay() end
local function SECOND_DAY_ENTER(self) RESET_DAY_STATE() EnsureOrdersForCurrentDay() end
local function THIRD_DAY_ENTER(self)  RESET_DAY_STATE() EnsureOrdersForCurrentDay() end
local function FOURTH_DAY_ENTER(self) RESET_DAY_STATE() EnsureOrdersForCurrentDay() end
local function FIFTH_DAY_ENTER(self)  RESET_DAY_STATE() EnsureOrdersForCurrentDay() end

-- =========================
-- Lifecycle
-- =========================
function Start()
    WarehouseBudget = 150
    WarehouseContents = {}
    TruckOrders = nil
    CurrentOrder = nil

    StatusUI = API_GameObject.BL_FindInWorld("StatusUI")
    StatusUIBehaviour = API_GameObject.BL_GetComponent(StatusUI,"LuaBehaviour")

    OrderUI = API_GameObject.BL_FindInWorld("OrderUI")
    OrderUIBehaviour = API_GameObject.BL_GetComponent(OrderUI,"LuaBehaviour")

    OrderStartTime = nil
    OrderTime = nil
    OrderTimePassed = 0
    Bonus = nil
    ParTime = nil

    -- init stabilization counters
    _lastPackageCount = 0
    _lastPackageChangeTime = Time.time
    _packagesStable = false

    -- Build the Day FSM
    DaySM = FSM.new({ name = "WarehouseDays", host = BL_Host, debug = false })
    FSM.add_state(DaySM, "FirstDay",  { on_enter = FIRST_DAY_ENTER })
    FSM.add_state(DaySM, "SecondDay", { on_enter = SECOND_DAY_ENTER })
    FSM.add_state(DaySM, "ThirdDay",  { on_enter = THIRD_DAY_ENTER  })
    FSM.add_state(DaySM, "FourthDay", { on_enter = FOURTH_DAY_ENTER })
    FSM.add_state(DaySM, "FifthDay",  { on_enter = FIFTH_DAY_ENTER  })

    -- Start the week on FirstDay
    ChangeState("FirstDay", true)
end


function Update()
    if (not IsValid(OrderUIBehaviour)) then
        OrderUI = API_GameObject.BL_FindInWorld("OrderUI")
        if (IsValid(OrderUI)) then  
            OrderUIBehaviour = API_GameObject.BL_GetComponent(OrderUI, "LuaBehaviour")
        end
        return
    end

    -- Inter-truck waiting: countdown + arrival
    if WaitingNextTruck then
        local remaining = math.max(0, NextTruckArriveAt - Time.time)
        SetNextTruckETAUI(remaining)
        if remaining <= 0 then
            WaitingNextTruck = false
            SetNextTruckETAUI(0)
            TruckArrive()
            --UnlockUIs()

            -- Activate next truck's order
            CurrentOrder = TruckOrders[CurrentTruckIndex + 1]
            OrderStartTime = nil
            OrderTime = nil
            OrderTimePassed = 0
            UpdateTruckUI()
            UpdateOrderBoard()
        end
        return -- while locked for next truck, skip order generation
    else
        --only reduce order time when not waiting for a truck
        OrderTimePassed = OrderTimePassed+Time.deltaTime
    end

    -- Only generate when the board is unlocked and we meet stability condition
    local orderBoardLocked = OrderUIBehaviour.GetScriptVariable("Locked") 
    if (not orderBoardLocked) then
        EnsureOrdersForCurrentDay()
    end
end

function SlowUpdate()
    if(not IsValid(StatusUIBehaviour)) then
        return
    end

    local StatusUILocked = StatusUIBehaviour.GetScriptVariable("Locked")
    if(not StatusUILocked) then
        if(OrderStartTime == nil) then
            OrderStartTime = Time.time
        end

        --local timePassed = Time.time-OrderStartTime -- seconds
        OrderTime = ParTime-OrderTimePassed
        StatusUIBehaviour.CallFunction("SetTimeString",OrderTime)

        local orderCount = GetOrderCount(CurrentOrder)
        local fufilledOrderCount = GetFufilledOrderCount(CurrentOrder)

        StatusUIBehaviour.CallFunction("SetItemsCollectedString",fufilledOrderCount)
        StatusUIBehaviour.CallFunction("SetOrderSizeString",orderCount)
        StatusUIBehaviour.CallFunction("SetBonusString",CalculateBonus(),OrderTime<=0)
    end
end

-- =========================
-- Budget / Utility
-- =========================
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

-- =========================
-- Orders / UI
-- =========================
function GetOrderCount(order)
    local packageCount = 0
    for _, value in ipairs(order or {}) do
        if(value ~= nil and IsValid(value)) then
            packageCount = packageCount+1
        end
    end
    return packageCount
end

function GetFufilledOrderCount(order)
    local loadedPackageCount = 0
    for _, value in ipairs(order or {}) do
        if(value ~= nil and IsValid(value)) then
            local itemLoaded = value.GetScriptVariable("ItemLoaded")
            if(itemLoaded) then
                loadedPackageCount = loadedPackageCount+1
            end
        end
    end
    return loadedPackageCount
end

OrderItemSlots = {}

function UpdateOrderBoard()
    if not IsValid(OrderUI) then
        OrderUI = API_GameObject.BL_FindInWorld("OrderUI")
        if not IsValid(OrderUI) then
            print("OrderUI not found")
            return
        end
    end

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

            local qr = CurrentOrder and CurrentOrder[i] or nil
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
    if(fufilledOrderCount >= orderCount and orderCount > 0) then
        -- Scoring for this truck
        local bonus = CalculateBonus()
        local baseEarnings = orderCount * 50
        AddBudget(baseEarnings + bonus)

        print(string.format("Truck %d/%d order complete! +%d base, +%d bonus",
            CurrentTruckIndex+1, TrucksToday, baseEarnings, bonus))

        local isLastTruck = (CurrentTruckIndex + 1) >= TrucksToday
        if isLastTruck then
            -- Final truck for the day: show end-of-shift UIs (AdvanceDay() will move the day on)
            if IsValid(StatusUIBehaviour) then
                StatusUIBehaviour.CallFunction("TerminalDisplayShiftOver", baseEarnings, bonus)
            end
            if IsValid(OrderUIBehaviour) then
                OrderUIBehaviour.CallFunction("TerminalDisplayShiftOver", baseEarnings, bonus)
            end

            -- Clear active data; wait for external AdvanceDay()
            CurrentOrder = nil
            OrderStartTime = nil
            OrderTime = nil
            OrderTimePassed = 0
            DayOrderQueued = false

        else
            -- Intermediate truck: depart, lock, wait, arrive, then load next truck order
            TruckLeave()
            --LockUIs()

            -- schedule next
            WaitingNextTruck = true
            NextTruckArriveAt = Time.time + NextTruckDelayS
            SetNextTruckETAUI(NextTruckDelayS)

            -- advance to next truck slot; we'll activate its order on arrival
            CurrentTruckIndex = CurrentTruckIndex + 1
            CurrentOrder = nil
            --don't reset time between trucks
           -- OrderStartTime = nil
          --  OrderTime = nil
           -- OrderTimePassed = 0
            UpdateTruckUI()
        end
    end
end

function FillOrderBoardSlot(slot, QRCode, location)
    if(not IsValid(QRCode)) then
        print("QRCode is not valid")
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

    local isLoaded = QRCode.GetScriptVariable("ItemLoaded") == true
    if(isLoaded) then
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

-- =========================
-- Lookup / Registration
-- =========================
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

        local packages = WarehouseContents[key]
        if packages and #packages > 0 then
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
        local qrCodeShelf  = QRCode.GetScriptVariable("ShelfPosition")   -- A-D
        local qrCodeRow    = QRCode.GetScriptVariable("RowPosition")     -- A-D
        local qrCodeColumn = QRCode.GetScriptVariable("ColumnPosition")  -- 1-8

        if(qrCodeShelf == nil or qrCodeRow == nil or qrCodeColumn == nil) then
            return
        end

        local qrCodeLocation = string.format("%s-%s-%d", qrCodeShelf, qrCodeRow, qrCodeColumn)
        if WarehouseContents[qrCodeLocation] == nil then
            WarehouseContents[qrCodeLocation] = {}
        end

        table.insert(WarehouseContents[qrCodeLocation], QRCode)

        -- Track new packages to detect when registration stabilizes
        local total = CountAllPackages()
        if total ~= _lastPackageCount then
            _lastPackageCount = total
            _lastPackageChangeTime = Time.time
            _packagesStable = false
        end
        -- Do NOT generate orders here; we wait for 3s stability via Update()->EnsureOrdersForCurrentDay()
    else
        print("Failed to register package: " .. tostring(spawnedObject))
    end
end

-- =========================
-- Day advance hook (unchanged API)
-- =========================
function AdvanceDay(nil1, nil2, nil3, nil4)
    if not IsValid(OrderUIBehaviour) or not IsValid(StatusUIBehaviour) then
        print("[AdvanceDay] UI behaviours not valid yet; aborting.")
        return
    end

    local ShiftComplete = OrderUIBehaviour.GetScriptVariable("ShiftOver")
    if not ShiftComplete then
        print("[AdvanceDay] Shift not flagged complete.")
        return
    end

    -- lock and reset
    if IsValid(OrderUIBehaviour) then OrderUIBehaviour.CallFunction("ShowLockedUI") end
    if IsValid(StatusUIBehaviour) then StatusUIBehaviour.CallFunction("ShowLockedUI") end

    TruckOrders = nil
    CurrentOrder = nil
    OrderStartTime = nil
    OrderTime = nil
    OrderTimePassed = 0
    DayOrderQueued = false

    -- reset stabilization window baseline
    _lastPackageCount = CountAllPackages()
    _lastPackageChangeTime = Time.time
    _packagesStable = false

    -- advance day
    local st = GetState()
    if st == "FirstDay" then
        ChangeState("SecondDay", true)
    elseif st == "SecondDay" then
        ChangeState("ThirdDay", true)
    elseif st == "ThirdDay" then
        ChangeState("FourthDay", true)
    elseif st == "FourthDay" then
        ChangeState("FifthDay", true)
    else
        ChangeState("FirstDay", true)
    end

    -- Prepare truck counters for the new day
    TrucksToday = GetTrucksForDay(StateToDayToken(GetState()))
    CurrentTruckIndex = 0
    WaitingNextTruck = false
    UpdateTruckUI()

    print("[AdvanceDay] Advanced to next day and locked UIs; waiting for QR scans to stabilize before generating the next day's truck orders.")
end
