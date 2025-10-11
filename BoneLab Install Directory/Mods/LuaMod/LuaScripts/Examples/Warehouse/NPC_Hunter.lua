local FSM = loadmodule("fsm.lua")

-- Tunables
local HUNT_DURATION      = 6.0     -- seconds to keep searching after losing LOS
local MAX_HUNT_SEARCH_POINTS = 6   -- max points to check before giving up
local WANDER_REPATH_S    = 30.0   -- how often to pick a new wander point
local CHASE_REPATH_S     = 0.25    -- how often to refresh chase path


local WANDER_SPEED      = 1.0
local CHASE_SPEED       = 3.5
local HUNT_SPEED        = 2.0
-- Cached refs
NavAgent = nil
Target   = nil

-- Internal
npcSM          = nil
_nextWanderRepath = 0
_nextChaseRepath  = 0
_huntEndTime      = 0
_huntPointWaitTime = 10.0
-- -------------------------
-- Minimal sensing helpers (stub these to your project)
-- -------------------------

IdleSounds = nil



function Start()

    Eyeball = API_GameObject.BL_FindInChildren(BL_Host, "EYEBALL")

    NPCBody = API_GameObject.BL_FindInChildren(BL_Host, "Mutated1_V3")
    NPCAnimator = API_GameObject.BL_GetComponentInChildren(NPCBody, "Animator")
    
    IdleSoundContainer = API_GameObject.BL_FindInChildren(BL_Host, "IdleSounds")
    IdleSounds = API_GameObject.BL_GetComponentsInChildren(IdleSoundContainer, "AudioSource")
    IdleSoundDelay = 5.0

    HuntSoundContainer = API_GameObject.BL_FindInChildren(BL_Host, "HuntSounds")
    HuntSounds = API_GameObject.BL_GetComponentsInChildren(HuntSoundContainer, "AudioSource")
    HuntSoundDelay = 5.0

    ChaseSoundContainer = API_GameObject.BL_FindInChildren(BL_Host, "ChaseSounds")
    ChaseSounds = API_GameObject.BL_GetComponentsInChildren(ChaseSoundContainer, "AudioSource")
    ChaseSoundDelay = 2.0

    npcSM = FSM.new({ name = "NPC_Hunter", host = BL_Host, debug = false })
    FSM.add_state(npcSM, "WANDER", { on_enter = STATE_WANDER_ENTER, on_update = STATE_WANDER_UPDATE })
    FSM.add_state(npcSM, "CHASE",  { on_enter = STATE_CHASE_ENTER,  on_update = STATE_CHASE_UPDATE  })
    FSM.add_state(npcSM, "HUNT",   { on_enter = STATE_HUNT_ENTER,   on_update = STATE_HUNT_UPDATE   })

    API_Events.BL_SubscribeEvent("ObjectDestructible_OnSignificantCollision", BL_This, "SigCollisionDetected")
    API_Events.BL_SubscribeEvent("OnProjectileFired", BL_This, "GunFired")
    NavAgent = API_GameObject.BL_GetComponent(BL_Host, "NavMeshAgent")
    NavAgent.autoBraking = false
    
    ChangeState("WANDER", true)
end





