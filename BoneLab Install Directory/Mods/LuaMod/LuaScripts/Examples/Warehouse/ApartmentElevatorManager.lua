local FSM = loadmodule("fsm.lua")

-- ==== Tunables ====
DoorOpenTimeS  = 2.0
DoorCloseTimeS = 2.0
TravelTimeS    = 10.0
DoorHoldS      = 3.0

-- ==== Refs ====
TopDoors = nil
TopLeftDoor = nil
TopRightDoor = nil

BottomDoors = nil
BottomLeftDoor = nil
BottomRightDoor = nil

Elevator = nil
ElevatorLeftDoor = nil
ElevatorRightDoor = nil

TopAnchor = nil
BottomAnchor = nil

-- ==== Rigidbodies (kinematic) ====
TopLeftRB = nil
TopRightRB = nil
BottomLeftRB = nil
BottomRightRB = nil
CarLeftRB = nil
CarRightRB = nil
ElevatorRB = nil

-- ==== Precomputed positions ====
TopLeftClosed = nil
TopLeftOpen = nil
TopRightClosed = nil
TopRightOpen = nil

BottomLeftClosed = nil
BottomLeftOpen = nil
BottomRightClosed = nil
BottomRightOpen = nil

CarLeftClosed = nil
CarLeftOpen = nil
CarRightClosed = nil
CarRightOpen = nil

-- ==== Car door local-space poses ====
CarLeftClosedLocal = nil
CarLeftOpenLocal   = nil
CarRightClosedLocal = nil
CarRightOpenLocal   = nil

-- Parent transform for car doors local->world
CarDoorsParent = nil

-- Shared open vector (same for all doors, negated for right doors)
OpenVector = nil

-- ==== Audio (named child GameObjects) ====
DoorMoveSoundGO = nil
TravelSoundGO   = nil
DingSoundGO     = nil

DoorMoveSound = nil   -- AudioSource
TravelSound   = nil   -- AudioSource
DingSound     = nil   -- AudioSource

-- ==== Runtime ====
local _sm = nil
local _t = 0.0
local _dur = 1.0
local _holdUntil = 0.0
local _wantUp = false
local _wantDown = false
local _carFrom = nil
local _carTo = nil

-- -------------------------
-- State change utility
-- -------------------------
function ChangeState(name, force)
    FSM.set_state(_sm, name, force)
end

function GetState()
    return FSM.get_state(_sm)
end

-- -------------------------
-- Audio helpers
-- -------------------------
local function PlayDoorMove()
    if IsValid(DoorMoveSound) and not DoorMoveSound.isPlaying then
        DoorMoveSound.Play()
    end
end

local function StopDoorMove()
    if IsValid(DoorMoveSound) and DoorMoveSound.isPlaying then
        DoorMoveSound.Stop()
    end
end

local function PlayTravel()
    if IsValid(TravelSound) and not TravelSound.isPlaying then
        TravelSound.Play()
    end
end

local function StopTravel()
    if IsValid(TravelSound) and TravelSound.isPlaying then
        TravelSound.Stop()
    end
end

local function PlayDing()
    if IsValid(DingSound) and not DingSound.isPlaying then
        DingSound.Play()
    end
end

-- -------------------------
-- Easing (for cab travel only)
-- -------------------------
local function EaseInOutCubic(t)
    -- Smooth ease-in/ease-out: 3t^2 - 2t^3
    return (3.0 * t * t) - (2.0 * t * t * t)
end

-- ==== Snap helpers (teleport kinematic RBs at setup/state boundaries) ====
local function SnapTopClosed()
    TopLeftRB.position = TopLeftClosed
    TopRightRB.position = TopRightClosed
end

local function SnapTopOpen()
    TopLeftRB.position = TopLeftOpen
    TopRightRB.position = TopRightOpen
end

local function SnapBottomClosed()
    BottomLeftRB.position = BottomLeftClosed
    BottomRightRB.position = BottomRightClosed
end

local function SnapBottomOpen()
    BottomLeftRB.position = BottomLeftOpen
    BottomRightRB.position = BottomRightOpen
end

