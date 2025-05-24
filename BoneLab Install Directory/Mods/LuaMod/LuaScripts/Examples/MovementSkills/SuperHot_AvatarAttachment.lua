

LeftHand = nil
RightHand = nil
Player = nil

function Start()

end



function CalculateHighestSpeed()
    PlayerVel = PlayerRB.velocity.magnitude
    LeftHandVel = LeftHandRB.velocity.magnitude
    RightHandVel = RightHandRB.velocity.magnitude
    return math.max(PlayerVel,LeftHandVel,RightHandVel)
end

OriginalFixedDeltaTime = Time.fixedDeltaTime
function SetTimeScale(velocity) 
    local maxVelocity = 8.0
    local timescale = (velocity / maxVelocity)
    timescale = math.max(timescale,0.01)
    timescale = math.min(timescale,1.0)
   -- refreshRate = MarrowGame.xr.Display.GetRefreshRate();

    Time.timeScale = timescale
	Time.fixedDeltaTime = timescale*OriginalFixedDeltaTime

end

function  OnDisable()
    SetTimeScale(1.0)
end
 
function OnDestroy()
    SetTimeScale(1.0)
end

function Update()

    if(BL_This == nil or not API_GameObject.BL_IsValid(BL_Host) or not BL_This.Ready) then
        print("superhot not yet ready")
        return
    end

    if(API_Player.BL_GetPhysicsRig() == nil or API_Input.BL_LeftHand() == nil or API_Input.BL_RightHand() == nil) then
        return 
    end

    if(LeftHand == nil or RightHand == nil or Player == nil) then
        Player = API_Player.BL_GetPhysicsRig().m_chest.gameObject
        LeftHand = API_Input.BL_LeftHand()
        RightHand = API_Input.BL_RightHand()
        LeftHandRB = API_GameObject.BL_GetComponent(LeftHand,"Rigidbody")
        RightHandRB = API_GameObject.BL_GetComponent(RightHand,"Rigidbody")
        PlayerRB = API_GameObject.BL_GetComponent(Player,"Rigidbody")
    end

    local highestSpeed = CalculateHighestSpeed()
    SetTimeScale(highestSpeed)
    print("highest velocity: " .. tostring(highestSpeed))

    
 
end



