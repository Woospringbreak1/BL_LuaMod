
function Start()
    print("Hello, World from the ANCIENT OBLISK BOSSFIGHT lua!")
    ObjDestruct = API_GameObject.BL_GetComponent2(BL_Host,"ObjectDestructible")


    LaserEye = API_GameObject.BL_FindInChildren(BL_Host,"LaserEye").gameObject
    LaserCharging = API_GameObject.BL_FindInChildren(BL_Host,"LaserChargingEffect").gameObject
    Laser = API_GameObject.BL_FindInChildren(BL_Host,"Laser").gameObject
    LaserLine = API_GameObject.BL_GetComponent2(Laser,"LineRenderer")

    LaserTarget = API_GameObject.BL_FindInChildren(BL_Host,"LaserTarget").gameObject

    DroneEmitter = API_GameObject.BL_FindInChildren(BL_Host,"DroneEmitter").gameObject
    MortarEmitter = API_GameObject.BL_FindInChildren(BL_Host,"MortarEmitter").gameObject
    print(API_GameObject.BL_FindInWorld)
    RiseUpTarget = API_GameObject.BL_FindInWorld("RiseUpTarget").gameObject

    LaserChargingTime = 1
    LaserFiringTime = 5
    LaserCooldownTime = 1

    MortarCooldownTime = 2
    StartDelayTime = 3
    BaseY = BL_Host.transform.position.y

end

function CanSeePlayer()
   PlayerViewRay = API_Physics.BL_SphereCast(LaserEye.transform.position,API_Input.BL_LeftHand().transform.position,0.1)

    if(PlayerViewRay ~= nil and PlayerViewRay.collider.transform.root == API_Input.BL_LeftHand().transform.root) then
        return true
    end
    return false

end

function ProcessDamage()

end

TargetMovementSpeed = 1
function MoveLaserTarget(teleport)
    local playerPos = API_Player.BL_GetAvatarCenter()
    local targetPos = LaserTarget.transform.position

    local delta = playerPos - targetPos
    local distance = delta.magnitude

    if teleport or distance < 0.001 then
        LaserTarget.transform.position = playerPos
        return
    end

    -- Normalize to get uniform direction
    local direction = delta.normalized
    local step = TargetMovementSpeed * Time.deltaTime
    local movement = direction * step

    if step >= distance then
        LaserTarget.transform.position = playerPos
    else
        LaserTarget.transform.position = targetPos + movement
    end

    --print("delta:", delta.x, delta.y, delta.z, " distance:", distance)
end


LaserMaxRange = 500.0
function PositionLaser()

    LaserLine.SetPosition(0,LaserCharging.transform.position)

    local FiringDirection = (LaserTarget.transform.position - LaserCharging.transform.position).normalized
    local laserHit = API_Physics.BL_RayCast(LaserCharging.transform.position,FiringDirection,LaserMaxRange)

    if(laserHit ~= nil and laserHit.collider.transform.root ~= BL_Host.transform.root) then
        LaserLine.SetPosition(1,laserHit.point)
        TriggerSurfaceImpact(laserHit.point,laserHit.normal)

        if(laserHit.rigidbody ~= nil) then
            DamageEnemy(laserHit.point,laserHit.normal*-1.0,laserHit.collider,laserHit.rigidbody.transform.root.gameObject,laserHit.rigidbody)
        end

    else
        LaserLine.SetPosition(1,LaserCharging.transform.position+FiringDirection*LaserMaxRange)
    end

   
    
end

function DamageEnemy(pos, normal,collider,gameObject,rigidbody)
    if(gameObject ~= nil) then
        if(rigidbody ~= nil) then    
            API_SLZ_Combat.BL_AttackEnemy(gameObject,0.9*Time.deltaTime*60,collider,pos,normal)
            API_SLZ_Combat.ApplyForce(rigidbody,pos,normal,1000*Time.deltaTime*60)
        else
            print("rigidbody is nil")
        end
    else
        print("GameObject is nil")
    end

