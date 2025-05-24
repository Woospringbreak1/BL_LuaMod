minVelocity = 4.0
nextPoint = 0.0
MinPointDistanceSqr = 0.2*0.2
FormingArc = false
ArcPoint = 0
LastPoint = Vector3.zero
TriggerPulled = false

STATE_READY = false
STATE_CHARGING = false
STATE_CHARGED = false
TriggerReleasedSinceReady = true

function Start()
    StabSlash = API_GameObject.BL_GetComponent(BL_Host,"StabSlash")
    RigidBody = API_GameObject.BL_GetComponent(BL_Host,"Rigidbody")
    BladeTip = API_GameObject.BL_FindInChildren(BL_Host,"stabTran")
    BladeArc = API_GameObject.BL_FindInChildren(BL_Host,"BladeArc")
    Spark = API_GameObject.BL_FindInChildren(BL_Host,"Spark")
    GrowPart = API_GameObject.BL_FindInChildren(Spark,"GrowPart")
    SparkEndPos = API_GameObject.BL_FindInChildren(BL_Host,"SparkEndPos")
    SparkStartPos = API_GameObject.BL_FindInChildren(BL_Host,"SparkStartPos")

    LineRenderer = API_GameObject.BL_GetComponent(BladeArc,"LineRenderer")
    SwordGrip = API_GameObject.BL_GetComponent(API_GameObject.BL_FindInChildren(BL_Host,"gripObject"),"CylinderGrip")
    ProjectileChain = {}
    ProjectileChainHolder = nil
    WaitingForProjectileChainHolder = false
    WaitingForBladeArcProjectile = false
    BladeArcProjectile = nil
end


function AddArcPoint(index,point)

    local Rot = API_Player.BL_GetPhysicsRig().m_head.transform.rotation
        if( not WaitingForBladeArcProjectile) then
            print("adding arc point " .. tostring(index)) 
            API_GameObject.BL_SpawnByBarcode(BL_This,"BladeArcProjectile","BonelabMeridian.LightsEdge.Spawnable.ProjectileBladeArcChain", point, Rot,ProjectileChainHolder, true) 
            WaitingForBladeArcProjectile = true
        end
end


function DetachBladeArc() 
    ProjectileChainHolderBehaviour = API_GameObject.BL_GetComponent(ProjectileChainHolder,"LuaBehaviour")
    ProjectileChainHolderBehaviour.CallFunction("SetOwnerGun", BL_Host)
    ProjectileChainHolderBehaviour.CallFunction("MarkArcFinished")
end





function MoveScaleSpark(perc)
    -- Clamp perc between 0.0 and 1.0
    perc = math.max(0,perc)
    perc = math.min(1,perc)
    if perc < 0 then perc = 0 elseif perc > 1 then perc = 1 end

    -- Linearly interpolate local position
    local startLocalPos = SparkStartPos.transform.localPosition
    local endLocalPos = SparkEndPos.transform.localPosition
    local newLocalPos = Vector3.Lerp(startLocalPos, endLocalPos, perc)
    Spark.transform.localPosition = newLocalPos

    -- Scale up to max scale
    local MaxScale = 3.5
    local scaleValue = perc * MaxScale
    GrowPart.transform.localScale = API_Vector.BL_Vector3(scaleValue, scaleValue, scaleValue)
end


function DrawArc()
    local playerVelocity = PlayerRB.GetPointVelocity(PlayerRB.transform.position + PlayerRB.transform.forward * 0.2)
    local bladeTipPos = BladeTip.transform.position
    local bladeTipVelocityVec3 = RigidBody.GetPointVelocity(bladeTipPos)
    local bladeTipVelocity = (playerVelocity - bladeTipVelocityVec3).magnitude


       if(TriggerPulled and bladeTipVelocity > minVelocity) then
        --print("blade tip velocity " .. tostring(bladeTipVelocity))
        FormingArc = true
        if((bladeTipPos-LastPoint).sqrMagnitude>MinPointDistanceSqr) then
            AddArcPoint(ArcPoint,bladeTipPos)
            ArcPoint = ArcPoint + 1
            LastPoint = bladeTipPos
        end
    else
        if(FormingArc) then
           
            if(ArcPoint > 5) then
                DetachBladeArc()
                print("arc launched")
                ProjectileChainHolder = nil
                FormingArc = false
                LastPoint = Vector3.zero
                return true
            else
                print("arc destroyed")
                ArcPoint = 0
                LastPoint = Vector3.zero
                ProjectileChainHolder = nil
                FormingArc = false
                return false
            end
        end
    end
end


