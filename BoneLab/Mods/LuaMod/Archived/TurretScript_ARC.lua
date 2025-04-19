--LuaBehaviour
i = 0
function Start()
    print("initiating Lua turret")
    TurretParent =  BL_Host.transform.parent.gameObject
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
        BaseRotorJoint.useMotor = true
       
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

    if (API_Input.BL_IsKeyDown(97)) then
        WeaponSetpoint = WeaponSetpoint + 0.1
    end

    if(API_Input.BL_IsKeyDown(98)) then
        WeaponSetpoint = WeaponSetpoint - 0.1
    end

    if (API_Input.BL_IsKeyDown(275)) then
        BaseSetpoint = BaseSetpoint + 0.5
    end

    if(API_Input.BL_IsKeyDown(276)) then
        BaseSetpoint = BaseSetpoint - 0.5
    end

end

function FixedUpdate()
    if BaseRotorJointRigidBody ~= nil then
        -- Read current positions
        BaseRotorPosition = BaseRotorJoint.angle --BaseRotorJointRigidBody.transform.localEulerAngles.y
        WeaponRotorPosition = WeaponRotorJoint.angle --WeaponRotorJointRigidBody.transform.localEulerAngles.z

        -- Compute errors
        BaseError = BaseSetpoint - BaseRotorPosition
        WeaponError = WeaponSetpoint - WeaponRotorPosition

        -- Accumulate integral term (sum of past errors)
        BaseInt = BaseInt + BaseError * deltaTime
        WeaponInt = WeaponInt + WeaponError * deltaTime

        -- Compute PI control output
        BaseOutput = (Kbase * BaseError) + (IBase * BaseInt)
        WeaponOutput = (Kweapon * WeaponError) + (IWeapon * WeaponInt)

        -- Optional: Add anti-windup (limit integral growth)
        maxIntegral = 10  -- Adjust this based on your needs
        BaseInt = math.max(-maxIntegral, math.min(BaseInt, maxIntegral))
        WeaponInt = math.max(-maxIntegral, math.min(WeaponInt, maxIntegral))

        -- Apply output to your actuators (if needed)
        API_Physics.BL_SetHingeJointMotor(TurretBaseRotor,BaseOutput,999,false)
        API_Physics.BL_SetHingeJointMotor(TurretWeaponRotor,WeaponOutput,999,false)
        -- BaseRotorJointRigidBody.AddForce(API_Vector.BL_Vector3(BaseOutput, 0, 0))
        --print(tostring(WeaponRotorJointRigidBody.transform.localEulerAngles))
        print(tostring(WeaponRotorPosition))
        print("setpoint " .. tostring(WeaponSetpoint) .. " error " .. WeaponError)
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
    
