-- LuaBehaviour

BaseSetpoint = 50
WeaponSetpoint = 0
SearchRadius = 5.0
Target = nil
TargetRenderer = nil
LuaGun = nil
function Start()
    print("Initiating Lua turret with Configurable Joints")
    print("I am " .. BL_Host.name)

    -- Find Turret Parts
    TurretParent = BL_Host.transform.root.gameObject
    TurretWeaponMarker = API_GameObject.BL_FindInChildren(TurretParent,"TurretWeaponMarker").gameObject --FindChild(TurretParent,"TurretWeaponMarker")[1].gameObject
    TurretBaseRotor = API_GameObject.BL_FindInChildren(TurretParent,"TurretBaseRotor").gameObject--TurretParent.transform.Find("TurretBaseRotor").gameObject
    TurretWeaponRotor = API_GameObject.BL_FindInChildren(TurretParent,"TurretWeaponRotor").gameObject--TurretParent.transform.Find("TurretWeaponRotor").gameObject

    -- Get Configurable Joints
    BaseRotorJoint = API_GameObject.BL_GetComponent2(TurretBaseRotor, "ConfigurableJoint")
    WeaponRotorJoint = API_GameObject.BL_GetComponent2(TurretWeaponRotor, "ConfigurableJoint")
    LuaGun = API_GameObject.BL_GetComponentInChildren(TurretParent, "LuaGun")

    print("LuaGun is " .. tostring(LuaGun) .. "name is " .. LuaGun.name .. " " .. " " )
    print("BaseRotorJoint: " .. tostring(BaseRotorJoint))
    print("WeaponRotorJoint: " .. tostring(WeaponRotorJoint))
    print("TurretWeaponMarker: " .. tostring(TurretWeaponMarker))

    if BaseRotorJoint ~= nil and WeaponRotorJoint ~= nil then
        print("Lua turret online")

        -- Save initial joint rotations (for proper local space targetRotation calculation)
        InitialBaseRotation = TurretBaseRotor.transform.localRotation
        InitialWeaponRotation = TurretWeaponRotor.transform.localRotation

        print("Initial Base Rotation: " .. tostring(InitialBaseRotation.eulerAngles))
        print("Initial Weapon Rotation: " .. tostring(InitialWeaponRotation.eulerAngles))

        --print("Base rotor joint pos damping: " .. BaseRotorJoint.angularYZDrive.positionDamper)
        BaseRotorJoint.angularYZDrive.positionDamper = 50
       -- print("Base rotor joint pos damping: " .. BaseRotorJoint.angularYZDrive.positionDamper)
        BaseRotorJoint.angularYZDrive.m_PositionDamper = 50
        --print("Base rotor joint pos damping: " .. BaseRotorJoint.angularYZDrive.positionDamper)
    end

    -- Target Rotation Setpoints (Degrees)

end



function LocateTargets()
    local position = BL_Host.transform.position

    -- Debug prints
    --print("position " .. tostring(position))
    --print("SearchRadius " .. tostring(SearchRadius))
    --print("Physics.OverlapSphere " .. tostring(Physics.OverlapSphere))

    -- Get colliders within the sphere
    local colliders = Physics.OverlapSphere(position, SearchRadius)
    local objects = {}


    for f in colliders do
        local obj = f.gameObject
        if (obj ~= TurretParent and not obj.transform:IsChildOf(TurretParent.transform)) then
            local distance = (obj.transform.position - position).sqrMagnitude
            table.insert(objects, { obj = obj, distance = distance })
        end
    end


-- If no valid objects remain after filtering, return
if #objects == 0 then
    --print("No valid objects found in sphere.")
    return
end

-- Sort the table by distance
table.sort(objects, function(a, b) return a.distance < b.distance end)

-- Iterate and print the sorted objects
for i = 1, #objects do
    --print("Object: " .. objects[i].obj.name .. ", Distance: " .. objects[i].distance)
    npc = API_GameObject.BL_GetComponentInChildren(objects[i].obj.transform.root.gameObject,"AIBrain")
    if(npc ~= nil and not npc.isDead) then
        Target = npc
        TargetRenderer = API_GameObject.BL_GetComponentInChildren(objects[i].obj.transform.root.gameObject,"Renderer")
        --print("setting target to: " .. npc.name)
        return
    end

