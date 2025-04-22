-- LuaBehaviour

BaseSetpoint = 50
WeaponSetpoint = 0

function Start()
    print("Initiating Lua turret with Configurable Joints")

    -- Find Turret Parts
    TurretParent = BL_Host.transform.parent.gameObject
    TurretWeaponMarker = TurretParent.Find("TurretWeaponMarker")
    TurretBaseRotor = TurretParent.Find("TurretBaseRotor")
    TurretWeaponRotor = TurretParent.Find("TurretWeaponRotor")

    -- Get Configurable Joints
    BaseRotorJoint = API_GameObject.BL_GetComponent2(TurretBaseRotor, "ConfigurableJoint")
    WeaponRotorJoint = API_GameObject.BL_GetComponent2(TurretWeaponRotor, "ConfigurableJoint")

    print("BaseRotorJoint: " .. tostring(BaseRotorJoint))
    print("WeaponRotorJoint: " .. tostring(WeaponRotorJoint))

    if BaseRotorJoint ~= nil and WeaponRotorJoint ~= nil then
        print("Lua turret online")

        -- Save initial joint rotations (for proper local space targetRotation calculation)
        InitialBaseRotation = TurretBaseRotor.transform.localRotation
        InitialWeaponRotation = TurretWeaponRotor.transform.localRotation

        print("Initial Base Rotation: " .. tostring(InitialBaseRotation.eulerAngles))
        print("Initial Weapon Rotation: " .. tostring(InitialWeaponRotation.eulerAngles))

        print("Base rotor joint pos damping: " .. BaseRotorJoint.angularYZDrive.positionDamper)
        BaseRotorJoint.angularYZDrive.positionDamper = 50
        print("Base rotor joint pos damping: " .. BaseRotorJoint.angularYZDrive.positionDamper)
        BaseRotorJoint.angularYZDrive.m_PositionDamper = 50
        print("Base rotor joint pos damping: " .. BaseRotorJoint.angularYZDrive.positionDamper)
    end

    -- Target Rotation Setpoints (Degrees)

end

function Update()
    CalculateTurretSetpoints()
    
    if API_Input.BL_IsKeyDown(97) then
        WeaponSetpoint = WeaponSetpoint + 1
    end

    if API_Input.BL_IsKeyDown(98) then
        WeaponSetpoint = WeaponSetpoint - 1
    end
end

function CalculateTurretSetpoints()
    -- Get player position
    local LeftController = API_Input.BL_LeftHand()
    if LeftController ~= nil then  
        local PlayerPosition = LeftController.transform.position

        -- Get turret position
        local TurretPosition = TurretWeaponMarker.transform.position

        -- Compute direction vector from turret to player
        local direction = (PlayerPosition - TurretPosition)

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
