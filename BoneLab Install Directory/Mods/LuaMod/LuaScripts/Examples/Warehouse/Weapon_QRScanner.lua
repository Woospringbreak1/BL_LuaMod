--LuaBehaviour

LaserMaxRange = 100
Hunter = nil
HunterBehaviour = nil

function SlowUpdate()
    if(not IsValid(Hunter)) then
        Hunter = API_GameObject.BL_FindInWorld("NPC_Hunter")
        if(IsValid(Hunter)) then
            HunterBehaviour = API_GameObject.BL_GetComponent(Hunter,"LuaBehaviour")
        end
    end

end

function Start()
    print("Hello, World from QR code scanner!")
    ScannerLight = API_GameObject.BL_FindInChildren(BL_Host,"Spot Light")
    ScannerLightComp = API_GameObject.BL_GetComponent(ScannerLight,"Light")

    ItemTitle = API_GameObject.BL_GetComponent(API_GameObject.BL_FindInChildren(BL_Host,"ItemTitle"),"TextMeshPro")
    ItemDescription = API_GameObject.BL_GetComponent(API_GameObject.BL_FindInChildren(BL_Host,"ItemDescription"),"TextMeshPro")

    BeepSound = API_GameObject.BL_GetComponent(BL_Host,"AudioSource")
end

function PlayBeep()
    if(not BeepSound.isPlaying) then
        BeepSound.Play()

        if(IsValid(HunterBehaviour)) then
            HunterBehaviour.CallFunction("ScannerBeep",BL_Host.transform.position)
        end
    end 
end

function CheckQRCodeConeHit(scannerTransform, spotAngle, maxDistance)
    local direction = scannerTransform:TransformDirection(API_Vector.BL_Vector3(0, 0, 1))
    local origin = scannerTransform.position
    local layerMask = Physics.DefaultRaycastLayers

    -- 1. Raycast forward from spotlight origin
    local hitInfo = API_Physics.BL_RayCast(origin, direction, maxDistance)
    if (hitInfo == nil) then
       -- print("Raycast did not hit anything.")
        return nil
    end

    local hitPoint = hitInfo.point
    local hitDistance = (hitPoint - origin).magnitude

    -- 2. Compute effective radius at that distance (tan(angle/2) * dist)
    local angleRad = math.rad(spotAngle / 2)
    local radius = math.tan(angleRad) * hitDistance * 0.8

    -- 3. OverlapSphere at impact point
    local overlapped = API_Physics.BL_OverlapSphere(hitPoint, radius)
   -- print("sphere radius " .. tostring(radius) .. " sphere location " .. tostring(hitPoint))
    --if(overlapped ~= nill) then
    --    for _,obj in ipairs(overlapped) do
    --        print(obj.name .. " in laser sphere")
    --    end
   -- end

    if not overlapped or #overlapped == 0 then
       -- print("No objects in laser cone.")
        return nil
    end

    -- 4. Check for QRCode object
    for i, obj in ipairs(overlapped) do
       -- print("obj: " .. tostring(obj))
        if (string.match(obj.name,"QRCode")) then
            local qrRenderer = API_GameObject.BL_GetComponent(obj.gameObject, "Renderer")
            if not IsValid(qrRenderer) then
                print("QRCode found but missing Renderer.")
                return nil
            end

            local bounds = qrRenderer.bounds
            local qrCenter = bounds.center
            local qrExtents = bounds.extents
            local qrCorners = {
                qrCenter + qrExtents,
                qrCenter - qrExtents,
                qrCenter + API_Vector.BL_Vector3(-qrExtents.x, qrExtents.y, qrExtents.z),
                qrCenter + API_Vector.BL_Vector3(qrExtents.x, -qrExtents.y, qrExtents.z),
                qrCenter + API_Vector.BL_Vector3(qrExtents.x, qrExtents.y, -qrExtents.z),
                qrCenter + API_Vector.BL_Vector3(-qrExtents.x, -qrExtents.y, qrExtents.z),
                qrCenter + API_Vector.BL_Vector3(qrExtents.x, -qrExtents.y, -qrExtents.z),
                qrCenter + API_Vector.BL_Vector3(-qrExtents.x, qrExtents.y, -qrExtents.z)
            }

            -- 5. Ensure all corners are inside the sphere radius
            local allInside = true
            for _, corner in ipairs(qrCorners) do
                local offset = corner - hitPoint
                local distSq = offset.x * offset.x + offset.y * offset.y + offset.z * offset.z
                if distSq > radius * radius then
                    allInside = false
                    break
                end
            end
            
            if allInside then
              --  print("QRCode fully inside laser cone at distance: " .. tostring(hitDistance))
                return obj.gameObject
            else
              --  print("QRCode only partially inside laser cone.")
                return nil
            end
        end
    end

   -- print("No QRCode found in laser cone.")
    return nil
end



function Update()

    if(BL_This == nil or not IsValid(BL_Host) or not BL_This.Ready) then
        print("script not ready")
        return
    end

    if(not IsValid(ScannerLight) or not IsValid(ScannerLightComp)) then
        print("weapon components invalid")
        return
    end

    if (BL_This.AttachedGun.isTriggerPulled) then
        ScannerLight.setActive(true)
       local qRCode = CheckQRCodeConeHit(ScannerLight.transform, ScannerLightComp.spotAngle, ScannerLightComp.range)
        if(IsValid(qRCode)) then
            PlayBeep()
            local qRCodeResources = API_GameObject.BL_GetComponent(qRCode, "LuaResources")
            local qRCodeBehaviour = API_GameObject.BL_GetComponent(qRCode, "LuaBehaviour")

          --  if(not IsValid(qRCodeResources)) then
           --     print("QRCode missing LuaResources")
           --     return
          --  end

          --  local ItemIDText = qRCodeResources.GetString("ItemID")
           -- local ItemDescriptionText = qRCodeResources.GetString("ItemDescription")

            local ItemIDText = qRCodeBehaviour.GetScriptVariable("ItemID")
            local ItemDescriptionText = qRCodeBehaviour.GetScriptVariable("ItemDescription")

            ItemTitle.text = "ID: " .. ItemIDText
            ItemDescription.text = "DESCRIPTION: " .. ItemDescriptionText
            ItemTitle.ForceMeshUpdate()
            ItemDescription.ForceMeshUpdate()
           -- print("Scanned item: " .. tostring(ItemIDText) .. " " .. tostring(ItemDescriptionText))

            if(IsValid(qRCodeBehaviour)) then
                qRCodeBehaviour.CallFunction("Scanned")
            end
            
        end
    else
        ScannerLight.setActive(false)
    end
  


end


function OnFire()
   return false
end