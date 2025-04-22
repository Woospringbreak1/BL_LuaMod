function Start()
    print("Hello, World from the ANCIENT OBLISK BOSSFIGHT lua!")
    math.randomseed(Time.time)
    SkeletonSpawn = nil
    MaxMinionCount = 5
    SkeletonMinions = {}
    local coneMesh = API_GameObject.BL_FindInChildren(BL_Host, "Cone")
    coneMeshRenderer = API_GameObject.BL_GetComponent(coneMesh, "MeshRenderer")
    ObjDestruct = API_GameObject.BL_GetComponent(BL_Host, "ObjectDestructible")

    LaserEye = API_GameObject.BL_FindInChildren(BL_Host, "LaserEye")
    LaserCharging = API_GameObject.BL_FindInChildren(LaserEye, "LaserChargingEffect")
    LaserCooldown = API_GameObject.BL_FindInChildren(LaserEye, "LaserCooldownEffect")
    LaserEmitter = API_GameObject.BL_FindInChildren(LaserEye, "LaserEmitter")
    LaserImpactEffect = API_GameObject.BL_FindInChildren(LaserEye, "LaserImpact")
    LaserImpactEffect.transform.SetParent(nil)
    Laser = API_GameObject.BL_FindInChildren(BL_Host, "Laser")
    LaserLine = API_GameObject.BL_GetComponent(Laser, "LineRenderer")
    LaserSound = API_GameObject.BL_GetComponent(Laser, "AudioSource")
    LaserAim = API_GameObject.BL_FindInChildren(BL_Host, "LaserTarget")
    LaserAim.transform.SetParent(null)

    DroneEmitter = API_GameObject.BL_FindInChildren(BL_Host, "DroneEmitter")
    MortarEmitter = API_GameObject.BL_FindInChildren(BL_Host, "MortarEmitter")
   
    RiseUpTarget = API_GameObject.BL_FindInWorld("RiseUpTarget")

    WellCap = API_GameObject.BL_FindInWorld("WellCap")
    WellCapAudio = API_GameObject.BL_GetComponent( API_GameObject.BL_FindInWorld("WellCapAudio"),"AudioSource")

    BunkerGun1 = API_GameObject.BL_GetComponent(API_GameObject.BL_FindInWorld("BunkerGun_1"), "LuaBehaviour")
    BunkerGun2 = API_GameObject.BL_GetComponent(API_GameObject.BL_FindInWorld("BunkerGun_2"), "LuaBehaviour")
    BunkerGun3 = API_GameObject.BL_GetComponent(API_GameObject.BL_FindInWorld("BunkerGun_3"), "LuaBehaviour")


   --HealthSetpoint1 = 500
    --HealthSetpoint2 = 1000
   -- HealthSetpoint3 = 1500
    --HealthSetpoint4 = 2000

    HealthSetpoint1 = 1000
    HealthSetpoint2 = 1889
    HealthSetpoint3 = 2777
    HealthSetpoint4 = 3222


    LaserChargingTime = 3
    LaserFiringTime = 5
    LaserCooldownTime = 5

    MortarCooldownTime = 2
    StartDelayTime = 3

    PlayerInBunker = false

    LaserCooldown.setActive(false)
    LaserCharging.setActive(false)

end

function SetPlayerInBunker(inbunker)
    PlayerInBunker = inbunker
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

function GetRandomPointOnMeshRendererSphere(meshRenderer)
    --source: chatGPT
    -- Get the bounds of the mesh renderer
    local bounds = meshRenderer.bounds
    local center = bounds.center
    local extents = bounds.extents

    -- Calculate the radius of the bounding sphere (diagonal from center to corner)
    local radius = extents.magnitude

    -- Generate a random direction on the surface of a unit sphere
    local function randomUnitVector()
        local x, y, z
        repeat
            x = math.random() * 2 - 1
            y = math.random() * 2 - 1
            z = math.random() * 2 - 1
            local magSq = x * x + y * y + z * z
        until magSq > 0 and magSq <= 1
        local mag = math.sqrt(x * x + y * y + z * z)
        return API_Vector.BL_Vector3(x / mag, y / mag, z / mag)
    end

    -- Compute the final point
    local direction = randomUnitVector()
    local point = center + direction * radius * 0.45
    return point