local function SnapCarClosed()
    CarLeftRB.position  = CarDoorsParent:TransformPoint(CarLeftClosedLocal)
    CarRightRB.position = CarDoorsParent:TransformPoint(CarRightClosedLocal)
end

local function SnapCarOpen()
    CarLeftRB.position  = CarDoorsParent:TransformPoint(CarLeftOpenLocal)
    CarRightRB.position = CarDoorsParent:TransformPoint(CarRightOpenLocal)
end

-- Public triggers
function GoUp()
    _wantUp = true
end

function GoDown()
    _wantDown = true
end

-- ==== Setup ====
function Start()
    TopDoors = API_GameObject.BL_FindInChildren(BL_Host, "TopDoors")
    TopLeftDoor = API_GameObject.BL_FindInChildren(TopDoors, "LeftDoor")
    TopRightDoor = API_GameObject.BL_FindInChildren(TopDoors, "RightDoor")

    BottomDoors = API_GameObject.BL_FindInChildren(BL_Host, "BottomDoors")
    BottomLeftDoor = API_GameObject.BL_FindInChildren(BottomDoors, "LeftDoor")
    BottomRightDoor = API_GameObject.BL_FindInChildren(BottomDoors, "RightDoor")

    Elevator = API_GameObject.BL_FindInChildren(BL_Host, "Elevator")
    ElevatorDoors = API_GameObject.BL_FindInChildren(Elevator, "Doors")
    ElevatorLeftDoor = API_GameObject.BL_FindInChildren(ElevatorDoors, "LeftDoor")
    ElevatorRightDoor = API_GameObject.BL_FindInChildren(ElevatorDoors, "RightDoor")

    TopAnchor = API_GameObject.BL_FindInChildren(BL_Host, "TopAnchor")
    BottomAnchor = API_GameObject.BL_FindInChildren(BL_Host, "BottomAnchor")

    -- Audio sources by name
    DoorMoveSoundGO = API_GameObject.BL_FindInChildren(Elevator, "DoorMoveSound")
    TravelSoundGO   = API_GameObject.BL_FindInChildren(Elevator, "TravelSound")
    DingSoundGO     = API_GameObject.BL_FindInChildren(Elevator, "DingSound")

    if DoorMoveSoundGO ~= nil then
        DoorMoveSound = API_GameObject.BL_GetComponent(DoorMoveSoundGO, "AudioSource")
    end
    if TravelSoundGO ~= nil then
        TravelSound = API_GameObject.BL_GetComponent(TravelSoundGO, "AudioSource")
    end
    if DingSoundGO ~= nil then
        DingSound = API_GameObject.BL_GetComponent(DingSoundGO, "AudioSource")
    end

    -- Cache Rigidbodies (must be kinematic)
    TopLeftRB = API_GameObject.BL_GetComponent(TopLeftDoor, "Rigidbody")
    TopRightRB = API_GameObject.BL_GetComponent(TopRightDoor, "Rigidbody")
    BottomLeftRB = API_GameObject.BL_GetComponent(BottomLeftDoor, "Rigidbody")
    BottomRightRB = API_GameObject.BL_GetComponent(BottomRightDoor, "Rigidbody")
    CarLeftRB = API_GameObject.BL_GetComponent(ElevatorLeftDoor, "Rigidbody")
    CarRightRB = API_GameObject.BL_GetComponent(ElevatorRightDoor, "Rigidbody")
    ElevatorRB = API_GameObject.BL_GetComponent(Elevator, "Rigidbody")

    -- Closed bases (read current RB positions)
    TopLeftClosed     = TopLeftRB.position
    TopRightClosed    = TopRightRB.position
    BottomLeftClosed  = BottomLeftRB.position
    BottomRightClosed = BottomRightRB.position

    -- Car door LOCAL closed poses (relative to Elevator/Doors)
    CarLeftClosedLocal  = ElevatorLeftDoor.transform.localPosition
    CarRightClosedLocal = ElevatorRightDoor.transform.localPosition

    -- Parent for TransformPoint
    CarDoorsParent = ElevatorDoors.transform

    -- Define a single LOCAL slide vector (same for all doors).
    local OpenVectorLocal = API_Vector.BL_Vector3(1.12, 0, 0)  -- slide along local +X (adjust)

    -- Station doors: compute WORLD open targets (accounts for parent rotation)
    local tl_world = TopLeftDoor.transform:TransformDirection(OpenVectorLocal)
    local tr_world = TopRightDoor.transform:TransformDirection(OpenVectorLocal)
    local bl_world = BottomLeftDoor.transform:TransformDirection(OpenVectorLocal)
    local br_world = BottomRightDoor.transform:TransformDirection(OpenVectorLocal)

    TopLeftOpen      = TopLeftClosed     + tl_world
    TopRightOpen     = TopRightClosed    - tr_world
    BottomLeftOpen   = BottomLeftClosed  + bl_world
    BottomRightOpen  = BottomRightClosed - br_world

    -- Car doors: compute LOCAL open poses (so they follow elevator motion)
    CarLeftOpenLocal  = CarLeftClosedLocal  + OpenVectorLocal
    CarRightOpenLocal = CarRightClosedLocal - OpenVectorLocal

    -- Optional world copies
    CarLeftClosed  = CarDoorsParent:TransformPoint(CarLeftClosedLocal)
    CarRightClosed = CarDoorsParent:TransformPoint(CarRightClosedLocal)
    CarLeftOpen    = CarDoorsParent:TransformPoint(CarLeftOpenLocal)
    CarRightOpen   = CarDoorsParent:TransformPoint(CarRightOpenLocal)

    -- Start car at top instantly
    ElevatorRB.position = TopAnchor.transform.position

    -- FSM states
    _sm = FSM.new({ name = "TwoStopElevator", host = BL_Host, debug = false })

    FSM.add_state(_sm, "TOP_WAIT_OPEN", { on_enter = TOP_WAIT_OPEN_ENTER, on_update = TOP_WAIT_OPEN_UPDATE })
    FSM.add_state(_sm, "TOP_DOORS_CLOSING", { on_enter = TOP_DOORS_CLOSING_ENTER, on_update = TOP_DOORS_CLOSING_UPDATE })
    FSM.add_state(_sm, "TRAVELING_DOWN", { on_enter = TRAVELING_DOWN_ENTER, on_update = TRAVELING_DOWN_UPDATE })
    FSM.add_state(_sm, "BOTTOM_DOORS_OPENING", { on_enter = BOTTOM_DOORS_OPENING_ENTER, on_update = BOTTOM_DOORS_OPENING_UPDATE })
    FSM.add_state(_sm, "BOTTOM_WAIT_OPEN",     { on_enter = BOTTOM_WAIT_OPEN_ENTER,     on_update = BOTTOM_WAIT_OPEN_UPDATE })
    FSM.add_state(_sm, "BOTTOM_DOORS_CLOSING", { on_enter = BOTTOM_DOORS_CLOSING_ENTER, on_update = BOTTOM_DOORS_CLOSING_UPDATE })
    FSM.add_state(_sm, "TRAVELING_UP",         { on_enter = TRAVELING_UP_ENTER,         on_update = TRAVELING_UP_UPDATE })
    FSM.add_state(_sm, "TOP_DOORS_OPENING",    { on_enter = TOP_DOORS_OPENING_ENTER,    on_update = TOP_DOORS_OPENING_UPDATE })


    