LastIdleSound = 0
function PlayIdleSound()
    local soundPlaying = false

    if(IdleSounds == nil or #IdleSounds == 0) then
        print("ERROR - IDLE SOUNDS MISSING")
        return
    end

    for key, sound in ipairs(IdleSounds) do
        if (IsValid(sound)) then 
            if  sound.isPlaying then
                soundPlaying = true
                break
            end
        end
    end

    if not soundPlaying then

        local soundIndex = math.random(1, #IdleSounds)
        while(soundIndex == LastIdleSound) do
            soundIndex = math.random(1, #IdleSounds)
        end
        LastIdleSound = soundIndex
        local sound = IdleSounds[soundIndex]
        sound:Play()
    end

end

LastHuntSound = 0
function PlayHuntSound()
    local soundPlaying = false

    if(HuntSounds == nil or #HuntSounds == 0) then
        print("ERROR - HUNT SOUNDS MISSING")
        return
    end

    for key, sound in ipairs(HuntSounds) do
        if (IsValid(sound)) then 
            if  sound.isPlaying then
                soundPlaying = true
                break
            end
        end
    end

    if not soundPlaying then
        local soundIndex = math.random(1, #HuntSounds)
        while(soundIndex == LastHuntSound) do
            soundIndex = math.random(1, #HuntSounds)
        end
        LastHuntSound = soundIndex
        local sound = HuntSounds[soundIndex]
        sound:Play()
    end

end
LastChseSound = 0
function PlayChaseSound()
    local soundPlaying = false

    if(ChaseSounds == nil or #ChaseSounds == 0) then
        print("ERROR - CHASE SOUNDS MISSING")
        return
    end

    for key, sound in ipairs(ChaseSounds) do
        if (IsValid(sound)) then 
            if  sound.isPlaying then
                soundPlaying = true
                break
            end
        end
    end

    if not soundPlaying then
        local soundIndex = math.random(1, #ChaseSounds)
        while(soundIndex == LastChaseSound) do
            soundIndex = math.random(1, #ChaseSounds)
        end
        LastChaseSound = soundIndex
        local sound = ChaseSounds[soundIndex]
        sound:Play()
    end

end



function AcquireTarget()
    -- TODO: plug in your detector (e.g., VisionFrustumOverlap, sphere cast, tag search)
    return Target ~= nil
end

function HasLineOfSight()
    -- TODO: plug in your LOS function
    return Target ~= nil
end

function GetTargetPos()
    return Target and Target.transform.position or BL_Host.transform.position
end

function PickWanderPoint()
    return FindPathablePoint(BL_Host.transform.position, 50.0, 15.0)
end

function PickHuntPoint(targetPosition,searchCount)
return FindPathablePoint(targetPosition, 5.0, 1.0)
end
-- -------------------------
-- State change utility
-- -------------------------
function ChangeState(name, force)
    FSM.set_state(npcSM, name, force)
end

function GetState()
    return FSM.get_state(npcSM)
end

-- -------------------------
-- STATE: WANDER
-- -------------------------
function STATE_WANDER_ENTER(self, prev)
    print("Hunter entering wander state")
    _nextWanderRepath = 0
    NavAgent.speed = WANDER_SPEED
end


NextIdleSoundTime = 0   
WanderWaiting     = false
_wanderWaitUntil  = 0.0
WanderPoint = Vector3.zero
function STATE_WANDER_UPDATE(self, dt)
    if IsValid(ChaseTarget) then
        ChangeState("CHASE")
        return
    end

    local currentPos = BL_Host.transform.position
    local distToDest = (NavAgent.destination - currentPos).magnitude

    if distToDest < 1.0 then
        -- Start a one-off random dwell if we just arrived
        if not WanderWaiting then
            WanderWaiting = true
            _wanderWaitUntil = Time.time + (math.random() * 5.0) -- 0..5s
            return
        end

        -- Done waiting? pick a new wander point
        if Time.time >= _wanderWaitUntil then
            WanderWaiting = false
            WanderPoint = PickWanderPoint()
            NavAgent.destination = WanderPoint
            _nextWanderRepath = Time.time + WANDER_REPATH_S -- keep your cadence marker if other code uses it
        end
    else
        -- In transit; ensure we’re not stuck in a waiting state
        WanderWaiting = false
    end

    -- Ambient idle audio
    if Time.time >= NextIdleSoundTime then
        PlayIdleSound()
        NextIdleSoundTime = Time.time + IdleSoundDelay + (math.random() * 5.0)
    end
end

-- -------------------------
-- STATE: CHASE
-- -------------------------
LastChasePos = Vector3.zero
LastNavPos = Vector3.zero
function STATE_CHASE_ENTER(self, prev)
    print("Hunter entering chase state")
    --_nextChaseRepath = 0
    NavAgent.destination  = ChaseTarget.transform.position
    LastChasePos = Vector3.zero
    LastNavPos = Vector3.zero
    NavAgent.speed = CHASE_SPEED
end

NextChaseSoundTime = 0   
function STATE_CHASE_UPDATE(self, dt)

    if(not IsValid(ChaseTarget)) then
        print("lost target, so hunting last known location")
        HuntTargetLocation = LastChasePos
        Hunt_MovingToChaseLocation = true
        ChangeState("HUNT")
        return
    else




        LastChasePos = ChaseTarget.transform.position

        if((LastChasePos-LastNavPos).sqrMagnitude > 2.0) then
            print("target moved, so updating nav")
            NavAgent.destination = LastChasePos
            --path = API_SLZ_NPC.BL_CalculatePath(BL_Host.transform.position, LastChasePos, AreaMask)
            --NavAgent.SetPath(path)
            LastNavPos = LastChasePos
        end

        if(Time.time >= NextChaseSoundTime) then
            PlayChaseSound()
            NextChaseSoundTime = Time.time + ChaseSoundDelay + (math.random() * 2.0)
        end


    end

   -- if Time.time >= _nextChaseRepath then
   --     if NavAgent then NavAgent.destination = GetTargetPos() end
   --     _nextChaseRepath = Time.time + CHASE_REPATH_S
  --  end
end

-- -------------------------
-- STATE: HUNT (search last known area)
-- -------------------------
HuntSearchPoints = 0
HuntTime     = 0
HuntTargetLocation = nil
Hunt_MovingToChaseLocation = false
function STATE_HUNT_ENTER(self, prev)
    print("Hunter entering hunt state")
    NPCAnimator.SetTrigger("WalkTransition")
    HuntSearchPoints = 0
    HuntTTime = 0
    _huntEndTime = Time.time + HUNT_DURATION
    _huntNextSearchPoint = 0.0

    if(Hunt_MovingToChaseLocation) then
        NavAgent.speed = CHASE_SPEED
    end
        NavAgent.speed = HUNT_SPEED
end


NextHuntSoundTime = 0
HuntWaiting       = false
_huntWaitUntil    = 0.0

function STATE_HUNT_UPDATE(self, dt)
    -- If we’ve (re)acquired a valid target, chase.
    if IsValid(ChaseTarget) then
        print("valid target, so chasing")
        ChangeState("CHASE")
        return
    end

    local currentPos = BL_Host.transform.position
    local distToDest = (NavAgent.destination - currentPos).magnitude

    -- At/near the current search point?
    if distToDest < 1.0 then
        -- If we just arrived and haven't started waiting yet, start a random dwell.
        if not HuntWaiting then
            HuntWaiting = true
            _huntWaitUntil = Time.time + (math.random() * 5.0)  -- wait 0..5s
            return
        end

        -- If we’ve finished waiting, pick the next point and move on.
        if Time.time >= _huntWaitUntil then
            HuntWaiting = false
            local wp = PickHuntPoint(HuntTargetLocation, HuntSearchPoints)
            HuntSearchPoints = HuntSearchPoints + 1
            NavAgent.destination = wp
        end
    else
        HuntWaiting = false
    end

    -- Give up conditions
    if HuntTargetLocation == nil or (Time.time >= _huntEndTime and HuntSearchPoints >= MAX_HUNT_SEARCH_POINTS) then
        ChangeState("WANDER")
        return
    end

    if Time.time >= NextHuntSoundTime then
        PlayHuntSound()
        NextHuntSoundTime = Time.time + HuntSoundDelay + (math.random() * 5.0)
    end
end
-- -------------------------
-- Unity Lifecycle
-- -------------------------

function SigCollisionDetected(instance,collision,velocity)
    local point = collision.GetContact(0).point
    --print("Significant collision detected on " .. instance.name .. " with relative velocity " .. tostring(velocity))
    NoiseDetected(point,velocity)
end
function GunFired(instance)
--just assume it's not silenced
    NoiseDetected(instance.transform.position,99)
end

function ScannerBeep(position)
    --you idiot
    NoiseDetected(position,10)
end



function  NoiseDetected(position,intensity)

    if(intensity < 1.8) then
        return
    end

    print("Noise Detected at " .. tostring(position) .. " intensity " .. tostring(intensity))
    if(GetState() ~= "CHASE") then
        ChangeState("HUNT")
        HuntTargetLocation = position
        NavAgent:SetDestination(position)
    end
end

lookVector = nil
function Update()

    if(not IsValid(BL_Host) or not IsValid(NavAgent) or not IsValid(NPCAnimator)) then
        print("waiting on critical script components")
       -- NavAgent = API_GameObject.BL_GetComponent(BL_Host, "NavMeshAgent")
        return
    end 

    HandleFrustumDisplayHotkey()
    FSM.update(npcSM, Time.deltaTime)

    local HunterVelocity = NavAgent.velocity.magnitude

    if(HunterVelocity <= 0.1) then
            NPCAnimator.SetBool("Idle",true)
            NPCAnimator.SetBool("Walk",false)
            NPCAnimator.SetBool("Run",false)
    elseif (HunterVelocity >= CHASE_SPEED - 0.3) then
            NPCAnimator.SetBool("Idle",false)
            NPCAnimator.SetBool("Walk",false)
            NPCAnimator.SetBool("Run",true)
    else
            NPCAnimator.SetBool("Idle",false)
            NPCAnimator.SetBool("Walk",true)
            NPCAnimator.SetBool("Run",false)
    end


        local currentState = GetState()
    lookVector = nil
    if(currentState == "CHASE") then
        lookVector = ChaseTarget.transform.position
    elseif (currentState == "HUNT") then
        lookVector = HuntTargetLocation
    elseif (currentState == "WANDER") then
        lookVector = WanderPoint
    end


end


ChaseTarget = nil

function SlowUpdate()

    local VisionObjects = VisionFrustumOverlap()
    if VisionObjects ~= nil and #VisionObjects > 0 then
        for i = 1, #VisionObjects do
            print("I see: " .. VisionObjects[i].gameObject.name .. " " .. VisionObjects[i].gameObject.transform.parent.name)

            if(IsAcceptableTarget(VisionObjects[i].gameObject)) then
                print("Acceptable target!")
                ChaseTarget = VisionObjects[i].gameObject

            end

        end
    else
        ChaseTarget = nil
    end

end

-- =========================
-- CONFIG (top of script)
-- =========================
local FRUSTUM_HALF_FOV_DEG     = 20        -- half-angle (°)
local FRUSTUM_MAX_DISTANCE     = 40
local FRUSTUM_NEAR_DISTANCE    = 0.25      -- >0 to avoid zero-radius first sphere
local FRUSTUM_STEPS            = 7        -- more slices = denser near-origin coverage
local FRUSTUM_DEPTH_EXP        = 2.0       -- >1 clusters slices near the origin (fixes early gap)
local FRUSTUM_LAYER_MASK       = -1        -- all layers
local FRUSTUM_MIN_RADIUS       = 3.0         -- minimum radius for overlap spheres
-- LOS sampling
local LOS_SAMPLE_COUNT         = 5
local LOS_CLEAR_FRACTION       = 0.5
local LOS_SPHERE_RADIUS_SCALE  = 0.35
local LOS_FUDGE                = 0.03


-- Display dots (one per slice)
local FRUSTUM_DISPLAY_ENABLED  = false
local DISPLAY_DOT_BARCODE      = "BonelabMeridian.Luamodexamplecontent.Spawnable.VertigoDisplaySphere"
local DOT_DIAMETER_MULT        = 5.0       -- child mesh scaled to 0.2 => use 1/0.2 = 5

-- =========================
-- INTERNALS / POOL
-- =========================
DisplayDots = DisplayDots or {}
DisplayDot  = DisplayDot  or nil

function SpawnDot()
    API_GameObject.BL_SpawnByBarcode(
        BL_This,
        "DisplayDot",
        DISPLAY_DOT_BARCODE,
        Vector3.zero,
        Quaternion.identity,
        nil,
        true
    )
end

function SliceRadius(depth, tanHalf)
    return math.max(tanHalf * depth, FRUSTUM_MIN_RADIUS)
end

function CollectNewDots()
    if DisplayDot ~= nil then
        table.insert(DisplayDots, DisplayDot)
        DisplayDot = nil
    end
end

function EnsureDotPool(targetCount)
    while #DisplayDots < targetCount do
        SpawnDot()
        break
    end
end

function HideAllDots()
    for i = 1, #DisplayDots do
        DisplayDots[i].setActive(false)
    end
end

-- =========================
-- Helpers
-- =========================
function get_origin_transform()
    return Eyeball.transform
end

function safe_min3(v)
    return math.min(v.x, math.min(v.y, v.z))
end

function target_center_and_radius(go)
    local mr = API_GameObject.BL_GetComponent(go, "MeshRenderer")
    if mr ~= nil then
        local c = mr.bounds.center
        local r = safe_min3(mr.bounds.extents) * LOS_SPHERE_RADIUS_SCALE
        return c, math.max(r, 0.05)
    end
    local bc = API_GameObject.BL_GetComponent(go, "BoxCollider")
    if bc ~= nil then
        local c = bc.bounds.center
        local r = safe_min3(bc.bounds.extents) * LOS_SPHERE_RADIUS_SCALE
        return c, math.max(r, 0.05)
    end
    return go.transform.position, 0.1
end

-- Inclusive, biased depth sampling (fixes gap near origin)
function SliceDepth(i)
    if FRUSTUM_STEPS <= 1 then
        return FRUSTUM_NEAR_DISTANCE
    end
    local t = (i - 1) / (FRUSTUM_STEPS - 1)         -- 0..1 inclusive
    if FRUSTUM_DEPTH_EXP ~= 1.0 then
        t = math.pow(t, FRUSTUM_DEPTH_EXP)          -- cluster near origin if >1
    end
    return FRUSTUM_NEAR_DISTANCE + (FRUSTUM_MAX_DISTANCE - FRUSTUM_NEAR_DISTANCE) * t
end

-- Acceptable-target filter: same root as left hand
function IsAcceptableTarget(go)
    local lh = API_Input.BL_LeftHand()

    if (not IsValid(lh) or not IsValid(go) or go.name == "Sphere") then
        return false
    end

    return go.transform.root == lh.transform.root
end

-- LOS: cast N rays to random points around target
function HasLineOfSight_MultiPoint(origin, targetGO)
    local center, radius = target_center_and_radius(targetGO)
    local objRoot = targetGO.transform.root
    local needed  = math.max(1, math.ceil(LOS_SAMPLE_COUNT * LOS_CLEAR_FRACTION))
    local clear   = 0

    for i = 1, LOS_SAMPLE_COUNT do
        local p = center + (API_Random.InsideUnitSphere() * radius)
        local seg  = p - origin
        local dist = seg.magnitude
        if dist > 1e-4 then
            local dir = seg / dist
            local hit = API_Physics.BL_RayCast(origin, dir, math.max(0, dist - LOS_FUDGE))
            if hit == nil or hit.collider == nil then
                clear = clear + 1
            else
                local hitRoot = hit.collider.gameObject.transform.root
                if hitRoot == objRoot then
                    clear = clear + 1
                end
            end
            if clear >= needed then return true end
        end
    end
    return false
end

-- Draw: ONE DOT PER SLICE, scaled to that slice's radius
function DrawFrustumDots(origin, forward, tanHalf)
    CollectNewDots()
    EnsureDotPool(FRUSTUM_STEPS)
    CollectNewDots()

    local idx = 1
    for i = 1, FRUSTUM_STEPS do
    local depth  = SliceDepth(i)
    local radius = SliceRadius(depth, tanHalf)      -- was: tanHalf * depth
    local center = origin + forward * depth

        local dotGO = DisplayDots[idx]
        if not dotGO then break end

        dotGO.transform.position   = center
        dotGO.transform.localScale = Vector3.one * (radius * 2.0 * DOT_DIAMETER_MULT)
        dotGO.setActive(true)

        idx = idx + 1
    end

    for k = idx, #DisplayDots do
        DisplayDots[k].setActive(false)
    end
end

-- Toggle draw
function SetFrustumDisplayEnabled(enabled)
    FRUSTUM_DISPLAY_ENABLED = enabled and true or false
    if not FRUSTUM_DISPLAY_ENABLED then
        HideAllDots()
    end
end

-- =========================
-- Frustum-by-OverlapSpheres (no args) + display
-- Returns: array of { gameObject=GO, collider=Collider, distance=number }
-- =========================
function VisionFrustumOverlap()


    if(IsValid(ChaseTarget)) then
        
        local chaseTPos = ChaseTarget.transform.position
        local toTarget = chaseTPos - BL_Host.transform.position
        local distToTarget = toTarget.sqrMagnitude
        if (distToTarget < 25) then
            print("current target is close, not rechecking vision " .. tostring(distToTarget))
            return { { gameObject = ChaseTarget, collider = nil, distance = distToTarget } }
        else
            print("current target is far, rechecking vision" .. tostring(distToTarget))
        end
    end

    local tOrigin = get_origin_transform()
    local origin  = tOrigin.position
    local forward = tOrigin.forward.normalized

    local halfRad = Mathf.Deg2Rad * FRUSTUM_HALF_FOV_DEG
    local tanHalf = Mathf.Tan(halfRad)
    local cosHalf = Mathf.Cos(halfRad)

    if FRUSTUM_DISPLAY_ENABLED then
        DrawFrustumDots(origin, forward, tanHalf)
    else
        HideAllDots()
    end

    local ignoreRoot = BL_Host.transform.root
    local seen, results = {}, {}

    for i = 1, FRUSTUM_STEPS do
        local depth  = SliceDepth(i)
        local radius = SliceRadius(depth, tanHalf)      -- was: tanHalf * depth
        local center = origin + forward * depth

        local overlaps = API_Physics.BL_OverlapSphere(center, radius, FRUSTUM_LAYER_MASK)
        if overlaps ~= nil then
            for index, col in ipairs(overlaps) do
                if col ~= nil then
                    local go = col.gameObject
                    if go ~= nil and API_GameObject.BL_IsValid(go) and go.transform.root ~= ignoreRoot then
                        local toObj = go.transform.position - origin
                        local dist  = toObj.magnitude
                        if dist > 0 and dist <= FRUSTUM_MAX_DISTANCE then
                            local dir = toObj / dist
                            if Vector3.Dot(dir, forward) >= cosHalf then
                                if (not seen[col] and IsAcceptableTarget(go)) then
                                    if( HasLineOfSight_MultiPoint(origin, go)) then
                                        seen[col] = true
                                        results[#results + 1] = { gameObject = go, collider = col, distance = dist }
                                        return results
                                    else
                                        --print("No LOS to " .. go.name)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return results
end

-- =========================
-- Hotkey: F2 toggles frustum display
-- =========================
local KEY_F1   = 283
local _f1Latch = false

function HandleFrustumDisplayHotkey()
    local isDown = API_Input.BL_IsKeyDown(KEY_F1)
    if isDown then
        if not _f1Latch then
            SetFrustumDisplayEnabled(not FRUSTUM_DISPLAY_ENABLED)
        end
        _f1Latch = true
    else
        _f1Latch = false
    end
end

function ToLuaTable(wrapper)
    local t = {}
    local index = 1

    -- MoonSharp EnumerableWrapper supports ipairs-style iteration
    for value in wrapper do
        t[index] = value
        index = index + 1
    end

    return t
end


function FindPathablePoint(StartingPoint,maxDistance, minDistance)
    local HunterLocAtion = BL_Host.transform.position
    for attempt = 1, 10 do
        -- Random point in a circle (XZ plane)
        local angle = math.random() * 2 * math.pi
        local radius = math.sqrt(math.random()) * maxDistance
        local offsetX = math.cos(angle) * radius
        local offsetZ = math.sin(angle) * radius
        local samplePos = API_Vector.BL_Vector3(StartingPoint.x + offsetX, HunterLocAtion.y, HunterLocAtion.z + offsetZ)

        -- Use C# helper to find NavMesh point
        local navPos = API_SLZ_NPC.BL_SamplePosition(samplePos, 2.0, AreaMask)
        if navPos ~= nil then
            -- Use C# helper to validate path
            local path = API_SLZ_NPC.BL_CalculatePath(HunterLocAtion, navPos, AreaMask)
            local pathCorners = nil
            if path ~= nil and path.corners ~= nil then
                pathCorners = ToLuaTable(path.corners)
            end

            if pathCorners ~= nil and #pathCorners > 0 then
                -- Compute path length using Lua table
                local totalLength = 0
                for i = 1, #pathCorners - 1 do
                    totalLength = totalLength + (pathCorners[i + 1] - pathCorners[i]).magnitude
                end

                if totalLength >= minDistance then
                    return navPos
                end
            end
        end
    end

    print("NextWanderPoint: No valid spawn point found.")
    return nil
end
