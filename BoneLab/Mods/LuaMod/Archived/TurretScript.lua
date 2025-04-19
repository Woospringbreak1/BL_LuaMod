-- LuaBehaviour
function Start()
    print("initiating Lua turret")
    TurretParent =  BL_Host.transform.parent.gameObject
    TurretWeaponMarker =  TurretParent.Find("TurretWeaponMarker")
    TurretBaseRotor = TurretParent.Find("TurretBaseRotor")
    TurretWeaponRotor = TurretParent.Find("TurretWeaponRotor")

    BaseRotorJoint = API_GameObject.BL_GetComponent2(TurretBaseRotor,"HingeJoint")
    WeaponRotorJoint = API_GameObject.BL_GetComponent2(TurretWeaponRotor,"HingeJoint")
    BaseRotorJointRigidBody = API_GameObject.BL_GetComponent2(TurretBaseRotor,"Rigidbody")
    WeaponRotorJointRigidBody = API_GameObject.BL_GetComponent2(TurretWeaponRotor,"Rigidbody")

    if(BaseRotorJoint ~= nil and WeaponRotorJoint ~= nil) then
        print("BaseRotorJoint " .. tostring(BaseRotorJoint))
        print("WeaponRotorJoint " .. tostring(WeaponRotorJoint))
        print("Lua turret online")
    end

    -- Setpoints
    BaseSetpoint  = 50
    WeaponSetpoint = 0

    -- Proportional and Integral Gains
    Kbase = 1
    IBase = 1

    Kweapon = 1
    IWeapon = 1

    -- Integral sum (accumulates error over time)
    BaseInt = 0
    WeaponInt = 0

    deltaTime = API_Player.BL_GetFixedDeltaTime()
end

function Update()

    CalculateTurretSetpoints()

  --  if (API_Input.BL_IsKeyDown(97)) then
  --      WeaponSetpoint = WeaponSetpoint + 1
   -- end

  --  if(API_Input.BL_IsKeyDown(98)) then
  --      WeaponSetpoint = WeaponSetpoint - 1
  --  end

 --   if (API_Input.BL_IsKeyDown(275)) then
  --      BaseSetpoint = BaseSetpoint + 1
 --   end

 --   if(API_Input.BL_IsKeyDown(276)) then
 --       BaseSetpoint = BaseSetpoint - 1
 --   end
end

function CalculateTurretSetpoints()
    -- Get player position
    -- only sort of works!
    local LeftController = API_Input.BL_LeftHand()
    if(LeftController ~= nil) then  
        local PlayerPosition = LeftController.transform.position

        -- Get turret position (assuming `TurretParent` is correctly assigned)
        local TurretPosition = TurretWeaponMarker.transform.position

        -- Compute direction vector from turret to player
        local direction = (PlayerPosition - TurretPosition)

        -- Compute base rotation angle (yaw) - rotation around the Y-axis
        local BaseSetpointRad = math.atan2(direction.x, direction.z) -- atan2(y, x) is atan2(x, z) in game space
        local BaseSetpointDeg = math.deg(BaseSetpointRad) -- Convert to degrees

        -- Compute weapon rotation angle (pitch) - rotation around the X-axis
        local horizontalDistance = math.sqrt(direction.x^2 + direction.z^2) -- Hypotenuse on X-Z plane
        local WeaponSetpointRad = math.atan2(direction.y, horizontalDistance) -- Pitch angle
        local WeaponSetpointDeg = -1.0*math.deg(WeaponSetpointRad) -- Convert to degrees

        --WeaponSetpointDeg = WeaponSetpointDeg + 90 // effects base rotation?

        -- Normalize angles to stay within [-180, 180]
        BaseSetpoint = NormalizeAngle(BaseSetpointDeg)
        WeaponSetpoint = NormalizeAngle(WeaponSetpointDeg)

        -- Debugging output
        --print("BaseSetpoint: " .. tostring(BaseSetpoint))
        --print("WeaponSetpoint: " .. tostring(WeaponSetpoint))
    end
end


function NormalizeAngle(angle)
    -- Ensures angle is in range [-180, 180]
    -- this prevents jumping and loss of control near +180 or -180 degrees
    while angle > 180 do
        angle = angle - 360
    end
    while angle < -180 do
        angle = angle + 360
    end
    return angle
end

function FixedUpdate()
    if BaseRotorJointRigidBody ~= nil then
        -- Read current positions
        BaseRotorPosition = BaseRotorJoint.angle
        WeaponRotorPosition = WeaponRotorJoint.angle

        -- Normalize both setpoints and current positions
        BaseSetpoint = NormalizeAngle(BaseSetpoint)
        WeaponSetpoint = NormalizeAngle(WeaponSetpoint)
        BaseRotorPosition = NormalizeAngle(BaseRotorPosition)
        WeaponRotorPosition = NormalizeAngle(WeaponRotorPosition)

        -- Compute shortest path errors
        BaseError = NormalizeAngle(BaseSetpoint - BaseRotorPosition)
        WeaponError = NormalizeAngle(WeaponSetpoint - WeaponRotorPosition)

        -- Accumulate integral term (sum of past errors)
        BaseInt = BaseInt + BaseError * deltaTime
        WeaponInt = WeaponInt + WeaponError * deltaTime

        -- Apply anti-windup BEFORE using it
        maxIntegral = 10  -- Adjust this based on your needs
        BaseInt = math.max(-maxIntegral, math.min(BaseInt, maxIntegral))
        WeaponInt = math.max(-maxIntegral, math.min(WeaponInt, maxIntegral))

        -- Compute PI control output
        BaseOutput = (Kbase * BaseError) + (IBase * BaseInt)
        WeaponOutput = (Kweapon * WeaponError) + (IWeapon * WeaponInt)

        -- Apply output to your actuators
        API_Physics.BL_SetHingeJointMotor(TurretBaseRotor, BaseOutput, 999, false)
        API_Physics.BL_SetHingeJointMotor(TurretWeaponRotor, WeaponOutput, 999, false)

        -- Debug printprint("Base Position: " .. tostring(BaseRotorJoint.transform.localRotation.eulerAngles.y) ..
      " | Setpoint: " .. tostring(BaseSetpoint) .. " | Error: " .. NormalizeAngle(BaseSetpoint - BaseRotorJoint.transform.localRotation.eulerAngles.y))

      print("Weapon Position: " .. tostring(WeaponRotorJoint.transform.localRotation.eulerAngles.x) ..
            " | Setpoint: " .. tostring(WeaponSetpoint) .. " | Error: " .. NormalizeAngle(WeaponSetpoint - WeaponRotorJoint.transform.localRotation.eulerAngles.x)))
      
        --print( "Base Position: " .. tostring(BaseRotorPosition .. " | Setpoint: " .. tostring(BaseSetpoint) .. " | Error: " .. BaseError))
        --print( "Weapon Position: " .. tostring(WeaponRotorPosition .. " | Setpoint: " .. tostring(WeaponSetpoint) .. " | Error: " .. WeaponError))
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