end

-- ==== TOP: waiting (open) ====
function TOP_WAIT_OPEN_ENTER(self)
    SnapTopOpen()
    SnapCarOpen()
    _holdUntil = Time.time + DoorHoldS
    StopDoorMove()
    StopTravel()
end

function TOP_WAIT_OPEN_UPDATE(self, dt)
    if _wantDown then
        _wantDown = false
        ChangeState("TOP_DOORS_CLOSING", true)
        return
    end
end

-- ==== TOP: doors closing ====
function TOP_DOORS_CLOSING_ENTER(self)
    _t = 0.0
    _dur = DoorCloseTimeS
    SnapTopOpen()
    SnapCarOpen()
end

function TOP_DOORS_CLOSING_UPDATE(self, dt)
    _t = math.min(1.0, _t + dt / _dur)
    PlayDoorMove()

    TopLeftRB:MovePosition(  Vector3.Lerp(TopLeftOpen,   TopLeftClosed,   _t) )
    TopRightRB:MovePosition( Vector3.Lerp(TopRightOpen,  TopRightClosed,  _t) )

    local carLeftLocal  = Vector3.Lerp(CarLeftOpenLocal,  CarLeftClosedLocal,  _t)
    local carRightLocal = Vector3.Lerp(CarRightOpenLocal, CarRightClosedLocal, _t)
    CarLeftRB:MovePosition(  CarDoorsParent:TransformPoint(carLeftLocal) )
    CarRightRB:MovePosition( CarDoorsParent:TransformPoint(carRightLocal) )

    if _t >= 1.0 then
        StopDoorMove()
        SnapTopClosed()
        SnapCarClosed()
        ChangeState("TRAVELING_DOWN", true)
        return
    end
