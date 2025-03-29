function Start()
    print("Hello, World from Vertigo 2 teleportation Lua!")
end


function LateStart()
    print("Late start")
    PlayerHand = API_Input.BL_LeftHand()
end

WaitingForResourceSpawn = false
function SpawnResources()
    if(not WaitingForResourceSpawn) then
        API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This,"JetpackController","33.33.Spawnable.JetpackConroller", Vector3.zero, Quaternion.identity,nil, true)
        WaitingForResourceSpawn = true
    end
end


function GetSmartArcPoint(P0, forward, ArcHeight, t)
    -- Internal helper: Quadratic Bezier curve
    local function Bezier(P0, P1, P2, t)
        local oneMinusT = 1 - t
        return P0 * (oneMinusT * oneMinusT) +
               P1 * (2 * oneMinusT * t) +
               P2 * (t * t)
    end

    -- Adjust arc distance based on how flat the aim is
    local flatness = math.pow(1.0 - math.abs(forward.y), 1.5)
    local minDistance = 2.0
    local maxDistance = 6.0
    local AimDistance = minDistance + (maxDistance - minDistance) * flatness

    -- Bezier points
    local P2 = P0 + forward * AimDistance
    local P1 = P0 + forward * (AimDistance * 0.5) + Vector3.up * ArcHeight

    -- Get the point on the curve at time t
    local point = Bezier(P0, P1, P2, t)

    -- Return the calculated point, and optionally the control points
    --return point, P1, P2
    return point
end



function SpawnDot()
    API_GameObject.BL_SpawnByBarcode_LuaVar(BL_This,"DisplayDot","33.33.Spawnable.VertigoDisplaySphere", Vector3.zero, Quaternion.identity,nil, true)
end


ArcHeight = 2.0    -- How high the arc rises
DisplayDots = {}
t = 0.0
ArcCalcPoints = 20
function Update()

    if(BL_This == nil or not API_GameObject.BL_IsValid(BL_Host) or not BL_This.Ready) then
        return
    end


    if(PlayerHand == nil) then
        
        if(API_Input.BL_LeftHand() ~= nil) then
            PlayerHand = API_Input.BL_LeftHand()
        end
        return
    end

    if(DisplayDot ~= nil ) then
        table.insert(DisplayDots,DisplayDot)
        DisplayDot = nil
    end

    
    if(API_Input.BL_IsAButtonDown()) then

        local handPos = PlayerHand.transform.position
        local aimDir = PlayerHand.transform.forward
        local arcHeight = 2.0
        
        -- Advance time
        t = t + 0.04
        if t > 3.0 then t = 0 end

        local midPoint = GetSmartArcPoint(handPos, aimDir, arcHeight, 0.5)
        local arcPoint = GetSmartArcPoint(handPos, aimDir, arcHeight, t)

        ArcPoint = 0
        ArcDiv = (2.0/ArcCalcPoints)
        CheckRadius = 0.1
        
        while(ArcPoint <= ArcCalcPoints) do
            CalulatedArcPoint = GetSmartArcPoint(handPos, aimDir, arcHeight, (ArcDiv*ArcPoint)+0.1)
            if(Physics.CheckSphere(CalulatedArcPoint,CheckRadius)) then
                if (API_GameObject.BL_IsValid(DisplayDots[2])) then
                    DisplayDots[2].transform.position = arcPoint
                    break
                end
            end
            ArcPoint = ArcPoint + 1
        end


        if #DisplayDots < 2 then
            SpawnDot()
            return
        end

        if (API_GameObject.BL_IsValid(DisplayDots[1]))  then
            DisplayDots[1].transform.position = midPoint
        end



    else
        for _,dispdot in pairs(DisplayDots) do
            API_GameObject.BL_DestroyGameObject(dispdot)
        end
        DisplayDots = {}
    end

  
end
