-- LuaBehaviour
function Start()
    print("Hello, World! from Manhack.lua")
   
    ManhackRB = API_GameObject.BL_GetComponent(BL_Host,"Rigidbody")
    AgentLink = API_GameObject.BL_GetComponentInChildren(BL_Host.transform.root.gameObject,"AgentLinkControl")
    NavAgent = AgentLink.navAgent
    BL_Muscles = BL_This.AttachedPuppetMaster.muscles
    LWristMuscle = nil
    for BL_Muscle in BL_Muscles do
        print("muscle: " .. BL_Muscle.name)
        if(BL_Muscle.name == "Wrist_L") then
            LWristMuscle = BL_Muscle
            print("wrist located")
             -- Set weights so PuppetMaster follows the target
             LWristMuscle.state.pinWeight = 1.0
             LWristMuscle.state.pinWeightMlp = 1.0
             LWristMuscle.state.muscleWeight = 1.0
             LWristMuscle.state.muscleWeightMlp = 1.0
        end
    end
end



function Update() 
    print("Manhack update")
    if(LWristMuscle ~= nil and NavAgent ~= nil and API_Input.BL_LeftHand() ~= nil) then
        PlayerPos = API_Input.BL_LeftHand().transform.position
        NavAgent.destination = PlayerPos
        LWPos = LWristMuscle.transform.position
        LWPos.y = PlayerPos.y
        LWristMuscle.transform.position = LWPos
        print("player hand pos: " .. tostring(PlayerPos) .. "setting ford hand target to " .. tostring(LWPos) )
    else
        print("critical component missing. LWristMuscle: " .. tostring(LWristMuscle))
    end
end


