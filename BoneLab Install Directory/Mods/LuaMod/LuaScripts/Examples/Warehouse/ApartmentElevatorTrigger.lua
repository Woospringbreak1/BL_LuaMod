Player = nil
ElevatorManager = nil
function OnTriggerEnter(other)
    if(IsValid(Player) and other.transform.root == Player.transform.root ) then
        ElevatorManager.CallFunction("SetPlayerInElevator",true)
        print("PLAYER IN ELEVATOR")
    else

    end
end

function OnTriggerExit(other)
    if(IsValid(Player) and other.transform.root == Player.transform.root ) then
        ElevatorManager.CallFunction("SetPlayerInElevator",false)
        print("PLAYER OUT OF ELEVATOR")
    else

    end
end

function Update()

    if(Player == nil) then
        local playerRig = API_Player.BL_GetPhysicsRig()
        if(playerRig ~= nil) then
            Player = playerRig.gameObject
        end
    end

    if(ElevatorManager == nil) then
        ElevatorManagerGO = API_GameObject.BL_FindInWorld("ElevatorManager")
        ElevatorManager = API_GameObject.BL_GetComponent(ElevatorManagerGO,"LuaBehaviour")
    end

end