end

function TriggerSurfaceImpact(pos, normal)
    local impactRotation = Quaternion.LookRotation(Vector3.forward, normal)
    local ImpactEffect = API_GameObject.BL_SpawnByBarcode("33.33.Spawnable.LaserImpact", pos, impactRotation)
end

RotSpeed = 8
function LookAtPlayer()
    local targetPos = API_Input.BL_LeftHand().transform.position

    -- Get direction to target, ignore Y-axis difference
    local selfPos = BL_Host.transform.position
    targetPos.y = selfPos.y  -- keep same height

    local direction = (targetPos - selfPos).normalized
    local targetRotation = Quaternion.LookRotation(direction)

    -- Smooth rotation with speed
    BL_Host.transform.rotation = Quaternion.RotateTowards( BL_Host.transform.rotation,targetRotation,RotSpeed * Time.deltaTime )
end


function OscilateMovement()
    local yBob = math.sin(Time.time * 0.5) * 1
    local Pos = BL_Host.transform.position
    Pos.y = BaseY + yBob  -- oscillate around base Y
    BL_Host.transform.position = Pos
end

function CalculateVelocityForAngle(LaunchPos, TargetPos, desiredAngleDeg)
    --credit: ChatGPT
    local g = -Physics.gravity.y  -- positive gravity
    local dx = TargetPos.x - LaunchPos.x
    local dz = TargetPos.z - LaunchPos.z
    local dy = TargetPos.y - LaunchPos.y

    local distanceXZ = math.sqrt(dx*dx + dz*dz)
    if distanceXZ < 1e-6 then return nil end  

    local theta = math.rad(desiredAngleDeg)
    local cosTheta = math.cos(theta)
    local sinTheta = math.sin(theta)
    local tanTheta = math.tan(theta)

    local denom = 2 * cosTheta * cosTheta * (distanceXZ * tanTheta - dy)
    if denom <= 0 then
        print("Cannot compute a valid arc with angle ≥ " .. desiredAngleDeg .. "°")
        return nil
    end

    local speedSquared = (g * distanceXZ * distanceXZ) / denom
    if speedSquared <= 0 then
        print("Imaginary speed required for angle " .. desiredAngleDeg .. "°")
        return nil
    end

    local speed = math.sqrt(speedSquared)

    -- Direction & velocity vector
    local horizontalDir = API_Vector.BL_Vector3(dx, 0, dz).normalized
    local velocity = horizontalDir * (speed * cosTheta) + ( Vector3.up * (speed * sinTheta) )
    local rotation = Quaternion.LookRotation(velocity)

    return {
        angle = desiredAngleDeg,
        speed = speed,
        velocity = velocity,
        rotation = rotation
    }
end


BombardmentArea = 3.0
function PropelMortarProjectiles()
    if(MortarProjectile ~= nil) then
        local TargetOffset = API_Random.BL_onUnitSphere()*BombardmentArea
        local solution = CalculateVelocityForAngle(MortarEmitter.transform.position, API_Input.BL_LeftHand().transform.position+TargetOffset,70) 
        local MortarRB = API_GameObject.BL_GetComponent2(MortarProjectile,"Rigidbody")
        local DespawnDelay = API_GameObject.BL_GetComponent2(MortarProjectile,"DespawnDelay") 

        if(DespawnDelay ~= nil) then
            DespawnDelay.secondsUntilDisable = 20            
        end

        if(MortarRB ~= nil) then
            MortarRB.drag = 0.0
            MortarRB.angularDrag = 0.0
            MortarRB.useGravity = true
            MortarRB.velocity = solution.velocity

        else
            print("mortar projectile Rigidbody is nil!")
        end

        MortarProjectile = nil
    end

end