end

function BunkerIsDestroyed(bunker)
    if (bunker == nil or not IsValid(bunker) or not IsValid(bunker.gameObject)) then
        return true
    end
    return false
end

MaxAttempts = 10
AreaMask = -1
function FindEnemySpawnPoint(targetCenter, maxDistance, minDistance)
    for attempt = 1, 10 do
        -- Random point in a circle (XZ plane)
        local angle = math.random() * 2 * math.pi
        local radius = math.sqrt(math.random()) * maxDistance
        local offsetX = math.cos(angle) * radius
        local offsetZ = math.sin(angle) * radius
        local samplePos = API_Vector.BL_Vector3(targetCenter.x + offsetX, targetCenter.y, targetCenter.z + offsetZ)

        -- Use C# helper to find NavMesh point
        local navPos = API_SLZ_NPC.BL_SamplePosition(samplePos, 2.0, AreaMask)
        if navPos ~= nil then
            -- Use C# helper to validate path
            local path = API_SLZ_NPC.BL_CalculatePath(targetCenter, navPos, AreaMask)
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

    print("FindEnemySpawnPoint: No valid spawn point found.")
    return nil
end

function CanSeeTarget()
    local targetPos = GetTargetPos()

    if (targetPos == nil) then
        return false
    end

    local distanceVec = targetPos - LaserEye.transform.position
    local direction = distanceVec.normalized
    local TargetViewRay = API_Physics.BL_RayCast(LaserEye.transform.position, direction, LaserMaxRange)

    if (TargetViewRay ~= nil and TargetViewRay.collider ~= nil and IsValid(Target)) then
        if (TargetViewRay.collider.gameObject == Target or TargetViewRay.collider.transform.root == Target.transform.root) then
            return true
        end
    end
    return false
end

LastHealth = 0
TotalDamage = 0
DamageReact = 10
DamageReactTrack = 0
function ProcessDamage(health)
    local damage = LastHealth - health
    LastHealth = health
    TotalDamage = TotalDamage + damage
    DamageReactTrack = DamageReactTrack + damage
    if (DamageReactTrack > DamageReact) then
        local explosionPosition = GetRandomPointOnMeshRendererSphere(coneMeshRenderer)
        API_GameObject.BL_SpawnByBarcode("c1534c5a-26fd-4606-aa5e-1098426c6173", explosionPosition, Quaternion.identity)
        DamageReactTrack = 0
    end
end

TargetMovementSpeed = 1
function MoveLaserAim(teleport)
    local targetPos = GetTargetPos()

    if (targetPos == nil) then
        return
    end

    local AimPos = LaserAim.transform.position

    local delta = targetPos - AimPos
    local distance = delta.magnitude

    if teleport or distance < 0.001 then
        LaserAim.transform.position = targetPos
        return
    end

    -- Normalize to get uniform direction
    local direction = delta.normalized
    local step = TargetMovementSpeed * Time.deltaTime
    local movement = direction * step

    if step >= distance then
        LaserAim.transform.position = targetPos
    else
        LaserAim.transform.position = AimPos + movement
    end
end

function PlayLaserSound(play)
    if (play) then
        if (not LaserSound.isPlaying) then
            LaserSound.Play()
        end
    else
        LaserSound.Stop()
    end
end

