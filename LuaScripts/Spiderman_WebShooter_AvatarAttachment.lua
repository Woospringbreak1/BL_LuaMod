--LuaBehaviour


function Start()
    print("Hello, World from Spiderman_Webshooter!")
    --print("locating LuaGun")

    print("locating Rigidbody")
    HandTransform = API_Input.BL_LeftHand().transform
    HandRB= API_GameObject.BL_GetComponent2(HandTransform.gameObject,"Rigidbody")
    FireSound = 
    print("CastTestRigidbody mass: " .. HandRB.mass)

    WebLaunchSound = nil
    
end

WaitingForResourceSpawn = false
function SpawnResources()
    if(not WaitingForResourceSpawn) then
        API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This,"SpiderManResources","33.33.Spawnable.SpiderManResources", Vector3.zero, Quaternion.identity,nil, true)
        WaitingForResourceSpawn = true
    end
end

function OnDestroy()
    DestroyConnections()
end

function OnDisable()
    DestroyConnections()
end

function DestroyConnections()
    for _,webproj in pairs(WebShooterProjectiles) do
        API_GameObject.BL_DestroyGameObject(webproj.gameObject)
    end
    WebShooterProjectiles = {}
end

function ShouldShoot()
    local ControllerGrabbed = false
    local HandEmpty = false
    if(Lefthanded) then
        ControllerGrabbed = API_Input.BL_LeftController_IsGrabbed()
        HandEmpty = API_Input.BL_LeftHandEmpty()
    else
        ControllerGrabbed = API_Input.BL_RightController_IsGrabbed()
        HandEmpty = API_Input.BL_RightHandEmpty()
    end

    return ControllerGrabbed and HandEmpty and WebLaunchSound ~= nil
end


function SetLeftHanded(leftHandMode)

    if(leftHandMode == Lefthanded) then
        return
    end

    Lefthanded = leftHandMode

    if(Lefthanded) then
        HandTransform = API_Input.BL_LeftHand().transform
    else
        HandTransform = API_Input.BL_RightHand().transform
    end
    HandRB = API_GameObject.BL_GetComponent2(HandTransform.gameObject,"Rigidbody")
    DestroyConnections()

end

WebShooterProjectiles = {}
ActOnce = false
function Update()

    if(ShouldShoot()) then
        if(not ActOnce) then
            API_Audio.BL_Play3DOneShot(WebLaunchSound,HandTransform.position,100.0)
            print("web launch sound: " .. WebLaunchSound.name)
            print("spawning projectile from spiderman webshooter!")
            Fpoint = HandTransform
            Pos = Fpoint.position + Fpoint.forward*0.35
            Rot = Fpoint.rotation;
            API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This,"WebProjectile","33.33.Spawnable.SpidermanWebProjectile", Pos, Rot,nil, true)
            ActOnce = true
        end
    else
        ActOnce = false
        DestroyConnections()
    end

    if(WebProjectile ~= nil ) then
        local WebProjectileBehaviour = API_GameObject.BL_GetComponentInChildren(WebProjectile,"LuaBehaviour")

        if(WebProjectileBehaviour.Ready) then
            local suc = WebProjectileBehaviour.CallFunction("SetOwnerGun", HandRB)
            table.insert(WebShooterProjectiles,WebProjectileBehaviour)
            WebProjectile = nil
        else
            print("webshooter projectile not ready")
        end
    end

    if(SpiderManResources == nill or not API_GameObject.BL_IsValid(SpiderManResources)) then
        SpawnResources()
    else
        if(WebLaunchSound == nil) then
            WebLaunchSound = API_GameObject.BL_GetComponentInChildren(SpiderManResources,"AudioSource").clip
        end
    end


end