STATE_DELAYED_START = false
STATE_RISE_UP = false
STATE_READY = false
STATE_CHARGING_LASER = false
STATE_FIRING_LASER = false
STATE_COOLDOWN_LASER = false
STATE_LAUNCHING_MORTAR = false
STATE_MORTAR_COOLDOWN = false
STATE_DISPATCHDRONES = false

RiseTime = 5 --ms
InitalYDif = nil
RiseTime = 5 -- seconds
RiseStartTime = nil
RiseStartY = nil

function STATE_RISE_UP_FUNC()
    local risePos = RiseUpTarget.transform.position
    local bossPos = BL_Host.transform.position

    if RiseStartTime == nil then
        RiseStartTime = Time.time
        RiseStartY = bossPos.y
    end

    local elapsed = Time.time - RiseStartTime
    local t = math.min(elapsed / RiseTime, 1)  -- goes from 0 to 1
    -- Apply easing: ease-out (slow at the end)
    local easedT = 1 - math.pow(1 - t, 3)  -- cubic ease-out

    bossPos.y = Mathf.Lerp(RiseStartY, risePos.y, easedT)
    BL_Host.transform.position = bossPos

    if(t >= 1) then
        STATE_RISE_UP = false
        STATE_DELAYED_START = true
        STATE_DELAYED_START_TIME = Time.time
        RiseStartTime = nil
        RiseStartY = nil
    end
end

STATE_DELAYED_START_TIME = 0
function STATE_DELAYED_START_FUNC()
    if(Time.time >= (STATE_DELAYED_START_TIME+StartDelayTime)) then
        MoveLaserTarget(true)
        STATE_DELAYED_START = false
        STATE_READY = true
    end
end





function STATE_READY_FUNC()

        --pick an attack method

        if(CanSeePlayer()) then
            STATE_READY = false
            STATE_CHARGING_LASER = true
            STATE_CHARGING_LASER_TIME = Time.time
        else
            if(math.random(0,10) >= 5) then
                STATE_READY = false
                STATE_LAUNCHING_MORTAR = true
            else
                STATE_READY = false
                STATE_DISPATCHDRONES = true
            end
        end

end

STATE_CHARGING_LASER_TIME = 0
function STATE_CHARGING_LASER_FUNC()
    --trigger start charging effect
    LaserCharging.setActive(true)
    if(Time.time >= STATE_CHARGING_LASER_TIME+LaserChargingTime) then
        STATE_CHARGING_LASER = false
        STATE_FIRING_LASER = true
        STATE_FIRING_LASER_TIME = Time.time
    end
end 

STATE_FIRING_LASER_TIME = 0
function STATE_FIRING_LASER_FUNC()
    --enable laser
    Laser.setActive(true)
    PositionLaser()
    if(Time.time >= STATE_FIRING_LASER_TIME+LaserFiringTime) then
        --disable laser
        LaserCharging.setActive(false)
        Laser.setActive(false)
        STATE_FIRING_LASER = false
        STATE_COOLDOWN_LASER = true
        STATE_COOLDOWN_LASER_TIME = Time.time
    end

end
STATE_COOLDOWN_LASER_TIME = 0
function STATE_COOLDOWN_LASER_FUNC()
    --laser venting effect

    if(Time.time >= STATE_COOLDOWN_LASER_TIME + LaserCooldownTime) then
        --disable laser venting effect
        STATE_COOLDOWN_LASER = false
        STATE_READY = true
    end
end

NumberOfMortars = 10
CurrentMortarCount = 0
NextMortarTime=0
function STATE_LAUNCHING_MORTAR_FUNC()

    if(Time.time > NextMortarTime) then
        API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This,"MortarProjectile","c1534c5a-355a-4734-8103-5ded46697265", MortarEmitter.transform.position, Quaternion.identity,nil, true)
        NextMortarTime = Time.time  + 0.4
        CurrentMortarCount = CurrentMortarCount + 1
    end


    if(CurrentMortarCount > NumberOfMortars) then
        STATE_LAUNCHING_MORTAR = false
        STATE_MORTAR_COOLDOWN = true
        STATE_MORTAR_COOLDOWN_TIME = Time.time
        CurrentMortarCount = 0
    end