LaserMaxRange = 999.0
function PositionLaser()
    LaserLine.SetPosition(0, LaserEmitter.transform.position)


    local distanceVec = LaserAim.transform.position - LaserEye.transform.position
    local direction = distanceVec.normalized
    --local TargetViewRay = API_Physics.BL_RayCast(LaserEye.transform.position, direction, LaserMaxRange)
    --local FiringDirection = (LaserAim.transform.position - LaserCharging.transform.position).normalized

    local laserHit = API_Physics.BL_RayCast(LaserEye.transform.position, direction, LaserMaxRange)

    if (laserHit ~= nil and laserHit.collider.transform.root ~= BL_Host.transform.root) then
        LaserLine.SetPosition(1, laserHit.point)
        TriggerSurfaceImpact(laserHit.point, laserHit.normal)

        if (laserHit.rigidbody ~= nil and IsValid(laserHit.rigidbody)) then
            DamageEnemy(laserHit.point, laserHit.normal * -1.0, laserHit.collider,
                laserHit.rigidbody.transform.root.gameObject, laserHit.rigidbody)
                LaserImpactEffect.setActive(true)
        end
    else
         LaserLine.SetPosition(1, LaserCharging.transform.position + FiringDirection * LaserMaxRange)
    end
end

function DamageEnemy(pos, normal, collider, gameObject, rigidbody)
    if (gameObject ~= nil and IsValid(gameObject)) then
        local TargetLuaBehaviour = API_GameObject.BL_GetComponent(gameObject.transform.root.gameObject, "LuaBehaviour")
        if (TargetLuaBehaviour ~= nil) then
            if (TargetLuaBehaviour.ScriptTags ~= nil) then
                if (TargetLuaBehaviour.ScriptTags.Contains("BOSS_ANCIENTOBLISK_BUNKERGUN")) then
                    TargetLuaBehaviour.CallFunction("DestroyedByBoss")
                    return
                end
                print("boss laser target: " .. TargetLuaBehaviour.name)
                --tell Bunkergun to kill it's self
            else
                print("boss laser target: " .. TargetLuaBehaviour.name)
            end
            return
        end

        if (rigidbody ~= nil) then
            API_SLZ_Combat.BL_AttackEnemy(gameObject, 0.9 * Time.deltaTime * 60, collider, pos, normal)
            local forceToApply  = (20000 + (20000 * math.random())) * Time.deltaTime * 60
            if(gameObject.transform.root == Target.transform.root) then -- don't push the player out of the beam
                forceToApply = (5000) * Time.deltaTime * 60
                rigidbody.AddForceAtPosition(normal*forceToApply, pos)
            else
                rigidbody.AddForceAtPosition(normal*forceToApply, pos)
            end

            print("rigidbody is nil")
        end
    else
        print("GameObject is nil")
    end
end

function TriggerSurfaceImpact(pos, normal)
    local impactRotation = Quaternion.LookRotation(Vector3.forward, normal)
    LaserImpactEffect.setActive(true)
    LaserImpactEffect.transform.position = pos
    LaserImpactEffect.transform.rotation = impactRotation
    --local ImpactEffect = API_GameObject.BL_SpawnByBarcode("33.33.Spawnable.LaserImpact", pos, impactRotation)
end

RotSpeed = 8
function LookAtTarget()
    local targetPos = GetTargetPos()
    if (targetPos == nil) then
        return
    end

    -- Get direction to target, ignore Y-axis difference
    local selfPos = BL_Host.transform.position
    targetPos.y = selfPos.y -- keep same height

    local direction = (targetPos - selfPos).normalized
    local targetRotation = Quaternion.LookRotation(direction)

    -- Smooth rotation with speed
    BL_Host.transform.rotation = Quaternion.RotateTowards(BL_Host.transform.rotation, targetRotation,
        RotSpeed * Time.deltaTime)
end

BaseY = nil
function OscilateMovement()
    if (BaseY == nil) then
        BaseY = BL_Host.transform.position.y
    end

    local yBob = math.sin(Time.time * 0.5) * 1
    local Pos = BL_Host.transform.position
    Pos.y = BaseY + yBob -- oscillate around base Y
    BL_Host.transform.position = Pos
end