end

-- ==== Travel down (ACCEL/DECEL) ====
function TRAVELING_DOWN_ENTER(self)
    _t = 0.0
    _dur = TravelTimeS
    _carFrom = ElevatorRB.position
    _carTo = TopAnchor and BottomAnchor.transform.position or ElevatorRB.position -- safety if anchors missing
    _carTo = BottomAnchor.transform.position
end

function TRAVELING_DOWN_UPDATE(self, dt)
    _t = math.min(1.0, _t + dt / _dur)
    PlayTravel()

    -- Ease the interpolation for acceleration/deceleration
    local te = EaseInOutCubic(_t)
    local desiredElevatorPos = Vector3.Lerp(_carFrom, _carTo, te)
    ElevatorRB:MovePosition(desiredElevatorPos)

    -- keep car doors closed relative to cab
    CarLeftRB:MovePosition(  CarDoorsParent:TransformPoint(CarLeftClosedLocal) )
    CarRightRB:MovePosition( CarDoorsParent:TransformPoint(CarRightClosedLocal) )

    if _t >= 1.0 then
        StopTravel()
        ChangeState("BOTTOM_DOORS_OPENING", true)
        return
    end
end

-- ==== BOTTOM: doors opening ====
function BOTTOM_DOORS_OPENING_ENTER(self)
    _t = 0.0
    _dur = DoorOpenTimeS
    SnapBottomClosed()
    SnapCarClosed()
    PlayDing()
end

function BOTTOM_DOORS_OPENING_UPDATE(self, dt)
    _t = math.min(1.0, _t + dt / _dur)
    PlayDoorMove()

    BottomLeftRB:MovePosition(  Vector3.Lerp(BottomLeftClosed,  BottomLeftOpen,  _t) )
    BottomRightRB:MovePosition( Vector3.Lerp(BottomRightClosed, BottomRightOpen, _t) )

    local carLeftLocal  = Vector3.Lerp(CarLeftClosedLocal,  CarLeftOpenLocal,  _t)
    local carRightLocal = Vector3.Lerp(CarRightClosedLocal, CarRightOpenLocal, _t)
    CarLeftRB:MovePosition(  CarDoorsParent:TransformPoint(carLeftLocal) )
    CarRightRB:MovePosition( CarDoorsParent:TransformPoint(carRightLocal) )

    if _t >= 1.0 then
        StopDoorMove()
        ChangeState("BOTTOM_WAIT_OPEN", true)
        return
    end
end

-- ==== BOTTOM: waiting (open) ====
function BOTTOM_WAIT_OPEN_ENTER(self)
    SnapBottomOpen()
    SnapCarOpen()
    _holdUntil = Time.time + DoorHoldS
    StopDoorMove()
    StopTravel()
end

function BOTTOM_WAIT_OPEN_UPDATE(self, dt)
    if _wantUp then
        _wantUp = false
        ChangeState("BOTTOM_DOORS_CLOSING", true)
        return
    end
end

-- ==== BOTTOM: doors closing ====
function BOTTOM_DOORS_CLOSING_ENTER(self)
    _t = 0.0
    _dur = DoorCloseTimeS
    SnapBottomOpen()
    SnapCarOpen()
end

