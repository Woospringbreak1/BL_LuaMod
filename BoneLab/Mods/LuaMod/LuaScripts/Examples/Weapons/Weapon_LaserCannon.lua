--LuaBehaviour

LaserMaxRange = 100

function Start()
    print("Hello, World from Lasercannon!")
    WeaponLaser = API_GameObject.BL_FindInChildren(BL_Host,"Laser")
    LaserLine = API_GameObject.BL_GetComponent(WeaponLaser,"LineRenderer")
    HeatIndicator = API_GameObject.BL_FindInChildren(BL_Host,"HeatIndicator")
    HeatIndicatorDisplay = API_GameObject.BL_GetComponent(HeatIndicator,"LuaBehaviour")
    LaserImpact = API_GameObject.BL_FindInChildren(BL_Host,"LaserImpact")

    FirePoint = API_GameObject.BL_FindInChildren(BL_Host,"FirePoint").transform
    LaserFireSound = API_GameObject.BL_GetComponent(BL_Host,"AudioSource")
    LaserLine.useWorldSpace = true
    HeatBuildup = 0.0
    MaxHeatBuildup = 10.0
    HeatRate = 5
    CoolRate = 1
    STATE_READY = false
    STATE_OVERHEATED = false
    Firing = false

end

function RaycastLaser()
    LaserOut = API_Physics.BL_RayCast(FirePoint.position,FirePoint.forward,LaserMaxRange)
    if(LaserOut ~= nil) then
        LaserLine.SetPosition(0,FirePoint.position)
        LaserLine.SetPosition(1,LaserOut.point)
        TriggerSurfaceImpact(LaserOut.point,LaserOut.normal)

        if(LaserOut.rigidbody ~= nil) then
            DamageEnemy(LaserOut.point,LaserOut.normal*-1.0,LaserOut.collider,LaserOut.rigidbody.transform.root.gameObject,LaserOut.rigidbody)
        end

    else
        LaserImpact.setActive(false)
        LaserLine.SetPosition(0,FirePoint.position)
        LaserLine.SetPosition(1,FirePoint.position+FirePoint.forward*LaserMaxRange)
    end
end


function TriggerSurfaceImpact(pos, normal)
    local impactRotation = Quaternion.LookRotation(Vector3.forward, normal)
    LaserImpact.setActive(true)
    LaserImpact.transform.position = pos
    LaserImpact.transform.rotation = impactRotation
end

function DamageEnemy(pos, normal,collider,gameObject,rigidbody)
    if(IsValid(gameObject) and IsValid(rigidbody)) then
        API_SLZ_Combat.BL_AttackEnemy(gameObject,2.0*Time.deltaTime*60,collider,pos,normal)
        local forceToApply  = 2000*Time.deltaTime*60
        rigidbody.AddForceAtPosition(normal*forceToApply, pos)  
    end
end

function PlayLaserSound()
    if(not LaserFireSound.isPlaying) then
        LaserFireSound.Play()
    end
end


SetDisplayColors = false
function Update()

    if(BL_This == nil or not IsValid(BL_Host) or not BL_This.Ready) then
        print("script not ready")
        return
    end

    if(not IsValid(WeaponLaser) or not IsValid(HeatIndicator) or LaserLine == nil or not HeatIndicatorDisplay.Ready) then
        print("weapon components invalid")
        return
    end

    if(not SetDisplayColors) then
        colorHigh = Color.red
        colorMed = Color.yellow
        colorLow = Color.green

        HeatIndicatorDisplay.SetScriptVariable("colorHigh",colorHigh)
        HeatIndicatorDisplay.SetScriptVariable("colorMed",colorMed)
        HeatIndicatorDisplay.SetScriptVariable("colorLow",colorLow)
    
        SetDisplayColors = true
    end
    
    if(not STATE_OVERHEATED and not STATE_READY) then
        STATE_OVERHEATED = false
        STATE_READY = true
    end
    
    if(HeatBuildup >= MaxHeatBuildup) then
        HeatBuildup = MaxHeatBuildup
        STATE_OVERHEATED = true
        STATE_READY = false
    end

    if(STATE_OVERHEATED and HeatBuildup <= 0.1*MaxHeatBuildup) then
        STATE_OVERHEATED = false
        STATE_READY = true    
    end
    

    if(Firing) then
        BL_This.SetMagazineRounds(320)
        RaycastLaser()
        WeaponLaser.setActive(true)
        PlayLaserSound()
        HeatBuildup = HeatBuildup+(HeatRate*Time.deltaTime)
    else
        LaserImpact.setActive(false)
        WeaponLaser.setActive(false)
        LaserFireSound.Stop()
        HeatBuildup = HeatBuildup-(CoolRate*Time.deltaTime)

        if(HeatBuildup < 0) then
            HeatBuildup = 0
        end

    end

    

    if(STATE_READY) then
        BL_This.AttachedGun.hammerState = HammerStates.COCKED
        HeatIndicatorDisplay.CallFunction("SetDisplayNumber",HeatBuildup/MaxHeatBuildup)
        if (BL_This.AttachedGun.isTriggerPulled) then
            Firing = true
        else
            Firing = false
        end
    elseif(STATE_OVERHEATED) then
        BL_This.AttachedGun.hammerState = HammerStates.UNCOCKED
        HeatIndicatorDisplay.CallFunction("SetOverheated",true,HeatBuildup/MaxHeatBuildup)
        Firing = false
    end


end


function OnFire()
   return false
end