function GetTargetPos()
    if (Target ~= nil and API_GameObject.BL_IsValid(Target)) then
        local boxCol = API_GameObject.BL_GetComponent(Target, "BoxCollider")
        local meshRend = API_GameObject.BL_GetComponent(Target, "MeshRenderer")

        if (meshRend ~= nil) then
            return meshRend.bounds.center
        elseif (boxCol ~= nil) then
            return boxCol.bounds.center
        else
            return Target.transform.position
        end
    end
    return nil
end

function CalculateVelocityForAngle(LaunchPos, TargetPos, desiredAngleDeg)
    --calculate velocity to apply to fireballs to act as mortars
    --credit: ChatGPT
    local g = -Physics.gravity.y -- positive gravity
    local dx = TargetPos.x - LaunchPos.x
    local dz = TargetPos.z - LaunchPos.z
    local dy = TargetPos.y - LaunchPos.y

    local distanceXZ = math.sqrt(dx * dx + dz * dz)
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
    local velocity = horizontalDir * (speed * cosTheta) + (Vector3.up * (speed * sinTheta))
    local rotation = Quaternion.LookRotation(velocity)

    return {
        angle = desiredAngleDeg,
        speed = speed,
        velocity = velocity,
        rotation = rotation
    }
end

BombardmentArea = 1.5
function PropelMortarProjectiles()
    if (MortarProjectile ~= nil and IsValid(MortarProjectile)) then
        local targetPos = GetTargetPos()
        local TargetOffset = API_Random.OnUnitSphere()*BombardmentArea
        local solution = CalculateVelocityForAngle(MortarEmitter.transform.position, targetPos + TargetOffset, 70)
        local MortarRB = API_GameObject.BL_GetComponent(MortarProjectile, "Rigidbody")
        local DespawnDelay = API_GameObject.BL_GetComponent(MortarProjectile, "DespawnDelay")

        if (DespawnDelay ~= nil) then
            --bonelab fireball projectiles dissapear after 5 seconds, not long enough to get to the player
            DespawnDelay.secondsUntilDisable = 20
        end

        if (MortarRB ~= nil) then
            --drag interfers with arc calculations
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
STATE_BANG_FLOOR = false
STATE_DELAYED_START = false
STATE_RISE_UP = false
STATE_READY = false
STATE_CHARGING_LASER = false
STATE_FIRING_LASER = false
STATE_COOLDOWN_LASER = false
STATE_LAUNCHING_MORTAR = false
STATE_MORTAR_COOLDOWN = false
STATE_DISPATCHDRONES = false

STATE_DESTROYBUNKER1 = false
STATE_DESTROYBUNKER2 = false
STATE_DESTROYBUNKER3 = false

STATE_DYING = false




BangCount = 0
BangDelay = nil

function BangOnFloor()
local BangPosition = API_Vector.BL_Vector3(49.0,-91.0,-46.0)
API_GameObject.BL_SpawnByBarcode("BonelabMeridian.Luamodexamplecontent.Spawnable.DustCloudBangEffect", BangPosition, Quaternion.identity)
end

function STATE_BANG_FLOOR_FUNC()

    if(WellcapSeenByPlayer and BangDelay == nil) then
        BangDelay = Time.time + 5.0 --delay 10 seconds from scene load
    end

    if (BangDelay ~= nil and Time.time >= BangDelay) then
        BangOnFloor()
        BangDelay = Time.time + 2.5
        BangCount = BangCount + 1
    end

    if(BangCount >= 5) then
        WellCapAudio.Play()
        API_GameObject.BL_Destroy(WellCap)
        STATE_BANG_FLOOR = false
        STATE_RISE_UP = true
        BangCount = 0
        BangDelay = nil
    end
end


RiseTime = 5 --ms
InitalYDif = nil
RiseTime = 5 -- seconds
RiseStartTime = nil
RiseStartY = nil