function BOTTOM_DOORS_CLOSING_UPDATE(self, dt)
    _t = math.min(1.0, _t + dt / _dur)
    PlayDoorMove()

    BottomLeftRB:MovePosition(  Vector3.Lerp(BottomLeftOpen,  BottomLeftClosed,  _t) )
    BottomRightRB:MovePosition( Vector3.Lerp(BottomRightOpen, BottomRightClosed, _t) )

    local carLeftLocal  = Vector3.Lerp(CarLeftOpenLocal,  CarLeftClosedLocal,  _t)
    local carRightLocal = Vector3.Lerp(CarRightOpenLocal, CarRightClosedLocal, _t)
    CarLeftRB:MovePosition(  CarDoorsParent:TransformPoint(carLeftLocal) )
    CarRightRB:MovePosition( CarDoorsParent:TransformPoint(carRightLocal) )

    if _t >= 1.0 then
        StopDoorMove()
        SnapBottomClosed()
        SnapCarClosed()
        ChangeState("TRAVELING_UP", true)
        return
    end
end

-- ==== Travel up (ACCEL/DECEL) ====
function TRAVELING_UP_ENTER(self)
    _t = 0.0
    _dur = TravelTimeS
    _carFrom = ElevatorRB.position
    _carTo = TopAnchor.transform.position
end

function TRAVELING_UP_UPDATE(self, dt)
    _t = math.min(1.0, _t + dt / _dur)
    PlayTravel()

    -- Ease the interpolation for acceleration/deceleration
    local te = EaseInOutCubic(_t)
    local desiredElevatorPos = Vector3.Lerp(_carFrom, _carTo, te)
    ElevatorRB:MovePosition(desiredElevatorPos)

    -- keep car doors closed relative to cab
    CarLeftRB:MovePosition(  CarDoorsParent:TransformPoint(CarLeftClosedLocal) )
    CarRightRB:MovePosition( CarDoorsParent:TransformPoint(CarRightClosedLocal) )

    if _t >= 1.0 then
        StopTravel()
        ChangeState("TOP_DOORS_OPENING", true)
        return
    end
end

-- ==== TOP: doors opening ====
function TOP_DOORS_OPENING_ENTER(self)
    _t = 0.0
    _dur = DoorOpenTimeS
    SnapTopClosed()
    SnapCarClosed()
    PlayDing()
end

function TOP_DOORS_OPENING_UPDATE(self, dt)
    _t = math.min(1.0, _t + dt / _dur)
    PlayDoorMove()

    TopLeftRB:MovePosition(  Vector3.Lerp(TopLeftClosed,  TopLeftOpen,  _t) )
    TopRightRB:MovePosition( Vector3.Lerp(TopRightClosed, TopRightOpen, _t) )

    local carLeftLocal  = Vector3.Lerp(CarLeftClosedLocal,  CarLeftOpenLocal,  _t)
    local carRightLocal = Vector3.Lerp(CarRightClosedLocal, CarRightOpenLocal, _t)
    CarLeftRB:MovePosition(  CarDoorsParent:TransformPoint(carLeftLocal) )
    CarRightRB:MovePosition( CarDoorsParent:TransformPoint(carRightLocal) )

    if _t >= 1.0 then
        StopDoorMove()
        ChangeState("TOP_WAIT_OPEN", true)
        return
    end
end

startTicks = 0
-- ==== Physics-driven tick ====
function FixedUpdate()
    if(_sm == nil) then
        return
    end
    FSM.update(_sm, Time.fixedDeltaTime)

    if(startTicks ~= -1)    then
        startTicks = startTicks + 1
        if startTicks >= 20 then
            ChangeState("TOP_DOORS_OPENING", true)
            startTicks = -1
        end
    end

end


-- Latch so re-entry is required
local _playerWasInside = false

-- Externally triggered: pass true when player is inside the cab, false when not
function SetPlayerInElevator(isInside)
    -- rising edge detection: outside -> inside
    if isInside and not _playerWasInside then
        local st = GetState()
        if st == "TOP_WAIT_OPEN" then
            ChangeState("TOP_DOORS_CLOSING", false)
        elseif st == "BOTTOM_WAIT_OPEN" then
            ChangeState("BOTTOM_DOORS_CLOSING", false)
        end
    end

    _playerWasInside = isInside
end
