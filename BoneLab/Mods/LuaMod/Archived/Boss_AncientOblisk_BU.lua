
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

    LaserChargingTime = 5
    LaserFiringTime = 5
    LaserCooldownTime = 5

    MortarCooldownTime = 1

    BaseY = BL_Host.transform.position.y

end

function CanSeePlayer()
   PlayerViewRay = API_Physics.BL_SphereCast(LaserEye.transform.position,API_Input.BL_LeftHand().transform.position,0.1)

    if(PlayerViewRay ~= nil and PlayerViewRay.collider.transform.root == API_Input.BL_LeftHand().transform.root) then
        print("boss can see the player")
        return true
    end
    print("boss can not see player")
    return false

end

function ProcessDamage()

end

TargetMovementSpeed = 1
function MoveLaserTarget(teleport)
    local PlayerPos = API_Input.BL_LeftHand().transform.position
    local TargetPos = LaserTarget.transform.position
    local Direction = (PlayerPos-TargetPos).normalized
    local Movement = (Direction*(TargetMovementSpeed*Time.deltaTime))
    --print("movement vector" .. tostring(Movement))

    if(teleport) then
        LaserTarget.transform.position = PlayerPos
    else
        LaserTarget.transform.position = TargetPos+Movement
    end
    
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
            API_SLZ_Combat.BL_AttackEnemy(gameObject,10*Time.deltaTime*60,collider,pos,normal)
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

RotSpeed = 4
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
    local yBob = math.sin(Time.time * 0.1) * 0.01
    local Pos = BL_Host.transform.position
    Pos.y = BaseY + yBob  -- oscillate around base Y
    BL_Host.transform.position = Pos
end

function CalculateVelocityForAngle(LaunchPos, TargetPos, desiredAngleDeg)
    local g = -Physics.gravity.y  -- positive gravity
    local dx = TargetPos.x - LaunchPos.x
    local dz = TargetPos.z - LaunchPos.z
    local dy = TargetPos.y - LaunchPos.y

    local distanceXZ = math.sqrt(dx*dx + dz*dz)
    if distanceXZ < 1e-6 then return nil end  -- vertical shot fallback could go here

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


function CalculateLaunchAngleAndVelocity(launchPos, targetPos, speed, minHighAngleDeg)
    local g = -Physics.gravity.y  -- positive gravity magnitude
    local dx = targetPos.x - launchPos.x
    local dz = targetPos.z - launchPos.z
    local dy = targetPos.y - launchPos.y

    local distanceXZ = math.sqrt(dx*dx + dz*dz)
    if distanceXZ < 1e-6 then
        -- Vertical shot
        if math.abs(dy) < 1e-6 then return nil end  -- same point
        local verticalSpeed = speed
        if dy > 0 and (speed * speed < 2 * g * dy) then
            return nil  -- not enough speed to reach
        end
        local angle = dy > 0 and 90.0 or -90.0
        local velocity = Vector3(0, dy > 0 and speed or -speed, 0)
        local rotation = Quaternion.LookRotation(velocity)
        return { angle = angle, velocity = velocity, rotation = rotation }
    end

    local v2 = speed * speed
    local v4 = v2 * v2
    local D2 = distanceXZ * distanceXZ
    local discriminant = v4 - g * (g * D2 + 2 * dy * v2)
    if discriminant < 0 then
        return nil  -- target unreachable at this speed
    end

    local sqrtDisc = math.sqrt(discriminant)
    local angle1Rad = math.atan((v2 + sqrtDisc) / (g * distanceXZ))
    local angle2Rad = math.atan((v2 - sqrtDisc) / (g * distanceXZ))
    local angle1Deg = math.deg(angle1Rad)
    local angle2Deg = math.deg(angle2Rad)

    -- Ensure angle1 is the high arc
    if angle1Deg < angle2Deg then
        angle1Deg, angle2Deg = angle2Deg, angle1Deg
        angle1Rad, angle2Rad = angle2Rad, angle1Rad
    end

    -- If minimum high angle required, check it
    if minHighAngleDeg and angle1Deg < minHighAngleDeg then
        print("High arc too low to clear obstacle (got "..tostring(angle1Deg).."°, need ≥ "..tostring(minHighAngleDeg).."°)")
        return nil
    end

    -- Build horizontal direction
    local horizontalDir = Vector3(dx, 0, dz).normalized

    -- High arc velocity
    local cos1 = math.cos(angle1Rad)
    local sin1 = math.sin(angle1Rad)
    local velocity1 = horizontalDir * (cos1 * speed) + Vector3.up * (sin1 * speed)
    local rotation1 = Quaternion.LookRotation(velocity1)

    -- Low arc velocity
    local cos2 = math.cos(angle2Rad)
    local sin2 = math.sin(angle2Rad)
    local velocity2 = horizontalDir * (cos2 * speed) + Vector3.up * (sin2 * speed)
    local rotation2 = Quaternion.LookRotation(velocity2)

    return
        { angle = angle2Deg, velocity = velocity2, rotation = rotation2 },  -- low arc
        { angle = angle1Deg, velocity = velocity1, rotation = rotation1 }   -- high arc