function STATE_RISE_UP_FUNC()
    yOffset = 2.0
    local targetPos = GetTargetPos()
    local risePos = targetPos
    local bossPos = BL_Host.transform.position

    if RiseStartTime == nil then
        RiseStartTime = Time.time
        RiseStartY = bossPos.y
    end

    local elapsed = Time.time - RiseStartTime
    local t = math.min(elapsed / RiseTime, 1) -- goes from 0 to 1
    -- Apply easing: ease-out (slow at the end)
    local easedT = 1 - math.pow(1 - t, 3)     -- cubic ease-out
    bossPos.y = Mathf.Lerp(RiseStartY, risePos.y + yOffset, easedT)
    BL_Host.transform.position = bossPos

    if (t >= 1) then
        STATE_RISE_UP = false
        STATE_DELAYED_START = true
        STATE_DELAYED_START_TIME = Time.time
        RiseStartTime = nil
        RiseStartY = nil
    end
end

STATE_DELAYED_START_TIME = 0
function STATE_DELAYED_START_FUNC()
    if (Time.time >= (STATE_DELAYED_START_TIME + StartDelayTime)) then
        MoveLaserAim(true)
        STATE_DELAYED_START = false
        STATE_READY = true
    end
end

function STATE_DESTROYBUNKER1_FUNC()
    Target = BunkerGun1.gameObject

    if (BunkerIsDestroyed(BunkerGun1)) then
        print("bunker 1 destroyed - returning target to player from" .. Target.name)
        Target = PlayerTarget
    end
    --return to ready so the boss can keep fighting
    STATE_DESTROYBUNKER1 = false
    STATE_READY = true
end

function STATE_DESTROYBUNKER2_FUNC()
    Target = BunkerGun2.gameObject

    if (BunkerIsDestroyed(BunkerGun2)) then
        Target = PlayerTarget
    end
    STATE_DESTROYBUNKER2 = false
    STATE_READY = true
end

function STATE_DESTROYBUNKER3_FUNC()
    Target = BunkerGun3.gameObject

    if (BunkerIsDestroyed(BunkerGun3)) then
        Target = PlayerTarget
    end
    STATE_DESTROYBUNKER3 = false
    STATE_READY = true
end

function STATE_READY_FUNC()
    --pick an attack method
    local targetPos = GetTargetPos()
    if (targetPos ~= nil) then
        targetYdif = math.abs(targetPos.y - BL_Host.transform.position.y)

        if (targetYdif > 3.5) then
            STATE_RISE_UP = true
            STATE_READY = false
            return
        end
    end

    if (TotalDamage > HealthSetpoint1 and not BunkerIsDestroyed(BunkerGun1) and Target == PlayerTarget) then
        STATE_READY = false
        STATE_DESTROYBUNKER1 = true
        print("destroying bunker 1")
        return
    end

    if (TotalDamage > HealthSetpoint2 and not BunkerIsDestroyed(BunkerGun2) and Target == PlayerTarget) then
        STATE_READY = false
        STATE_DESTROYBUNKER2 = true
        print("destroying bunker 2")
        return
    end

    if (TotalDamage > HealthSetpoint3 and not BunkerIsDestroyed(BunkerGun3) and Target == PlayerTarget) then
        STATE_READY = false
        STATE_DESTROYBUNKER3 = true
        print("destroying bunker 3")
        return
    end

    if (TotalDamage > HealthSetpoint4) then
        STATE_READY = false
        STATE_DYING = true
        print("DYIIIING")
        return
    end

    if (CanSeeTarget() and not PlayerInBunker) then
        STATE_READY = false
        STATE_CHARGING_LASER = true
        STATE_CHARGING_LASER_TIME = Time.time
        MoveLaserAim(true)
        return
    else
        local fireOption = math.random(1, 3)
        if (fireOption == 1) then
            STATE_READY = false
            STATE_LAUNCHING_MORTAR = true
            return
        elseif (fireOption == 2) then
            STATE_READY = false
            STATE_DISPATCHDRONES = true
            return
        elseif (fireOption == 3) then
            STATE_READY = false
            STATE_CHARGING_LASER = true
            STATE_CHARGING_LASER_TIME = Time.time
            MoveLaserAim(true)
            return
        end
    end
end

