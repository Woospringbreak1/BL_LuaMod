--LuaBehaviour

function Start()
    print("BUNKER SCRIPT ONLINE!")
    Boss = API_GameObject.BL_FindInWorld("AncientObliskV2")
    BossBehaviour = API_GameObject.BL_GetComponent(Boss,"LuaBehaviour")
    Player = nil
end

function OnTriggerEnter(other)
    if(IsValid(Player) and other.transform.root == Player.transform.root ) then
        BossBehaviour.CallFunction("SetPlayerInBunker",true)
       -- print("PLAYER IN BUNKER")
    else
        --print("OTHER IN BUNKER " .. other.name .. " root " .. other.transform.root.name ..  " player is " .. Player.name .. " root " .. Player.transform.root.name)
    end
end

function OnTriggerExit(other)
    if(IsValid(Player) and other.transform.root == Player.transform.root ) then
        BossBehaviour.CallFunction("SetPlayerInBunker",false)
        --print("PLAYER OUT OF BUNKER")
    else
        --print("OTHER OUT OF BUNKER " .. other.name .. " root " .. other.transform.root.name ..  " player is " .. Player.name .. " root " .. Player.transform.root.name)
    end
end

function Update()

    if(Player == nil) then
        local playerRig = API_Player.BL_GetPhysicsRig()
        if(playerRig ~= nil) then
            Player = playerRig.gameObject
            print("PLAYER VARIABLE SET " .. Player.name)
        end

    end
end