end


STATE_MORTAR_COOLDOWN_TIME = 0
function STATE_MORTAR_COOLDOWN_FUNC()
    

    if(Time.time >= STATE_MORTAR_COOLDOWN_TIME + MortarCooldownTime) then
        STATE_MORTAR_COOLDOWN = false
        STATE_READY = true
    end
end


NumberOfDrones = 3
CurrentDroneCount = 0
NextDroneTime=0
function STATE_DISPATCHDRONES_FUNC()
    if(Time.time > NextDroneTime) then
        API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This,"DroneProjectile","c1534c5a-355a-4734-8103-5ded46697265", DroneEmitter.transform.position, Quaternion.identity,nil, true)
        NextDroneTime = Time.time  + 0.8
        CurrentDroneCount = CurrentDroneCount + 1
    end


    if(CurrentDroneCount > NumberOfDrones) then
        STATE_DISPATCHDRONES = false
        STATE_READY = true
        CurrentDroneCount = 0
    end

end


Setup = true
LastHealth = 0
function Update()

    if(BL_This == nil or not API_GameObject.BL_IsValid(BL_Host) or not BL_This.Ready) then
        return
    end

    if(ObjDestruct == nil or not API_GameObject.BL_IsValid(ObjDestruct) or API_Input.BL_LeftHand() == nil or RiseUpTarget == nil or not API_GameObject.BL_IsValid(RiseUpTarget)) then
        print("script components nil")
        return
    end

    if(Setup) then
        --run initial set up functions once everything is loaded
        ObjDestruct._health = 9999
        LastHealth = ObjDestruct._health
        Setup = false
    end

    if not(STATE_RISE_UP or STATE_DELAYED_START or STATE_READY or STATE_CHARGING_LASER or STATE_FIRING_LASER or STATE_COOLDOWN_LASER or STATE_LAUNCHING_MORTAR or STATE_MORTAR_COOLDOWN or STATE_DISPATCHDRONES) then
        STATE_RISE_UP = true
    end

    --ready to go

    ProcessDamage()
    MoveLaserTarget(false)
    LookAtPlayer()
    PropelMortarProjectiles()

    if not (STATE_RISE_UP) then
        OscilateMovement()
    end


    if(STATE_DELAYED_START) then
        STATE_DELAYED_START_FUNC()
        print("STATE_DELAYED_START")
    elseif (STATE_RISE_UP) then
        STATE_RISE_UP_FUNC()
        print("STATE_RISE_UP")
    elseif(STATE_READY) then
        STATE_READY_FUNC()
        print("STATE_READY")
    elseif (STATE_CHARGING_LASER) then
        STATE_CHARGING_LASER_FUNC()
        print("STATE_CHARGING_LASER")
    elseif(STATE_FIRING_LASER) then
        STATE_FIRING_LASER_FUNC()
        print("STATE_FIRING_LASER")
    elseif(STATE_COOLDOWN_LASER) then
        STATE_COOLDOWN_LASER_FUNC()
        print("STATE_COOLDOWN_LASER")
    elseif(STATE_LAUNCHING_MORTAR) then
        STATE_LAUNCHING_MORTAR_FUNC()
       -- print("STATE_LAUNCHING_MORTAR")
    elseif(STATE_MORTAR_COOLDOWN) then
        STATE_MORTAR_COOLDOWN_FUNC()
        --print("STATE_MORTAR_COOLDOWN")
    elseif(STATE_DISPATCHDRONES) then
        STATE_DISPATCHDRONES_FUNC()
        print("STATE_DISPATCHDRONES")
    end


    if(ObjDestruct._health ~= LastHealth) then
        local damage = ObjDestruct._health-LastHealth
        LastHealth = ObjDestruct._health
        print("Boss damaged for " .. tostring(damage))
        
    end
end