STATE_CHARGING_LASER_TIME = 0
function STATE_CHARGING_LASER_FUNC()
    --trigger start charging effect
    LaserCharging.setActive(true)
    if (Time.time >= STATE_CHARGING_LASER_TIME + LaserChargingTime) then
        STATE_CHARGING_LASER = false
        STATE_FIRING_LASER = true
        STATE_FIRING_LASER_TIME = Time.time
    end
end

STATE_FIRING_LASER_TIME = 0
function STATE_FIRING_LASER_FUNC()
    --enable laser
    Laser.setActive(true)
    PlayLaserSound(true)
    PositionLaser()
    if (Time.time >= STATE_FIRING_LASER_TIME + LaserFiringTime) then
        --disable laser
        LaserCharging.setActive(false)
        Laser.setActive(false)
        LaserImpactEffect.setActive(false)
        PlayLaserSound(false)
        STATE_FIRING_LASER = false
        STATE_COOLDOWN_LASER = true
        STATE_COOLDOWN_LASER_TIME = Time.time
    end
end

STATE_COOLDOWN_LASER_TIME = 0
function STATE_COOLDOWN_LASER_FUNC()
    --laser venting effect
    LaserCooldown.setActive(true)
    if (Time.time >= STATE_COOLDOWN_LASER_TIME + LaserCooldownTime) then
        --disable laser venting effect
        STATE_COOLDOWN_LASER = false
        STATE_READY = true
        LaserCooldown.setActive(false)
    end
end

NumberOfMortars = 10
CurrentMortarCount = 0
NextMortarTime = 0
function STATE_LAUNCHING_MORTAR_FUNC()
    if (Time.time > NextMortarTime) then
        API_GameObject.BL_SpawnByBarcode(BL_This, "MortarProjectile", "c1534c5a-355a-4734-8103-5ded46697265",MortarEmitter.transform.position, Quaternion.identity, nil, true)
        NextMortarTime = Time.time + 0.4
        CurrentMortarCount = CurrentMortarCount + 1
    end


    if (CurrentMortarCount > NumberOfMortars) then
        STATE_LAUNCHING_MORTAR = false
        STATE_MORTAR_COOLDOWN = true
        STATE_MORTAR_COOLDOWN_TIME = Time.time
        CurrentMortarCount = 0
    end
end

STATE_MORTAR_COOLDOWN_TIME = 0
function STATE_MORTAR_COOLDOWN_FUNC()
    if (Time.time >= STATE_MORTAR_COOLDOWN_TIME + MortarCooldownTime) then
        STATE_MORTAR_COOLDOWN = false
        STATE_READY = true
    end
end

