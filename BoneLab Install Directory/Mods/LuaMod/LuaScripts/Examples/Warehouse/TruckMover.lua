-- =========================================================
-- TruckAnimator.lua
-- Lua / MoonSharp script for Unity / Bonelab-style mod
-- =========================================================

local FSM = loadmodule("fsm.lua")

-- ==== Tunables ====
local DRIVE_SPEED     = 8.0      -- forward drive speed (m/s)
local REVERSE_SPEED   = 5.0      -- reverse speed (m/s)
local TURN_SPEED_DEG  = 180.0    -- turning speed (deg/s)
local TURN_FINISH_YAW = 90.0     -- yaw after turn
local RETURN_FINISH_YAW = -90.0  -- yaw on return
local EPS_POS         = 0.05
local EPS_YAW         = 1.0

-- ==== References ====
TruckBody       = nil
ForwardPos      = nil
TurnFinishPos   = nil
EndPos          = nil
ArriveStartPos  = nil
TruckReversePos = nil
OriginPos       = nil

-- ==== Internal ====
TruckSM = nil

-- =========================================================
-- STATE HELPERS
-- =========================================================

function MoveTowards(current, target, speed, dt)
    local to = target - current
    local dist = to.magnitude
    if dist <= EPS_POS then return target, true end
    local step = speed * dt
    if step >= dist then return target, true end
    return current + to.normalized * step, false
end

function RotateTowardsYaw(currentRot, targetYaw, turnSpeed, dt)
    local currentYaw = currentRot.eulerAngles.y
    local newYaw = Mathf.MoveTowardsAngle(currentYaw, targetYaw, turnSpeed * dt)
    local newRot = Quaternion.Euler(0, newYaw, 0)
    local done = math.abs(Mathf.DeltaAngle(newYaw, targetYaw)) < EPS_YAW
    return newRot, done
end

-- =========================================================
-- STATE: TRUCK_LEAVE
-- =========================================================
function STATE_LEAVE_ENTER(self, prev)
    print("Truck: starting leave sequence")
    self.stage = 0
end

function STATE_LEAVE_UPDATE(self, dt)
    local pos = TruckBody.transform.position
    local rot = TruckBody.transform.rotation

    if self.stage == 0 then
        local newPos, done = MoveTowards(pos, ForwardPos.position, DRIVE_SPEED, dt)
        TruckBody.transform.position = newPos
        if done then self.stage = 1 end

    elseif self.stage == 1 then
        -- Turning arc toward TurnFinishPos and yaw 90°
        local newPos, donePos = MoveTowards(pos, TurnFinishPos.position, DRIVE_SPEED, dt)
        local newRot, doneRot = RotateTowardsYaw(rot, TURN_FINISH_YAW, TURN_SPEED_DEG, dt)
        TruckBody.transform.position = newPos
        TruckBody.transform.rotation = newRot
        if donePos and doneRot then self.stage = 2 end

    elseif self.stage == 2 then
        local newPos, done = MoveTowards(pos, EndPos.position, DRIVE_SPEED, dt)
        TruckBody.transform.position = newPos
        if done then
            print("Truck reached EndPos")
            FSM.set_state(TruckSM, "IDLE")
        end
    end
end

-- =========================================================
-- STATE: TRUCK_ARRIVE
-- =========================================================
function STATE_ARRIVE_ENTER(self, prev)
    print("Truck: starting arrive sequence")
    TruckBody.transform.position = ArriveStartPos.position
    self.stage = 0
end

function STATE_ARRIVE_UPDATE(self, dt)
    local pos = TruckBody.transform.position
    local rot = TruckBody.transform.rotation

    if self.stage == 0 then
        local newPos, done = MoveTowards(pos, TruckReversePos.position, DRIVE_SPEED, dt)
        TruckBody.transform.position = newPos
        if done then self.stage = 1 end

    elseif self.stage == 1 then
        -- Reverse while rotating toward yaw -90°
        local newPos, donePos = MoveTowards(pos, OriginPos.position, REVERSE_SPEED, dt)
        local newRot, doneRot = RotateTowardsYaw(rot, RETURN_FINISH_YAW, TURN_SPEED_DEG, dt)
        TruckBody.transform.position = newPos
        TruckBody.transform.rotation = newRot

        if donePos and doneRot then
            print("Truck returned to origin")
            FSM.set_state(TruckSM, "IDLE")
        end
    end
end

-- =========================================================
-- STATE: IDLE
-- =========================================================
function STATE_IDLE_ENTER(self, prev)
    -- Do nothing
end

function STATE_IDLE_UPDATE(self, dt)
    self.timer = (self.timer or 0) + dt
    if self.timer > 5.0 then  -- wait 5 seconds
        self.timer = 0
        TruckLeave()
    end
end

-- =========================================================
-- FUNCTIONS TO START MOVEMENTS
-- =========================================================
function TruckLeave()
    FSM.set_state(TruckSM, "LEAVE")
end

function TruckArrive()
    FSM.set_state(TruckSM, "ARRIVE")
end

-- =========================================================
-- UNITY LIFECYCLE
-- =========================================================
function Start()
    TruckBody       = API_GameObject.BL_FindInChildren(BL_Host, "TruckBody")
    ForwardPos      = API_GameObject.BL_FindInChildren(BL_Host, "ForwardPos").transform
    TurnFinishPos   = API_GameObject.BL_FindInChildren(BL_Host, "TurnFinishPos").transform
    EndPos          = API_GameObject.BL_FindInChildren(BL_Host, "EndPos").transform
    ArriveStartPos  = API_GameObject.BL_FindInChildren(BL_Host, "ArriveStartPos").transform
    TruckReversePos = API_GameObject.BL_FindInChildren(BL_Host, "TurnFinishPos").transform
    OriginPos       = API_GameObject.BL_FindInChildren(BL_Host, "OriginPos").transform

    TruckSM = FSM.new({ name = "TruckAnimator", host = BL_Host, debug = false })
    FSM.add_state(TruckSM, "IDLE",   { on_enter = STATE_IDLE_ENTER,   on_update = STATE_IDLE_UPDATE   })
    FSM.add_state(TruckSM, "LEAVE",  { on_enter = STATE_LEAVE_ENTER,  on_update = STATE_LEAVE_UPDATE  })
    FSM.add_state(TruckSM, "ARRIVE", { on_enter = STATE_ARRIVE_ENTER, on_update = STATE_ARRIVE_UPDATE })

    FSM.set_state(TruckSM, "IDLE", true)
end

function Update()
    FSM.update(TruckSM, Time.deltaTime)
end