end



function CalculateMortarVelocity(LaunchPos, TargetPos, launchAngleDegrees)
    local gravityY = Physics.gravity.y  -- should be negative in Unity
    local displacement = TargetPos - LaunchPos

    local horizontalDisplacement = API_Vector.BL_Vector3(displacement.x, 0, displacement.z)
    local horizontalDistance = horizontalDisplacement.magnitude
    local verticalDisplacement = displacement.y

    local angleRad = math.rad(launchAngleDegrees)

    -- Ensure denominator is not zero or negative
    local cosAngle = math.cos(angleRad)
    local sinAngle = math.sin(angleRad)

    local denominator = 2 * (horizontalDistance * math.tan(angleRad) - verticalDisplacement)
    if denominator <= 0 then
        print("No valid solution for angle "..launchAngleDegrees.."° — target too high or too close.")
        return nil, nil
    end

    -- Solve for speed²
    local speedSquared = (gravityY * horizontalDistance * horizontalDistance) / denominator
    if speedSquared <= 0 then
        print("Cannot calculate a real velocity — result was imaginary.")
        return nil, nil
    end

    local speed = math.sqrt(math.abs(speedSquared))

    -- Build velocity vector
    local direction = horizontalDisplacement.normalized
    local velocity = direction * (speed * cosAngle)
    velocity.y = speed * sinAngle

    local rotation = Quaternion.LookRotation(velocity)

    return velocity, rotation
end



function PropelMortarProjectiles()
    if(MortarProjectile ~= nil) then
        --local velocity, rotation = CalculateMortarVelocity(MortarEmitter.transform.position, API_Input.BL_LeftHand().transform.position, 5) 
        local solution = CalculateVelocityForAngle(MortarEmitter.transform.position, API_Input.BL_LeftHand().transform.position,70) 
        print("High solution " .. tostring(solutionHigh))
        print("Low solution " .. tostring(solutionLow))
        local MortarRB = API_GameObject.BL_GetComponent2(MortarProjectile,"Rigidbody")
        local DespawnDelay = API_GameObject.BL_GetComponent2(MortarProjectile,"DespawnDelay") 

        if(DespawnDelay ~= nil) then
            DespawnDelay.secondsUntilDisable = 20            
        end

        if(MortarRB ~= nil) then
            print("projecting mortar " .. tostring(velocity))
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

STATE_READY = false
STATE_CHARGING_LASER = false
STATE_FIRING_LASER = false
STATE_COOLDOWN_LASER = false
STATE_LAUNCHING_MORTAR = false
STATE_MORTAR_COOLDOWN = false
STATE_DISPATCHDRONES = false

LastHealth = 0



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
function STATE_LAUNCHING_MORTAR_FUNC()

   -- local velocity, rotation = CalculateMortarVelocity(MortarEmitter.transform.position, API_Input.BL_LeftHand().transform.position, 30.0) --replace with correct mass
   -- print("velocity: " .. tostring(velocity))
    --print("rotation: " .. tostring(rotation))
    
    API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This,"MortarProjectile","c1534c5a-355a-4734-8103-5ded46697265", MortarEmitter.transform.position, Quaternion.identity,nil, true)
    --API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This,"MortarProjectile","c1534c5a-935a-44e8-8036-d86043726174", MortarEmitter.transform.position, Quaternion.identity,nil, true)
    STATE_LAUNCHING_MORTAR = false
    STATE_MORTAR_COOLDOWN = true
    STATE_MORTAR_COOLDOWN_TIME = Time.time
end


STATE_MORTAR_COOLDOWN_TIME = 0
function STATE_MORTAR_COOLDOWN_FUNC()
    

    if(Time.time >= STATE_MORTAR_COOLDOWN_TIME + MortarCooldownTime) then
        --disable laser venting effect
        STATE_MORTAR_COOLDOWN = false
        STATE_READY = true
    end
end

function STATE_DISPATCHDRONES_FUNC()
    STATE_DISPATCHDRONES = false
    STATE_READY = true
end


Setup = true
function Update()

    if(BL_This == nil or not API_GameObject.BL_IsValid(BL_Host) or not BL_This.Ready) then
        return
    end

    if(ObjDestruct == nil or not API_GameObject.BL_IsValid(ObjDestruct) or API_Input.BL_LeftHand() == nil) then
        print("script components nil")
        return
    end

    if(Setup) then
        --run initial set up functions once everything is loaded
        ObjDestruct._health = 9999
        LastHealth = ObjDestruct._health
        MoveLaserTarget(true)
        HealthSetup = false
    end

    if not(STATE_READY or STATE_CHARGING_LASER or STATE_FIRING_LASER or STATE_COOLDOWN_LASER or STATE_LAUNCHING_MORTAR or STATE_MORTAR_COOLDOWN or STATE_DISPATCHDRONES) then
        STATE_READY = true
    end

    --ready to go

    ProcessDamage()
    OscilateMovement()
    MoveLaserTarget()
    LookAtPlayer()
    PropelMortarProjectiles()

    if(STATE_READY) then
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