NumberOfDrones = 3
CurrentDroneCount = 0
NextDroneTime = 0
waitingOnDroneSpawn = false
minNextDroneWave = 0            --soonest time we can summon drones again - be a little kind to the player
secondsBetweenDroneWaves = 40.0 --minimum
function STATE_DISPATCHDRONES_FUNC()

    if(Time.time < minNextDroneWave) then
        print("too soon for next drone wave")
        STATE_DISPATCHDRONES = false
        STATE_READY = true
        CurrentDroneCount = 0
        waitingOnDroneSpawn = false
    end

    if (#SkeletonMinions >= MaxMinionCount) then
        print("too many active drones " .. tostring(#SkeletonMinions) .. " max: " .. tostring(MaxMinionCount))
        STATE_DISPATCHDRONES = false
        STATE_READY = true
        CurrentDroneCount = 0
        waitingOnDroneSpawn = false
        return
    end

    if (Time.time > NextDroneTime and not waitingOnDroneSpawn) then
        targetPos = GetTargetPos()

        if (targetPos == nil) then
            return
        end
        enemySpawnPos = FindEnemySpawnPoint(targetPos, 10, 1)
        if (enemySpawnPos ~= nil) then
            API_GameObject.BL_SpawnByBarcode(BL_This, "SkeletonSpawn", "c1534c5a-de57-4aa0-9021-5832536b656c",
                enemySpawnPos, Quaternion.identity, nil, true)
            API_GameObject.BL_SpawnByBarcode("SLZ.BONELAB.Content.Spawnable.BlasterLightningNegative", enemySpawnPos,
                Quaternion.identity)
            waitingOnDroneSpawn = true
            NextDroneTime = Time.time + 1.0
            CurrentDroneCount = CurrentDroneCount + 1
        end
    end


    if (CurrentDroneCount > NumberOfDrones) then
        STATE_DISPATCHDRONES = false
        STATE_READY = true
        waitingOnDroneSpawn = false
        CurrentDroneCount = 0
        minNextDroneWave = Time.time + secondsBetweenDroneWaves
    else
        --print("drones: " .. tostring(CurrentDroneCount) .. " target: " .. NumberOfDrones)
    end
end

deathExplosionMax = 70
deathExplosionCount = 0
deathExplosionDelay = 0.2
nextExplosion = 0.0
function STATE_DYING_FUNC()
    if (deathExplosionCount < deathExplosionMax) then
        if (Time.time > nextExplosion) then
            local explosionPosition = GetRandomPointOnMeshRendererSphere(coneMeshRenderer)
            local explosionPosition2 = GetRandomPointOnMeshRendererSphere(coneMeshRenderer)
            API_GameObject.BL_SpawnByBarcode("c1534c5a-26fd-4606-aa5e-1098426c6173", explosionPosition,
                Quaternion.identity)
            API_GameObject.BL_SpawnByBarcode("SLZ.BONELAB.Content.Spawnable.BlasterLightningNegative", explosionPosition2,
                Quaternion.identity)
            nextExplosion = Time.time + math.random() * deathExplosionDelay
            deathExplosionCount = deathExplosionCount + 1
        end
    else
        bossPoolee = API_GameObject.BL_GetComponent(BL_Host.transform.root.gameObject, "Poolee")
        bossPoolee.Despawn()
        --API_GameObject.BL_Destroy(BL_Host.transform.root.gameObject)
    end
end

function CullExtraSkeletons()

    local targetPos = GetTargetPos()
    if (targetPos == nil) then
        -- print("CullExtraSkeletons: Target position not found.")
        return
    end
    local distances = {}
    for i, minion in ipairs(SkeletonMinions) do
        if minion ~= nil and API_GameObject.BL_IsValid(minion) then
            local pos = minion.transform.position
            local dist = (pos - targetPos).sqrMagnitude
            table.insert(distances, { index = i, sqrDist = dist })
        end
    end

    table.sort(distances, function(a, b)
        return a.sqrDist > b.sqrDist
    end)
    local toRemove = #SkeletonMinions - MaxMinionCount
    for i = 1, toRemove do
        local entry = distances[i]
        local minion = SkeletonMinions[entry.index]
        if minion ~= nil and API_GameObject.BL_IsValid(minion) then
            --   print("deleting skeleton " .. tostring(entry.index) .. " at distance" .. tostring(entry.sqrDist))
            API_GameObject.BL_Destroy(minion)
            SkeletonMinions[entry.index] = nil
        end
    end

    -- Rebuild the list without nils
    local cleaned = {}
    for _, obj in ipairs(SkeletonMinions) do
        print(obj.name .. " is active? " .. tostring(obj.activeInHierarchy) .. " " .. tostring(obj.activeSelf))
        if (obj ~= nil and IsValid(obj) and obj.activeInHierarchy) then
            table.insert(cleaned, obj)
        end
    end
    SkeletonMinions = cleaned
end

function SlowUpdate()
    print("BOSS SLOW UPDATE!")
    CullExtraSkeletons()
end

WellcapSeenByPlayer = false
function WellcapVisible()
    print("WellcapVisible called on boss script")
    WellcapSeenByPlayer = true
end

Setup = true
function Update()
    if (BL_This == nil or not API_GameObject.BL_IsValid(BL_Host) or not BL_This.Ready) then
        return
    end

    if (API_Player.BL_GetPhysicsRig() == nil or ObjDestruct == nil or API_Input.BL_LeftHand() == nil or RiseUpTarget == nil or not API_GameObject.BL_IsValid(RiseUpTarget)) then
        print("script components nil")
        return
    end

    if (Setup) then
        --run initial set up functions once everything is loaded
        ObjDestruct._health = 9999
        LastHealth = ObjDestruct._health
        PlayerTarget = API_Player.BL_GetPhysicsRig().m_head.gameObject
        Setup = false
    end

    if (Target == nil or not IsValid(Target)) then
        Target = PlayerTarget
    end

    if (SkeletonSpawn ~= nil and API_GameObject.BL_IsValid((SkeletonSpawn))) then
        table.insert(SkeletonMinions, SkeletonSpawn)
        API_SLZ_NPC.BL_SetNPCAnger(SkeletonSpawn, Target)
        --print("added skeleton to minion list - " .. tostring(#SkeletonMinions))
        waitingOnDroneSpawn = false
        SkeletonSpawn = nil
    end

    if not (STATE_BANG_FLOOR or STATE_RISE_UP or STATE_DELAYED_START or STATE_READY or STATE_CHARGING_LASER or STATE_FIRING_LASER or STATE_COOLDOWN_LASER or STATE_LAUNCHING_MORTAR or STATE_MORTAR_COOLDOWN or STATE_DISPATCHDRONES or STATE_DESTROYBUNKER1 or STATE_DESTROYBUNKER2 or STATE_DESTROYBUNKER3 or STATE_DYING) then
        print("NO STATE SET - SWITCHED TO STATE_BANG_FLOOR")
        STATE_BANG_FLOOR = true
        return
    end

    --ready to go

    ProcessDamage(ObjDestruct._health)
    MoveLaserAim(false)
    LookAtTarget()
    PropelMortarProjectiles()


    if (STATE_DELAYED_START) then
        STATE_DELAYED_START_FUNC()
        --print("STATE_DELAYED_START")
    elseif (STATE_BANG_FLOOR) then
        STATE_BANG_FLOOR_FUNC()
       -- print("STATE_RISE_UP")
    elseif (STATE_RISE_UP) then
        STATE_RISE_UP_FUNC()
       -- print("STATE_RISE_UP")
    elseif (STATE_READY) then
        STATE_READY_FUNC()
        --print("STATE_READY")
    elseif (STATE_CHARGING_LASER) then
        STATE_CHARGING_LASER_FUNC()
        --  print("STATE_CHARGING_LASER")
    elseif (STATE_FIRING_LASER) then
        STATE_FIRING_LASER_FUNC()
        -- print("STATE_FIRING_LASER")
    elseif (STATE_COOLDOWN_LASER) then
        STATE_COOLDOWN_LASER_FUNC()
        -- print("STATE_COOLDOWN_LASER")
    elseif (STATE_LAUNCHING_MORTAR) then
        STATE_LAUNCHING_MORTAR_FUNC()
        -- print("STATE_LAUNCHING_MORTAR")
    elseif (STATE_MORTAR_COOLDOWN) then
        STATE_MORTAR_COOLDOWN_FUNC()
        --print("STATE_MORTAR_COOLDOWN")
    elseif (STATE_DISPATCHDRONES) then
        STATE_DISPATCHDRONES_FUNC()
        -- print("STATE_DISPATCHDRONES")
    elseif (STATE_DESTROYBUNKER1) then
        STATE_DESTROYBUNKER1_FUNC()
        print("STATE_DESTROYBUNKER1")
    elseif (STATE_DESTROYBUNKER2) then
        STATE_DESTROYBUNKER2_FUNC()
        print("STATE_DESTROYBUNKER2")
    elseif (STATE_DESTROYBUNKER3) then
        STATE_DESTROYBUNKER3_FUNC()
        print("STATE_DESTROYBUNKER3")
    elseif (STATE_DYING) then
        STATE_DYING_FUNC()
    end
end
