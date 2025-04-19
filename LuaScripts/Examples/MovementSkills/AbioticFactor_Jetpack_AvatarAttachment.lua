Thrusting = false
MaxFlightTime = 8.5 --seconds
RemainingFlightTime = MaxFlightTime
RechargeRate = 0.3 -- seconds per second
ThrustForce = 1.2*9.8 

STATE_READY = false
STATE_OVERHEATED = false

function Start()
    print("Hello, World from the Abiotic Factor jetpack lua!")
    JetpackController = nil
    JetpackControllerInterface = nil
end


WaitingForResourceSpawn = false
function SpawnResources()
    if(not WaitingForResourceSpawn) then
        API_GameObject.BL_SpawnByBarcode(BL_This,"JetpackController","BonelabMeridian.Luamodexamplecontent.Spawnable.JetpackController", Vector3.zero, Quaternion.identity,nil, true)
        WaitingForResourceSpawn = true
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

function SetUpController()
    if(PlayerPhysicsRig ~= nil and API_GameObject.BL_IsValid(PlayerPhysicsRig.gameObject)) then
        forearm = API_GameObject.BL_FindInChildren(PlayerPhysicsRig.gameObject,"ForearmLf").transform
        JetpackControllerInterface = API_GameObject.BL_GetComponent(JetpackController,"LuaBehaviour")
        JetpackController.transform.parent = forearm
        JetpackController.transform.localPosition = API_Vector.BL_Vector3(0.05,0,0.4)
        Rot = Quaternion.identity
        Rot.eulerAngles = API_Vector.BL_Vector3(0,90,0)
        JetpackController.transform.localRotation = Rot
        JetpackAudioList = API_GameObject.BL_GetComponents(JetpackController,"AudioSource")
        JetpackAudio = JetpackAudioList
        JetpackBeep = JetpackAudio[2]
        JetpackRumble = JetpackAudio[1]

        ControllerSetup = true
    end
end

OnlyOnce = false
ControllerSetup = false
MaxBeepTime = 0.5
MinBeepTime = 0.0  --i.e, play continously
BeepTime = 0
FuelWarningPoint = 0.5
function Beep(fuelremaining)
    if(JetpackAudioList ~= nil) then
        if(Time.time > BeepTime) then
            if(not JetpackBeep.isPlaying) then
                JetpackBeep.Play()
                BeepTime = Time.time + ((MaxBeepTime-MinBeepTime)/FuelWarningPoint)*fuelremaining
            end
            
        end
    else
    end
end


function PlayEngineRumble()
    if(not JetpackRumble.isPlaying) then
        JetpackRumble.Play()
    end
end

function Update()

    if(BL_This == nil or not API_GameObject.BL_IsValid(BL_Host) or not BL_This.Ready) then
        print("JetpackController not yet ready")
        return
    end

    if(PlayerFeet == nil and API_Player.BL_GetPhysicsRig() ~= nil) then
        PlayerPhysicsRig = API_Player.BL_GetPhysicsRig()
        PlayerFeet = PlayerPhysicsRig._feetRb
        print("player not yet ready")
    end
 
    if(not API_GameObject.BL_IsValid(JetpackController)) then
        SpawnResources()
       -- print("spawning/waiting for jetpack controller " .. tostring(JetpackController))
        return
    end

    if(API_GameObject.BL_IsValid(JetpackController) and not ControllerSetup) then
        SetUpController();
        print("setting up jetpack controller")
        return
    end

    if(not STATE_OVERHEATED and not STATE_READY and API_GameObject.BL_IsValid(JetpackControllerInterface) and ControllerSetup and JetpackControllerInterface.Ready) then
        STATE_OVERHEATED = false
        STATE_READY = true
    end

    if(Thrusting and RemainingFlightTime < FuelWarningPoint*MaxFlightTime) then
       Beep(RemainingFlightTime/MaxFlightTime)
    end

    if(Thrusting) then
        PlayEngineRumble()
        RemainingFlightTime = RemainingFlightTime - Time.deltaTime
        if(RemainingFlightTime <= 0.11) then
            Thrusting = false
            RemainingFlightTime = 0
            STATE_READY = false
            STATE_OVERHEATED = true
            JetpackRumble.Stop()
        end
    else
        JetpackRumble.Stop()
        RemainingFlightTime = RemainingFlightTime + (Time.fixedDeltaTime * RechargeRate)
        if(RemainingFlightTime > MaxFlightTime) then
            RemainingFlightTime = MaxFlightTime
        end
    end

    if(STATE_OVERHEATED) then
        RemainingFlightTime = RemainingFlightTime + (Time.fixedDeltaTime * RechargeRate*0.5)
        JetpackControllerInterface.CallFunction("SetOverheated",true,RemainingFlightTime/MaxFlightTime)
        if(RemainingFlightTime > 0.41*MaxFlightTime) then
            STATE_OVERHEATED = false
            STATE_READY = true
            JetpackControllerInterface.CallFunction("SetOverheated",false,RemainingFlightTime/MaxFlightTime)
        end

    end

    if(STATE_READY) then
        JetpackControllerInterface.CallFunction("SetDisplayNumber",RemainingFlightTime/MaxFlightTime) 
        if(PlayerPhysicsRig ~= nil and API_GameObject.BL_IsValid(PlayerPhysicsRig.gameObject)) then
            if(API_Input.BL_IsAButtonDownOnce() and PlayerPhysicsRig.ungroundedThisFrame and RemainingFlightTime > 0) then
                Thrusting = true
            elseif(not API_Input.BL_IsAButtonDown() or RemainingFlightTime <= 0) then
                Thrusting = false
            end
        end
    end



end

function FixedUpdate()
    if(Thrusting) then
        PlayerPhysicsRig.marrowEntity.AddForce(Vector3.up * ThrustForce,ForceMode.Acceleration) --removing mass from the equations makes all avatars usable
    end
end


function  OnDisable()
    API_GameObject.BL_Destroy(JetpackController)    
    WaitingForResourceSpawn = false
end
 
  function OnDestroy()
    API_GameObject.BL_Destroy(JetpackController)  
    WaitingForResourceSpawn = false
  end