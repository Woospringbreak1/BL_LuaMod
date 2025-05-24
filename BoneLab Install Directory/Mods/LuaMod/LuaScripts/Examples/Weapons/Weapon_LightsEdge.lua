
function Start()
    StabSlash = API_GameObject.BL_GetComponent(BL_Host,"StabSlash")
    RigidBody = API_GameObject.BL_GetComponent(BL_Host,"Rigidbody")
    BladeTip = API_GameObject.BL_FindInChildren(BL_Host,"stabTran")
    BladeArc = API_GameObject.BL_FindInChildren(BL_Host,"BladeArc")
    Spark = API_GameObject.BL_FindInChildren(BL_Host,"Spark")
    LineRenderer = API_GameObject.BL_GetComponent(BladeArc,"LineRenderer")
    SwordGrip = API_GameObject.BL_GetComponent(API_GameObject.BL_FindInChildren(BL_Host,"gripObject"),"CylinderGrip")
end

ArcPoints = {}
function AddArcPoint(index,point)
    LineRenderer.positionCount = index+1
    LineRenderer.SetPosition(index,point)
    print("setting arc point " .. tostring(index) .. " to " .. tostring(point))
    ArcPoints[index+1] = point
end

WaitingArcSpawn = false
function DetachBladeArc() 
    WaitingArcSpawn = true
    local Rot = API_Player.BL_GetPhysicsRig().m_head.transform.rotation
    local Pos = API_Player.BL_GetPhysicsRig().m_head.transform.position + (API_Player.BL_GetPhysicsRig().m_head.transform.forward * 0.5)
    API_GameObject.BL_SpawnByBarcode(BL_This,"BladeArcProjectile","BonelabMeridian.LightsEdge.Spawnable.ProjectileBladeArc", Pos, Rot,nil, true)
end



minVelocity = 4.0
nextPoint = 0.0
MinPointDistanceSqr = 0.01*0.01
FormingArc = false
ArcPoint = 0
LastPoint = Vector3.zero


STATE_READY = false
STATE_CHARGING = false
STATE_CHARGED = false

function Update()

    if(API_Player.BL_GetPhysicsRig() == nil) then
        return
    end

    if(not IsValid(LineRenderer)) then
        print("LineRenderer is nil")
        return
    end

    if(STATE_READY == false and STATE_CHARGING == false and STATE_CHARGED == false) then
        STATE_READY = true
    end
    

    if( IsValid(BladeArcProjectile)) then

        local BladeArcProjectileBehaviour = API_GameObject.BL_GetComponentInChildren(BladeArcProjectile,"LuaBehaviour")

        if(IsValid(BladeArcProjectileBehaviour) and BladeArcProjectileBehaviour.Ready) then
            print("Creating an arc with " .. tostring(#ArcPoints) .. " points")
            BladeArcProjectileBehaviour.CallFunction("SetOwnerGun", BL_Host)
            local arcLineRenderer = API_GameObject.BL_GetComponent(BladeArcProjectile,"LineRenderer")
            local lastSphereIndex = -99
            arcLineRenderer.positionCount = #ArcPoints
            for index, point in ipairs(ArcPoints) do
                local localPoint = BladeArcProjectile.transform.InverseTransformPoint(point) -- convert world -> local space
                arcLineRenderer.SetPosition(index - 1, localPoint) -- c# array so is 0-based

                if(index-lastSphereIndex >= 3) then
                    --only spawn a collider evert 3 points
                    local sCol = API_GameObject.BL_AddComponent(BladeArcProjectile, "SphereCollider")
                    sCol.center = localPoint -- set local position relative to BladeArc
                    sCol.radius = 0.03
                    sCol.isTrigger = false
                    lastSphereIndex = index
                end

            end

            BladeArcProjectile = nil --only removes lua reference
            WaitingArcSpawn = false
            LineRenderer.positionCount = 0
            ArcPoint = 0
            ArcPoints = {}
            LastPoint = Vector3.zero
        end
    end

    local bladeTipPos = BladeTip.transform.position
    local bladeTipVelocityVec3 = RigidBody.GetPointVelocity(bladeTipPos)
    local bladeTipVelocity = bladeTipVelocityVec3.magnitude


   if(WaitingArcSpawn) then
    return
   end

   local gripHand = API_Utils.BL_GetArrayElement(SwordGrip,"attachedHands",0)
   if(gripHand ~= nil) then
       TriggerPulled = gripHand.GetIndexTriggerAxis() > 0.5

        if(TriggerPulled) then
            print("triggering haptics")
            gripHand.Controller.Haptic(10.0);
        end

   end


    if(TriggerPulled and bladeTipVelocity > minVelocity) then
        --print("blade tip velocity " .. tostring(bladeTipVelocity))
        if((bladeTipPos-LastPoint).sqrMagnitude>MinPointDistanceSqr) then
            AddArcPoint(ArcPoint,bladeTipPos)
            ArcPoint = ArcPoint + 1
            --nextPoint = Time.time + 0.00
            FormingArc = true
            LastPoint = bladeTipPos
        end
    else
        if(FormingArc) then
            if(ArcPoint > 15) then
                DetachBladeArc()
                print("arc launched")
            else
                print("arc destroyed")
                LineRenderer.positionCount = 0
                ArcPoint = 0
                ArcPoints = {}
                LastPoint = Vector3.zero
            end
            FormingArc = false
        end
    end

end