function ApplyJitterForceAtSparkEnd(forceMagnitude)
    if (RigidBody == nil or SparkEndPos == nil) then
         return   
    end

    -- Generate a small random vector for jitter
    local randomDirection = API_Vector.BL_Vector3(
        (math.random() - 0.5) * 2,  -- X: -1 to 1
        (math.random() - 0.5) * 2,  -- Y: -1 to 1
        (math.random() - 0.5) * 2   -- Z: -1 to 1
    ).normalized * forceMagnitude

    -- Get world-space position to apply force
    local forcePosition = SparkEndPos.transform.position

    -- Apply force at position
    RigidBody.AddForceAtPosition(randomDirection, forcePosition, ForceMode.Impulse)
end


function Update()

    if(API_Player.BL_GetPhysicsRig() == nil) then
        return
    end

    if(PlayerRB == nil) then
        PlayerRB = API_GameObject.BL_GetComponent(API_Player.BL_GetPhysicsRig().m_chest.gameObject,"Rigidbody")
    end

    if(not IsValid(LineRenderer)) then
        print("LineRenderer is nil")
        return
    end

    if(IsValid(ProjectileChainHolder)) then
        WaitingForProjectileChainHolder = false
    else
        if(not WaitingForProjectileChainHolder) then
            API_GameObject.BL_SpawnByBarcode(BL_This,"ProjectileChainHolder","BonelabMeridian.LightsEdge.Spawnable.ProjectileBladeArc", point, Rot,nil, true)
            WaitingForProjectileChainHolder = true 
        end
        return
    end
    

    if( IsValid(BladeArcProjectile)) then
        BladeArcProjectileBehaviour = API_GameObject.BL_GetComponent(BladeArcProjectile,"LuaBehaviour")
        if(BladeArcProjectileBehaviour.Ready) then
            table.insert(ProjectileChain, BladeArcProjectile)
            BladeArcProjectileBehaviour.CallFunction("SetOwnerGun", BL_Host)
            BladeArcProjectile = nil --only removes lua reference
            BladeArcProjectileBehaviour = nil
            WaitingForBladeArcProjectile = false
        else
             print("BladeArcProjectile is not ready " .. BladeArcProjectile.name )
        end

    end


    
   local gripHand = API_Utils.BL_GetArrayElement(SwordGrip,"attachedHands",0)
   if(gripHand ~= nil) then
       TriggerPulled = gripHand.GetIndexTriggerAxis() > 0.5
   end

   if(gripHand == nil) then
    return
   end


    if(STATE_READY == false and STATE_CHARGING == false and STATE_CHARGED == false) then
        STATE_READY = true
    end

    if(STATE_READY) then

        Spark.SetActive(false)

        if(not TriggerPulled) then
            TriggerReleasedSinceReady = true
        end
    

        if(TriggerPulled and TriggerReleasedSinceReady) then
            TriggerReleasedSinceReady = false -- consume the latch
            STATE_READY = false
            STATE_CHARGING = true
            STATE_CHARGING_TIME = nil
            print("charging")
        end
    end


    Max_ChargeTime = 3.0
    if(STATE_CHARGING) then

        if(gripHand == nil) then
            STATE_CHARGING = false
            STATE_READY = true
            Spark.SetActive(false)
            return
        end
        
        if(STATE_CHARGING_TIME == nil) then
            STATE_CHARGING_TIME = Time.time + Max_ChargeTime
        end

        local ChargePercent = 1.0 - ((STATE_CHARGING_TIME - Time.time) / Max_ChargeTime)
        Spark.SetActive(true)
        MoveScaleSpark(ChargePercent)
        gripHand.Controller.HapticAction(0.0,0.1,20,ChargePercent)
        ApplyJitterForceAtSparkEnd(0.5*ChargePercent)
        if(ChargePercent >= 0.95) then
            STATE_CHARGING = false
            STATE_CHARGED = true
            STATE_CHARGING_TIME = nil
            print("charged")
        end

        if(not TriggerPulled) then
            STATE_CHARGING = false
            STATE_READY = true
            STATE_CHARGING_TIME = nil
        end
    end


    if(STATE_CHARGED) then

        if(gripHand == nil) then
            STATE_CHARGING = false
            STATE_READY = true
            Spark.SetActive(false)
            return
        end

        gripHand.Controller.HapticAction(0.0,0.1,20,1.0)
        MoveScaleSpark(1.0)
        ApplyJitterForceAtSparkEnd(0.5)
        if(DrawArc() or not TriggerPulled) then
            STATE_CHARGED = false
            STATE_READY = true
            STATE_CHARGING_TIME = nil
        end
    end

    

end