end
    
   

end

function CheckFiringLine()
    local position = TurretWeaponMarker.transform.position
    local direction = TurretWeaponMarker.transform.forward
    local SphereCast = API_Physics.BL_SphereCast(position, direction, 0.2, 20)

    if (SphereCast ~= nil) then
        if (SphereCast.transform.root == Target.transform.root) then
            return true
        end
    end

    return false
end


once = false

function SlowUpdate()
    --print("lua turret slow update")
    if(Target == nil) then 
        LocateTargets()
    end
end

function Update()
    --print("lua turret  update")
    if(Target ~= nil and Target.isDead) then 
        Target = nil
        TargetRenderer = nil
    end

    if(Target ~= nil) then
        CalculateTurretSetpoints()
        if(CheckFiringLine()) then
            LuaGun.SetMagazineRounds(32)
            LuaGun.ForceGunFire()
        end

    end
        
    

    
end

function CalculateTurretSetpoints()
    -- Get player position
        local TargetPosition = Target.transform.position

        if(TargetRenderer ~= nil) then
            TargetPosition = TargetRenderer.bounds.center
           -- print('using renderer to find center' .. tostring(TargetRenderer.bounds.center))
        end

        -- Get turret position
        local TurretPosition = TurretWeaponMarker.transform.position

        -- Compute direction vector from turret to player
        local direction = (TargetPosition - TurretPosition)

        -- Compute base rotation angle (yaw) - rotation around the Y-axis
        local BaseSetpointRad = math.atan2(direction.x, direction.z) 
        local BaseSetpointDeg = math.deg(BaseSetpointRad)

        -- Compute weapon rotation angle (pitch) - rotation around the X-axis
        local horizontalDistance = math.sqrt(direction.x^2 + direction.z^2) 
        local WeaponSetpointRad = math.atan2(direction.y, horizontalDistance) 
        local WeaponSetpointDeg = -math.deg(WeaponSetpointRad) 

        -- Normalize angles to stay within [-180, 180]
        BaseSetpoint = NormalizeAngle(BaseSetpointDeg)
        WeaponSetpoint = NormalizeAngle(WeaponSetpointDeg)
end

function NormalizeAngle(angle)
    -- Ensures angle is in range [-180, 180]
    while angle > 180 do
        angle = angle - 360
    end
    while angle < -180 do
        angle = angle + 360
    end
    return angle
end

function FixedUpdate()
    --print("lua turret fixed update")
    if BaseRotorJoint ~= nil and WeaponRotorJoint ~= nil then
        -- Convert Euler angles to Quaternions
        local BaseRotationV = API_Vector.BL_Vector3(0, -BaseSetpoint, 0)
        local WeaponRotationV = API_Vector.BL_Vector3(-WeaponSetpoint, -WeaponSetpoint, -WeaponSetpoint)

        local BaseRotation = Quaternion.Euler(BaseRotationV)
        local WeaponRotation = Quaternion.Euler(WeaponRotationV)

        -- Apply rotation relative to initial joint rotation
      --  BaseRotorJoint.targetRotation = Quaternion.Inverse(InitialBaseRotation) * BaseRotation
      --  WeaponRotorJoint.targetRotation = Quaternion.Inverse(InitialWeaponRotation) * WeaponRotation
      BaseRotorJoint.targetRotation = BaseRotation
      WeaponRotorJoint.targetRotation = WeaponRotation

        -- Debugging output
        --print("Base Target: " .. tostring(BaseRotationV))
        --print("Weapon Target: " .. tostring(WeaponRotationV))
        --print("Weapon Orientation: " .. tostring(TurretWeaponRotor.transform.localRotation.eulerAngles))
        --print("Weapon Setpoint: " .. tostring(WeaponSetpoint))
        --print("From Joint: " .. tostring(WeaponRotorJoint.targetRotation.eulerAngles))
    end
end

function OnEnable()
    print("OnEnable")
end

function OnDisable()
    print("OnDisable")
end

function OnDestroy()
    print("OnDestroy")
end
