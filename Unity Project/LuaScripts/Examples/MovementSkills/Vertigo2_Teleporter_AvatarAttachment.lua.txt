function Start()
    print("Hello, World from Vertigo 2 teleportation Lua!")
    TeleTrail = API_GameObject.BL_GetComponent(BL_Host,"LineRenderer")
    TeleportDestinationEffect = API_GameObject.BL_FindInChildren(BL_Host, "VertigoTeleportDest")
    ArcPoints = API_Particles.CreateTrailSegmentArray(25)
    print(tostring(ArcPoints))
    RemapRig = nil
    PlayerAvatar = nil
    PhysicsRig = nil
end

function LateStart()
    print("Late start")
    PlayerHand = API_Input.BL_LeftHand()
end

WaitingForResourceSpawn = false
function SpawnResources()
    if(not WaitingForResourceSpawn) then
        WaitingForResourceSpawn = true
    end
end

HoldTime = 0.0

function GetSmartArcPoint(P0, forward, ArcHeight, t)
    local function Bezier(P0, P1, P2, t)
        local oneMinusT = 1 - t
        return P0 * (oneMinusT * oneMinusT) +
               P1 * (2 * oneMinusT * t) +
               P2 * (t * t)
    end

    -- Distance grows with HoldTime
    local minDistance = 2.0
    local maxDistance = 5.0
    local chargeSpeed = 2.0
    local chargedDistance = math.min(minDistance + (HoldTime * chargeSpeed), maxDistance)

    local AimDistance = chargedDistance

    local P2 = P0 + forward * AimDistance
    local P1 = P0 + forward * (AimDistance * 0.5) + Vector3.up * ArcHeight

    local point = Bezier(P0, P1, P2, t)
    return point
end

function SpawnDot()
    API_GameObject.BL_SpawnByBarcode(BL_This,"DisplayDot","BonelabMeridian.Luamodexamplecontent.Spawnable.VertigoDisplaySphere", Vector3.zero, Quaternion.identity,nil, true)
end

function IsSurfaceSlopeAcceptable(impactNormal, maxSlope)
    local up = Vector3.up
    local dot = Vector3.Dot(up, impactNormal)
    local angle = math.acos(dot) * Mathf.Rad2Deg
    return angle <= maxSlope
end

function IsAreaClear(teleportDest)
    local startPoint = teleportDest + API_Vector.BL_Vector3(0, 0.2, 0)
    local endPoint = startPoint + API_Vector.BL_Vector3(0,PlayerAvatar.height*1.2, 0)
    local footRadius = PhysicsRig.footballRadius*1.2
    local isClear = not (API_Physics.BL_CheckCapsule(startPoint,endPoint,footRadius))
    return isClear
end

ArcHeight = 2.0
DisplayDots = {}
t = 0.0
ArcCalcPoints = 40
ArcDistance = 0.0

function OnDestroy()
    RemapRig.jumpEnabled = true
end

function OnDisable()
    RemapRig.jumpEnabled = true
end

function Update()

    if(BL_This == nil or not API_GameObject.BL_IsValid(BL_Host) or not BL_This.Ready) then
        return
    end

    if(TeleTrail == nil or not API_GameObject.BL_IsValid(TeleTrail)) then
        print("script components nil")
        return
    end

    if(PlayerHand == nil) then
        if(API_Input.BL_LeftHand() ~= nil) then
            PlayerHand = API_Input.BL_LeftHand()
        end
        return
    end

    if(RemapRig == nil) then
        if(API_Player.BL_GetRemapRig() ~= nil) then
            RemapRig = API_Player.BL_GetRemapRig()
            RemapRig.jumpEnabled = false
        end
        return
    end

    if(PlayerAvatar == nil) then
        if(API_Player.BL_GetAvatar() ~= nil) then
            PlayerAvatar = API_Player.BL_GetAvatar()
        end
        return
    end

    if(PhysicsRig == nil) then
        if(API_Player.BL_GetPhysicsRig() ~= nil) then
            PhysicsRig = API_Player.BL_GetPhysicsRig()
        end
        return
    end

    if(DisplayDot ~= nil ) then
        table.insert(DisplayDots,DisplayDot)
        DisplayDot = nil
    end

    if(API_Input.BL_IsAButtonDown()) then

        HoldTime = HoldTime + Time.deltaTime

        if(ArcDistance < 1.0) then
            ArcDistance = ArcDistance + 0.01*Time.deltaTime
        end

        if #DisplayDots < 2 then
            SpawnDot()
            return
        end

        local handPos = PlayerHand.transform.position
        local aimDir = PlayerHand.transform.forward
        local arcHeight = 2.0

        t = t + 0.04
        if t > 3.0 then t = 0 end

        local midPoint = GetSmartArcPoint(handPos, aimDir, arcHeight, 0.5)

        ArcPoint = 1
        ArcDiv = (4.0/ArcCalcPoints)
        CheckRadius = 0.1
        PreviousArcPoint = Vector3.zero
        TeleportPos = nil
        TeleTrail.SetPosition(0, handPos)
        while(ArcPoint <= ArcCalcPoints) do
            PreviousArcPoint = CalulatedArcPoint
            CalulatedArcPoint = GetSmartArcPoint(handPos, aimDir,  arcHeight, (ArcDiv*ArcPoint)+0.03)
            TeleTrail.SetPosition(ArcPoint,CalulatedArcPoint)
            if(Physics.CheckSphere(CalulatedArcPoint,CheckRadius)) then
                local RayOut = API_Physics.BL_RayCast(PreviousArcPoint,CalulatedArcPoint)
                if (RayOut ~= nil) then
                    if (API_GameObject.BL_IsValid(DisplayDots[2])) then

                        local impactNormal = RayOut.normal

                        if(IsSurfaceSlopeAcceptable(impactNormal,45.0) and IsAreaClear(RayOut.point)) then
                            TeleportPos = RayOut.point + API_Vector.BL_Vector3(0,0.1,0)
                        else
                            TeleportPos = nil
                        end

                        TeleTrail.SetPosition(ArcPoint,RayOut.point)
                        TeleTrail.positionCount = ArcPoint
                        break
                    end
                end
            end
            ArcPoint = ArcPoint + 1
        end

        if(TeleportPos ~= nil) then
            TeleportDestinationEffect.setActive(true)
            TeleportDestinationEffect.transform.position = TeleportPos
        else
            TeleportDestinationEffect.setActive(false)
        end

    else
        TeleTrail.positionCount = 0
        ArcDistance = 0.0
        HoldTime = 0.0
        TeleportDestinationEffect.setActive(false)
        if(TeleportPos ~= nil) then
            API_Player.BL_SetAvatarPosition(TeleportPos)
            TeleportPos = nil
        end

        for _,dispdot in pairs(DisplayDots) do
            API_GameObject.BL_Destroy(dispdot)
        end
        DisplayDots = {}
    end

end