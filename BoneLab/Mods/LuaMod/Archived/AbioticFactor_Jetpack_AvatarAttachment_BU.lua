Thrusting = false
MaxFlightTime = 8.5 --seconds
RemainingFlightTime = MaxFlightTime
RechargeRate = 0.3 -- seconds per second
ThrustForce = 1.2*9.8 

STATE_READY = false
STATE_OVERHEATED = false

function Start()
    print("Hello, World from the Abiotic Factor jetpack lua!")
    PlayerPhysicsRig = API_Player.BL_GetPhysicsRig()
    PlayerFeet = PlayerPhysicsRig._feetRb
    JetpackController = nil
    JetpackControllerInterface = nil
    
end


WaitingForResourceSpawn = false
function SpawnResources()
    if(not WaitingForResourceSpawn) then
        API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This,"JetpackController","33.33.Spawnable.JetpackConroller", Vector3.zero, Quaternion.identity,nil, true)
        WaitingForResourceSpawn = true
    end
end


function SetUpController()
    if(PlayerPhysicsRig ~= nil and API_GameObject.BL_IsValid(PlayerPhysicsRig.gameObject)) then
        forearm = API_GameObject.BL_FindInChildren(PlayerPhysicsRig.gameObject,"ForearmLf") 
        JetpackControllerInterface = API_GameObject.BL_GetComponent2(JetpackController,"LuaBehaviour")
        JetpackController.transform.parent = forearm
        JetpackController.transform.localPosition = API_Vector.BL_Vector3(0.05,0,0.4)
        Rot = Quaternion.identity
        Rot.eulerAngles = API_Vector.BL_Vector3(0,90,0)
        JetpackController.transform.localRotation = Rot
        JetpackAudioList = API_GameObject.BL_GetComponents(JetpackController,"AudioSource")
        print(tostring(JetpackAudioList))
        print(tostring(JetpackAudioList.Count))
        JetpackAudio = API_Utils.BL_ToLuaTable(JetpackAudioList,BL_This)
        JetpackBeep = JetpackAudio[2]
        JetpackRumble = JetpackAudio[1]
        print("audio holder " .. tostring(JetpackAudio))
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
            if(not JetpackAudioList[1].isPlaying) then
                JetpackBeep.Play()
                BeepTime = Time.time + ((MaxBeepTime-MinBeepTime)/FuelWarningPoint)*fuelremaining
            end
            
        end
    else
       -- print("Jetpack audio invalid!")
    end
end


function PlayEngineRumble()
    if(not JetpackRumble.isPlaying) then
        JetpackRumble.Play()
    end
end

function Update()

 
    if(not API_GameObject.BL_IsValid(JetpackController)) then
        SpawnResources()
        return
    end

    if(API_GameObject.BL_IsValid(JetpackController) and not ControllerSetup) then
        SetUpController();
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
    else
        JetpackRumble.Stop()
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
                RemainingFlightTime = RemainingFlightTime - Time.deltaTime
                print(tostring(RemainingFlightTime))
                if(RemainingFlightTime <= 0.11) then
                    Thrusting = false
                    RemainingFlightTime = 0
                    STATE_READY = false
                    STATE_OVERHEATED = true
                    JetpackRumble.Stop()
                end
            elseif(not API_Input.BL_IsAButtonDown or not PlayerPhysicsRig.ungroundedThisFrame or RemainingFlightTime <= 0) then
                Thrusting = false
                RemainingFlightTime = RemainingFlightTime + (Time.fixedDeltaTime * RechargeRate)
                if(RemainingFlightTime > MaxFlightTime) then
                    RemainingFlightTime = MaxFlightTime
                end
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
    API_GameObject.BL_DestroyGameObject(JetpackController)    
    WaitingForResourceSpawn = false
end
 
  function OnDestroy()
    API_GameObject.BL_DestroyGameObject(JetpackController)  
    WaitingForResourceSpawn = false
  end